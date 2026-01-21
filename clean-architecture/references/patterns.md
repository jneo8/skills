# Implementation Patterns

## Table of Contents

- [Repository Pattern](#repository-pattern)
- [Use Case Pattern](#use-case-pattern)
- [Dependency Injection](#dependency-injection)
- [Boundary Crossing](#boundary-crossing)
- [Error Handling](#error-handling)
- [Testing Strategies](#testing-strategies)

---

## Repository Pattern

Abstracts data persistence, allowing domain to remain ignorant of storage details.

### Interface in Domain Layer

```python
# domain/repositories/order_repository.py
from abc import ABC, abstractmethod
from typing import Optional, List
from domain.entities.order import Order
from domain.value_objects.order_id import OrderId
from domain.value_objects.customer_id import CustomerId

class OrderRepository(ABC):
    @abstractmethod
    async def find_by_id(self, id: OrderId) -> Optional[Order]:
        pass

    @abstractmethod
    async def find_by_customer(self, customer_id: CustomerId) -> List[Order]:
        pass

    @abstractmethod
    async def save(self, order: Order) -> None:
        pass

    @abstractmethod
    async def next_identity(self) -> OrderId:
        """Generate a new unique identifier."""
        pass
```

### Implementation in Infrastructure

```python
# infrastructure/repositories/sqlalchemy_order_repository.py
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from domain.repositories.order_repository import OrderRepository
from domain.entities.order import Order
from domain.value_objects.order_id import OrderId
from domain.value_objects.customer_id import CustomerId
from infrastructure.persistence.models import OrderModel
from infrastructure.mappers.order_mapper import OrderMapper
import uuid

class SqlAlchemyOrderRepository(OrderRepository):
    def __init__(self, session: AsyncSession):
        self._session = session

    async def find_by_id(self, id: OrderId) -> Optional[Order]:
        stmt = select(OrderModel).where(OrderModel.id == str(id))
        result = await self._session.execute(stmt)
        model = result.scalar_one_or_none()
        return OrderMapper.to_domain(model) if model else None

    async def find_by_customer(self, customer_id: CustomerId) -> List[Order]:
        stmt = select(OrderModel).where(
            OrderModel.customer_id == str(customer_id)
        )
        result = await self._session.execute(stmt)
        models = result.scalars().all()
        return [OrderMapper.to_domain(m) for m in models]

    async def save(self, order: Order) -> None:
        model = OrderMapper.to_persistence(order)
        await self._session.merge(model)
        await self._session.flush()

    async def next_identity(self) -> OrderId:
        return OrderId(str(uuid.uuid4()))
```

### In-Memory Implementation for Testing

```python
# tests/fakes/fake_order_repository.py
from typing import Optional, List, Dict
from domain.repositories.order_repository import OrderRepository
from domain.entities.order import Order
from domain.value_objects.order_id import OrderId
from domain.value_objects.customer_id import CustomerId
import uuid

class FakeOrderRepository(OrderRepository):
    def __init__(self):
        self._orders: Dict[str, Order] = {}

    async def find_by_id(self, id: OrderId) -> Optional[Order]:
        return self._orders.get(str(id))

    async def find_by_customer(self, customer_id: CustomerId) -> List[Order]:
        return [
            o for o in self._orders.values()
            if o.customer_id == customer_id
        ]

    async def save(self, order: Order) -> None:
        self._orders[str(order.id)] = order

    async def next_identity(self) -> OrderId:
        return OrderId(str(uuid.uuid4()))
```

---

## Use Case Pattern

Single-purpose classes that orchestrate domain logic.

### Structure

```python
# application/use_cases/place_order.py
from dataclasses import dataclass
from typing import List
from domain.entities.order import Order
from domain.entities.order_item import OrderItem
from domain.repositories.order_repository import OrderRepository
from domain.repositories.product_repository import ProductRepository
from domain.value_objects.customer_id import CustomerId
from domain.value_objects.product_id import ProductId
from application.ports.payment_gateway import PaymentGateway
from application.ports.event_publisher import EventPublisher
from domain.events.order_placed_event import OrderPlacedEvent

@dataclass
class OrderItemInput:
    product_id: str
    quantity: int

@dataclass
class PlaceOrderInput:
    customer_id: str
    items: List[OrderItemInput]
    payment_method_id: str

@dataclass
class PlaceOrderOutput:
    order_id: str
    total: float
    status: str

class PlaceOrderUseCase:
    def __init__(
        self,
        order_repository: OrderRepository,
        product_repository: ProductRepository,
        payment_gateway: PaymentGateway,
        event_publisher: EventPublisher
    ):
        self._order_repo = order_repository
        self._product_repo = product_repository
        self._payment = payment_gateway
        self._events = event_publisher

    async def execute(self, input: PlaceOrderInput) -> PlaceOrderOutput:
        # 1. Validate and fetch products
        items = []
        for item_input in input.items:
            product = await self._product_repo.find_by_id(
                ProductId(item_input.product_id)
            )
            if not product:
                raise ProductNotFoundError(item_input.product_id)
            if not product.is_available(item_input.quantity):
                raise InsufficientStockError(product.id, item_input.quantity)

            items.append(OrderItem.create(product, item_input.quantity))

        # 2. Create order (domain logic)
        order_id = await self._order_repo.next_identity()
        order = Order.create(
            id=order_id,
            customer_id=CustomerId(input.customer_id),
            items=items
        )

        # 3. Process payment
        payment_result = await self._payment.charge(
            amount=order.total,
            payment_method_id=input.payment_method_id
        )
        if not payment_result.success:
            raise PaymentFailedError(payment_result.error)

        order.confirm(payment_result.transaction_id)

        # 4. Persist
        await self._order_repo.save(order)

        # 5. Publish event
        await self._events.publish(OrderPlacedEvent(
            order_id=order.id,
            customer_id=order.customer_id,
            total=order.total
        ))

        return PlaceOrderOutput(
            order_id=str(order.id),
            total=order.total,
            status=order.status
        )
```

### Use Case Guidelines

1. **Single responsibility** - One use case per business action
2. **Input/Output DTOs** - Isolate from external representations
3. **Orchestration only** - Business rules in domain entities
4. **No framework dependencies** - Pure Python

---

## Dependency Injection

Wire dependencies at the composition root, keeping layers decoupled.

### Manual Injection (Composition Root)

```python
# infrastructure/container.py
from dataclasses import dataclass
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from infrastructure.repositories.sqlalchemy_order_repository import SqlAlchemyOrderRepository
from infrastructure.repositories.sqlalchemy_product_repository import SqlAlchemyProductRepository
from infrastructure.services.stripe_payment_gateway import StripePaymentGateway
from infrastructure.events.kafka_event_publisher import KafkaEventPublisher
from application.use_cases.place_order import PlaceOrderUseCase
from application.use_cases.get_order import GetOrderUseCase

@dataclass
class Container:
    """Dependency injection container - composition root."""
    session: AsyncSession
    place_order_use_case: PlaceOrderUseCase
    get_order_use_case: GetOrderUseCase

def create_container(database_url: str, stripe_key: str) -> Container:
    # Infrastructure
    engine = create_async_engine(database_url)
    session = AsyncSession(engine)

    # Repositories
    order_repo = SqlAlchemyOrderRepository(session)
    product_repo = SqlAlchemyProductRepository(session)

    # External services
    payment_gateway = StripePaymentGateway(stripe_key)
    event_publisher = KafkaEventPublisher()

    # Use cases
    place_order = PlaceOrderUseCase(
        order_repository=order_repo,
        product_repository=product_repo,
        payment_gateway=payment_gateway,
        event_publisher=event_publisher
    )
    get_order = GetOrderUseCase(order_repository=order_repo)

    return Container(
        session=session,
        place_order_use_case=place_order,
        get_order_use_case=get_order
    )
```

### Using dependency-injector Library

```python
# infrastructure/container.py
from dependency_injector import containers, providers
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

class Container(containers.DeclarativeContainer):
    config = providers.Configuration()

    # Database
    engine = providers.Singleton(
        create_async_engine,
        config.database_url
    )

    session = providers.Factory(
        AsyncSession,
        engine
    )

    # Repositories
    order_repository = providers.Factory(
        SqlAlchemyOrderRepository,
        session=session
    )

    product_repository = providers.Factory(
        SqlAlchemyProductRepository,
        session=session
    )

    # External services
    payment_gateway = providers.Singleton(
        StripePaymentGateway,
        api_key=config.stripe_api_key
    )

    event_publisher = providers.Singleton(
        KafkaEventPublisher
    )

    # Use cases
    place_order_use_case = providers.Factory(
        PlaceOrderUseCase,
        order_repository=order_repository,
        product_repository=product_repository,
        payment_gateway=payment_gateway,
        event_publisher=event_publisher
    )
```

### FastAPI Integration

```python
# presentation/dependencies.py
from fastapi import Depends
from infrastructure.container import Container

container = Container()
container.config.from_env("APP")

def get_place_order_use_case() -> PlaceOrderUseCase:
    return container.place_order_use_case()

# In controller
@router.post("/orders")
async def place_order(
    request: PlaceOrderRequest,
    use_case: PlaceOrderUseCase = Depends(get_place_order_use_case)
):
    return await use_case.execute(...)
```

---

## Boundary Crossing

Data crossing layer boundaries should use simple DTOs, not domain objects.

### Input Boundary

```python
# application/use_cases/register_user.py
@dataclass
class RegisterUserInput:
    """Input DTO - primitives only, no domain objects."""
    email: str
    password: str
    full_name: str

class RegisterUserUseCase:
    async def execute(self, input: RegisterUserInput) -> RegisterUserOutput:
        # Convert primitives to domain objects inside use case
        email = Email(input.email)
        password = Password.create(input.password)  # Hashing happens here
        name = FullName(input.full_name)

        user = User.create(email, password, name)
        # ...
```

### Output Boundary

```python
# application/use_cases/get_user.py
@dataclass
class GetUserOutput:
    """Output DTO - primitives only, safe for serialization."""
    id: str
    email: str
    full_name: str
    created_at: str
    status: str

class GetUserUseCase:
    async def execute(self, user_id: str) -> GetUserOutput:
        user = await self._user_repo.find_by_id(UserId(user_id))
        if not user:
            raise UserNotFoundError(user_id)

        # Convert domain object to output DTO
        return GetUserOutput(
            id=str(user.id),
            email=str(user.email),
            full_name=str(user.name),
            created_at=user.created_at.isoformat(),
            status=user.status
        )
```

### Mapper Pattern

```python
# infrastructure/mappers/user_mapper.py
class UserMapper:
    @staticmethod
    def to_domain(model: UserModel) -> User:
        """Database model -> Domain entity."""
        return User(
            id=UserId(model.id),
            email=Email(model.email),
            name=FullName(model.full_name),
            status=UserStatus(model.status),
            created_at=model.created_at
        )

    @staticmethod
    def to_persistence(user: User) -> UserModel:
        """Domain entity -> Database model."""
        return UserModel(
            id=str(user.id),
            email=str(user.email),
            full_name=str(user.name),
            status=user.status.value,
            created_at=user.created_at
        )

    @staticmethod
    def to_response(output: GetUserOutput) -> UserResponse:
        """Use case output -> API response."""
        return UserResponse(
            data=UserData(
                type="user",
                id=output.id,
                attributes=UserAttributes(
                    email=output.email,
                    fullName=output.full_name,
                    status=output.status
                )
            )
        )
```

---

## Error Handling

Layer-specific errors that cross boundaries appropriately.

### Domain Errors

```python
# domain/errors.py
class DomainError(Exception):
    """Base class for domain errors."""
    pass

class InvariantViolationError(DomainError):
    """Business rule violation."""
    pass

class EntityNotFoundError(DomainError):
    """Entity does not exist."""
    def __init__(self, entity_type: str, entity_id: str):
        self.entity_type = entity_type
        self.entity_id = entity_id
        super().__init__(f"{entity_type} with id {entity_id} not found")
```

### Application Errors

```python
# application/errors.py
class ApplicationError(Exception):
    """Base class for application errors."""
    pass

class AuthorizationError(ApplicationError):
    """User not authorized for this action."""
    pass

class ValidationError(ApplicationError):
    """Input validation failed."""
    def __init__(self, field: str, message: str):
        self.field = field
        super().__init__(f"{field}: {message}")
```

### Error Translation in Presentation

```python
# presentation/http/error_handlers.py
from fastapi import Request
from fastapi.responses import JSONResponse
from domain.errors import DomainError, EntityNotFoundError
from application.errors import ApplicationError, AuthorizationError

async def domain_error_handler(request: Request, exc: DomainError):
    if isinstance(exc, EntityNotFoundError):
        return JSONResponse(
            status_code=404,
            content={"error": str(exc), "type": exc.entity_type}
        )
    return JSONResponse(
        status_code=422,
        content={"error": str(exc)}
    )

async def application_error_handler(request: Request, exc: ApplicationError):
    if isinstance(exc, AuthorizationError):
        return JSONResponse(status_code=403, content={"error": str(exc)})
    return JSONResponse(status_code=400, content={"error": str(exc)})

# Register handlers
app.add_exception_handler(DomainError, domain_error_handler)
app.add_exception_handler(ApplicationError, application_error_handler)
```

---

## Testing Strategies

### Unit Testing Domain Layer

```python
# tests/domain/test_order.py
import pytest
from domain.entities.order import Order
from domain.entities.order_item import OrderItem
from domain.value_objects.order_id import OrderId
from domain.value_objects.customer_id import CustomerId
from domain.errors import EmptyOrderError

class TestOrder:
    def test_create_order_with_items(self):
        order = Order.create(
            id=OrderId("ord-123"),
            customer_id=CustomerId("cust-456"),
            items=[self._create_item(price=100, qty=2)]
        )

        assert order.total == 200
        assert order.status == "pending"

    def test_cannot_create_empty_order(self):
        with pytest.raises(EmptyOrderError):
            Order.create(
                id=OrderId("ord-123"),
                customer_id=CustomerId("cust-456"),
                items=[]
            )

    def test_confirm_order_sets_status(self):
        order = self._create_order()
        order.confirm(transaction_id="tx-789")

        assert order.status == "confirmed"
        assert order.transaction_id == "tx-789"
```

### Unit Testing Use Cases

```python
# tests/application/test_place_order.py
import pytest
from unittest.mock import AsyncMock
from application.use_cases.place_order import PlaceOrderUseCase, PlaceOrderInput
from tests.fakes.fake_order_repository import FakeOrderRepository
from tests.fakes.fake_product_repository import FakeProductRepository

class TestPlaceOrderUseCase:
    @pytest.fixture
    def use_case(self):
        return PlaceOrderUseCase(
            order_repository=FakeOrderRepository(),
            product_repository=FakeProductRepository([
                self._create_product(id="prod-1", price=50, stock=10)
            ]),
            payment_gateway=AsyncMock(return_value=self._success_payment()),
            event_publisher=AsyncMock()
        )

    async def test_places_order_successfully(self, use_case):
        input = PlaceOrderInput(
            customer_id="cust-123",
            items=[{"product_id": "prod-1", "quantity": 2}],
            payment_method_id="pm-456"
        )

        result = await use_case.execute(input)

        assert result.total == 100
        assert result.status == "confirmed"

    async def test_fails_when_insufficient_stock(self, use_case):
        input = PlaceOrderInput(
            customer_id="cust-123",
            items=[{"product_id": "prod-1", "quantity": 100}],
            payment_method_id="pm-456"
        )

        with pytest.raises(InsufficientStockError):
            await use_case.execute(input)
```

### Integration Testing Infrastructure

```python
# tests/infrastructure/test_postgres_order_repository.py
import pytest
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from infrastructure.repositories.postgres_order_repository import PostgresOrderRepository

@pytest.fixture
async def session():
    engine = create_async_engine("postgresql+asyncpg://test:test@localhost/test")
    async with AsyncSession(engine) as session:
        yield session
        await session.rollback()

@pytest.fixture
def repository(session):
    return PostgresOrderRepository(session)

class TestPostgresOrderRepository:
    async def test_save_and_find_order(self, repository):
        order = self._create_order()
        await repository.save(order)

        found = await repository.find_by_id(order.id)

        assert found is not None
        assert found.id == order.id
        assert found.total == order.total
```

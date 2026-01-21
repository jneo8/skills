# Architectural Layers Reference

## Table of Contents

- [Domain Layer](#domain-layer)
- [Application Layer](#application-layer)
- [Infrastructure Layer](#infrastructure-layer)
- [Presentation Layer](#presentation-layer)

---

## Domain Layer

The innermost layer containing enterprise business rules. This layer has NO dependencies on outer layers or frameworks.

### Components

#### Entities

Business objects with identity and lifecycle. Encapsulate the most critical business rules.

```python
# domain/entities/user.py
from dataclasses import dataclass, field
from domain.value_objects.email import Email
from domain.value_objects.user_id import UserId
from domain.errors import InvalidUserNameError, UserAlreadyDeactivatedError

@dataclass
class User:
    id: UserId
    email: Email
    _name: str
    _status: str = field(default="active")

    @classmethod
    def create(cls, email: Email, name: str) -> "User":
        return cls(
            id=UserId.generate(),
            email=email,
            _name=name,
            _status="active"
        )

    @property
    def name(self) -> str:
        return self._name

    def change_name(self, new_name: str) -> None:
        if not new_name or len(new_name) < 2:
            raise InvalidUserNameError(new_name)
        self._name = new_name

    def deactivate(self) -> None:
        if self._status == "deactivated":
            raise UserAlreadyDeactivatedError(self.id)
        self._status = "deactivated"
```

#### Value Objects

Immutable objects defined by their attributes, not identity. Use for domain concepts.

```python
# domain/value_objects/email.py
from dataclasses import dataclass
import re
from domain.errors import InvalidEmailError

@dataclass(frozen=True)
class Email:
    value: str

    def __post_init__(self):
        if not self._is_valid(self.value):
            raise InvalidEmailError(self.value)

    @staticmethod
    def _is_valid(email: str) -> bool:
        pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
        return bool(re.match(pattern, email))

    def __str__(self) -> str:
        return self.value
```

#### Repository Interfaces (Ports)

Contracts for data persistence. Defined in domain, implemented in infrastructure.

```python
# domain/repositories/user_repository.py
from abc import ABC, abstractmethod
from typing import Optional
from domain.entities.user import User
from domain.value_objects.user_id import UserId
from domain.value_objects.email import Email

class UserRepository(ABC):
    @abstractmethod
    async def find_by_id(self, id: UserId) -> Optional[User]:
        pass

    @abstractmethod
    async def find_by_email(self, email: Email) -> Optional[User]:
        pass

    @abstractmethod
    async def save(self, user: User) -> None:
        pass

    @abstractmethod
    async def delete(self, id: UserId) -> None:
        pass
```

#### Domain Services

Business logic that doesn't belong to a single entity.

```python
# domain/services/user_domain_service.py
from domain.repositories.user_repository import UserRepository
from domain.value_objects.email import Email

class UserDomainService:
    def __init__(self, user_repository: UserRepository):
        self._user_repository = user_repository

    async def is_email_unique(self, email: Email) -> bool:
        existing = await self._user_repository.find_by_email(email)
        return existing is None
```

#### Domain Events

Capture something that happened in the domain.

```python
# domain/events/user_created_event.py
from dataclasses import dataclass, field
from datetime import datetime
from domain.value_objects.user_id import UserId
from domain.value_objects.email import Email

@dataclass(frozen=True)
class UserCreatedEvent:
    user_id: UserId
    email: Email
    occurred_at: datetime = field(default_factory=datetime.utcnow)
```

#### Domain Errors

Explicit error types for domain rule violations.

```python
# domain/errors.py
class DomainError(Exception):
    pass

class InvalidEmailError(DomainError):
    def __init__(self, email: str):
        super().__init__(f"Invalid email format: {email}")

class InvalidUserNameError(DomainError):
    def __init__(self, name: str):
        super().__init__(f"Invalid user name: {name}")

class UserAlreadyDeactivatedError(DomainError):
    def __init__(self, user_id):
        super().__init__(f"User {user_id} is already deactivated")
```

### Domain Layer Rules

1. **No framework imports** - Pure Python constructs only
2. **No infrastructure concerns** - No database, HTTP, or file system code
3. **Self-validating** - Entities and value objects validate themselves
4. **Rich behavior** - Business logic lives in domain objects, not services

---

## Application Layer

Orchestrates the flow of data and coordinates domain objects. Contains use cases (application business rules).

### Components

#### Use Cases (Interactors)

Single-purpose classes that orchestrate domain objects to fulfill a specific business action.

```python
# application/use_cases/create_user.py
from dataclasses import dataclass
from domain.entities.user import User
from domain.value_objects.email import Email
from domain.repositories.user_repository import UserRepository
from domain.events.user_created_event import UserCreatedEvent
from application.ports.event_publisher import EventPublisher
from application.errors import UserAlreadyExistsError

@dataclass
class CreateUserInput:
    email: str
    name: str

@dataclass
class CreateUserOutput:
    id: str
    email: str
    name: str

class CreateUserUseCase:
    def __init__(
        self,
        user_repository: UserRepository,
        event_publisher: EventPublisher
    ):
        self._user_repository = user_repository
        self._event_publisher = event_publisher

    async def execute(self, input: CreateUserInput) -> CreateUserOutput:
        email = Email(input.email)

        existing_user = await self._user_repository.find_by_email(email)
        if existing_user:
            raise UserAlreadyExistsError(email)

        user = User.create(email, input.name)
        await self._user_repository.save(user)

        await self._event_publisher.publish(
            UserCreatedEvent(user.id, user.email)
        )

        return CreateUserOutput(
            id=str(user.id),
            email=str(user.email),
            name=user.name
        )
```

#### DTOs (Data Transfer Objects)

Simple data structures for crossing boundaries.

```python
# application/dtos/user_dto.py
from dataclasses import dataclass
from typing import Optional

@dataclass
class UserDTO:
    id: str
    email: str
    name: str
    status: Optional[str] = None
```

#### Application Services

Coordinate multiple use cases or provide cross-cutting concerns.

```python
# application/services/user_application_service.py
from application.use_cases.create_user import CreateUserUseCase, CreateUserInput, CreateUserOutput
from application.use_cases.get_user import GetUserUseCase
from application.ports.transaction_manager import TransactionManager

class UserApplicationService:
    def __init__(
        self,
        create_user_use_case: CreateUserUseCase,
        get_user_use_case: GetUserUseCase,
        transaction_manager: TransactionManager
    ):
        self._create_user = create_user_use_case
        self._get_user = get_user_use_case
        self._transaction_manager = transaction_manager

    async def create_user(self, input: CreateUserInput) -> CreateUserOutput:
        async with self._transaction_manager:
            return await self._create_user.execute(input)
```

#### Ports (Interfaces)

Contracts for external dependencies that use cases need.

```python
# application/ports/event_publisher.py
from abc import ABC, abstractmethod
from typing import Any

class EventPublisher(ABC):
    @abstractmethod
    async def publish(self, event: Any) -> None:
        pass

# application/ports/transaction_manager.py
from abc import ABC, abstractmethod

class TransactionManager(ABC):
    @abstractmethod
    async def __aenter__(self):
        pass

    @abstractmethod
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        pass
```

### Application Layer Rules

1. **Depends only on domain layer** - No infrastructure imports
2. **Framework agnostic** - No HTTP, database, or framework code
3. **Orchestration only** - Business rules belong in domain
4. **Use cases are single-purpose** - One public method per use case

---

## Infrastructure Layer

Implements interfaces defined in domain/application layers. Contains all external concerns.

### Components

#### Repository Implementations

```python
# infrastructure/repositories/postgres_user_repository.py
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from domain.entities.user import User
from domain.repositories.user_repository import UserRepository
from domain.value_objects.user_id import UserId
from domain.value_objects.email import Email
from infrastructure.mappers.user_mapper import UserMapper

class PostgresUserRepository(UserRepository):
    def __init__(self, session: AsyncSession):
        self._session = session

    async def find_by_id(self, id: UserId) -> Optional[User]:
        result = await self._session.execute(
            "SELECT * FROM users WHERE id = :id",
            {"id": str(id)}
        )
        row = result.fetchone()
        return UserMapper.to_domain(row) if row else None

    async def find_by_email(self, email: Email) -> Optional[User]:
        result = await self._session.execute(
            "SELECT * FROM users WHERE email = :email",
            {"email": str(email)}
        )
        row = result.fetchone()
        return UserMapper.to_domain(row) if row else None

    async def save(self, user: User) -> None:
        data = UserMapper.to_persistence(user)
        await self._session.execute(
            """
            INSERT INTO users (id, email, name, status)
            VALUES (:id, :email, :name, :status)
            ON CONFLICT (id) DO UPDATE SET
                email = :email, name = :name, status = :status
            """,
            data
        )

    async def delete(self, id: UserId) -> None:
        await self._session.execute(
            "DELETE FROM users WHERE id = :id",
            {"id": str(id)}
        )
```

#### Mappers

Convert between domain objects and external representations.

```python
# infrastructure/mappers/user_mapper.py
from typing import Any, Dict
from domain.entities.user import User
from domain.value_objects.user_id import UserId
from domain.value_objects.email import Email
from application.dtos.user_dto import UserDTO

class UserMapper:
    @staticmethod
    def to_domain(row: Any) -> User:
        return User(
            id=UserId(row.id),
            email=Email(row.email),
            _name=row.name,
            _status=row.status
        )

    @staticmethod
    def to_persistence(user: User) -> Dict[str, Any]:
        return {
            "id": str(user.id),
            "email": str(user.email),
            "name": user.name,
            "status": user._status
        }

    @staticmethod
    def to_dto(user: User) -> UserDTO:
        return UserDTO(
            id=str(user.id),
            email=str(user.email),
            name=user.name,
            status=user._status
        )
```

#### External Service Adapters

```python
# infrastructure/services/sendgrid_email_service.py
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from application.ports.email_service import EmailService

class SendGridEmailService(EmailService):
    def __init__(self, api_key: str):
        self._client = SendGridAPIClient(api_key)

    async def send(self, to: str, subject: str, body: str) -> None:
        message = Mail(
            from_email="noreply@example.com",
            to_emails=to,
            subject=subject,
            plain_text_content=body
        )
        self._client.send(message)
```

#### Event Publishers

```python
# infrastructure/events/kafka_event_publisher.py
import json
from aiokafka import AIOKafkaProducer
from application.ports.event_publisher import EventPublisher

class KafkaEventPublisher(EventPublisher):
    def __init__(self, producer: AIOKafkaProducer):
        self._producer = producer

    async def publish(self, event: Any) -> None:
        topic = event.__class__.__name__
        value = json.dumps(event.__dict__, default=str).encode()
        await self._producer.send(topic, value=value)
```

### Infrastructure Layer Rules

1. **Implements domain/application interfaces** - Fulfills contracts
2. **Contains all framework code** - ORM, HTTP clients, etc.
3. **Maps between formats** - Domain ↔ Database ↔ API
4. **Handles technical concerns** - Caching, logging, transactions

---

## Presentation Layer

Handles all user interface and API concerns. Delegates to application layer.

### Components

#### HTTP Controllers (FastAPI)

```python
# presentation/http/controllers/user_controller.py
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from application.use_cases.create_user import CreateUserUseCase, CreateUserInput
from application.errors import UserAlreadyExistsError
from domain.errors import InvalidEmailError

router = APIRouter(prefix="/users", tags=["users"])

class CreateUserRequest(BaseModel):
    email: str
    name: str

class UserResponse(BaseModel):
    id: str
    email: str
    name: str

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    request: CreateUserRequest,
    use_case: CreateUserUseCase = Depends(get_create_user_use_case)
):
    try:
        input = CreateUserInput(email=request.email, name=request.name)
        result = await use_case.execute(input)
        return UserResponse(
            id=result.id,
            email=result.email,
            name=result.name
        )
    except UserAlreadyExistsError as e:
        raise HTTPException(status_code=409, detail=str(e))
    except InvalidEmailError as e:
        raise HTTPException(status_code=400, detail=str(e))
```

#### Dependency Injection

```python
# presentation/dependencies.py
from functools import lru_cache
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from infrastructure.repositories.postgres_user_repository import PostgresUserRepository
from infrastructure.events.kafka_event_publisher import KafkaEventPublisher
from application.use_cases.create_user import CreateUserUseCase

@lru_cache
def get_database_session() -> AsyncSession:
    engine = create_async_engine("postgresql+asyncpg://...")
    return AsyncSession(engine)

def get_user_repository(
    session: AsyncSession = Depends(get_database_session)
) -> PostgresUserRepository:
    return PostgresUserRepository(session)

def get_event_publisher() -> KafkaEventPublisher:
    return KafkaEventPublisher(get_kafka_producer())

def get_create_user_use_case(
    user_repo: PostgresUserRepository = Depends(get_user_repository),
    event_publisher: KafkaEventPublisher = Depends(get_event_publisher)
) -> CreateUserUseCase:
    return CreateUserUseCase(user_repo, event_publisher)
```

#### Application Factory

```python
# presentation/app.py
from fastapi import FastAPI
from presentation.http.controllers import user_controller, health_controller

def create_app() -> FastAPI:
    app = FastAPI(title="User Service")

    app.include_router(user_controller.router)
    app.include_router(health_controller.router)

    return app
```

### Presentation Layer Rules

1. **Thin controllers** - Delegate to use cases immediately
2. **Framework-specific code** - HTTP, GraphQL, CLI concerns
3. **Input validation** - Basic format validation (business validation in domain)
4. **Error translation** - Convert domain errors to appropriate responses

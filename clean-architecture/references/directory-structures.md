# Directory Structures

## Table of Contents

- [Python (Standard)](#python-standard)
- [Go](#go)

---

## Python (Standard)

Standard Python project with clean architecture layers.

```
project/
├── src/
│   ├── domain/
│   │   ├── __init__.py
│   │   ├── entities/
│   │   │   ├── __init__.py
│   │   │   ├── user.py
│   │   │   ├── order.py
│   │   │   └── product.py
│   │   ├── value_objects/
│   │   │   ├── __init__.py
│   │   │   ├── email.py
│   │   │   ├── money.py
│   │   │   └── user_id.py
│   │   ├── repositories/
│   │   │   ├── __init__.py
│   │   │   ├── user_repository.py
│   │   │   └── order_repository.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   └── pricing_service.py
│   │   ├── events/
│   │   │   ├── __init__.py
│   │   │   ├── user_created.py
│   │   │   └── order_placed.py
│   │   └── errors.py
│   │
│   ├── application/
│   │   ├── __init__.py
│   │   ├── use_cases/
│   │   │   ├── __init__.py
│   │   │   ├── users/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── create_user.py
│   │   │   │   ├── get_user.py
│   │   │   │   └── update_user.py
│   │   │   └── orders/
│   │   │       ├── __init__.py
│   │   │       ├── place_order.py
│   │   │       └── cancel_order.py
│   │   ├── dtos/
│   │   │   ├── __init__.py
│   │   │   ├── user_dto.py
│   │   │   └── order_dto.py
│   │   ├── ports/
│   │   │   ├── __init__.py
│   │   │   ├── event_publisher.py
│   │   │   ├── email_service.py
│   │   │   └── payment_gateway.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   └── user_application_service.py
│   │   └── errors.py
│   │
│   ├── infrastructure/
│   │   ├── __init__.py
│   │   ├── persistence/
│   │   │   ├── __init__.py
│   │   │   ├── models/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── user_model.py
│   │   │   │   └── order_model.py
│   │   │   ├── repositories/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── sqlalchemy_user_repository.py
│   │   │   │   └── sqlalchemy_order_repository.py
│   │   │   └── database.py
│   │   ├── mappers/
│   │   │   ├── __init__.py
│   │   │   ├── user_mapper.py
│   │   │   └── order_mapper.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   ├── sendgrid_email_service.py
│   │   │   └── stripe_payment_gateway.py
│   │   ├── events/
│   │   │   ├── __init__.py
│   │   │   └── kafka_event_publisher.py
│   │   └── container.py
│   │
│   └── presentation/
│       ├── __init__.py
│       ├── http/
│       │   ├── __init__.py
│       │   ├── controllers/
│       │   │   ├── __init__.py
│       │   │   ├── user_controller.py
│       │   │   └── order_controller.py
│       │   ├── middleware/
│       │   │   ├── __init__.py
│       │   │   └── auth_middleware.py
│       │   └── routes.py
│       ├── cli/
│       │   ├── __init__.py
│       │   └── commands.py
│       └── dependencies.py
│
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── unit/
│   │   ├── domain/
│   │   │   ├── test_user.py
│   │   │   └── test_order.py
│   │   └── application/
│   │       ├── test_create_user.py
│   │       └── test_place_order.py
│   ├── integration/
│   │   └── infrastructure/
│   │       └── test_user_repository.py
│   └── fakes/
│       ├── __init__.py
│       ├── fake_user_repository.py
│       └── fake_event_publisher.py
│
├── pyproject.toml
├── requirements.txt
└── main.py
```

---

## Go

Go project with clean architecture.

```
project/
├── cmd/
│   └── api/
│       └── main.go                   # Entry point
│
├── internal/
│   ├── domain/
│   │   ├── entity/
│   │   │   ├── user.go
│   │   │   └── order.go
│   │   ├── valueobject/
│   │   │   ├── email.go
│   │   │   └── money.go
│   │   ├── repository/
│   │   │   ├── user_repository.go    # Interface
│   │   │   └── order_repository.go
│   │   ├── service/
│   │   │   └── pricing_service.go
│   │   └── errors.go
│   │
│   ├── application/
│   │   ├── usecase/
│   │   │   ├── create_user.go
│   │   │   ├── get_user.go
│   │   │   └── place_order.go
│   │   ├── dto/
│   │   │   ├── user_dto.go
│   │   │   └── order_dto.go
│   │   └── port/
│   │       ├── event_publisher.go
│   │       └── email_service.go
│   │
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   ├── postgres/
│   │   │   │   ├── user_repository.go
│   │   │   │   └── order_repository.go
│   │   │   └── model/
│   │   │       └── user_model.go
│   │   ├── mapper/
│   │   │   └── user_mapper.go
│   │   └── service/
│   │       └── sendgrid_email.go
│   │
│   └── presentation/
│       └── http/
│           ├── handler/
│           │   ├── user_handler.go
│           │   └── order_handler.go
│           ├── middleware/
│           │   └── auth.go
│           └── router.go
│
├── pkg/                              # Shared libraries
│   └── logger/
│       └── logger.go
│
├── tests/
├── go.mod
├── go.sum
└── Makefile
```

---

## Key Principles Across All Structures

1. **Domain has no dependencies** - Only standard library imports
2. **Application depends only on domain** - Defines ports for external services
3. **Infrastructure implements interfaces** - Repositories, external services
4. **Presentation is thin** - Delegates to use cases immediately
5. **Tests mirror source structure** - Easy to find tests for any component
6. **Dependency injection at composition root** - Usually in infrastructure/container

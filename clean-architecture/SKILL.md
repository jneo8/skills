---
name: clean-architecture
description: Guide for implementing Clean Architecture principles when writing code. Use this skill when (1) implementing new features or modules, (2) refactoring existing code for better separation of concerns, (3) designing system architecture or project structure, (4) reviewing code for architectural compliance, (5) creating new projects from scratch, or (6) when the user explicitly mentions clean architecture, hexagonal architecture, ports and adapters, or onion architecture.
---

# Clean Architecture

Guide for implementing Clean Architecture principles (Robert C. Martin) when writing code. Ensures proper separation of concerns, testability, and independence from frameworks.

## Core Principle: The Dependency Rule

**Dependencies MUST point inward.** Inner layers cannot know about outer layers.

```
┌────────────────────────────────────────────────┐
│            Frameworks & Drivers                │
│  ┌────────────────────────────────────────┐   │
│  │         Interface Adapters              │   │
│  │  ┌────────────────────────────────┐    │   │
│  │  │      Application Layer          │    │   │
│  │  │  ┌────────────────────────┐    │    │   │
│  │  │  │     Domain Layer       │    │    │   │
│  │  │  │    (Entities)          │    │    │   │
│  │  │  └────────────────────────┘    │    │   │
│  │  └────────────────────────────────┘    │   │
│  └────────────────────────────────────────┘   │
└────────────────────────────────────────────────┘
```

## Quick Reference

| Layer | Contains | Depends On |
|-------|----------|------------|
| Domain | Entities, Value Objects, Domain Services, Repository Interfaces | Nothing |
| Application | Use Cases, DTOs, Application Services | Domain |
| Infrastructure | Repository Implementations, External Services, Mappers | Domain, Application |
| Presentation | Controllers, Views, API Handlers | Application |

## Implementation Workflow

### Phase 1: Design Domain Layer

1. Identify core business entities and their behaviors
2. Define value objects for domain concepts
3. Create repository interfaces (ports) in the domain layer
4. Establish domain services for cross-entity logic

**Load [Domain Layer Reference](./references/layers.md#domain-layer) for detailed guidance.**

### Phase 2: Design Application Layer

1. Define use cases as single-purpose classes/functions
2. Create DTOs for data crossing boundaries
3. Define input/output ports for external dependencies
4. Keep orchestration logic here, business rules in domain

**Load [Application Layer Reference](./references/layers.md#application-layer) for detailed guidance.**

### Phase 3: Implement Infrastructure

1. Implement repository interfaces from domain layer
2. Create adapters for external services
3. Build mappers to convert between layers
4. Configure dependency injection

**Load [Infrastructure Reference](./references/layers.md#infrastructure-layer) for detailed guidance.**

### Phase 4: Build Presentation Layer

1. Create thin controllers that delegate to use cases
2. Handle HTTP/CLI/UI concerns only
3. Transform use case responses to appropriate format

**Load [Presentation Reference](./references/layers.md#presentation-layer) for detailed guidance.**

## Key Rules

### DO:
- Define interfaces in inner layers, implement in outer layers
- Use dependency injection to provide implementations
- Pass simple data structures (DTOs) across boundaries
- Keep entities free of framework dependencies

### DON'T:
- Import framework code in domain/entities
- Put business logic in controllers or repositories
- Let database schemas dictate entity structure
- Create circular dependencies between layers

## Reference Documentation

Load these resources as needed:

- **[Layer Details](./references/layers.md)** - Comprehensive guide for each architectural layer with responsibilities and examples
- **[Implementation Patterns](./references/patterns.md)** - Common patterns including repository, use case, dependency injection, and boundary crossing
- **[Directory Structures](./references/directory-structures.md)** - Example project layouts for TypeScript, Python, Go, and Java

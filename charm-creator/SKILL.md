---
name: charm-creator
description: Create and maintain high-quality Juju charms using the Operator Framework. Use this skill when the user asks to create a charm, write charm code, set up testing for a charm, or asks about Juju/Charmcraft best practices.
---

# Charm Creator Skill

This skill guides you through creating, structuring, and testing Juju charms using the Operator Framework (`ops`).

## Core Principles

1.  **Framework:** Use the `ops` Python library.
2.  **Structure:** Follow the standard `charmcraft` structure (`src/charm.py`, `tests/`, `pyproject.toml`).
3.  **Dependency Management:** Use `uv` and `pyproject.toml`.
4.  **Testing:** Rigorous unit testing with `ops.testing` and integration testing with `jubilant`. Use `concierge` for setting up test environments.

## Workflow

### 1. Initialization
Create a new charm structure:
```bash
charmcraft init --profile=machine  # or --profile=kubernetes
```
*   Use `uv lock` to generate the lockfile.
*   Update `pyproject.toml` with dependencies.

### 2. Development
*   **Charm Class:** Inherit from `ops.CharmBase`.
*   **Events:** Observe events in `__init__`.
*   **Workload:** Isolate workload-specific logic in separate modules (e.g., `src/webserver.py`).
*   **Status:** Use `collect_unit_status` and `collect_app_status` events.

### 3. Testing
*   **Unit:** Run with `tox -e unit`. Use `ops.testing` Harness/Context.
*   **Integration:** Run with `tox -e integration`. Use `jubilant` and `pytest`.
*   **Environment Setup:** Use `concierge` to provision test environments (e.g. `concierge prepare -p k8s`).
*   **Lint:** Run with `tox -e lint`. Use `ruff`, `codespell`, `pyright`.

## Reference Documentation

- **[Best Practices](./references/best-practices.md)** - Code style, project structure, and status handling.
- **[Testing Guide](./references/testing.md)** - Detailed guide for unit and integration tests, including `concierge` setup.
- **[Workflow Guide](./references/workflow.md)** - CLI commands and development lifecycle.

# Charm Best Practices

## Code Style & Conventions

-   **Formatting:** Use `ruff` for formatting and linting.
-   **Type Checking:** Use `pyright`.
-   **Imports:** Import modules, not objects (e.g., `import ops`, not `from ops import CharmBase`).
-   **Relative Imports:** Use relative imports within the package (e.g., `from . import charm`).
-   **Comprehensions:** Avoid nested comprehensions.
-   **Enum Comparisons:** Compare enum values by identity (`is`, `is not`), except for `IntEnum`/`StrEnum`.
-   **Return Types:** Always provide return type annotations for functions/methods (except `__init__`).

## Project Structure

-   **`src/charm.py`**: Contains the `CharmBase` subclass and event observers.
-   **`src/<workload>.py`**: Contains workload-specific logic (independent of `ops` if possible).
-   **`pyproject.toml`**: Manages dependencies. Use `uv` for lockfile management.
-   **`tests/`**: Contains `unit/` and `integration/` tests.

## Status Handling

-   **`collect_unit_status`**: Observe this event to report unit status.
-   **`collect_app_status`**: Observe this event to report application status (leader only).
-   **`add_status()`**: Use this method on the event object. Ops sends the highest priority status.
-   **During Events:** You can set `self.unit.status` or `self.app.status` directly for immediate updates during hook execution.

## Error Handling

-   **Automatically Recoverable:** Use `MaintenanceStatus`. Retry operations with backoff.
-   **Operator Recoverable:** Use `BlockedStatus` (e.g., missing config).
-   **Unrecoverable:** Raise exceptions. The charm will go into `ErrorStatus`.

## Maturity Checklist

1.  **Sensible Defaults:** The charm should work out-of-the-box where possible.
2.  **Proxy Support:** Respect `juju-http-proxy` etc.
3.  **Upgrade Support:** Handle upgrades gracefully preserving data.
4.  **Scaling:** Support scale-up/down if applicable.
5.  **Observability:** Integrate with COS (Canonical Observability Stack).

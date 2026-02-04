# Testing Charms

## Unit Tests

Use `ops.testing` (Context/State) for unit testing.

### Setup
Install `ops[testing]`.
Create `tests/unit/test_charm.py`.

### Structure
1.  **Arrange:** Create `testing.Context(MyCharm)` and initial `testing.State`.
2.  **Act:** Call `ctx.run(event, state_in)`.
3.  **Assert:** Check `state_out` or side effects.

### Example
```python
import ops.testing
from charm import MyCharm

def test_pebble_ready():
    ctx = ops.testing.Context(MyCharm)
    state_in = ops.testing.State(leader=True)
    state_out = ctx.run(ctx.on.pebble_ready(), state_in)
    assert state_out.unit_status == ops.ActiveStatus()
```

## Integration Tests

Use `jubilant` and `pytest`.

### Environment Setup with Concierge
Use `concierge` to prepare a Juju environment.

```bash
# Install concierge
sudo snap install --classic concierge

# Prepare environment (e.g., for k8s charms)
sudo concierge prepare -p k8s
```

### Test Structure (`tests/integration/test_charm.py`)
1.  **Fixtures (`conftest.py`):** Define `juju` (model) and `charm` (path) fixtures.
2.  **Deploy:** `juju.deploy(f"./{charm}")`.
3.  **Wait:** `juju.wait(jubilant.all_active)`.
4.  **Integrate:** `juju.integrate("app1", "app2")`.
5.  **Assert:** Check status, run actions, or query workload.

### Example
```python
import jubilant

def test_deploy(charm, juju):
    juju.deploy(f"./{charm}")
    juju.wait(jubilant.all_active)
    
    status = juju.status()
    assert "my-app" in status.applications
```

## Running Tests

```bash
# Unit tests
tox -e unit

# Integration tests
tox -e integration
```

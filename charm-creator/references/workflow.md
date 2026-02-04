# Charm Development Workflow

## 1. Initialization

Initialize a new charm repository.

```bash
# Create directory
mkdir my-charm
cd my-charm

# Initialize (choose profile)
charmcraft init --profile=machine
# OR
charmcraft init --profile=kubernetes
```

## 2. Dependency Management

Use `uv` to manage dependencies in `pyproject.toml`.

```bash
# Add dependency
uv add ops

# Update lockfile
uv lock
```

## 3. Development Loop

1.  **Modify Code:** Edit `src/charm.py` and `src/<workload>.py`.
2.  **Lint:** Ensure code quality.
    ```bash
    tox -e lint
    ```
3.  **Unit Test:** Verify logic.
    ```bash
    tox -e unit
    ```
4.  **Pack:** Build the charm.
    ```bash
    charmcraft pack
    ```
5.  **Integration Test:** Test in a real environment.
    ```bash
    tox -e integration
    ```

## 4. Publishing

1.  **Register:** Register the name on Charmhub.
    ```bash
    charmcraft register <charm-name>
    ```
2.  **Upload:** Upload the charm file.
    ```bash
    charmcraft upload <charm-file>.charm
    ```
3.  **Release:** Release to a channel.
    ```bash
    charmcraft release <charm-name> --revision=<rev> --channel=edge
    ```

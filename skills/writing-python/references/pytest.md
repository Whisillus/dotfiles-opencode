# Pytest - Python Test Framework

Pytest keeps tests concise and readable. Use it to verify changed behavior with the smallest reliable test that matches the repository's existing style.

## Runner Note

Commands below use bare `pytest`. If the repo uses a runner, prefix the command instead of changing the workflow:

```bash
pytest
uv run pytest
poetry run pytest
pipenv run pytest
```

## What to Test

Add or update tests when they protect real behavior changed by the task:

- bug fixes and regressions
- parsing, validation, and boundary conditions
- public function behavior
- CLI output, exit codes, or environment handling when those are part of the task

Do not add speculative tests for unrelated code just because you touched the file.

## Safe Default Workflow

1. Test pure functions directly when possible.
2. Use fixtures to isolate filesystem and environment state.
3. Use subprocess tests only when the CLI wrapper itself is part of the behavior under test.
4. Run the narrowest relevant tests first.
5. Keep tests deterministic and free of real network or destructive side effects.

Common commands:

```bash
pytest
pytest -v
pytest -x
pytest --lf
pytest -k keyword
pytest path/to/test_file.py
pytest path/to/test_file.py::TestName::test_case
```

## Choosing the Right Test Style

### Direct Function Tests

Use direct tests by default. They are faster, clearer, and less flaky than subprocess tests.

```python
def test_slugify_basic_case() -> None:
    assert slugify("Hello, World!") == "hello-world"
```

Prefer direct tests for:

- pure business logic
- validators and parsers
- transformations and helpers
- code that does not depend on CLI argument parsing or process-level environment setup

### Subprocess Tests

Use subprocess tests when you need to verify:

- CLI argument parsing
- exit codes
- stdout and stderr behavior
- current working directory handling
- environment variable loading at process start

Use `sys.executable` and a timeout so the test runs in the current environment and cannot hang forever.

```python
import subprocess
import sys
from pathlib import Path

SCRIPT_PATH = Path(__file__).parent.parent / "script.py"


def run_script(
    *args: str,
    env: dict[str, str] | None = None,
    timeout: int = 10,
) -> tuple[str, str, int]:
    result = subprocess.run(
        [sys.executable, str(SCRIPT_PATH), *args],
        capture_output=True,
        text=True,
        env=env,
        timeout=timeout,
        check=False,
    )
    return result.stdout, result.stderr, result.returncode
```

Example subprocess test:

```python
def test_help_flag() -> None:
    stdout, stderr, code = run_script("--help")
    assert code == 0
    assert "usage:" in stdout.lower()
    assert stderr == ""
```

Let `subprocess.TimeoutExpired` fail the test unless you are explicitly testing timeout handling.

## Fixtures for Isolation

### `tmp_path`

Use `tmp_path` for filesystem tests instead of real user directories.

```python
from pathlib import Path


def test_write_report(tmp_path: Path) -> None:
    output = tmp_path / "report.txt"
    write_report(output, "done")
    assert output.read_text(encoding="utf-8") == "done"
```

### `monkeypatch`

Use `monkeypatch` for environment variables, globals, and function replacement.

```python
def test_missing_api_key(monkeypatch) -> None:
    monkeypatch.delenv("API_KEY", raising=False)
    stdout, stderr, code = run_script()
    assert code == 1
    assert "API_KEY" in stderr
```

### `capsys`

Use `capsys` when calling Python functions directly and checking terminal output.

```python
def test_dry_run_message(capsys) -> None:
    code = main(["--dry-run"])
    captured = capsys.readouterr()
    assert code == 0
    assert "Would perform work" in captured.out
```

## Useful Test Patterns

### Exception Assertions

```python
import pytest


def test_invalid_port_raises() -> None:
    with pytest.raises(ValueError, match="port"):
        validate_port(-1)
```

### Parametrized Tests

```python
import pytest


@pytest.mark.parametrize(
    "size,expected",
    [("1024x1024", 0), ("512x512", 0), ("invalid", 2)],
)
def test_size_validation(size: str, expected: int) -> None:
    stdout, stderr, code = run_script("--size", size)
    assert code == expected
```

### Mocking External Calls

Avoid real network calls by replacing the dependency at the boundary.

```python
import service


def test_fetch_user(monkeypatch) -> None:
    def fake_request(user_id: str) -> dict[str, str]:
        return {"id": user_id, "name": "Ada"}

    monkeypatch.setattr(service, "request_user", fake_request)
    assert service.fetch_user_name("42") == "Ada"
```

## Configuration

Keep project-level settings in `pyproject.toml` and match the repo's current layout:

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_functions = "test_*"
addopts = "-v --tb=short"
```

## Common Failure Modes

- tests depend on the current working directory without setting it explicitly
- subprocess helpers do not set a timeout
- assertions overfit exact formatting when only meaning matters
- tests share mutable global state
- tests rely on real time, randomness, or network access

## Best Practices

1. Test behavior, not incidental implementation details.
2. Keep tests close to the changed behavior.
3. Use fixtures to isolate environment and filesystem state.
4. Prefer direct tests over subprocess tests when both cover the same behavior.
5. Keep tests deterministic, local, and fast.

## Resources

- Docs: https://docs.pytest.org/
- Fixtures: https://docs.pytest.org/en/stable/fixture.html
- Parametrize: https://docs.pytest.org/en/stable/parametrize.html
- Plugins: https://docs.pytest.org/en/stable/plugins.html

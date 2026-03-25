# Ruff - Python Linter and Formatter

Ruff combines linting, import sorting, and formatting in one fast tool. Use it to verify style and catch a class of easy-to-fix bugs without changing the repository's overall workflow.

## Runner Note

Commands below use bare `ruff`. If the repo uses a runner, prefix the command instead of changing the workflow:

```bash
ruff check .
uv run ruff check .
poetry run ruff check .
pipenv run ruff check .
```

## Safe Default Workflow

Use the smallest scope that answers the question:

1. Check the file or package you changed.
2. Run format checks before mutating files.
3. Use `--fix` only when edits are expected.
4. Expand to the full project only when the repo expects it or the task requires it.

Typical sequence for a touched file:

```bash
ruff check path/to/file.py
ruff format --check path/to/file.py
ruff check --fix path/to/file.py
ruff format path/to/file.py
```

## Common Commands

Check only:

```bash
ruff check .
ruff check path/to/file.py
ruff format --check .
ruff format --check path/to/package/
```

Mutating commands:

```bash
ruff check --fix path/to/file.py
ruff format path/to/file.py
```

Avoid repo-wide mutating commands unless the task explicitly expects broad formatting changes:

```bash
ruff check --fix .
ruff format .
```

## How to Respond to Ruff Diagnostics

Use Ruff output to make small, local fixes first. Do not change repo-wide config just to silence one warning.

Example output:

```text
path/to/file.py:10:5: F841 Local variable `x` is assigned but never used
path/to/file.py:15:1: I001 Import block is un-sorted or un-formatted
```

Exit codes:

- `0` - no issues found
- `1` - issues found or Ruff failed

## Common Fix Patterns

### Unused Imports and Variables

Remove unused names instead of muting the warning.

```python
# Before
import json
import os


def get_name(name: str) -> str:
    return name.strip()


# After
def get_name(name: str) -> str:
    return name.strip()
```

If an import is intentionally unused because it defines the public surface of a package, match the repo's existing pattern and document it narrowly.

### Import Sorting

Let Ruff sort imports instead of hand-editing large blocks.

```python
# Before
from pathlib import Path
import json
import sys


# After
import json
import sys
from pathlib import Path
```

### Simplification and Cleanup

Accept straightforward simplifications, but do not rewrite working logic into a less clear form just to satisfy a rule.

```python
# Before
if flag == True:
    return "yes"
return "no"


# After
if flag:
    return "yes"
return "no"
```

### Formatting

Use the formatter for layout and wrapping. Avoid manual line-wrapping churn unless it improves readability or fixes a real issue.

## Safe Autofix Boundaries

Usually safe:

- import sorting in files you already changed
- removing clearly unused imports or variables in the edited scope
- formatting the files you touched

Use extra care with:

- repo-wide `--fix`
- large import cleanup in unrelated files
- changing Ruff configuration just to satisfy one edit
- `--unsafe-fixes`

Do not use `--unsafe-fixes` unless the task explicitly calls for broader refactoring and you review the behavior carefully.

## Configuration

Keep configuration in `pyproject.toml` or `ruff.toml` and follow what the repo already uses:

```toml
[tool.ruff]
target-version = "py310"
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]
ignore = ["E501"]
```

Prefer matching the existing target version and rule set. Do not modernize syntax beyond the configured Python target.

## Best Practices

1. Check the narrowest scope first.
2. Use non-mutating commands before autofix.
3. Run `ruff check --fix` before `ruff format` when both are needed.
4. Keep ignores narrow and justified.
5. Let the repo's existing config drive rule selection.

## Resources

- Docs: https://docs.astral.sh/ruff/
- Rules: https://docs.astral.sh/ruff/rules/
- Configuration: https://docs.astral.sh/ruff/configuration/

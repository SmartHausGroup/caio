# Local Validation Setup

This document describes how to set up your local environment so pre-commit and pre-push hooks run
successfully.

## Pre-Push Hook Environment Setup

Pre-push hooks automatically use the venv Python if available, falling back to system Python with dependency checks.

### Required Dependencies

- `pydantic-settings>=2.0.0` (used by unit-tests-quick hook)
- All dependencies from `requirements.txt`
- Python 3.10+ (for all hooks)

### Setup Instructions

1. **Create a virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   pip install -e .  # Install CAIO package
   ```

3. **Install pre-commit hooks:**
   ```bash
   pre-commit install --hook-type pre-commit --hook-type pre-push
   ```

4. **Verify hooks work:**
   ```bash
   pre-commit run --all-files
   ```

### Hook Behavior

The `unit-tests-quick` hook (pre-push) automatically:
1. Uses `venv/bin/pytest` if venv exists (recommended)
2. Falls back to system `pytest` if `pydantic_settings` is available
3. Skips gracefully if dependencies are missing (warns but doesn't block)

**Note:** For reliable test execution, use a venv with all dependencies installed.

### CI Environment

CI environments must have:

- All dependencies from `requirements.txt` installed
- `pydantic-settings` available in Python path
- Pre-commit hooks installed

### Troubleshooting

**Error: `ModuleNotFoundError: No module named 'pydantic_settings'`**

- **Solution:** Install dependencies with `pip install -r requirements.txt` in your venv.
- **Note:** The hook now uses venv Python automatically if `venv/` exists.

**Error: Pre-push hooks fail in CI**

- **Solution:** Ensure CI installs dependencies before running hooks.

# CAIO Update Package Name for PyPI

**Status:** Ready for Execution  
**Date:** 2026-01-15  
**Owner:** Codex  
**Plan Reference:** `plan:update-package-name:19.8`
**North Star Alignment:** `docs/NORTH_STAR.md` - Enterprise Distribution

---

## Executive Summary

Update CAIO's package name from `caio` to `smarthaus-caio` in `pyproject.toml` to prepare for PyPI publication. This avoids naming conflicts with the existing PyPI `caio` package and establishes clear ownership.

**Key Deliverables:**
1. Update `pyproject.toml` package name to `smarthaus-caio`
2. Verify package builds correctly
3. Verify import name remains `caio` (package directory unchanged)
4. Test package installation
5. Update documentation if needed

**Estimated Time:** 1-2 hours  
**Priority:** High (required before PyPI publication)

---

## Context & Background

### Current State

- ✅ Package name in `pyproject.toml`: `name = "caio"`
- ✅ Package directory: `caio/` (import name)
- ❌ PyPI conflict: Package name `caio` already exists (async I/O library)
- ❌ Not published to PyPI yet

### North Star Alignment

- **Enterprise Distribution:** CAIO should be distributable via PyPI for easy integration
- **Clear Ownership:** `smarthaus-` prefix establishes SmartHaus Group ownership

---

## Step-by-Step Implementation Instructions

### Step 1: Update pyproject.toml

**File:** `pyproject.toml`

**Change:**
```toml
[project]
name = "smarthaus-caio"  # Changed from "caio"
version = "0.1.0"
description = "CAIO - Coordinatio Auctus Imperium Ordo: Universal AI Orchestration Platform"
# ... rest stays the same
```

**Verify:**
- Package name is lowercase with hyphens (PyPI standard: `smarthaus-caio`)
- Version remains `0.1.0`
- All other fields unchanged (description, authors, dependencies, etc.)

### Step 2: Verify Package Structure

**Check:**
- Package directory remains `caio/` (import name unchanged)
- `caio/__init__.py` exists
- All modules importable as `import caio`

**Why:** PyPI package name (`smarthaus-caio`) is different from import name (`caio`). This is standard Python practice:
- Install: `pip install smarthaus-caio`
- Import: `import caio`

### Step 3: Test Package Build

**Commands:**
```bash
# Install build tools (if not already installed)
pip install build twine

# Clean previous builds
rm -rf dist/ build/ *.egg-info

# Build package
python -m build

# Verify build artifacts
ls -lh dist/
# Should see:
# - smarthaus-caio-0.1.0.tar.gz
# - smarthaus-caio-0.1.0-py3-none-any.whl (or platform-specific wheel)
```

**Verify:**
- Build succeeds without errors
- Build artifacts have correct name (`smarthaus-caio-*`)
- Package metadata is correct (check `dist/*.whl` or `dist/*.tar.gz` contents)

### Step 4: Test Package Installation

**Commands:**
```bash
# Install from local build
pip install dist/smarthaus-caio-0.1.0-py3-none-any.whl

# Verify import still works (import name is still 'caio')
python -c "import caio; print('Import successful')"

# Verify version
python -c "import caio; print(caio.__version__)"  # If __version__ exists

# Test basic functionality
python -c "from caio import Orchestrator; print('Orchestrator import successful')"
```

**Verify:**
- Package installs successfully
- Import name is still `caio` (not `smarthaus_caio`)
- All functionality works (Orchestrator, API routes, etc.)

### Step 5: Update Documentation (if needed)

**Files to check:**
- `README.md` - Installation instructions
- `docs/operations/UPDATE_MECHANISM_ARCHITECTURE.md` - Package name references
- Any other docs mentioning package name or installation

**Changes:**
- Update installation examples to use `smarthaus-caio`:
  ```markdown
  ## Installation
  
  ### From PyPI (Recommended)
  ```bash
  pip install smarthaus-caio
  ```
  
  ### From GitHub (Development)
  ```bash
  pip install git+https://github.com/SmartHausGroup/CAIO.git@development
  ```
  ```
- Keep import examples as `import caio` (import name unchanged)

### Step 6: Verify No Breaking Changes

**Check:**
- All existing code still works
- All imports still work (`import caio`, `from caio import ...`)
- All tests still pass
- No references to old package name in code

**Run Tests:**
```bash
# Run all tests to ensure nothing broke
pytest tests/ -v

# Run specific import tests
python -c "from caio import Orchestrator; from caio.api import app; print('All imports work')"
```

---

## Validation Procedures

### Build Verification

```bash
# Build package
python -m build

# Check build artifacts
ls -lh dist/
# Verify: smarthaus-caio-0.1.0-* files exist
```

### Installation Verification

```bash
# Install from local build
pip install dist/smarthaus-caio-0.1.0-py3-none-any.whl

# Verify import
python -c "import caio; print('✅ Import works')"

# Verify functionality
python -c "from caio import Orchestrator; o = Orchestrator(); print('✅ Orchestrator works')"
```

### Test Suite Verification

```bash
# Run all tests
pytest tests/ -v

# Verify no test failures related to package name change
```

---

## Success Criteria

- [ ] `pyproject.toml` updated to `name = "smarthaus-caio"`
- [ ] Package builds successfully with new name
- [ ] Build artifacts named `smarthaus-caio-*`
- [ ] Import name remains `caio` (unchanged)
- [ ] Package installs correctly from local build
- [ ] All imports work (`import caio`, `from caio import ...`)
- [ ] All functionality works after installation
- [ ] All tests pass
- [ ] Documentation updated (if needed)
- [ ] No breaking changes to existing code

---

## Troubleshooting

### Common Issues

**Issue:** Build fails with "Invalid package name"
**Solution:** Verify package name is lowercase with hyphens only (`smarthaus-caio`), no underscores or uppercase

**Issue:** Import fails after installation
**Solution:** Verify package directory is still `caio/` (not `smarthaus_caio/`), check `__init__.py` exists

**Issue:** Tests fail after package name change
**Solution:** Package name change shouldn't affect tests (import name unchanged), check for hardcoded package name references

---

## Notes

- **PyPI Package Name ≠ Import Name:** This is standard Python practice
  - PyPI: `smarthaus-caio` (what you `pip install`)
  - Import: `caio` (what you `import`)
- **No Code Changes Needed:** Only `pyproject.toml` needs updating
- **Backward Compatible:** All existing code continues to work (import name unchanged)
- **Can Be Done Independently:** This task doesn't depend on other tasks

---

## Related Documents

- `pyproject.toml` - Package configuration
- `README.md` - Installation instructions
- `docs/operations/UPDATE_MECHANISM_ARCHITECTURE.md` - Update mechanism
- `docs/NORTH_STAR.md` - North Star vision
- `plans/update-package-name/update-package-name.md` - Detailed plan

---

**Last Updated:** 2026-01-15  
**Version:** 1.0

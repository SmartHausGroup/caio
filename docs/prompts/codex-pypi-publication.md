# CAIO PyPI Publication

**Status:** Ready for Execution  
**Date:** 2026-01-15  
**Owner:** Codex  
**Plan Reference:** `plan:pypi-publication:19.8`
**North Star Alignment:** `docs/NORTH_STAR.md` - Enterprise Distribution

---

## Executive Summary

Publish CAIO to PyPI as `smarthaus-caio` to enable easy installation and distribution. This allows TAI and other applications to install CAIO via `pip install smarthaus-caio` without requiring GitHub access.

**Key Deliverables:**
1. PyPI account setup (if not exists)
2. Package build and validation
3. TestPyPI publication and testing
4. PyPI publication
5. Verification of published package
6. Documentation updates

**Estimated Time:** 2-4 hours (first time), 30 minutes (subsequent releases)  
**Priority:** High (enables TAI integration via PyPI)

---

## Context & Background

### Current State

- ✅ Package name updated to `smarthaus-caio` (Task 2 complete)
- ✅ Package builds successfully
- ❌ Not published to PyPI yet
- ❌ PyPI account may need setup

### Prerequisites

- Task 2 complete (update-package-name)
- Package builds successfully (`python -m build` works)
- PyPI account credentials available in `.env` file:
  - `PYPI_USERNAME` - Your PyPI username
  - `PYPI_API_TOKEN` - Your PyPI API token (get from https://pypi.org/manage/account/token/)
  - `TESTPYPI_USERNAME` (optional) - For TestPyPI testing
  - `TESTPYPI_API_TOKEN` (optional) - For TestPyPI testing

### North Star Alignment

- **Enterprise Distribution:** CAIO should be distributable via PyPI
- **Easy Integration:** Other applications should be able to `pip install smarthaus-caio`

---

## Step-by-Step Implementation Instructions

### Step 1: PyPI Account Setup

**If account doesn't exist:**

1. **Create Account:**
   - Go to https://pypi.org/account/register/
   - Register with email and password
   - Verify email address

2. **Enable Two-Factor Authentication (Recommended):**
   - Go to account settings
   - Enable 2FA for security

3. **Generate API Token (Recommended):**
   - Go to account settings → API tokens
   - Create new token with scope: "Entire account" or project-specific
   - Save token securely (use GitHub Secrets for CI/CD)

**If account exists:**

1. **Verify Credentials:**
   - Test login at https://pypi.org
   - Verify API token works (if using tokens)

2. **Check Permissions:**
   - Ensure account can upload packages
   - Verify project name `smarthaus-caio` is available

### Step 2: Prepare Package for Publication

**Files to verify:**

1. **`pyproject.toml`:**
   - Package name: `smarthaus-caio`
   - Version: `0.1.0` (or appropriate version)
   - Description: Clear and descriptive
   - Authors: SmartHaus Group
   - License: MIT (or appropriate)
   - Readme: Points to README.md
   - Requires-python: `>=3.14` (or appropriate)

2. **`README.md`:**
   - Clear description of CAIO
   - Installation instructions
   - Quick start guide
   - Links to documentation

3. **`LICENSE`:**
   - License file exists
   - Matches license in `pyproject.toml`

4. **`MANIFEST.in` (if needed):**
   - Include all necessary files
   - Exclude development files

**Version Check:**
- Current version: `0.1.0` (from pyproject.toml)
- Verify version is appropriate for first release
- Use semantic versioning (0.1.0, 0.1.1, 0.2.0, etc.)

### Step 3: Build Package

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
# - smarthaus-caio-0.1.0.tar.gz (source distribution)
# - smarthaus-caio-0.1.0-py3-none-any.whl (wheel distribution)
```

**Verify:**
- Build succeeds without errors
- Artifacts are correct size (not empty)
- Package metadata is correct (check with `twine check dist/*`)

### Step 4: Validate Package

**Commands:**
```bash
# Check package for common issues
twine check dist/*

# Verify package structure
python -m zipfile -l dist/smarthaus-caio-0.1.0-py3-none-any.whl
```

**Verify:**
- No errors from `twine check`
- Package structure is correct
- All required files included

### Step 5: Test Publication (TestPyPI)

**Load Credentials from .env:**
```bash
# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Or use python-dotenv
pip install python-dotenv
python -c "from dotenv import load_dotenv; import os; load_dotenv(); print(os.getenv('PYPI_USERNAME'))"
```

**Commands:**
```bash
# Upload to TestPyPI first (always test here first!)
# Uses TESTPYPI_USERNAME and TESTPYPI_API_TOKEN from .env if set, otherwise PYPI credentials
twine upload --repository testpypi dist/* \
  --username "${TESTPYPI_USERNAME:-$PYPI_USERNAME}" \
  --password "${TESTPYPI_API_TOKEN:-$PYPI_API_TOKEN}"

# Alternative: Use environment variables directly
export TWINE_USERNAME="${TESTPYPI_USERNAME:-$PYPI_USERNAME}"
export TWINE_PASSWORD="${TESTPYPI_API_TOKEN:-$PYPI_API_TOKEN}"
twine upload --repository testpypi dist/*
```

**Verify Upload:**
- Upload succeeds without errors
- Package appears on https://test.pypi.org/project/smarthaus-caio/

**Test Installation from TestPyPI:**
```bash
# Install from TestPyPI
pip install --index-url https://test.pypi.org/simple/ smarthaus-caio

# Verify installation
python -c "import caio; print('✅ Import works')"
python -c "from caio import Orchestrator; print('✅ Orchestrator works')"

# Test basic functionality
python -m caio.main --help
```

**Verify:**
- Package installs from TestPyPI
- Import works correctly (`import caio`)
- Functionality works
- Version is correct

### Step 6: Publish to PyPI (Production)

**Load Credentials from .env:**
```bash
# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Or use python-dotenv
pip install python-dotenv
python -c "from dotenv import load_dotenv; import os; load_dotenv(); print(os.getenv('PYPI_USERNAME'))"
```

**Commands:**
```bash
# Upload to PyPI (production)
# Uses PYPI_USERNAME and PYPI_API_TOKEN from .env file
twine upload dist/* \
  --username "${PYPI_USERNAME}" \
  --password "${PYPI_API_TOKEN}"

# Alternative: Use environment variables directly
export TWINE_USERNAME="${PYPI_USERNAME}"
export TWINE_PASSWORD="${PYPI_API_TOKEN}"
twine upload dist/*
```

**Verify Upload:**
- Upload succeeds without errors
- Package appears on https://pypi.org/project/smarthaus-caio/
- Package page displays correctly (description, version, etc.)

**Test Installation from PyPI:**
```bash
# Uninstall local/test version first
pip uninstall smarthaus-caio -y

# Install from PyPI
pip install smarthaus-caio

# Verify installation
python -c "import caio; print('✅ Import works')"
python -c "from caio import Orchestrator; print('✅ Orchestrator works')"

# Test basic functionality
python -m caio.main --help
```

**Verify:**
- Package installs from PyPI
- Import works correctly
- Functionality works
- Version is correct

### Step 7: Update Documentation

**Files to update:**

1. **`README.md`:**
   - Add PyPI installation section:
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

2. **`docs/operations/UPDATE_MECHANISM_ARCHITECTURE.md`:**
   - Update package name references to `smarthaus-caio`
   - Update installation examples

3. **Any other docs with installation instructions:**
   - Update to mention PyPI option
   - Keep GitHub option for development

### Step 8: Set Up Automated Publishing (Optional but Recommended)

**GitHub Actions Workflow:**

**File:** `.github/workflows/publish-pypi.yml`

**Implementation:**
```yaml
name: Publish to PyPI

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.14'
      - name: Install build tools
        run: pip install build twine
      - name: Build package
        run: python -m build
      - name: Publish to PyPI
        env:
          TWINE_USERNAME: __token__
          TWINE_PASSWORD: ${{ secrets.PYPI_API_TOKEN }}
        run: twine upload dist/*
```

**Benefits:**
- Automated publication on release tags
- Consistent process
- No manual uploads needed

**Setup:**
1. Create GitHub Secret: `PYPI_API_TOKEN` with PyPI API token
2. Create workflow file
3. Test with a release tag

---

## Validation Procedures

### Build Verification

```bash
# Build package
python -m build

# Check build artifacts
ls -lh dist/
# Verify: smarthaus-caio-0.1.0-* files exist

# Validate package
twine check dist/*
# Verify: No errors
```

### TestPyPI Verification

```bash
# Upload to TestPyPI
twine upload --repository testpypi dist/*

# Install from TestPyPI
pip install --index-url https://test.pypi.org/simple/ smarthaus-caio

# Verify
python -c "import caio; from caio import Orchestrator; print('✅ Works')"
```

### PyPI Verification

```bash
# Upload to PyPI
twine upload dist/*

# Install from PyPI
pip install smarthaus-caio

# Verify
python -c "import caio; from caio import Orchestrator; print('✅ Works')"

# Check package page
# Visit: https://pypi.org/project/smarthaus-caio/
```

### Integration Verification

**Test TAI Installation:**
```bash
# In TAI repository
pip install smarthaus-caio

# Verify TAI can import and use CAIO
python -c "import caio; from caio import Orchestrator; print('✅ TAI integration works')"
```

---

## Success Criteria

- [ ] PyPI account set up (if needed)
- [ ] Package builds successfully
- [ ] Package validated (`twine check` passes)
- [ ] Package published to TestPyPI
- [ ] Package installs from TestPyPI
- [ ] Package published to PyPI
- [ ] Package installs from PyPI
- [ ] Package appears on https://pypi.org/project/smarthaus-caio/
- [ ] Package page displays correctly
- [ ] Documentation updated with PyPI instructions
- [ ] TAI can install via `pip install smarthaus-caio`
- [ ] Automated publishing workflow set up (optional)

---

## Troubleshooting

### Common Issues

**Issue:** Upload fails with "403 Forbidden"
**Solution:** Check API token is correct, verify token has upload permissions, ensure using `__token__` as username

**Issue:** Upload fails with "400 Bad Request - File already exists"
**Solution:** Version already published, increment version in `pyproject.toml` and rebuild

**Issue:** Package installs but import fails
**Solution:** Verify package structure is correct, check `caio/__init__.py` exists

**Issue:** Package page shows incorrect information
**Solution:** Verify `pyproject.toml` metadata is correct, rebuild and re-upload

---

## Notes

- **Always Test on TestPyPI First:** Never upload to production PyPI without testing on TestPyPI
- **Version Management:** Use semantic versioning (0.1.0, 0.1.1, 0.2.0, etc.)
- **Credentials Security:** Never commit PyPI credentials to repo (use GitHub Secrets)
- **Automation:** Consider GitHub Actions for automated publishing on releases
- **Documentation:** Update all installation instructions to mention PyPI

---

## Post-Publication Checklist

After successful publication:

- [ ] Update TAI's `requirements.txt` to use PyPI package
- [ ] Test TAI installation with PyPI package
- [ ] Document PyPI publication process for future releases
- [ ] Set up automated publishing workflow (optional)
- [ ] Announce publication (if appropriate)

---

## Related Documents

- `pyproject.toml` - Package configuration
- `README.md` - Installation instructions
- `docs/operations/UPDATE_MECHANISM_ARCHITECTURE.md` - Update mechanism
- `docs/NORTH_STAR.md` - North Star vision
- `plans/pypi-publication/pypi-publication.md` - Detailed plan

---

**Last Updated:** 2026-01-15  
**Version:** 1.0

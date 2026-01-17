# Phase 19.8.1: GitHub Distribution Strategy

**Objective:** Implement "Option C" - GitHub-based distribution as the primary installation method while PyPI approval is pending. Eliminate reliance on GitHub Actions for release management.

## Context
PyPI account approval is pending, blocking standard `pip install smarthaus-caio`. To unblock usage (internal TAI and external), we will treat the GitHub repository as the source of truth for installation (`pip install git+...`). We also need to ensure releases are managed locally (`scripts/release/tag_version.sh`) rather than via expensive GitHub Actions.

## Tasks

### Task 1: Update Documentation
**Files:** `README.md`, `docs/deployment/PACKAGING.md`

1.  **Prioritize GitHub Install:** Move `pip install git+...` to the top of the "Installation" section in `README.md`.
2.  **Mark PyPI as Pending:** Add a note that PyPI installation is coming soon.
3.  **Document Version Pinning:** Show users how to install specific versions:
    ```bash
    pip install git+https://github.com/SmartHausGroup/CAIO.git@v0.1.0
    ```

### Task 2: Implement Local Release Script
**File:** `scripts/release/tag_version.sh`

Create a bash script to:
1.  Read the version from `pyproject.toml` (e.g., using `grep` or python).
2.  Check if the git tag already exists.
3.  If not, create the tag locally (`git tag v$VERSION`).
4.  Push the tag to origin (`git push origin v$VERSION`).
5.  Print success message: "Release v$VERSION tagged and pushed."

**Requirements:**
- Must be executable (`chmod +x`).
- Must run from project root.
- Must verify clean git state (optional but recommended).

### Task 3: Validate Installation Flow
**Action:**
1.  Create a temporary virtual environment.
2.  Run `pip install git+https://github.com/SmartHausGroup/CAIO.git@development` (or current branch).
3.  Verify import: `python -c "import caio; print(caio.__version__)"`.
4.  Delete temporary environment.

## Success Criteria
- `README.md` clearly directs users to install from GitHub.
- `scripts/release/tag_version.sh` exists and works.
- Installation from GitHub is verified locally.

## Plan Reference
`plan:phase-19-8-1-github-distribution:19.8.1.1`

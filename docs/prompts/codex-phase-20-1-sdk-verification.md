# Codex Prompt: Phase 20.1 — SDK Verification & Test Fixes

**Plan Reference:** `plans/phase-20-1-sdk-verification/phase-20-1-sdk-verification.md`
**Context:** Post-SDK separation cleanup.

**Goal:**
1.  Fix the `ModuleNotFoundError` in License CLI tests caused by missing `PYTHONPATH` in subprocess calls.
2.  Verify the new `smarthaus-caio-sdk` package builds successfully.

**Instructions:**
1.  **Fix Tests:**
    - Open `tests/unit/test_license_cli.py`.
    - In the test setup or the subprocess call, ensure `os.environ["PYTHONPATH"]` includes the repository root.
    - Run `pytest tests/unit/test_license_cli.py` to verify the fix.
2.  **Verify SDK Build:**
    - Navigate to `packages/sdk`.
    - Run `python -m build`.
    - Check that `dist/` contains valid artifacts.
3.  **Validate:**
    - Run `make test` from the root to ensure all tests pass.

**Output:**
- Passed tests.
- Built SDK artifacts.

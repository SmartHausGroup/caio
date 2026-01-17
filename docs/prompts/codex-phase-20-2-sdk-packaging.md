# Codex Prompt: Phase 20.2 — SDK Packaging Fix

**Plan Reference:** `plans/phase-20-2-sdk-packaging/phase-20-2-sdk-packaging.md`
**Context:** The SDK directory `packages/sdk` is missing build configuration.

**Goal:**
Enable `smarthaus-caio-sdk` to be built and distributed.

**Instructions:**
1.  **Create `packages/sdk/pyproject.toml`:**
    - Package Name: `smarthaus-caio-sdk`
    - Version: `0.1.0`
    - Dependencies: `httpx>=0.24.0`, `pydantic>=2.0.0`
    - Build System: `setuptools>=61.0`
    - Point `packages` discovery to `caio_sdk`.
2.  **Build Verification:**
    - Run `python -m build` inside `packages/sdk`.
    - Validate that `dist/` is created with `.whl` and `.tar.gz` files.

**Output:**
- A valid `pyproject.toml` file.
- Successfully built artifacts.

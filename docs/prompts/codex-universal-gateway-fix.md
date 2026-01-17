# Codex Prompt: Universal Gateway Fix & Completion

## Executive Summary
Fix critical import errors in the Universal Service Gateway core to unblock Phase 19.

## Context & Background
The `GatewayExecutor` is currently throwing a `ModuleNotFoundError` because it tries to import `BaseAdapter` from a non-existent path. This prevents service execution and E2E testing.

## Target State
- `GatewayExecutor` is importable without errors.
- `BaseAdapter` is correctly located and exported.
- E2E routing flow tests pass the import phase.

## Implementation Instructions

### Step 1: Fix Import Paths
Identify the correct location of `BaseAdapter`. Currently, it seems to be at `caio/gateway/base.py`, but `executor.py` looks for it in `caio.gateway.adapters.base`.
- Update `caio/gateway/executor.py`: Change `from caio.gateway.adapters.base import BaseAdapter` to `from caio.gateway.base import BaseAdapter`.
- Update `caio/gateway/adapters/__init__.py`: Change `from caio.gateway.adapters.base import BaseAdapter` to `from caio.gateway.base import BaseAdapter`.

### Step 2: Update Package Initializers
- Verify `caio/gateway/__init__.py` exports `GatewayExecutor` and `HttpAdapter`.
- Ensure all Tier 1 adapters in `caio/gateway/adapters/` (if any were partially implemented) use the corrected import path for `BaseAdapter`.

### Step 3: Verification
- Run `PYTHONPATH=. pytest tests/e2e/test_production_deployment.py` (or any E2E test) to ensure the `ModuleNotFoundError` is resolved.
- Run a minimal smoke test: `python -c "from caio.gateway.executor import GatewayExecutor; print('Success')"`

## Validation Procedures
1. Run `pytest` and verify that test collection succeeds.
2. Run the smoke test command above.

## Success Criteria
- [ ] `GatewayExecutor` is importable.
- [ ] E2E tests can collect and run without import errors.
- [ ] Gateway core is functional.

## Plan Reference
`plan:universal-gateway-fix`

## North Star Alignment
Aligns with "Universal Compatibility" and "Master Equation Execute Step" by ensuring the execution engine is functional.

# Codex Prompt: Production Hardening Completion

## Executive Summary
Complete the final production hardening items, including rate limiting and test suite stability.

## Context & Background
CAIO is nearly production-ready, but lacks rate limiting and has minor instabilities in the E2E test suite (coroutine warnings and environment issues).

## Target State
- Rate limiting middleware is active and configurable.
- E2E production tests pass 100% without warnings.
- `HARDENING_CHECKLIST.md` is fully verified.

## Implementation Instructions

### Step 1: Implement Rate Limiting Middleware
Create `caio/api/middleware/rate_limit.py`:
- Implement a simple token-bucket or sliding-window rate limiter.
- Use an in-memory store (e.g., `dict`) for development/on-prem.
- Wire it into `caio/api/app.py`'s `create_app` factory.
- Add configuration settings in `caio/config.py` for rate limits.

### Step 2: Fix E2E Test Failures
- Address coroutine warnings in `tests/integration/test_api_sdk.py` by ensuring all async calls are awaited.
- Fix any remaining `ModuleNotFoundError` in the test environment.
- Ensure `tests/e2e/test_production_deployment.py` runs correctly.

### Step 3: Final Hardening Validation
- Run `make ai-validate` and ensure all quality gates are green.
- Manually verify each item in `docs/deployment/HARDENING_CHECKLIST.md` and mark as complete.

## Validation Procedures
1. Run `pytest tests/e2e/test_production_deployment.py`.
2. Test rate limiting by hammering an endpoint with `curl` or a script.
3. Check `scorecard.json` status.

## Success Criteria
- [ ] Rate limiting functional and configurable.
- [ ] E2E production tests passing 100%.
- [ ] Hardening checklist fully verified.

## Plan Reference
`plan:production-hardening-completion`

## North Star Alignment
Aligns with "Operational Excellence" and "Security Built into Math" by adding defensive layers and comprehensive validation.

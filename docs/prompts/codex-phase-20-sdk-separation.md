# Codex Prompt: Phase 20 — SDK Separation

**Plan Reference:** `plan:phase-20-sdk-separation:20.0`  
**Execution Plan Reference:** `docs/operations/execution_plan.md` (Phase 20)  
**North Star Alignment:** `docs/NORTH_STAR.md` — SDK Specification, Universal Compatibility

---

## Executive Summary

Split the CAIO SDK into an isolated package under `packages/sdk` to enforce strict boundaries between core runtime logic and the SDK surface. Preserve a stable public SDK API while preventing core↔SDK dependency leakage.

---

## Context & Background

The SDK currently lives under `caio/sdk`, which risks coupling the public SDK surface to core runtime dependencies. Phase 20 introduces a `packages/sdk` package to ensure the SDK can be distributed independently and used without pulling the full orchestrator runtime.

---

## Current State

- SDK modules live under `caio/sdk` (client, service interface, exceptions).
- Internal imports may assume `caio.sdk` paths.
- No separate SDK package boundary exists.

---

## Target State

- SDK modules moved to `packages/sdk`
- Strict isolation between core runtime and SDK
- Backward-compatible import paths (if required)
- Documentation updated to reference `packages/sdk`

---

## Step-by-Step Implementation

### 1) Audit SDK Surface

- Identify SDK modules and public API surface.
- Confirm if any SDK modules import core runtime modules.
- Record allowed dependencies (SDK should avoid core runtime).

### 2) Create SDK Package Structure

- Create `packages/sdk` directory.
- Move SDK modules from `caio/sdk` into `packages/sdk`.
- Add minimal package metadata and README (follow repo conventions).

### 3) Preserve Compatibility

- If required, keep `caio/sdk` as a compatibility shim that re-exports SDK symbols.
- Update internal imports to the new package path with minimal diffs.

### 4) Update Documentation

- Update SDK and integration docs to reference `packages/sdk`.
- Document boundary rules (no core↔SDK coupling).

### 5) Validate

- Run lint and tests per repo standards.
- Ensure SDK-only usage works without core runtime imports.

---

## Validation Procedures

Use only commands from `docs/codex/CODEX_PROFILE.md`:

- `make lint-all`
- `make test`
- `pytest tests/` (if SDK-specific tests are added)

---

## Troubleshooting

- **Import errors after move**: Add or update compatibility shim in `caio/sdk`.
- **Circular dependencies**: Remove SDK references from core runtime or replace with interfaces.
- **Test failures**: Ensure tests import SDK from the new path or via shim.

---

## Success Criteria

- SDK package exists under `packages/sdk`
- SDK can be used without core runtime dependency leakage
- Existing import paths remain functional
- Documentation updated

---

## Notes & References

- `docs/NORTH_STAR.md`
- `docs/operations/execution_plan.md`
- `docs/SDK_SPECIFICATION.md`
- `caio/sdk/`


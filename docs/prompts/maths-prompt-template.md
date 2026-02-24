# MATHS Prompt Template

Use this template to prompt any MA-scoped build/change request. For full machine-readable protocol (phase contract, state machine, CHECK:C-FILE-SCOPE, resource budgets), see `agent_governance/master-maths-prompt-template.md`.

## Execution Rules (Mandatory)

- Do not proceed past a phase when required inputs are missing.
- Fail closed when invariant, schema, or artifact requirements are ambiguous.
- Do not modify thresholds to "make gates green" without explicit owner approval.
- If deterministic replay fails, stop promotion and resolve before continuing.
- If scope drifts beyond declared boundaries, stop and re-scope first.
- Before any write: run CHECK:C-FILE-SCOPE (git diff --name-only; assert all files in Context allowlist; no denylist file touched). If violation: emit STATUS BLOCKED, TASK scope_violation.
- Assure/Observe: Include only when plan sets `Assure_required: true` or `Observe_required: true`; otherwise omit.

## Prompt Run Metadata

- Prompt version:
- Task ID:
- Run ID:
- Commit SHA:
- Dataset/version fingerprint:
- Invariant IDs in scope:
- Owners (product/engineering/MA):

## Context

- Task name:
- Domain: framework | app
- Owner:
- Dependencies:
- Explicit file allowlist (may touch):
- Explicit file denylist (must not touch):

## M — Model

- Problem:
- User/stakeholder:
- Success metrics:
- Constraints (time/cost/stack/compliance):
- Out of scope:

## A — Annotate

- Formal rules/equations:
- Assumptions:
- Data/contracts/interfaces:
- Invariants impacted (IDs):
- Required artifacts:

## T — Tie

- Dependency checks:
- Service/API/MCP readiness:
- Environment/config readiness:
- Confidence protocol (what to do when uncertain):
- Known failure modes + prevention:
- Go/No-Go:

## H — Harness

- Implementation plan (ordered):
- Notebook-first requirements:
- Files to create/update:
- Extraction boundary (if notebook-derived):

## S — Stress-test

- Functional tests:
- Edge/adversarial tests:
- Determinism/replay checks:
- Acceptance gates:

## Phase Contract (when using full protocol)

Each phase emits `configs/generated/maths_phase_output/<phase>.json` with phase, invariants_declared, variables_defined, constraints_declared, assumptions, artifact_sha256, signed_hash. Next phase consumes it; fail-closed if missing.

## Optional — Assure (production hardening)

- Security checks:
- Input validation:
- Additional test coverage:

## Optional — Observe (production operations)

- Telemetry/signals:
- Alert thresholds:
- Rollback/kill-switch:

## Output Contract

- Deliverables:
- Artifacts generated:
- Validation result:
- Residual risks:
- Evidence links (files/paths only):
- Blocking decisions taken:
- Follow-up actions with owners/dates:

## No-Go Triggers (Mandatory)

- Missing required artifact file(s).
- Artifact schema mismatch against declared contract.
- Invariant checks missing or failing.
- Deterministic replay check is false.
- Unapproved threshold/config drift.
- Security/compliance gate failure (when Assure is in scope).

## Required Completion Block

- `M` complete? (yes/no) Evidence:
- `A` complete? (yes/no) Evidence:
- `T` complete? (yes/no) Evidence:
- `H` complete? (yes/no) Evidence:
- `S` complete? (yes/no) Evidence:
- `Assure` required? (yes/no) Evidence:
- `Observe` required? (yes/no) Evidence:
- Final Decision: `GO` | `NO-GO`
- Approved by:
- Timestamp (UTC):

## Crosswalk (Legacy Naming)

- Model = Architect
- Annotate = Trace
- Tie = Link
- Harness = Assemble
- Stress-test = Stress-test
- Assure = Validate
- Observe = Monitor

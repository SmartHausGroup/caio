# Invariant Violation Runbook

## Purpose
Respond to MA invariants failing (scorecard red) and restore compliance.

## Triggers
- `scorecard.json` reports `decision: red`.
- Alerts include `scorecard_red`.
- MA validation (`make ma-validate-quiet`) fails.

## Investigation
1. Identify failing invariant IDs in `scorecard.json`.
2. Review math specification in `docs/math/*_MATHEMATICS.md`.
3. Check invariants in `invariants/INV-*.yaml`.
4. Inspect notebooks proving invariants.

## Remediation
1. Follow MA process: Math → Invariants → Notebooks → Artifacts → Validation → Code.
2. Fix notebooks and re-extract code if required.
3. Re-run MA validation and integration tests.

## Prevention
- Add regression tests for the invariant class.
- Update runbooks and validation gates if needed.


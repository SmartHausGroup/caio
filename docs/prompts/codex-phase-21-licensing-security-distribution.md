# Codex Prompt: Phase 21 — Licensing Security & Distribution Control

**Plan Reference:** `plan:EXECUTION_PLAN:21`
**Detailed Plan:** `plans/phase-21-licensing-security-distribution/phase-21-licensing-security-distribution.md`
**North Star Alignment:** §3.2.1 Local Licensing, §2.3 Security as Mathematical Invariants, INV-CAIO-SEC-0006.

---

## Directive

Execute Phase 21 per `plans/phase-21-licensing-security-distribution/phase-21-licensing-security-distribution.md`.

## Pre-Work

1. North Star alignment: confirm §3.2.1, §2.3, INV-CAIO-SEC-0006.
2. Execution plan: confirm Phase 21 and `plan:EXECUTION_PLAN:21`.
3. Read `caio/licensing/generator.py`, `validator.py`, `generation_service.py`, `schema.py`, and `docs/licensing/LICENSE_MANAGEMENT.md`.

## Execution Order

1. **21.1** — Add `cryptography`; add `scripts/licensing/generate_keypair.sh`; document key custody.
2. **21.2** — Refactor `generator.py` (private key, `v2` format) and `validator.py` (public key, verify).
3. **21.3** — Config: drop `CAIO_LICENSE_SECRET`; add `CAIO_LICENSE_KEY`, `CAIO_LICENSE_PUBLIC_KEY`; wire validator.
4. **21.4** — `generation_service.py` and CLI to use private key and emit `v2`.
5. **21.5** — `deploy/customer/` and `scripts/release/push_to_registry.sh`; docs.
6. **21.6** — LICENSE_MANAGEMENT, ON_PREMISES, LICENSE_ACTIVATION, runbook.

## Validation

- `make ma-validate-quiet`; `make test`; `make lint-all`.
- Unit tests for generator/validator `v2`; integration tests for activate/validate with `v2`.
- Grep for `CAIO_LICENSE_SECRET` and `secret_key` in customer-facing paths; expect none (or only in migration notes).

## Post-Work

- CODEX_ACTION_LOG: plan:EXECUTION_PLAN:21, North Star alignment, itemized actions.
- STATUS_PLAN: Phase 21 status, Recent Work.
- EXECUTION_PLAN: checkboxes for 21.1–21.6.

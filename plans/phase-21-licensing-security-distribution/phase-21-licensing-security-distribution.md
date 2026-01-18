# Plan: Phase 21 — Licensing Security & Distribution Control

**Plan ID:** `phase-21-licensing-security-distribution`
**Status:** Complete
**Date:** 2026-01-18
**Owner:** @smarthaus
**Execution Plan Reference:** `plan:EXECUTION_PLAN:21`
**North Star Alignment:** `docs/NORTH_STAR.md` — §3.2.1 Embedded Governance (Local Licensing), §2.3 Security as Mathematical Invariants, INV-CAIO-SEC-0006 Data Integrity. Strengthens licensing to meet enterprise control: asymmetric signing so customers cannot forge keys; distribution control so only licensed customers can download.

---

## Objective

Upgrade CAIO licensing from HMAC (symmetric) to asymmetric (RSA/Ed25519) so the **private key stays only with you** and the **public key is embedded in builds**. Add distribution control so customers download only via a private registry/token you control.

**Repository Split:**
- **Code Implementation (caio-core):** Generator, validator, config, CLI, and key scripts.
- **Documentation & Deployment (CAIO):** Deployment configs, user guides, runbooks.

---

## Scope

### 21.1 Asymmetric License Cryptography (caio-core)
- **Complete:** Generator signs with private key; validator verifies with public key.
- **Key custody:** Private key on operator machine; public key in repo/build.

### 21.2 Validator and Generator Refactor (caio-core)
- **Complete:** `LicenseKeyGenerator` uses RSA private key; `LicenseValidator` uses RSA public key.
- **Format:** `CAIO-v2-{customer_id}-{payload_b64}.{signature_b64}`.

### 21.3 Configuration and Key Embedding (caio-core)
- **Complete:** Removed `CAIO_LICENSE_SECRET`. Added `CAIO_LICENSE_KEY` and `CAIO_LICENSE_PUBLIC_KEY`.

### 21.4 Distribution Control (CAIO)
- **Private registry:** Documented for customer pull.
- **Artifacts:** `deploy/customer/docker-compose.yml` updated.
- **Scripts:** `push_to_registry.sh` moved to `caio-core` (internal tool).

### 21.5 Generation Service, CLI, and DB (caio-core)
- **Complete:** CLI (`manage_licenses.py`) updated for RSA keys.

### 21.6 Documentation and Runbooks (CAIO)
- **Docs:** Updated `LICENSE_MANAGEMENT.md`, `ON_PREMISES_DEPLOYMENT.md`, `LICENSE_ACTIVATION.md`.
- **Runbook:** Added `docs/operations/runbooks/license_key_rotation.md`.

---

## Requirements

### Prerequisites
- Phase 17/18 complete.
- `caio-core` access for code changes.

### Success Criteria
- [x] Generator signs with private key; validator verifies with public key only. (caio-core)
- [x] No HMAC secret or private key in any customer-facing artifact or config. (caio-core / CAIO docs)
- [x] Existing activation/validation APIs and CLI work with `v2` keys. (caio-core)
- [x] Key generation and rotation documented; runbook exists. (CAIO)
- [x] Distribution: customer path for Docker documented. (CAIO)

---

## Detailed Tasks

### 21.1: Asymmetric Crypto and Keypair
- [x] Add `cryptography` dependency. (caio-core)
- [x] Create `scripts/licensing/generate_keypair.sh`. (Moved to `caio-core`)

### 21.2: Generator and Validator
- [x] **generator.py:** RSA private key signing. (caio-core)
- [x] **validator.py:** RSA public key verification. (caio-core)

### 21.3: Config and Embedding
- [x] **config:** Remove `CAIO_LICENSE_SECRET`; add `CAIO_LICENSE_PUBLIC_KEY`. (caio-core)

### 21.4: Generation Service and CLI
- [x] **CLI:** Update `manage_licenses.py`. (caio-core)

### 21.5: Distribution Control
- [x] Add `deploy/customer/docker-compose.yml`. (CAIO)
- [x] Add `scripts/release/push_to_registry.sh`. (Moved to `caio-core`)

### 21.6: Docs and Runbooks
- [x] **LICENSE_MANAGEMENT.md:** Update for asymmetric model. (CAIO)
- [x] **ON_PREMISES_DEPLOYMENT.md:** Update env vars. (CAIO)
- [x] **Runbook:** Key rotation. (CAIO)

---

## Validation

- Unit tests: generator produces `v2` keys; validator accepts valid `v2` and rejects tampered/invalid.
- Integration: activate and validate via existing APIs with `v2` keys; revoke and expiry behavior unchanged.
- Snapshot: no `CAIO_LICENSE_SECRET` or private key in `caio/` or customer docs; `CAIO_LICENSE_PUBLIC_KEY` or embedded public key used.
- `make ma-validate-quiet`; `make test`; `make lint-all`.

---

## Risks and Mitigation

| Risk | Mitigation |
|------|------------|
| `v1` customers in production | Support `v1` in validator for a documented period; `generate` only `v2`; set sunset date. |
| Private key compromise | Runbook: revoke, rotate keypair, re-issue; document HSM or vault for production. |
| Regressions in 17/18 | Reuse existing activation/validation tests; add `v2` cases; keep DB/API contracts. |

---

## References

- **North Star:** `docs/NORTH_STAR.md` (§3.2.1, §2.3, INV-CAIO-SEC-0006)
- **Execution Plan:** `docs/operations/execution_plan.md` (Phase 17, 18)
- **License Management:** `docs/licensing/LICENSE_MANAGEMENT.md`
- **On‑Premises:** `docs/deployment/ON_PREMISES_DEPLOYMENT.md`, `docs/deployment/LICENSE_ACTIVATION.md`
- **MA Process:** `docs/operations/MA_PROCESS_MANDATORY_RULE.md` (if new invariants/artifacts; else implementation-only)

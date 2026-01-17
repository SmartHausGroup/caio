# Plan: Phase 21 — Licensing Security & Distribution Control

**Plan ID:** `phase-21-licensing-security-distribution`
**Status:** In Progress
**Date:** 2026-01-17
**Owner:** @smarthaus
**Execution Plan Reference:** `plan:EXECUTION_PLAN:21`
**North Star Alignment:** `docs/NORTH_STAR.md` — §3.2.1 Embedded Governance (Local Licensing), §2.3 Security as Mathematical Invariants, INV-CAIO-SEC-0006 Data Integrity. Strengthens licensing to meet enterprise control: asymmetric signing so customers cannot forge keys; distribution control so only licensed customers can download.

---

## Objective

Upgrade CAIO licensing from HMAC (symmetric) to asymmetric (RSA/Ed25519) so the **private key stays only with you** and the **public key is embedded in builds**. Add distribution control so customers download only via a private registry/token you control. Result: you control both **who can download** and **who can run** via license keys.

**MA / Security:** Aligns with INV-CAIO-SEC-0006 (Data Integrity: `VerifySignature(result)`). License verification becomes a formal signature check; generation remains out-of-band.

---

## Scope

### 21.1 Asymmetric License Cryptography

- **Generator (you):** Sign license payload (customer_id, expires_at, features, limits) with **private key**; never ship private key.
- **Validator (customer build):** Embed or load **public key**; verify signature. No secret in shipped software.
- **Key custody:** Private key on operator/admin machine or HSM only; public key in repo or bundled in release.

### 21.2 Validator and Generator Refactor

- **caio/licensing/generator.py:** Replace HMAC with RSA or Ed25519 signing. Input: `private_key_pem` (or path). Output: `{payload_b64}.{signature_b64}` (or equivalent).
- **caio/licensing/validator.py:** Replace `secret_key` with `public_key_pem`. Verify signature; reject if invalid.
- **Backward compatibility:** Optional. Plan: new `v2` license format; `v1` (HMAC) can be deprecated or supported during transition.

### 21.3 Configuration and Key Embedding

- **Config:** Remove `CAIO_LICENSE_SECRET` from customer-facing config. Add `CAIO_LICENSE_KEY` (the license string). For validator: `CAIO_LICENSE_PUBLIC_KEY` (path or PEM) or embed default public key in build.
- **Key generation:** Document `openssl genrsa -out private.pem 2048` and `openssl rsa -in private.pem -pubout -out public.pem` (or Ed25519 equivalent). Add `scripts/licensing/generate_keypair.sh` (or similar) for operators.

### 21.4 Distribution Control

- **Private registry:** Document/code for pulling Docker image from a private registry (e.g. GHCR, ECR, Docker Hub private). Customer gets a **registry token** (read-only) to `docker pull`.
- **Artifacts:** `deploy/customer/docker-compose.yml` (or equivalent) that uses `image: <private-registry>/caio:<tag>`. Optional: `scripts/distribute.sh` for your internal push-to-registry workflow.
- **Wheel:** If you ship wheel to enterprises, document delivery via secure channel (e.g. S3 pre-signed, private PyPI, or direct transfer). No change to wheel content; only to how it's obtained.

### 21.5 Generation Service, CLI, and DB

- **caio/licensing/generation_service.py:** Accept `private_key_pem` (or path) instead of `secret_key`. Use new generator.
- **caio/licensing/database.py:** No schema change for license payload; `license_key` column stores the new `v2` format.
- **CLI (`scripts/licensing/manage_licenses.py` or equivalent):** `CAIO_LICENSE_PRIVATE_KEY` or `--private-key`. Generate `v2` keys. Optional: `generate-v2` subcommand during migration.
- **Distribution/delivery:** Keep SMTP/email or secure handoff for sending the license key to the customer; no change to the "send key" flow, only to the key format.

### 21.6 Documentation and Runbooks

- **docs/licensing/LICENSE_MANAGEMENT.md:** Asymmetric model, key generation, `CAIO_LICENSE_PUBLIC_KEY`, `CAIO_LICENSE_KEY`, and deprecation of `CAIO_LICENSE_SECRET`.
- **docs/deployment/ON_PREMISES_DEPLOYMENT.md** and **docs/deployment/LICENSE_ACTIVATION.md:** Update for public key and `v2` license.
- **docs/operations/runbooks/:** Runbook for key rotation (new keypair, re-issue licenses, rotate public key in builds).

---

## Requirements

### Prerequisites

- Phase 17 (On-Premises Licensing Model) and Phase 18 (License Management System) complete.
- Access to `caio-core/caio/licensing/*` and `CAIO/docs`.
- `cryptography` (or equivalent) available in the CAIO runtime and CLI env.

### Dependencies

- Phase 17, 18 done.
- 21.1 and 21.2 can be done in one MR; 21.3–21.6 depend on 21.2.

### Success Criteria

- [ ] Generator signs with private key; validator verifies with public key only.
- [ ] No HMAC secret or private key in any customer-facing artifact or config.
- [ ] Existing activation/validation APIs and CLI work with `v2` keys; `v1` handling documented (supported or deprecated).
- [ ] Key generation and rotation documented; runbook exists.
- [ ] Distribution: customer path for Docker (and optionally wheel) documented; `deploy/customer` (or equivalent) uses private registry.
- [ ] `make ma-validate-quiet` and relevant tests pass; no regressions in Phase 17/18 behavior for `v2` keys.

---

## Detailed Tasks

### 21.1: Asymmetric Crypto and Keypair

- [ ] Add `cryptography` to `pyproject.toml` (or requirements) for CAIO and CLI.
- [ ] Create `scripts/licensing/generate_keypair.sh` (or .py): outputs `private.pem`, `public.pem`; document in `docs/licensing/`.
- [ ] Document: private key only on operator machine; never commit; public key in repo or build.

### 21.2: Generator and Validator

- [ ] **generator.py:** `LicenseKeyGenerator(private_key_pem)`. `generate_license_key(metadata)` → `CAIO-v2-{customer_id}-{payload_b64}.{signature_b64}`. Sign `payload_json` with private key (RSA PKCS#1 v1.5 or Ed25519).
- [ ] **validator.py:** `LicenseValidator(public_key_pem)`. Parse `v2` format; verify signature with public key; on failure return `(False, error)`. `load_license` / `validate_license_key` unchanged in contract.
- [ ] **schema.py:** Reuse `LicenseMetadata`; no change. Optionally add `version` to payload for `v2`.

### 21.3: Config and Embedding

- [ ] **config / env:** Remove `CAIO_LICENSE_SECRET` from customer docs. Add `CAIO_LICENSE_KEY`, `CAIO_LICENSE_PUBLIC_KEY` (or embed). Update `caio/config.py` (or equivalent) to pass `public_key_pem` into `LicenseValidator`.
- [ ] **Embed:** In built Docker/wheel, either bundle default `public.pem` or read from `CAIO_LICENSE_PUBLIC_KEY`. Document override.

### 21.4: Generation Service and CLI

- [ ] **generation_service.py:** Constructor takes `private_key_pem` (or path). Use `LicenseKeyGenerator(private_key_pem)`. Persist `license_key` in `v2` form.
- [ ] **distribution.py:** No crypto change; keep `distribute_license` and email flow. Keys are now `v2`.
- [ ] **manage_licenses.py (or equivalent):** `CAIO_LICENSE_PRIVATE_KEY` / `--private-key`. `generate-license` emits `v2`. Optional: `--format v1` for a transition period.

### 21.5: Distribution Control

- [ ] Add `deploy/customer/docker-compose.yml` (or similar) with `image: <registry>/caio:<tag>` and instructions for `docker login` with a token.
- [ ] Add `scripts/release/push_to_registry.sh` (or equivalent) for your internal push; document in `docs/deployment/` or `docs/licensing/`.
- [ ] Document: customer receives (1) registry token, (2) license key. Download = `docker pull`; run = `CAIO_LICENSE_KEY=...`.

### 21.6: Docs and Runbooks

- [ ] **LICENSE_MANAGEMENT.md:** Asymmetric model, `v2` format, `CAIO_LICENSE_PUBLIC_KEY`, `CAIO_LICENSE_KEY`, key generation, and `CAIO_LICENSE_SECRET` deprecation.
- [ ] **ON_PREMISES_DEPLOYMENT.md**, **LICENSE_ACTIVATION.md:** Public key, `v2`, and new env vars.
- [ ] **Runbook:** Key rotation (generate new pair, re-issue, deploy new public key, timeline for `v1` sunset if applicable).

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

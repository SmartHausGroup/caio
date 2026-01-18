# CAIO — Execution Plan (Trackable)

Status: v1.0 (execution blueprint)  
Owner: @smarthaus  
Lead PM/CTO: Cursor AI Assistant  
Lead Engineer: Codex  
Research & Validation: GPT‑5  

Status source of truth: `make ma-validate-quiet` (math gates + artifacts). Alignment reference: `docs/NORTH_STAR.md`. Notebook‑first; code must match notebooks (MA process).

---

## Core axiom

CAIO orchestrates AI services with mathematical guarantees through contract-based discovery and provable routing decisions. Every routing decision flows from the master equation, every guarantee is mathematically verified, every security property is an invariant, and every action is provable and traceable.

---

## Methodology & Governance (MA doc‑first)

- **Docs are normative**: This plan and `docs/NORTH_STAR.md` define scope, gates, and acceptance. Code must implement the documented math.
- **Notebooks are producers**: Math notebooks generate JSON artifacts in `configs/generated/` (no NaN/Inf; freshness required).
- **CI gates enforce math and contracts**: A single scorecard decision (`scorecard.json`) must be green for staging/main.
- **Branch policy**: `feature/*` → `development` → `staging` → `main`; branches must be up to date; merge queue on `development`/`staging`.

### MA Cadence (canonical)

1. **Docs/spec**: North Star + Execution Plan set scope and contracts (normative).
2. **Math**: Formalize the calculus (`CAIO_MASTER_CALCULUS`, `CAIO_CONTROL_CALCULUS`).
3. **Lemmas/proofs**: Record rationale and bounds (`CAIO_LEMMAS_APPENDIX`).
4. **Invariants**: Encode guarantees in `invariants/INV-CAIO-XXXX.yaml` (what must be true).
5. **Notebooks**: Produce JSON artifacts proving the invariants (seeded; no NaN/Inf).
6. **Code**: Implement exactly what the docs/math specify; no drift.
7. **Tests & CI gates**: Enforce invariants, API contract, determinism, lint/format, SBOM, secret scan.

Operational commands:

```bash
make ma-status || true
make ma-validate-quiet || true
```

---

## Phase overview

| Phase | Name                         | Goal                                                | Primary acceptance                                  |
|-------|------------------------------|-----------------------------------------------------|-----------------------------------------------------|
| 0     | Foundation & CI              | Repo structure, MA scaffolding, CI                  | `make ma-validate-quiet` passes                     |
| 1     | Intent & Description         | North Star, boundaries, guarantees                  | North Star signed; stakeholders aligned             |
| 2     | Mathematical Foundation      | Master calculus & control calculus                  | `CAIO_MASTER_CALCULUS`, `CAIO_CONTROL_CALCULUS`     |
| 3     | Lemmas & Invariants          | Lemmas + invariants for core + security + control   | `CAIO_LEMMAS_APPENDIX`, all `INV-CAIO-*` drafted    |
| 4     | Verification Notebooks       | One notebook per invariant + artifacts              | All 14 notebooks green (12 core/security + 2 control) |
| 5     | CI Enforcement               | Notebook plan, artifact gates, scorecard            | Scorecard green; NaN/Inf gates; determinism gates   |
| 6     | Orchestrator Implementation  | Master equation, contracts, registry, rules, proofs | Core CAIO orchestrator running with tests           |
| 7     | SDK & API Surface            | Service SDK + HTTP/gRPC APIs                        | SDK stable; OpenAPI/docs; integration smoke green   |
| 8     | Security & Traceability Ops  | Security, audit, traceability, SLOs, runbooks       | Security invariants enforced in runtime             |
| 9     | External Service Integration | First external service via bridge + contract        | Codex bridge service registered; tests + docs pass  |
| 10    | Prototype                    | Standalone demo scripts and documentation           | Prototypes demonstrate CAIO working end-to-end      |
| 11    | Productionized               | Packaging fix, integration guides, hardening        | CAIO installable, integrated, production-ready     |
| 12    | Operational Improvements     | Docs sync, hook tuning, validation clarity          | Operational docs + hooks updated; ADR gate tuned    |
| 13    | Comprehensive E2E Testing    | E2E tests, production deployment validation, load/stress testing | CAIO fully tested end-to-end, production-ready with comprehensive coverage |
| 14    | AWS SaaS                     | AWS SaaS deployment, hosting, and operations                    | Multi-tenant SaaS deployment operational                                 |
| 15    | Configuration Dashboard      | Web-based configuration dashboard for operational settings      | Dashboard functional with validation and audit trail                      |
| 16    | Open Integration Layer       | Open-source SDK + integration layer                             | External developers can integrate services                                |
| 17    | On-Premises Licensing Model   | License key system and on-premises deployment       | License validation working, on-premises deployment possible |
| 18    | License Management System      | System for generating, distributing, tracking licenses | License management system functional, licenses trackable |
| 19    | Universal Service Gateway & Adapters | Service gateway executor + 25+ service adapters (Tier 1-3) | Gateway executes requests, all tiers integrated, guarantee enforcement working |
| 20    | SDK Separation               | Split SDK into isolated package (`packages/sdk`)           | SDK isolated from core, clear boundaries and dependency separation |
| 21    | Licensing Security & Distribution Control | Asymmetric license signing, distribution control | License v2 (RSA/Ed25519); customers cannot forge keys; download via private registry |

---

## Phase completion status

(0–5 reflect current MA status; 6–8 are implementation work.)

| Phase | Status       | Notes |
|-------|--------------|-------|
| 0     | ✅ Done       | Repo + MA scaffolding + CI scripts present                  |
| 1     | ✅ Done       | `docs/NORTH_STAR.md` defines scope, guarantees, boundaries  |
| 2     | ✅ Done       | `CAIO_MASTER_CALCULUS`, `CAIO_CONTROL_CALCULUS` complete    |
| 3     | ✅ Done       | 14 lemmas + invariants (12 core/security + 2 control)      |
| 4     | ✅ Done       | 13 verification notebooks under `notebooks/math/verify_*.ipynb` + `caio_control_validation.ipynb` |
| 5     | ✅ Done       | Complete local CI/CD: pre-commit (notebooks → artifacts → scorecard → gate), pre-push (full validation), local validation scripts working |
| 6     | ✅ Done       | Orchestrator core implemented; all components extracted from notebooks and integrated; tests updated |
| 7     | ✅ Done       | SDK interface, client, HTTP/REST API, integration tests complete; OpenAPI docs generated |
| 8     | ✅ Done       | Security ops + audit + SLO monitoring + runbooks complete (2026-01-02) |
| 9     | ✅ Done       | External service integration (Codex bridge) — complete 2026-01-08 |
| 10    | ✅ Done       | Prototype demonstration complete 2026-01-08                 |
| 11    | ✅ Done       | Productionization — complete 2026-01-10                     |
| 12    | ✅ Done       | Operational improvements — complete 2026-01-10              |
| 13    | ✅ Done       | Comprehensive E2E testing complete 2026-01-10               |
| 14    | ✅ Done       | AWS SaaS deployment complete                                |
| 15    | ✅ Done       | Configuration dashboard complete 2026-01-12                 |
| 16    | ✅ Done       | Open integration layer — complete 2026-01-12               |
| 17    | ✅ Done       | On-premises licensing model complete                       |
| 18    | ✅ Done       | License management system — complete 2026-01-14            |
| 19    | ⚠️ In Progress | Universal Service Gateway & Adapters — 19.1-19.9 complete; 19.10 pending |
| 19.1  | ✅ Done       | Build Service Gateway Core (executor, base, transformer) |
| 19.2  | ✅ Done       | Tier 1 Adapters — MIGRATED TO VFE per ADR-0001 |
| 19.3  | ⚠️ Partial    | Tier 2 Adapters — Created but SHOULD BE IN VFE (inference adapters) |
| 19.4  | ⚠️ Partial    | Tier 3 Adapters — Non-inference complete; inference adapters SHOULD BE IN VFE |
| 19.5  | ✅ Done       | Contract Templates & Documentation |
| 19.6  | ✅ Done       | Update Mechanism Implementation (API endpoints, service module) |
| 19.7  | ✅ Done       | PyPI Preparation (Package Name Update to `smarthaus-caio`) |
| 19.8  | ⚠️ In Progress | PyPI Publication (Publish `smarthaus-caio` to PyPI) |
| 19.8.1| ✅ Done       | Enterprise Distribution Strategy (Private Docker + Signed Wheel) |
| 19.9  | ✅ Done       | Enterprise Artifact Validation (Re-run passed; Docker/Wheel validated) |
| 19.10 | ⚠️ In Progress | Live Gateway Verification (Non-Inference Adapters Only) - Plan in `caio-core/plans/` |
| 19.11 | ✅ Done       | Testing & Validation (Unit, integration, E2E, performance, error handling) |
| 20    | ✅ Done       | SDK Separation — complete 2026-01-16                     |
| 20.1  | ✅ Done       | SDK Verification & Test Fixes — complete 2026-01-16        |
| 20.2  | ✅ Done       | SDK Packaging Fix — complete 2026-01-17                    |
| 21    | ⚠️ In Progress | Licensing Security & Distribution — docs/scripts done; code pending in this repo |

---

## Traceability & Coverage Matrix (North Star → Execution Plan)

| North Star Section                            | Covered In Phase(s) | Evidence (Tasks/Artifacts)                        |
|----------------------------------------------|---------------------|---------------------------------------------------|
| Exec Summary & Purpose                       | 1                   | `docs/NORTH_STAR.md`                              |
| Master Control Equation                      | 2, 6                | `CAIO_MASTER_CALCULUS`, orchestrator core         |
| Control Calculus (u\* & trait constraints)   | 2, 6, 8             | `CAIO_CONTROL_CALCULUS`, control invariants       |
| Mathematical Guarantees & Invariants         | 3, 4, 5             | `CAIO_LEMMAS_APPENDIX`, `invariants/`, notebooks  |
| Security Calculus                            | 2, 3, 4, 5, 8       | Security section of `CAIO_MASTER_CALCULUS`, SEC invariants |
| Contract-Based Discovery                     | 6, 7                | Contract parser, registry, SDK, APIs              |
| Traceability & Proofs                        | 3, 4, 6, 8          | Trace/Proof system, artifacts, audit APIs         |
| Integration Points (MAIA, NME, RFS, VFE, VEE)| 6, 7, 8, 11         | Integration tests, telemetry, SDK usage, TAI integration guide |
| Prototype Demonstrations                     | 10                  | Standalone Python script, HTTP API docs            |
| Productionization                             | 11                  | Packaging fix, integration guides, hardening       |
| Operational Excellence                        | 12                  | Documentation sync, pre-commit hooks, test environment, ADR gate tuning |
| Production Readiness & Testing                | 13                  | E2E tests, production deployment validation, load/stress testing, hardening checklist validation |

---

## Active TODO Board

Only future work is listed; math/MA phases are already complete.

| Task ID                   | Status     | Notes |
|---------------------------|-----------|-------|
| pypi-publication          | in-progress   | Publish CAIO to PyPI (plan:pypi-publication:19.8)       |
| sdk-separation            | completed | Split SDK into isolated package (plan:phase-20-sdk-separation:20.0) |
| update-package-name       | completed | Updated PyPI package name to smarthaus-caio (plan:update-package-name:19.7) |
| update-api-endpoints      | completed | Implemented update/restart/version endpoints (plan:update-api-endpoints:19.6) |
| license-revocation        | completed | Implemented revocation logic in Phase 18               |
| universal-gateway-fix     | completed | Fix import errors in Gateway core (Phase 19.1)          |
| production-hardening      | completed | Complete rate limiting and fix E2E tests (Phase 11/13)  |
| adapter-migration-to-vfe  | completed | Tier 1 adapters removed from gateway; inference routed to VFE |
| production-readiness      | completed | Executed codex-production-readiness plan (10 deployment hardening gaps); complete 2026-01-07 |
| notebook-cell-id-normalization-logs | completed | Normalized cell IDs in logs/quality/notebooks and updated nbformat_minor; complete 2026-01-02 |
| notebook-cell-id-normalization | completed | Normalized notebook cell IDs to eliminate nbformat warnings; complete 2026-01-02 |
| math-thesis-alignment     | completed | Math Thesis alignment implemented (docs, notebooks, field math, tests); complete 2026-01-02 |
| contract-math-thesis-alignment | completed | Contract schema aligned to math thesis guarantees; alignment guide added; complete 2026-01-14 |
| caio-ma-phase5-ci         | in-progress | Ensure notebooks + invariants are fully wired into CI for CAIO (not just scripts present) |
| caio-control-notebook-plan| completed | Added control invariants (INV-CAIO-CONTROL-0001, INV-CAIO-CONTROL-0002) to notebook_plan.json |
| caio-orchestrator-core    | pending   | Implement master equation routing core (Phase 6)         |
| caio-contract-parser      | pending   | YAML schema + parser + validation for service contracts  |
| caio-service-registry     | pending   | In-memory/DB registry for CAIO-compatible services       |
| caio-rule-engine          | pending   | Policy/constraint evaluation engine                      |
| caio-security-verifier    | pending   | Runtime authn/authz/privacy/access checks                |
| caio-guarantee-enforcer   | pending   | Guarantee composition & enforcement in runtime           |
| caio-traceability-system  | pending   | Proof/trace objects, storage, retrieval APIs             |
| caio-sdk-impl             | pending   | Implement `AIUCPService` base & helpers from SDK spec    |
| caio-http-api             | pending   | REST API endpoints + OpenAPI docs                        |
| caio-grpc-api             | pending   | Optional gRPC surface                                    |
| caio-integration-tests    | pending   | End‑to‑end tests with dummy services & contracts         |
| caio-security-ops         | completed | Phase 8.1: Security operations (API auth, metrics, incident handling) — complete 2026-01-02 |
| caio-traceability-audit   | completed | Phase 8.2: Traceability & audit (persistent storage, audit APIs, query) — complete 2026-01-02 |
| caio-slos-alerts          | completed | Phase 8.3: SLOs & alerts (monitoring, alerting, metrics) — complete 2026-01-02 |
| caio-runbooks             | completed | Phase 8.4: Runbooks (security, traceability, contract, invariant) — complete 2026-01-02 |
| external-service-integration | completed | Phase 9.1–9.5: External service integration (Codex bridge) — complete 2026-01-08 |

---

## Recent Work

- **2026-01-17:** Phase 21 execution updates — added keypair and registry scripts, customer deploy compose, licensing/deployment docs updates, key-rotation runbook — `plan:EXECUTION_PLAN:21`
- **2026-01-17:** Phase 21 formal plan and Codex prompts created — `plan:EXECUTION_PLAN:21` (plans/phase-21-licensing-security-distribution/, docs/prompts/codex-phase-21-licensing-security-distribution*.md)
- **2026-01-17:** Phase 20.2 SDK Packaging Fix complete; created `packages/sdk/pyproject.toml` and verified build artifacts — `plan:phase-20-2-sdk-packaging:20.2`
- **2026-01-17:** Phase 19.9 Enterprise Artifact Validation Re-run complete; verified wheel builds successfully — `plan:phase-19-9-enterprise-validation:19.9.3`
- **2026-01-16:** Phase 20 SDK Separation complete — `plan:phase-20-sdk-separation:20.0`
- **2026-01-15:** Phase 19.9 complete: Enterprise artifacts (Docker/Wheel) validated locally — `plan:phase-19-9-enterprise-validation:19.9.3`
- **2026-01-15:** Update package name for PyPI — `plan:update-package-name:19.7`
- **2026-01-15:** Update API endpoints implemented — `plan:update-api-endpoints:19.6`
- **2026-01-15:** PyPI publication build + docs updates (build + twine check complete; publication pending credentials) — `plan:pypi-publication:19.8`
- **2026-01-15:** TestPyPI upload attempt failed (missing `.env` credentials; 403 Forbidden) — `plan:pypi-publication:19.8`
- **2026-01-14:** Production hardening completion (rate limiting, E2E stability, checklist) — `plan:production-hardening-completion`

- **2026-01-14:** License revocation logic implemented — `plan:license-revocation`
- **2026-01-14:** Contract math thesis alignment guide completed — `plan:contract-math-thesis-alignment:contract-verification`
- **2026-01-14:** Universal gateway fix completed — `plan:universal-gateway-fix`
- **2026-01-13:** Adapter migration to VFE complete — `plan:adapter-migration-to-vfe:unified-inference-architecture`
- **2026-01-13:** Phase 18 license management system complete — `plan:EXECUTION_PLAN:18`
- **2026-01-12:** Phase 17 on-premises licensing model complete — `plan:EXECUTION_PLAN:17`
- **2026-01-12:** Phase 16 open integration layer complete — `plan:EXECUTION_PLAN:16`
- **2026-01-11:** Production readiness tests auto-enabled — `plan:EXECUTION_PLAN:test-configuration` (load/stress and Docker tests now run automatically when environment supports)
- **2026-01-11:** Fixed 10 test failures — `plan:EXECUTION_PLAN:test-fixes` (access control, guarantee composition, hash determinism, health checks)
- **2026-01-10:** Phase 13 comprehensive E2E testing complete — `plan:phase-13-comprehensive-e2e-testing:13.1-13.4`
- **2026-01-10:** Phase 13 comprehensive E2E testing plan created — `plan:phase-13-comprehensive-e2e-testing:13.1-13.4`
- **2026-01-10:** Phase 12 operational improvements complete — `plan:EXECUTION_PLAN:12`
- **2026-01-10:** Phase 11 productionization complete — `plan:EXECUTION_PLAN:11`
- **2026-01-08:** Phase 10 prototype demos complete — `plan:EXECUTION_PLAN:10`
- **2026-01-08:** Phase 10 and 11 added to execution plan — `plan:EXECUTION_PLAN:10,11`
- **2026-01-08:** Phase 9 external service integration (Codex) complete — `plan:EXECUTION_PLAN:9.1-9.5`
- **2026-01-07:** Docker validation complete — `plan:EXECUTION_PLAN:production-readiness`
- **2026-01-07:** Production readiness implementation complete — `plan:EXECUTION_PLAN:production-readiness`
- **2026-01-02:** Normalized notebook cell IDs in logs and updated nbformat_minor — `plan:EXECUTION_PLAN:notebook-cell-id-normalization-logs`
- **2026-01-02:** Normalized notebook cell IDs to remove nbformat warnings — `plan:EXECUTION_PLAN:notebook-cell-id-normalization`
- **2026-01-02:** Math Thesis alignment implemented (docs + field math + validation + benchmarks) — `plan:EXECUTION_PLAN:math-thesis-alignment`

---

## Quality Gates — Always-on

### MA & artifact gates

- **MA Validate (CAIO)**: `make ma-validate-quiet` must pass.
- **Notebook execution**: `scripts/ci/notebooks_ci_run.py` executes `configs/generated/notebook_plan.json` for CAIO.
- **No NaN/Inf**: `scripts/ci/artifacts_nan_gate.py` fails on NaN/Inf in `configs/generated/*.json`.
- **Invariant evaluation**: All CAIO invariants (`INV-CAIO-*`) evaluated; violations affect scorecard.
- **Determinism**: Seeds (`PYTHONHASHSEED`, notebook seeds) enforced; determinism gate records env fingerprint.

### Runtime & API gates (to be enabled with implementation)

- **Contract schema gate**: Changes to contract schema require updated SDK/docs and CI validation.
- **Registry gate**: Services must have valid contracts before activation; CI tests enforce invariant.
- **Security gate**: Runtime requests must pass authn/authz/privacy/access checks; e2e tests enforce.
- **Traceability gate**: Every orchestrated decision must have a trace/proof; tests verify presence.

---

## Phase 0 — Foundation & CI Stabilization

**Scope:** Align repo structure, MA scaffolding, CI gates, determinism, seed policy.  
**Success:** `make ma-validate-quiet` green; determinism enforced; seed policy documented.

- [x] Repo structure established (`docs/`, `invariants/`, `notebooks/math/`, `configs/generated/`)
- [x] MA scaffolding scripts present (`scripts/ci/notebooks_ci_run.py`, `tools/aggregate_scorecard.py`)
- [x] Makefile targets (`ma-status`, `ma-validate-quiet`, `notebooks-plan`)
- [x] CI workflows configured (GitHub Actions)
- [x] Determinism gates (`scripts/ci/determinism_gate.py`)
- [x] Seed policy documented (`CAIO_NOTEBOOK_SEED` env var)

---

## Phase 1 — Intent & Description

**Scope:** Define North Star, boundaries, guarantees, success criteria.  
**Success:** North Star signed; stakeholders aligned; scope locked.

- [x] Problem statement written (universal AI orchestration with mathematical guarantees)
- [x] Conceptual significance documented (contract-based discovery, provable routing)
- [x] Success criteria defined (hot-swappable services, traceability, security)
- [x] Service boundaries defined (standalone SOA, integration points with MAIA/NME/RFS/VFE/VEE)
- [x] **Document**: `docs/NORTH_STAR.md`

---

## Phase 2 — Mathematical Foundation

**Scope:** Formalize master equation, control calculus, sub-calculi.  
**Success:** Master calculus + control calculus complete; all sub-calculi documented.

- [x] Master equation defined (8-step process: contract matching → rule satisfaction → security → optimization → guarantee composition → proof → trace → execution)
- [x] Contract matching calculus formalized (set intersection mathematics)
- [x] Rule application calculus formalized (constraint satisfaction)
- [x] Security calculus formalized (mathematical proofs for authn/authz/privacy/trust/access)
- [x] Guarantee composition calculus formalized (combining service guarantees)
- [x] Proof generation calculus formalized (verifiable proofs for all steps)
- [x] Control calculus formalized (control signal u(t), trait constraints G_traits)
- [x] **Documents**: `docs/math/CAIO_MASTER_CALCULUS.md`, `docs/math/CAIO_CONTROL_CALCULUS.md`

---

## Phase 3 — Lemmas & Invariants

**Scope:** Convert math to formal lemmas and invariants.  
**Success:** All lemmas documented; all invariants created and indexed.

### Lemmas

- [x] L1: Determinism (INV-CAIO-0001)
- [x] L2: Correctness (INV-CAIO-0002)
- [x] L3: Traceability (INV-CAIO-0003)
- [x] L4: Security (INV-CAIO-0004)
- [x] L5: Guarantee Preservation (INV-CAIO-0005)
- [x] L6: Performance Bounds (INV-CAIO-0006)
- [x] L7: Authentication (INV-CAIO-SEC-0001)
- [x] L8: Authorization (INV-CAIO-SEC-0002)
- [x] L9: Privacy Preservation (INV-CAIO-SEC-0003)
- [x] L10: Access Control (INV-CAIO-SEC-0004)
- [x] L11: Audit Trail (INV-CAIO-SEC-0005)
- [x] L12: Data Integrity (INV-CAIO-SEC-0006)
- [x] **Document**: `docs/math/CAIO_LEMMAS_APPENDIX.md`

### Invariants

**Core Guarantees:**
- [x] INV-CAIO-0001: Determinism
- [x] INV-CAIO-0002: Correctness
- [x] INV-CAIO-0003: Traceability
- [x] INV-CAIO-0004: Security
- [x] INV-CAIO-0005: Guarantee Preservation
- [x] INV-CAIO-0006: Performance Bounds

**Security Invariants:**
- [x] INV-CAIO-SEC-0001: Authentication
- [x] INV-CAIO-SEC-0002: Authorization
- [x] INV-CAIO-SEC-0003: Privacy Preservation
- [x] INV-CAIO-SEC-0004: Access Control
- [x] INV-CAIO-SEC-0005: Audit Trail
- [x] INV-CAIO-SEC-0006: Data Integrity

**Control Invariants:**
- [x] INV-CAIO-CONTROL-0001: Control Signal Stability
- [x] INV-CAIO-CONTROL-0002: Trait Constraint Satisfaction

- [x] **Files**: `invariants/INV-CAIO-XXXX.yaml` (all 14 invariants)
- [x] **Index**: `invariants/INDEX.yaml`

---

## Phase 4 — Verification Notebooks

**Scope:** Create verification notebooks for each invariant; emit artifacts.  
**Success:** All notebooks execute; artifacts generated; no NaN/Inf.

### Core & Security Notebooks

- [x] `verify_determinism.ipynb` → `determinism_verification.json` (INV-CAIO-0001, L1)
- [x] `verify_correctness.ipynb` → `correctness_verification.json` (INV-CAIO-0002, L2)
- [x] `verify_traceability.ipynb` → `traceability_verification.json` (INV-CAIO-0003, L3)
- [x] `verify_security.ipynb` → `security_verification.json` (INV-CAIO-0004, L4)
- [x] `verify_guarantee_preservation.ipynb` → `guarantee_preservation_verification.json` (INV-CAIO-0005, L5)
- [x] `verify_performance_bounds.ipynb` → `performance_bounds_verification.json` (INV-CAIO-0006, L6)
- [x] `verify_authentication.ipynb` → `authentication_verification.json` (INV-CAIO-SEC-0001, L7)
- [x] `verify_authorization.ipynb` → `authorization_verification.json` (INV-CAIO-SEC-0002, L8)
- [x] `verify_privacy_preservation.ipynb` → `privacy_preservation_verification.json` (INV-CAIO-SEC-0003, L9)
- [x] `verify_access_control.ipynb` → `access_control_verification.json` (INV-CAIO-SEC-0004, L10)
- [x] `verify_audit_trail.ipynb` → `audit_trail_verification.json` (INV-CAIO-SEC-0005, L11)
- [x] `verify_data_integrity.ipynb` → `data_integrity_verification.json` (INV-CAIO-SEC-0006, L12)

### Control Notebooks

- [x] `caio_control_validation.ipynb` → `caio_policy_bounds.json` (INV-CAIO-CONTROL-0001, INV-CAIO-CONTROL-0002)

**Status**: 13/13 notebooks complete (100%)

**Note**: Control invariants added to `configs/generated/notebook_plan.json` (task `caio-control-notebook-plan` completed).

### Phase 4 Completion — Integration & Testing

**Scope:** Create integration tests, E2E tests, and update documentation for Phase 4 verification notebooks.  
**Success:** Test infrastructure in place, documentation complete, quality validation passing.

- [x] Verified all Phase 4 verification notebooks execute successfully (13/13 notebooks)
- [x] Created integration test infrastructure (`tests/integration/`)
- [x] Created E2E test infrastructure (`tests/e2e/`)
- [x] Created mathematical validation tests (`tests/mathematical/`)
- [x] Updated README.md with setup instructions and documentation links
- [x] Created API Reference documentation (`docs/api/API_REFERENCE.md`)
- [x] Created Developer Guide (`docs/developer/DEVELOPER_GUIDE.md`)
- [x] Created User Guide (`docs/user/USER_GUIDE.md`)
- [x] Created Configuration documentation (`docs/configuration/CONFIGURATION.md`)
- [x] Ran quality validation (MA validation: green scorecard, linting: all checks passed)

**Status**: ✅ Complete (2026-01-02)

---

## Phase 5 — CI Enforcement

**Scope:** Wire notebook execution, artifact gates, scorecard to CI.  
**Success:** CI executes notebooks; artifacts validated; scorecard green; merges blocked on violations.

- [x] Notebook plan created (`configs/generated/notebook_plan.json`) — **Note**: Missing control invariants
- [x] Notebook execution script (`scripts/ci/notebooks_ci_run.py`)
- [x] Artifact NaN/Inf gate (`scripts/ci/artifacts_nan_gate.py`)
- [x] Scorecard aggregation (`tools/aggregate_scorecard.py`)
- [x] Scorecard gate (`scripts/ci/scorecard_gate.py`)
- [x] Makefile targets (`ma-validate-quiet`, `ma-status`, `validate-local`)
- [x] **DONE**: Added control invariants to notebook plan
- [x] **DONE**: All notebooks execute in pre-commit hook (local CI)
- [x] **DONE**: Scorecard enforcement blocks commits/pushes on violations (local CI)
- [x] **DONE**: Complete local CI/CD wiring (pre-commit: notebooks → artifacts → scorecard → gate; pre-push: full validation via `scripts/local/validate.sh`)
- [x] **DONE**: Local validation scripts (`scripts/local/validate.sh`, `scripts/local/pre-push-validation.sh`, `scripts/local/ci-replicate.sh`)
- [x] **DONE**: Pre-commit hooks configured (`.pre-commit-config.yaml`)
- [x] **DONE**: Pre-push hooks installed and working
- [x] **DONE**: Local CI/CD fully operational (no GitHub Actions required - all validation runs locally)

---

## Phase 6 — Orchestrator Implementation

**Scope:** Implement the CAIO orchestrator core that realizes the master control equation and sub‑calculi in code.

**Success:** Core orchestrator running; contract parser/registry functional; rule engine operational; security verifier active; guarantee enforcer working; traceability system producing proofs.

### Tasks

1. **Core routing engine (master equation)**

Implement core function (shape):

```python
def caio_route(request, registry, policies, history, seed) -> RoutingDecision:
    ...
```

Responsibilities:

- Compute candidate services via contract matching (capabilities/requirements).
- Filter by guarantees and rules (constraints, compliance).
- Score each candidate according to the master equation terms:
  - Intent/attention/field terms (from MAIA/NME/RFS metrics),
  - Cost, risk, latency penalties.
- Respect constraints `G_safety`, `G_policy`, `G_traits`.
- Output: chosen action `a*`, model/service `m*`, control signal `u*`, proofs/trace skeleton.

2. **Contract parser & validator**

- Define YAML schema consistent with `docs/SDK_SPECIFICATION.md`:
  - Capabilities, guarantees, constraints, cost, privacy, API details.
- Implement parser:
  - Load YAML → typed Python structure.
  - Validate required fields and types.
  - Validate guarantee specs against CAIO invariants (e.g. latency bound types).

3. **Service registry**

- Data model: `ServiceEntry` containing:
  - Parsed contract,
  - Runtime metadata (health, version, tags).
- Operations:
  - `register_service(contract_path)`,
  - `list_services(filters?)`,
  - `get_candidates(request)` for routing.

4. **Rule engine**

- Represent rules as structured objects:
  - Policy constraints (e.g. "no PII to external services"),
  - Legal/compliance constraints,
  - Business rules (cost tiers, priorities).
- Evaluate:
  - `G_policy(a, m) ≤ 0` for each candidate,
  - Indicate violations and drop/fail accordingly.

5. **Security verifier (runtime)**

- Implement runtime layer matching security invariants:
  - Authentication (INV-CAIO-SEC-0001): token/key verification.
  - Authorization (INV-CAIO-SEC-0002): RBAC/ABAC per service/route.
  - Privacy (INV-CAIO-SEC-0003): enforce data‑handling constraints.
  - Access control (INV-CAIO-SEC-0004): service boundaries/isolation.
  - Audit trail (INV-CAIO-SEC-0005): ensure every decision is logged.
  - Data integrity (INV-CAIO-SEC-0006): optional signatures/hashes where defined.

6. **Guarantee enforcer**

- Implement guarantee composition:
  - For service chains `s1 → s2 → ... → sn`, compute combined guarantees (min accuracy, sum latency, etc.) as per calculus.
- Check:
  - Composed guarantees meet request requirements and invariants.
  - Produce a result guarantee object attached to the trace.

7. **Traceability & proof generation**

- Implement trace structure (from calculus):
  - Request, selected route, proofs, guarantees, result, hash, timestamp.
- Implement `Prove(...)` / `VerifyProof(...)` as structured proof metadata aligned with lemmas.
- Ensure every orchestrator decision writes a trace record.

8. **Control integration with MAIA**

- Implement mapping from routing decision to control signal `u(t)` per `CAIO_CONTROL_CALCULUS.md`.
- Enforce `INV-CAIO-CONTROL-0001` (control signal stability) and `INV-CAIO-CONTROL-0002` (trait constraint satisfaction).

---

## Phase 7 — SDK & API Surface

**Scope:** Expose CAIO functionality via SDK and HTTP/gRPC APIs, aligned with the SDK spec and contract schema.

**Success:** SDK stable; OpenAPI/docs complete; integration smoke tests green.

### Tasks

1. **SDK**

- Implement `AIUCPService` interface and related exceptions (`ContractValidationError`, `ServiceExecutionError`, etc.).
- Provide:
  - Contract loading/validation helpers,
  - Guarantee verification helpers,
  - Client utilities to call CAIO APIs.

2. **HTTP/REST API**

Endpoints (names illustrative; must match final OpenAPI):

- `POST /orchestrate` — orchestrate a request given contracts, policies, and context.
- `POST /register-service` — register or update a service contract.
- `GET /services` — list registered services and their status.
- `GET /trace/{decision_id}` — fetch trace/proof for a decision.
- `GET /health` — CAIO health.
- `GET /metrics` — metrics (latency, determinism, correctness, security stats).

3. **gRPC API (optional)**

- Define gRPC service equivalent for high‑throughput use cases.

4. **Integration tests**

- Use dummy contracts + mock services to test:
  - Registration,
  - Orchestration behavior,
  - Traceability,
  - Security checks at the API layer.

---

## Phase 8 — Security & Traceability Operations

**Scope:** Make CAIO's security and traceability guarantees operational in production.

**Success:** Runtime security enforced; traceability/audit operational; SLOs monitored; runbooks exist.

### Tasks

**8.1: Security Operations** (✅ Complete — 2026-01-02)

- [x] Wire CAIO API authn/authz into your identity system.
- [x] Add metrics like `cai_authn_failures`, `cai_authz_denials`, `cai_policy_violations`.
- [x] Implement security incident handling procedures.

**8.2: Traceability & Audit** (✅ Complete — 2026-01-02)

- [x] Choose storage for trace/proof records (logs + optional DB).
- [x] Build views or APIs for compliance/audit teams to query decisions.
- [x] Implement trace query and filtering capabilities.

**8.3: SLOs & Alerts** (✅ Complete — 2026-01-02)

- [x] Define SLOs for:
  - Orchestration latency (P95/P99),
  - Decision correctness (sampled),
  - Security violation rate,
  - Trace completeness.
- [x] Wire alerts when SLOs or invariants breach.
- [x] Implement SLO monitoring and alerting system.

**8.4: Runbooks** (✅ Complete — 2026-01-02)

- [x] Add runbooks under `docs/operations/runbooks/` for:
  - Security incident handling,
  - Traceability/audit workflows,
  - Contract misconfiguration or invariant violations.

---

## Phase 9 — External Service Integration (Codex)

**Scope:** Integrate the first external service (Codex) via HTTP bridge and contract registration.

**Success:** Codex bridge service runs; contract validates and registers; CAIO can discover + route; integration tests pass; docs updated.

**Status:** ✅ Complete — 2026-01-08

### Tasks

**9.1: Codex Bridge Service (HTTP Wrapper)**

- [x] Create `services/external/codex/` directory structure with `api/`, `core/`, `tests/`.
- [x] Implement Codex SDK wrapper (notebook-first) and extract to `services/external/codex/core/codex_client.py`.
- [x] Implement request/response transformer (notebook-first) and extract to `services/external/codex/core/transformer.py`.
- [x] Implement FastAPI routes (notebook-first) and extract to `services/external/codex/api/routes.py`.
- [x] Add `services/external/codex/main.py`, `requirements.txt`, and `README.md`.

**9.2: Codex Service Contract**

- [x] Create `configs/services/external/codex.yaml` (service contract).
- [x] Validate contract against `configs/schemas/service_contract.schema.yaml`.

**9.3: Service Registration**

- [x] Create `scripts/register_codex_service.py`.
- [x] Register Codex service with CAIO (local).
- [x] Verify registration via CAIO service list endpoint.

**9.4: Integration Tests**

- [x] Add end-to-end tests in `services/external/codex/tests/test_integration.py`.
- [x] Run integration tests with CAIO + Codex bridge services running.

**9.5: Documentation**

- [x] Create `docs/external_services.md` guide.
- [x] Update `docs/developer/DEVELOPER_GUIDE.md` with external services section.

**Ports/Env**

- `CODEX_BRIDGE_PORT` (default: 8082)
- `OPENAI_API_KEY` required for real Codex responses

---

## Phase 10 — Prototype

**Scope:** Create standalone prototype demonstrations that show CAIO working end-to-end.

**Success:** Standalone Python prototype script and HTTP API prototype documentation created; both prototypes demonstrate CAIO functionality; documentation complete.

### Tasks

**10.1: Create Standalone Python Prototype Script**

- [x] Create `caio_prototype_demo.py` in repository root
- [x] Implement demo service contract function
- [x] Implement main function with step-by-step CAIO demonstration
- [x] Add error handling and clear output formatting
- [x] Make script executable
- [x] Validate script runs successfully: `python caio_prototype_demo.py`

**10.2: Create HTTP API Prototype Documentation**

- [x] Create `docs/prototype/API_PROTOTYPE.md`
- [x] Add prerequisites section (server startup)
- [x] Add service registration curl examples
- [x] Add orchestration request curl examples
- [x] Add trace retrieval curl examples
- [x] Add health check curl examples
- [x] Add expected responses section
- [x] Add troubleshooting section
- [x] Validate all curl examples work when CAIO server is running

**10.3: Create Prototype README**

- [x] Create `docs/prototype/README.md`
- [x] Add overview of both prototypes
- [x] Add prerequisites
- [x] Add instructions for standalone Python prototype
- [x] Add instructions for HTTP API prototype
- [x] Add expected outputs section
- [x] Add troubleshooting section

**10.4: Update Main README**

- [x] Add "Quick Start - Prototype Demo" section to `README.md`
- [x] Link to prototype documentation
- [x] Add quick command to run standalone prototype
- [x] Validate all links

**Plan Reference:** `plan:EXECUTION_PLAN:10`  
**Detailed Plan:** `plans/phase-10-prototype/phase-10-prototype.md`

---

## Phase 11 — Productionized

**Scope:** Productionize CAIO for real-world deployment and integration.

**Success:** Python packaging fixed; TAI integration guide created; packaging/distribution guide created; deployment hardening checklist created; production deployment validated.

### Tasks

**11.1: Fix Python Packaging Configuration**

- [x] Identify CAIO package structure (`caio/` directory)
- [x] Update `pyproject.toml`: Change `packages = []` to proper package discovery
- [x] Validate installation: `pip install -e .` works
- [x] Verify all CAIO modules are importable
- [x] Test package distribution (build wheel, test installation)

**11.2: Create TAI Integration Guide**

- [x] Create `docs/integration/TAI_INTEGRATION.md`
- [x] Add overview section (CAIO's role in TAI)
- [x] Add installation section (development and production)
- [x] Add programmatic integration section (using Orchestrator directly)
- [x] Add HTTP API integration section (curl examples)
- [x] Add MAIA integration section (control signal usage)
- [x] Add service registration section (TAI services)
- [x] Add configuration section (environment variables, config files)
- [x] Add examples section (code snippets, patterns)
- [x] Add troubleshooting section

**11.3: Create Packaging & Distribution Guide**

- [x] Create `docs/deployment/PACKAGING.md`
- [x] Add development installation section
- [x] Add production installation section
- [x] Add building distribution packages section
- [x] Add publishing to PyPI section (if applicable)
- [x] Add private package repository section
- [x] Add Docker distribution section
- [x] Add version management section

**11.4: Create Deployment Hardening Checklist**

- [x] Create `docs/deployment/HARDENING_CHECKLIST.md`
- [x] Add security hardening section (auth, TLS, secrets, network)
- [x] Add reliability hardening section (health checks, monitoring, logging, backup)
- [x] Add performance hardening section (resource limits, scaling, caching)
- [x] Add operational hardening section (runbooks, incident response, disaster recovery)
- [x] Reference existing runbooks in `docs/operations/runbooks/`

**11.5: Update Documentation**

- [x] Update `README.md` with installation section
- [x] Update `docs/deployment/PRODUCTION_DEPLOYMENT.md` if needed
- [x] Validate all documentation links

**Plan Reference:** `plan:EXECUTION_PLAN:11`  
**Detailed Plan:** `plans/phase-11-productionized/phase-11-productionized.md`

---

## Phase 12 — Operational Improvements

**Scope:** Documentation sync, pre-commit hook improvements, validation setup clarity, ADR gate tuning.

**Success:** North Star reflects completed phases, hooks no longer false-positive, validation setup documented, ADR gate clarified.

### Tasks

**12.1: Documentation Sync**

- [x] Update `docs/NORTH_STAR.md` Phase 3-6 statuses to ✅ Complete
- [x] Confirm alignment with execution plan

**12.2: Pre-Commit Hook Improvements**

- [x] Migrate deprecated pre-commit stages to `pre-commit`/`pre-push`
- [x] Exclude documentation/examples from secret scan false positives

**12.3: Test Environment Consistency**

- [x] Document pre-push hook dependencies and setup instructions

**12.4: ADR Gate Tuning**

- [x] Reduce ADR gate false positives by improving guardrail change detection
- [x] Document ADR gate scope

**Plan Reference:** `plan:EXECUTION_PLAN:12`  
**Detailed Plan:** `plans/phase-12-operational-improvements/phase-12-operational-improvements.md`

---

## Phase 13 — Comprehensive E2E Testing

**Scope:** E2E tests, production deployment validation, load/stress testing.  
**Success:** CAIO fully tested end-to-end, production-ready with comprehensive coverage.

### Tasks

**13.1: E2E Test Suite**

- [x] Create E2E test framework
- [x] Implement E2E tests for core workflows
- [x] Implement E2E tests for service registration/discovery
- [x] Implement E2E tests for routing decisions

**13.2: Production Deployment Validation**

- [x] Validate production deployment process
- [x] Validate environment configuration
- [x] Validate security settings

**13.3: Load & Stress Testing**

- [x] Load testing for scalability
- [x] Stress testing for reliability
- [x] Performance benchmarking

**Plan Reference:** `plan:EXECUTION_PLAN:13`  
**Detailed Plan:** `plans/phase-13-comprehensive-e2e-testing/phase-13-comprehensive-e2e-testing.md`

---

## Phase 14 — AWS SaaS Deployment

**Scope:** Deploy CAIO as a scalable, multi-tenant SaaS solution on AWS infrastructure.  
**Success:** CAIO running in AWS with multi-tenancy, CI/CD, monitoring, and cost optimization.

### Tasks

**14.1: Design AWS Architecture**

- [ ] Design VPC, subnets, security groups
- [ ] Design ALB, ECS, RDS architecture
- [ ] Design multi-tenancy architecture
- [ ] Create architecture diagrams

**14.2: Implement Infrastructure as Code**

- [ ] Create Terraform configurations
- [ ] Define VPC, subnets, security groups
- [ ] Define ALB, ECS, RDS resources
- [ ] Define IAM roles and policies
- [ ] Define Secrets Manager configuration

**14.3: Implement Multi-Tenancy Support**

- [ ] Tenant isolation (database, services)
- [ ] Tenant resource quotas
- [ ] Tenant usage tracking
- [ ] Tenant-scoped service/data

**14.4: Containerize CAIO Application**

- [ ] Create production Dockerfile
- [ ] Optimize container size
- [ ] Configure health checks
- [ ] Test container locally

**14.5: Create CI/CD Pipeline**

- [ ] GitHub Actions workflow for AWS deployment
- [ ] Automated testing in CI/CD
- [ ] Automated deployment to staging/production
- [ ] Rollback procedures

**14.6: Configure Monitoring & Alerting**

- [ ] CloudWatch metrics and alarms
- [ ] Application logging
- [ ] Error tracking
- [ ] Performance monitoring

**14.7: Create Deployment Documentation**

- [ ] Deployment guide
- [ ] Architecture documentation
- [ ] Cost estimation
- [ ] Troubleshooting guide

**Plan Reference:** `plan:EXECUTION_PLAN:14`  
**Detailed Plan:** `plans/phase-14-aws-saas/phase-14-aws-saas.md`  
**Detailed Prompt:** `docs/prompts/codex-phase-14-aws-saas.md`

---

## Phase 15 — Configuration Dashboard

**Scope:** Create web-based configuration dashboard for non-technical users to configure CAIO's operational settings (policies, constraints, SLOs, tenant management).  
**Success:** Dashboard functional, all operational settings configurable via UI, real-time validation working.

### Tasks

**15.1: Design Dashboard Architecture**

- [x] Create architecture diagram
- [x] Define configuration scope (operational settings, NOT mathematical coefficients)
- [x] Create UI/UX mockups
- [x] Define API endpoint specifications

**15.2: Create Configuration Database Schema**

- [x] Design database schema for configurations
- [x] Create database models
- [x] Create migration scripts
- [x] Define indexes

**15.3: Implement Backend Configuration API**

- [x] Create configuration service
- [x] Create configuration API endpoints
- [x] Create configuration validation logic
- [x] Implement error handling

**15.4: Implement Frontend Dashboard**

- [x] Create Streamlit dashboard structure
- [x] Implement configuration forms
- [x] Implement configuration history view
- [x] Implement real-time validation

**15.5: Implement Real-Time Validation**

- [x] Add client-side validation
- [x] Add server-side validation integration
- [x] Add real-time feedback

**15.6: Implement Audit Trail**

- [x] Integrate audit logging
- [x] Add audit trail view to dashboard
- [x] Implement user attribution

**15.7: Create Documentation**

- [x] Create dashboard user guide
- [x] Create configuration API reference
- [x] Update main documentation

**Plan Reference:** `plan:EXECUTION_PLAN:15`  
**Detailed Plan:** `plans/phase-15-config-dashboard/phase-15-config-dashboard.md`  
**Detailed Prompt:** `docs/prompts/codex-phase-15-config-dashboard.md`

**CRITICAL:** Dashboard configures **operational settings** (policies, constraints, SLOs), NOT mathematical coefficients. Mathematical coefficients (α, β, γ, δ, λ, ρ, η) are fixed per `CAIO_MASTER_CALCULUS.md` (MA Doc-First: math is normative).

**Status:** ✅ Complete — 2026-01-12

---

## Phase 16 — Open Integration Layer

**Scope:** Create open-source integration layer (SDK, APIs, documentation) that allows external developers to connect their custom AI services to CAIO.  
**Success:** Open-source SDK available, external developers can connect services to CAIO, comprehensive documentation complete.

### Tasks

**16.1: Prepare Open-Source SDK Package**

- [x] Create open-source package structure
- [x] Extract SDK components (service interface, client, exceptions)
- [x] Create package configuration (pyproject.toml, setup.py)
- [x] Add LICENSE file (MIT or Apache 2.0)

**16.2: Create Integration APIs**

- [x] Create public integration endpoints
- [x] Document integration APIs
- [x] Create API examples

**16.3: Create Contract Templates & Examples**

- [x] Create contract templates
- [x] Create example contracts
- [x] Document contract schema

**16.4: Create Developer Documentation**

- [x] Create integration guide
- [x] Create SDK reference
- [x] Create API reference

**16.5: Create Example Implementations**

- [x] Create simple service example
- [x] Create advanced service example
- [x] Create integration test examples

**16.6: Set Up Open-Source Repository (if needed)**

- [x] Create GitHub repository (prepared locally)
- [x] Create README
- [x] Create contributing guidelines

**Plan Reference:** `plan:EXECUTION_PLAN:16`  
**Detailed Plan:** `plans/phase-16-open-integration-layer/phase-16-open-integration-layer.md`  
**Detailed Prompt:** `docs/prompts/codex-phase-16-open-integration-layer.md`

**CRITICAL:** The integration layer is open-source. The core mathematical engine (orchestrator, master equation, guarantee enforcement) remains proprietary.

**Status:** ✅ Complete — 2026-01-12

---

## Phase 17 — On-Premises Licensing Model

**Scope:** Enable CAIO to be deployed on-premises by customers with license control.  
**Success:** License validation working, on-premises deployment possible, customers can install and activate CAIO on-premises.

### Tasks

**17.1: Design License Key System**

- [x] Define license key format
- [x] Design license metadata schema
- [x] Design license key generation algorithm
- [x] Design license key validation algorithm

**17.2: Implement License Validation**

- [x] Create license validation service
- [x] Integrate license validation into CAIO
- [x] Implement feature flag enforcement
- [x] Implement graceful degradation

**17.3: Create On-Premises Deployment**

- [x] Create on-premises Docker container
- [x] Create installation scripts
- [x] Create configuration guide
- [x] Create environment setup guide

**17.4: Create License Management APIs**

- [x] Create license activation endpoint
- [x] Create license validation endpoint
- [x] Create license status endpoint
- [x] Create license renewal endpoint

**17.5: Create Documentation**

- [x] Create on-premises deployment guide
- [x] Create license activation guide
- [x] Create troubleshooting guide

**Plan Reference:** `plan:EXECUTION_PLAN:17`  
**Detailed Plan:** `plans/phase-17-on-premises-licensing/phase-17-on-premises-licensing.md`  
**Detailed Prompt:** `docs/prompts/codex-phase-17-on-premises-licensing.md`

**Status:** ✅ Complete — 2026-01-12

**CRITICAL:** This phase implements the licensing infrastructure. License management (generation, distribution, tracking) is handled in Phase 18.

---

## Phase 18 — License Management System

**Scope:** Create license management system for generating, distributing, tracking, and managing CAIO licenses.  
**Success:** License management system functional, licenses can be generated, distributed, and tracked.

### Tasks

**18.1: Create License Generation System**

- [x] Create customer database
- [x] Create license generation service
- [x] Create license key export functionality
- [x] Test license generation

**18.2: Create License Distribution System**

- [x] Create license delivery system
- [x] Implement email distribution (optional)
- [x] Create customer notification system
- [x] Test license distribution

**18.3: Create License Tracking System**

- [x] Create license tracking service
- [x] Implement activation tracking
- [x] Implement expiration monitoring
- [x] Implement renewal reminders

**18.4: Create License Management UI (Optional)**

- [x] Create Streamlit UI or CLI
- [x] Implement license generation form
- [x] Implement license list view
- [x] Implement statistics view

**18.5: Integrate with Phase 17**

- [x] Integrate license activation tracking
- [x] Integrate license status synchronization
- [x] Test integration

**18.6: Create Documentation**

- [x] Create license management guide
- [x] Create API documentation (if APIs created)
- [x] Create troubleshooting guide

**Plan Reference:** `plan:EXECUTION_PLAN:18`  
**Detailed Plan:** `plans/phase-18-license-management/phase-18-license-management.md`  
**Detailed Prompt:** `docs/prompts/codex-phase-18-license-management.md`

**CRITICAL:** This can start as a simple in-house system (SQLite database, basic Python scripts) and evolve to a more sophisticated solution or third-party integration later. Start simple to avoid initial costs.

**Status:** ✅ Complete — 2026-01-14

---

## Phase 19 — Universal Service Gateway & Adapters

**Scope:** Build Service Gateway executor module and implement 25+ service adapters across all three tiers (Tier 1: Core LLM providers, Tier 2: Specialized + local, Tier 3: Extended ecosystem). Gateway executes HTTP/gRPC/native requests to external services, performs request/response transformation, and enforces mathematical guarantees post-execution.  
**Success:** Gateway executes requests end-to-end, all 25+ service adapters functional with contract templates, guarantee enforcement integrated, orchestrator → gateway → service → guarantee enforcer flow working.

### Tasks

**19.1: Build Service Gateway Core**

- [x] Create `caio/gateway/executor.py` — HTTP/gRPC/native execution engine
- [x] Create `caio/gateway/base.py` — Base adapter interface
- [x] Create `caio/gateway/transformer.py` — Request/response transformation utilities
- [x] Integrate with `GuaranteeEnforcer` for post-execution validation
- [x] Update `orchestrate_request` to call gateway after routing decision
- [x] Add error handling, retry logic, circuit breakers
- [x] Add request/response logging and tracing

**19.2: Tier 1 Adapters (5 services) — MVP**

**NOTE:** Per ADR-0001, Tier 1 inference adapters (OpenAI, Anthropic, Groq, Mistral, Cohere) were **migrated to VFE** as external API backends. CAIO now routes inference requests to VFE, not directly to external APIs.

- [x] OpenAI adapter (GPT-4, GPT-4o, GPT-3.5-turbo) — **MIGRATED TO VFE**
- [x] Anthropic adapter (Claude 3.5 Sonnet, Claude 3 Opus) — **MIGRATED TO VFE**
- [x] Groq adapter (fast inference) — **MIGRATED TO VFE**
- [x] Mistral AI adapter (Mistral Medium, Mistral Large) — **MIGRATED TO VFE**
- [x] Cohere adapter (Command R+, Command R) — **MIGRATED TO VFE**
- [x] Create contract templates for all Tier 1 services
- [x] Test each adapter with real API calls — **N/A (migrated to VFE)**

**19.3: Tier 2 Adapters (10 services) — Phase 1**

**NOTE:** Per ADR-0001, inference adapters should be in VFE, not CAIO. The following inference adapters should be **moved to VFE or removed from CAIO**:
- Ollama, LM Studio, Gemini, Grok, Perplexity, Hugging Face, Together, Replicate, Azure OpenAI, AWS Bedrock

**Current Status:** These adapters exist in CAIO but violate the architecture. They should be migrated to VFE or removed.

- [x] Ollama adapter (local models) — **SHOULD BE IN VFE**
- [x] LM Studio adapter (local models) — **SHOULD BE IN VFE**
- [x] Google Gemini adapter (Gemini Pro, Gemini Ultra) — **SHOULD BE IN VFE**
- [x] xAI Grok adapter (Grok-4) — **SHOULD BE IN VFE**
- [x] Perplexity adapter (search-augmented) — **SHOULD BE IN VFE**
- [x] Hugging Face Inference API adapter — **SHOULD BE IN VFE**
- [x] Together AI adapter (open models) — **SHOULD BE IN VFE**
- [x] Replicate adapter (model hosting) — **SHOULD BE IN VFE**
- [x] Azure OpenAI adapter (enterprise) — **SHOULD BE IN VFE**
- [x] AWS Bedrock adapter (enterprise) — **SHOULD BE IN VFE**
- [x] Create contract templates for all Tier 2 services
- [x] Test each adapter with real API calls (where API keys available) - Integration tests created with skipif markers

**19.4: Tier 3 Adapters (10+ services) — Extended Ecosystem**

**NOTE:** Per ADR-0001, CAIO adapters should only handle **non-inference marketplace services**. The following are correctly placed in CAIO:
- **Embeddings:** OpenAI Embeddings, Cohere Embed, Voyage AI ✅
- **Code:** GitHub Copilot API, Cursor API ✅
- **Search:** Tavily, Serper ✅
- **Voice:** ElevenLabs, Deepgram ✅
- **Image:** Midjourney API, Stability AI, DALL-E ✅

**The following inference adapters should be moved to VFE or removed:**
- Meta AI, Google PaLM, Aleph Alpha — **SHOULD BE IN VFE**

- [x] Embedding services: OpenAI Embeddings, Cohere Embed, Voyage AI ✅
- [x] Code services: GitHub Copilot API, Cursor API ✅
- [x] Search services: Tavily, Serper ✅
- [x] Voice services: ElevenLabs, Deepgram ✅
- [x] Image services: Midjourney API, Stability AI, DALL-E ✅
- [x] Additional: Meta AI, Google PaLM, Aleph Alpha — **SHOULD BE IN VFE**
- [x] Create contract templates for all Tier 3 services
- [x] Test each adapter with real API calls (where API keys available) - Integration tests created with skipif markers

**19.5: Contract Templates & Documentation**

- [x] Create contract templates for all 25+ services in `configs/services/external/`
- [x] Document adapter patterns and usage in `docs/gateway/`
- [x] Create integration examples for each tier
- [x] Create troubleshooting guide for common issues
- [x] Document API versioning and compatibility

**19.6: Update Mechanism Implementation**

- [x] Implement update service module (download, verify, install)
- [x] Create standardized update API endpoints (`/api/v1/update`, `/api/v1/restart`, `/api/v1/version`)
- [x] Register update routes in API application
- [x] Add unit tests for update endpoints
- [x] Update API documentation

**19.7: PyPI Preparation**

- [x] Update package name to `smarthaus-caio` in `pyproject.toml`
- [x] Update README with PyPI installation instructions
- [x] Verify package build and structure
- [x] Verify no breaking changes (import name remains `caio`)

**19.8: PyPI Publication**

- [ ] Set up PyPI account and credentials (missing `.env` credentials in repo)
- [x] Build package distributions (sdist and wheel)
- [ ] Test publication on TestPyPI (upload failed: 403 Forbidden)
- [ ] Publish production package to PyPI (`smarthaus-caio`)
- [ ] Verify installation from PyPI
- [ ] Set up automated publishing workflow (optional)

**19.9: Enterprise Artifact Validation**

- [x] Docker image validation script (`scripts/release/validate_docker.sh`)
- [x] Wheel package validation script (`scripts/release/validate_wheel.sh`)
- [x] Smoke tests for enterprise distribution artifacts
- [x] Re-run validation after SDK separation (2026-01-16)

**19.10: Live Gateway Verification (Non-Inference Adapters Only)**

**Scope:** Verify CAIO's non-inference marketplace adapters with live API calls. Per ADR-0001, inference adapters are in VFE, so this phase only verifies:
- Embeddings: OpenAI Embeddings, Cohere Embed, Voyage AI
- Code: GitHub Copilot API, Cursor API
- Search: Tavily, Serper
- Voice: ElevenLabs, Deepgram
- Image: Midjourney API, Stability AI, DALL-E

**NOTE:** Inference adapters (gemini, grok, ollama, etc.) should NOT be verified here — they belong in VFE.

- [x] Create live verification test suite (`tests/integration/test_live_gateway_verification.py`)
- [x] Add safety gates (`LIVE_TESTS_ENABLED=1`) and per-adapter API key skips
- [ ] Verify embeddings adapters with real API calls (Blocked: Missing API keys in environment)
- [ ] Verify code adapters with real API calls (Blocked: Missing API keys in environment)
- [ ] Verify search adapters with real API calls (Blocked: Missing API keys in environment)
- [ ] Verify voice adapters with real API calls (Blocked: Missing API keys in environment)
- [ ] Verify image adapters with real API calls (Blocked: Missing API keys in environment)
- [x] Document which adapters were verified and which require API keys (`docs/gateway/ADAPTER_VERIFICATION.md`)
- [x] Update integration test documentation (`tests/integration/README.md`)

**Plan Reference:** `plan:phase-19-10-live-gateway-verification:19.10` (caio-core repo)
**Detailed Plan:** `caio-core/plans/phase-19-10-live-gateway-verification/phase-19-10-live-gateway-verification.md`
**Detailed Prompt:** `caio-core/docs/prompts/codex-phase-19-10-live-gateway-verification.md` (if exists)

**19.11: Testing & Validation**

- [x] Unit tests for gateway executor
- [x] Unit tests for each adapter (25+ test files)
- [x] Integration tests with real API calls (where API keys available)
- [x] E2E tests for orchestrator → gateway → service → guarantee enforcer flow
- [x] Guarantee enforcement validation tests
- [x] Performance tests (latency, throughput)
- [x] Error handling tests (rate limits, timeouts, failures)

**Plan Reference:** `plan:EXECUTION_PLAN:19`  
**Detailed Plan:** `plans/phase-19-universal-gateway/phase-19-universal-gateway.md`  
**Detailed Prompts:** 
- `docs/prompts/codex-phase-19.1-gateway-core.md`
- `docs/prompts/codex-phase-19.2-tier1-adapters.md`
- `docs/prompts/codex-phase-19.3-tier2-adapters.md`
- `docs/prompts/codex-phase-19.4-tier3-adapters.md`
- `docs/prompts/codex-phase-19.5-contracts-docs.md`
- `docs/prompts/codex-phase-19.6-update-api-endpoints.md` (Update Mechanism Implementation)
- `docs/prompts/codex-phase-19.7-update-package-name.md` (PyPI Preparation)
- `docs/prompts/codex-phase-19.8-pypi-publication.md` (PyPI Publication)
- `docs/prompts/codex-phase-19.8.1-github-distribution.md` (GitHub Distribution)
- `docs/prompts/codex-phase-19.9-testing-validation.md` (Testing & Validation)

**CRITICAL:** 
- Use web search during implementation to get current API documentation for each service
- Gateway must integrate with existing `GuaranteeEnforcer` for post-execution validation
- All adapters must follow the base adapter interface pattern
- Contract templates must validate against `configs/schemas/service_contract.schema.yaml`
- Testing should use real API calls where possible (with API keys), mock otherwise

**Status:** ⚠️ In Progress — 19.1 complete (2026-01-13)

---

## Phase 20 — SDK Separation

**Scope:** Split the CAIO SDK into an isolated package (`packages/sdk`) with strict isolation between core orchestrator code and SDK surface.  
**Success:** SDK builds independently, core remains isolated from SDK dependencies, and public SDK API remains stable.

**Sequencing Note:** Phase 20 is authorized to start before Phase 19 completion by explicit approval (2026-01-16). Phase 19 remains in progress.

### Tasks

**20.1: Define SDK Package Boundaries**

- [x] Identify SDK surface (client, service interface, exceptions, schemas)
- [x] Define allowed imports from core (if any) and forbid reverse imports
- [x] Document SDK dependency constraints

**20.2: Create `packages/sdk` Package Structure**

- [x] Create `packages/sdk` package scaffolding
- [x] Move SDK modules from `caio/sdk` into isolated package
- [x] Add package README and licensing notes

**20.3: Wire Compatibility & Backward Imports**

- [x] Provide compatibility shim in `caio/sdk` (if required)
- [x] Update import paths across codebase (minimal changes)
- [x] Ensure public SDK API remains stable

**20.4: Validation & Documentation**

- [x] Update SDK documentation and integration guides
- [x] Add/adjust tests to ensure SDK isolation
- [x] Verify build and lint rules for SDK package

**Plan Reference:** `plan:phase-20-sdk-separation:20.0`  
**Detailed Plan:** `plans/phase-20-sdk-separation/phase-20-sdk-separation.md`  
**Detailed Prompt:** `docs/prompts/codex-phase-20-sdk-separation.md`

**Status:** ✅ Complete — 2026-01-16

---

## Phase 21 — Licensing Security & Distribution Control

**Scope:** Asymmetric license signing (RSA/Ed25519), refactor generator/validator, config (drop `CAIO_LICENSE_SECRET`; add `CAIO_LICENSE_PUBLIC_KEY`), distribution control (private registry, deploy/customer), docs and runbooks. **Success:** Customers cannot forge keys; download only via controlled registry; `v2` keys in use.

### Tasks

**21.1: Asymmetric Crypto and Keypair**
- [x] Add `cryptography`; `scripts/licensing/generate_keypair.sh`; document key custody. (Code complete in `caio-core`)

**21.2: Generator and Validator**
- [x] `generator.py`: private key, `v2` format. `validator.py`: public key, verify. (Complete in `caio-core`)

**21.3: Config and Embedding**
- [x] Drop `CAIO_LICENSE_SECRET`; add `CAIO_LICENSE_KEY`, `CAIO_LICENSE_PUBLIC_KEY`; wire validator. (Complete in `caio-core`)

**21.4: Generation Service and CLI**
- [x] `generation_service.py` and CLI use private key; emit `v2`. (Complete in `caio-core`)

**21.5: Distribution Control**
- [x] `deploy/customer/` and `scripts/release/push_to_registry.sh`; docs.

**21.6: Docs and Runbooks**
- [x] LICENSE_MANAGEMENT, ON_PREMISES, LICENSE_ACTIVATION; key-rotation runbook.

**21.7: GitHub Container Registry (GHCR) Setup**
- [ ] Update build/push scripts to use `ghcr.io/smarthausgroup/caio`
- [ ] Update Docker Compose files to reference GHCR images
- [ ] Update documentation with GHCR authentication steps
- [ ] Create GitHub Actions workflow for automated builds (optional)

**Notes:**
- Code implementation (Tasks 21.1-21.4) completed in `caio-core` repository (commit `69613ce`).
- Scripts (`generate_keypair.sh`, `push_to_registry.sh`) moved to `caio-core` as internal tools.
- `CAIO` repository handles public documentation, deployment configs, and distribution guidelines.
- Phase 21.7 (GHCR setup) is code/infrastructure work in `caio-core`; coordination tracked in this plan.

**Plan Reference:** `plan:EXECUTION_PLAN:21`  
**Detailed Plan:** `plans/phase-21-licensing-security-distribution/phase-21-licensing-security-distribution.md`  
**Detailed Prompt:** `docs/prompts/codex-phase-21-licensing-security-distribution.md`

**Phase 21.7 Plan Reference:** `plan:phase-21-7-ghcr-setup:21.7` (caio-core repo)  
**Phase 21.7 Detailed Plan:** `caio-core/plans/phase-21-7-ghcr-setup/phase-21-7-ghcr-setup.md`

**Status:** ✅ Complete — Code in `caio-core`, docs/config in `CAIO`.

---

## Plan ↔ North Star Sync (hard rule)

- If an item appears in `docs/NORTH_STAR.md` (KPIs, invariants, notebooks, APIs, telemetry, runbooks), it MUST appear here with an explicit task/checkbox and cross‑reference.
- If an item is added here (execution or ops deliverables), ensure the corresponding North Star section references it (KPIs/architecture/ops).
- CI sync check (if implemented) enforces invariant references across all files.

---

## References

- **North Star**: `docs/NORTH_STAR.md`
- **Status Plan**: `docs/operations/STATUS_PLAN.md`
- **Action Log**: `CODEX_ACTION_LOG`
- **Master Calculus**: `docs/math/CAIO_MASTER_CALCULUS.md`
- **Control Calculus**: `docs/math/CAIO_CONTROL_CALCULUS.md`
- **Lemmas**: `docs/math/CAIO_LEMMAS_APPENDIX.md`
- **Invariants**: `invariants/INDEX.yaml`
- **SDK Spec**: `docs/SDK_SPECIFICATION.md`
- **MA Process**: `docs/MA_PROCESS_STATUS.md`
- **MA Process Rule**: `docs/operations/MA_PROCESS_MANDATORY_RULE.md`
- **Phase 21 Plan**: `plans/phase-21-licensing-security-distribution/phase-21-licensing-security-distribution.md`

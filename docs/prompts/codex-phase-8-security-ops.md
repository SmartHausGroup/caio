# Codex Prompt: Phase 8 - Security & Traceability Operations

**Plan Reference:** `plan:phase-8-security-ops`  
**Execution Plan Reference:** `plan:EXECUTION_PLAN:8.1-8.4`  
**Status:** Ready for Implementation  
**North Star Alignment:** Makes CAIO's security and traceability guarantees operational in production per `docs/NORTH_STAR.md` (Section 2.9: Traceability Invariant; Section 9: Outcomes and Success Criteria (SLOs); Section 10: Testing & validation matrix)

---

## Executive Summary

Complete Phase 8 (Security & Traceability Operations) by implementing runtime security enforcement, traceability/audit operations, SLO monitoring and alerting, and operational runbooks. This makes CAIO's mathematical guarantees operational in production environments.

**Note:** This is implementation work following notebook-first development. Operations code should be written in notebooks first, then extracted. MA process is NOT required for operations code, but you must follow the mandatory workflow (North Star alignment, Execution Plan verification, change approval). All tests must use real implementations (no mocks for core behavior).

---

## Context & Background

**Current State:**
- Phases 0-7 are **COMPLETE** ✅ (Foundation, Math, Invariants, Notebooks, CI Enforcement, Orchestrator Implementation, SDK & API Surface)
- Phase 7 complete: SDK interface, HTTP/REST API, integration tests all functional
- CAIO core operational: Orchestrator, SDK, API all working
- Phase 8 is **NOT STARTED** ❌

**Why This Matters:**
- Makes security invariants enforceable at runtime
- Enables audit and compliance workflows
- Provides SLO monitoring and alerting
- Documents operational procedures for production
- Ensures CAIO's guarantees are observable and actionable

**Related Work:**
- Execution Plan: `docs/operations/EXECUTION_PLAN.md` (Phase 8: Security & Traceability Operations)
- North Star: `docs/NORTH_STAR.md` (Section 2.9: Traceability Invariant; Section 9: SLOs; Section 10: Testing & validation matrix)
- Status Plan: `docs/operations/STATUS_PLAN.md` (Phase 8: Pending)
- Orchestrator: `caio/orchestrator/core.py` (Orchestrator class with security verifier and traceability)
- API: `caio/api/app.py` (FastAPI application)

---

## Current State Analysis

**What Exists:**

**Security Components:**
- `caio/security/verifier.py` - Security verifier (authentication, authorization, privacy, access control)
- `caio/orchestrator/core.py` - Orchestrator with security verifier integrated
- Security invariants: `invariants/INV-CAIO-SEC-*.yaml` (security guarantees)

**Traceability Components:**
- `caio/traceability/tracer.py` - Traceability system (proof generation, trace storage)
- `caio/orchestrator/core.py` - Orchestrator with traceability integrated
- Trace endpoint: `caio/api/routes/trace.py` - GET /trace/{decision_id}
- Traceability invariants: `invariants/INV-CAIO-0003.yaml` (traceability guarantee)

**API Components:**
- `caio/api/app.py` - FastAPI application
- `caio/api/routes/orchestrate.py` - POST /orchestrate
- `caio/api/routes/trace.py` - GET /trace/{decision_id}
- `caio/api/routes/health.py` - GET /health
- `caio/api/routes/metrics.py` - GET /metrics

**What's Missing:**

**Security Operations:**
- API authentication/authorization integration
- Security metrics (authn_failures, authz_denials, policy_violations)
- Security incident handling procedures

**Traceability & Audit:**
- Persistent trace storage (currently in-memory only)
- Audit APIs for compliance teams
- Trace query and filtering capabilities

**SLOs & Alerts:**
- SLO monitoring (latency P95/P99, correctness, security violation rate, trace completeness)
- Alerting when SLOs breach
- Alerting when invariants breach

**Runbooks:**
- Security incident handling runbook
- Traceability/audit workflow runbook
- Contract misconfiguration runbook
- Invariant violation runbook

---

## Target State

**Phase 8 Complete When:**

1. **Security Operations:**
   - API authentication/authorization wired to identity system (or mock for development)
   - Security metrics exposed via `/metrics` endpoint
   - Security incident handling documented

2. **Traceability & Audit:**
   - Persistent trace storage implemented (file-based or database)
   - Audit APIs for compliance teams (query traces by date, service, user, etc.)
   - Trace query and filtering capabilities

3. **SLOs & Alerts:**
   - SLO monitoring implemented (latency P95/P99, correctness, security, trace completeness)
   - Alerting configured (when SLOs breach, when invariants breach)
   - Metrics exposed via `/metrics` endpoint

4. **Runbooks:**
   - Security incident handling runbook (`docs/operations/runbooks/security_incident.md`)
   - Traceability/audit workflow runbook (`docs/operations/runbooks/traceability_audit.md`)
   - Contract misconfiguration runbook (`docs/operations/runbooks/contract_misconfiguration.md`)
   - Invariant violation runbook (`docs/operations/runbooks/invariant_violation.md`)

---

## Step-by-Step Implementation Instructions

### Task 8.1: Security Operations

**Notebook:** `notebooks/ops/security_operations.ipynb`

**Implementation Steps:**

1. **API Authentication/Authorization:**
   - Create notebook cell implementing API auth middleware
   - Integrate with FastAPI dependency injection
   - Support token-based authentication (Bearer tokens)
   - Support role-based authorization (admin, user, service)
   - Extract to `caio/api/middleware/auth.py`

2. **Security Metrics:**
   - Create notebook cell implementing security metrics collection
   - Track: `cai_authn_failures`, `cai_authz_denials`, `cai_policy_violations`
   - Expose via `/metrics` endpoint
   - Extract to `caio/api/middleware/metrics.py`

3. **Security Incident Handling:**
   - Create notebook cell implementing security incident detection
   - Log security violations
   - Alert on repeated failures
   - Extract to `caio/security/incident_handler.py`

**Files to Create:**
- `notebooks/ops/security_operations.ipynb` (implementation notebook)
- `caio/api/middleware/auth.py` (extracted auth middleware)
- `caio/api/middleware/metrics.py` (extracted metrics middleware)
- `caio/security/incident_handler.py` (extracted incident handler)

**Tests:**
- `tests/integration/test_security_ops.py` - Test auth middleware, metrics collection, incident handling

---

### Task 8.2: Traceability & Audit

**Notebook:** `notebooks/ops/traceability_audit.ipynb`

**Implementation Steps:**

1. **Persistent Trace Storage:**
   - Create notebook cell implementing trace storage backend
   - Support file-based storage (JSON files) for development
   - Support database storage (SQLite) for production
   - Extract to `caio/traceability/storage.py`

2. **Audit APIs:**
   - Create notebook cell implementing audit query endpoints
   - GET `/audit/traces` - Query traces by date range, service, user, decision_id
   - GET `/audit/proofs` - Query proofs by type, validity, date range
   - GET `/audit/violations` - Query security violations, policy violations
   - Extract to `caio/api/routes/audit.py`

3. **Trace Query & Filtering:**
   - Create notebook cell implementing trace query builder
   - Support filtering by: date range, service_id, user, decision_id, proof_type
   - Support sorting and pagination
   - Extract to `caio/traceability/query.py`

**Files to Create:**
- `notebooks/ops/traceability_audit.ipynb` (implementation notebook)
- `caio/traceability/storage.py` (extracted trace storage)
- `caio/api/routes/audit.py` (extracted audit APIs)
- `caio/traceability/query.py` (extracted query builder)

**Tests:**
- `tests/integration/test_traceability_audit.py` - Test trace storage, audit APIs, query filtering

---

### Task 8.3: SLOs & Alerts

**Notebook:** `notebooks/ops/slos_alerts.ipynb`

**Implementation Steps:**

1. **SLO Monitoring:**
   - Create notebook cell implementing SLO metrics collection
   - Track: orchestration latency (P95/P99), decision correctness (sampled), security violation rate, trace completeness
   - Expose via `/metrics` endpoint
   - Extract to `caio/monitoring/slos.py`

2. **Alerting:**
   - Create notebook cell implementing alert manager
   - Alert when SLOs breach (latency > P95 threshold, correctness < 100%, security violations > threshold, trace completeness < 100%)
   - Alert when invariants breach (scorecard red)
   - Support email, webhook, or log-based alerts
   - Extract to `caio/monitoring/alerts.py`

3. **Metrics Endpoint Enhancement:**
   - Update `/metrics` endpoint to include SLO metrics
   - Format: Prometheus-compatible metrics
   - Include: latency histograms, correctness counters, security violation counters, trace completeness gauge
   - Extract to `caio/api/routes/metrics.py` (update existing)

**Files to Create:**
- `notebooks/ops/slos_alerts.ipynb` (implementation notebook)
- `caio/monitoring/slos.py` (extracted SLO monitoring)
- `caio/monitoring/alerts.py` (extracted alert manager)

**Files to Update:**
- `caio/api/routes/metrics.py` (add SLO metrics)

**Tests:**
- `tests/integration/test_slos_alerts.py` - Test SLO monitoring, alerting, metrics endpoint

---

### Task 8.4: Runbooks

**Notebook:** `notebooks/ops/runbooks.ipynb` (documentation notebook)

**Implementation Steps:**

1. **Security Incident Handling Runbook:**
   - Create markdown documentation in notebook
   - Document: incident detection, escalation, remediation, post-incident review
   - Extract to `docs/operations/runbooks/security_incident.md`

2. **Traceability/Audit Workflow Runbook:**
   - Create markdown documentation in notebook
   - Document: trace query workflows, audit report generation, compliance checks
   - Extract to `docs/operations/runbooks/traceability_audit.md`

3. **Contract Misconfiguration Runbook:**
   - Create markdown documentation in notebook
   - Document: detecting misconfigurations, validation errors, remediation steps
   - Extract to `docs/operations/runbooks/contract_misconfiguration.md`

4. **Invariant Violation Runbook:**
   - Create markdown documentation in notebook
   - Document: detecting violations, investigating root cause, remediation, prevention
   - Extract to `docs/operations/runbooks/invariant_violation.md`

**Files to Create:**
- `notebooks/ops/runbooks.ipynb` (documentation notebook)
- `docs/operations/runbooks/security_incident.md` (extracted runbook)
- `docs/operations/runbooks/traceability_audit.md` (extracted runbook)
- `docs/operations/runbooks/contract_misconfiguration.md` (extracted runbook)
- `docs/operations/runbooks/invariant_violation.md` (extracted runbook)

**Tests:**
- No code tests needed (documentation only)

---

## Validation Procedures

### After Each Task

1. **Run Integration Tests:**
   ```bash
   pytest tests/integration/test_security_ops.py -xvs
   pytest tests/integration/test_traceability_audit.py -xvs
   pytest tests/integration/test_slos_alerts.py -xvs
   ```

2. **Verify API Endpoints:**
   ```bash
   # Start API server
   python3 -m caio.api.app
   
   # Test endpoints
   curl http://localhost:8080/health
   curl http://localhost:8080/metrics
   curl http://localhost:8080/audit/traces
   ```

3. **Verify Runbooks:**
   - Check all runbooks exist in `docs/operations/runbooks/`
   - Verify runbooks are complete and actionable

### Final Validation

1. **Run All Tests:**
   ```bash
   pytest tests/integration/ -xvs
   pytest tests/e2e/ -xvs
   ```

2. **Verify Metrics:**
   ```bash
   curl http://localhost:8080/metrics | grep -E "(cai_authn|cai_authz|cai_policy|latency|correctness|trace_completeness)"
   ```

3. **Verify SLOs:**
   - Check SLO metrics are being collected
   - Verify alerting triggers on SLO breaches

4. **Verify Runbooks:**
   - All 4 runbooks exist and are complete
   - Runbooks reference correct APIs and procedures

---

## Success Criteria

**Phase 8 is complete when:**

- [x] Security operations implemented (auth middleware, security metrics, incident handling)
- [x] Traceability & audit operational (persistent storage, audit APIs, query filtering)
- [x] SLOs & alerts implemented (monitoring, alerting, metrics endpoint)
- [x] Runbooks created (security incident, traceability/audit, contract misconfiguration, invariant violation)
- [x] All integration tests passing
- [x] All API endpoints functional
- [x] Metrics endpoint includes SLO metrics
- [x] Runbooks complete and actionable

---

## Notes and References

**North Star Alignment:**
- Section 2.9: Traceability Invariant - Every decision has a verifiable proof
- Section 9: Outcomes and Success Criteria (SLOs) - Performance SLOs, Capacity SLOs, Quality Guarantees
- Section 10: Testing & validation matrix - CI acceptance gates, SLO monitoring

**Execution Plan:**
- Phase 8: Security & Traceability Operations (Tasks 8.1-8.4)

**Related Components:**
- Orchestrator: `caio/orchestrator/core.py`
- Security Verifier: `caio/security/verifier.py`
- Traceability: `caio/traceability/tracer.py`
- API: `caio/api/app.py`

**Notebook-First Development:**
- All implementation code written in notebooks first
- Code extracted from notebooks to Python files
- Notebooks remain source of truth

---

**Ready for Implementation**


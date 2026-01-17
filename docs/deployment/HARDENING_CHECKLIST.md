# CAIO Deployment Hardening Checklist

Use this checklist when preparing CAIO for production deployment.

## Security Hardening

- [x] Authentication and authorization enabled for all API routes.
  - **Test:** `tests/e2e/test_production_deployment.py::TestAuthenticationAuthorization`
- [ ] TLS/SSL termination configured (ingress or application).
  - **Note:** Infrastructure configuration, not code test
- [ ] Secrets stored in a secure vault or secret manager (no plaintext files).
  - **Note:** Infrastructure configuration, not code test
- [ ] Network access restricted (firewall rules, VPC security groups).
  - **Note:** Infrastructure configuration, not code test
- [x] CORS configured to allow only approved origins.
  - **Test:** `tests/e2e/test_production_deployment.py::TestCORS`
- [x] Rate limiting applied to external-facing endpoints.
  - **Test:** `tests/e2e/test_production_deployment.py::TestRateLimiting`
- [x] Audit logging enabled for security-sensitive actions.
  - **Test:** `tests/e2e/test_production_deployment.py::TestStructuredLogging`

## Reliability Hardening

- [x] `/health` endpoint monitored and used for readiness/liveness checks.
  - **Test:** `tests/e2e/test_production_deployment.py::TestHealthChecks`
- [x] Structured logging configured (`CAIO_LOG_FORMAT=json`).
  - **Test:** `tests/e2e/test_production_deployment.py::TestStructuredLogging`
- [x] Metrics collection enabled and scraped by monitoring stack.
  - **Test:** `tests/integration/test_api_sdk.py::TestAPIRoutes::test_metrics_endpoint`
- [x] Alerting configured for SLOs and security violations.
  - **Test:** `tests/integration/test_slos_alerts.py::test_slo_alerts_triggered`
- [ ] Backup/restore plan documented for trace/audit storage.
  - **Note:** Documentation, not code test
- [x] Runbooks available for incident response and recovery.
  - **Note:** Documentation exists in `docs/operations/runbooks/`

## Performance Hardening

- [x] Resource limits set for CPU and memory.
  - **Test:** `tests/e2e/test_load_stress.py::TestResourceUsage`
- [ ] Horizontal scaling strategy defined (replicas, autoscaling).
  - **Note:** Infrastructure configuration, not code test
- [ ] Service registry cache sized appropriately (`CAIO_REGISTRY_SIZE`).
  - **Note:** Configuration, not code test
- [ ] Contract cache TTL tuned (`CAIO_CONTRACT_CACHE_TTL`).
  - **Note:** Configuration, not code test
- [x] Latency SLOs monitored (P95/P99).
  - **Test:** `tests/e2e/test_load_stress.py::TestLatencySLOs`

## Operational Hardening

- [x] Production configuration validated (`CAIO_ENV=production`).
  - **Test:** `tests/e2e/test_production_deployment.py::TestEnvironmentVariables`
- [x] Environment variables documented and applied consistently.
  - **Test:** `tests/e2e/test_production_deployment.py::TestEnvironmentVariables`
- [ ] Deployment and rollback procedures rehearsed.
  - **Note:** Manual process, not code test
- [ ] Incident response plan confirmed with on-call rotation.
  - **Note:** Operational process, not code test
- [ ] Disaster recovery plan documented and tested.
  - **Note:** Documentation, not code test
- [x] Referenced runbooks under `docs/operations/runbooks/`.
  - **Note:** Documentation exists

## Test Coverage

All code-testable hardening checklist items have corresponding tests:

- **E2E Tests:** `tests/e2e/test_production_deployment.py`
- **Load/Stress Tests:** `tests/e2e/test_load_stress.py`
- **Integration Tests:** `tests/integration/`

Infrastructure/configuration items are documented in deployment guides and runbooks.

## References

- `docs/deployment/PRODUCTION_DEPLOYMENT.md`
- `docs/deployment/ENVIRONMENT_VARIABLES.md`
- `docs/operations/runbooks/`

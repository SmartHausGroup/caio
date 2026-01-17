# Contract Misconfiguration Runbook

## Purpose
Resolve failures caused by invalid or incomplete service contracts.

## Triggers
- `/register-service` returns validation errors.
- `/services` list missing expected service.
- Orchestrator reports no matching services for a request.

## Diagnosis
1. Validate the contract YAML with `caio_sdk.validate_contract` (or the `caio.sdk` shim).
2. Check required fields: `service_id`, `name`, `version`, `api`, `capabilities`.
3. Verify endpoint definitions and capability types.

## Remediation
1. Fix YAML formatting or missing fields.
2. Re-register service via `/register-service`.
3. Confirm `/services` includes the service.
4. Re-run orchestration request to validate routing.

## Prevention
- Add contract validation in CI for new service definitions.
- Maintain a schema checklist for service owners.

# Gateway Troubleshooting Guide

## Adapter Not Found

**Symptom:** `AdapterNotFoundError: No adapter found for service <service_id>`

**Checks:**
1. Confirm the adapter is registered in `GatewayExecutor.adapter_registry`.
2. Verify the contract `service_id` matches the adapter registration key.
3. Ensure the adapter module is imported in the gateway adapter registry.

## Contract Validation Errors

**Symptom:** Contract validation fails during registration or via `/validate-contract`.

**Checks:**
1. Ensure required fields exist: `service_id`, `name`, `version`, `api`, `capabilities`.
2. Confirm `service_id` uses lowercase letters, numbers, `-`, or `_`.
3. Validate `api.base_url` is a valid URI and endpoints include `path` + `method`.

## Service Execution Errors

**Symptom:** `ServiceExecutionError: Failed to execute service <service_id>`

**Checks:**
1. Confirm the service API key or token is configured (environment variables or secret manager).
2. Validate `api.base_url` and endpoint paths match the provider documentation.
3. Check the provider's status page for outages or maintenance.

## Guarantee Violations

**Symptom:** `GuaranteeViolationError: Service <service_id> response violates guarantees`

**Checks:**
1. Review the contract guarantees and compare with actual response metrics.
2. Verify the adapter response normalization is correct (latency, accuracy metadata).
3. Update guarantees or response transformation if the service behavior differs.

## Rate Limiting / Throttling

**Symptom:** HTTP 429 or throttling errors.

**Checks:**
1. Confirm the API key tier allows the requested throughput.
2. Adjust CAIO retry/backoff settings if needed.
3. Update contract constraints to reflect realistic rate limits.

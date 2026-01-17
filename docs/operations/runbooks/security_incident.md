# Security Incident Handling Runbook

## Purpose
Respond to authentication, authorization, or policy violations that indicate a potential security incident.

## Triggers
- Spike in `cai_authn_failures`, `cai_authz_denials`, or `cai_policy_violations` in `/metrics`.
- Alert codes: `security_violation_breach` or repeated `authn_failure`/`authz_denial` incidents.
- Audit violations in `/audit/violations`.

## Immediate Actions
1. Check `/metrics` and record current security counters and SLO snapshot.
2. Query recent violations: `/audit/violations?event_type=authn_failure` or `authz_denial`.
3. Review incident log file (`CAIO_SECURITY_INCIDENT_LOG`, default `logs/security/incidents.jsonl`).

## Investigation
1. Identify affected actors (token hashes) and time window.
2. Validate recent token changes in deployment configuration (`CAIO_AUTH_TOKENS`).
3. Correlate with trace data via `/audit/traces` for the same time window.

## Containment
- Rotate or revoke compromised tokens.
- Temporarily restrict endpoints to `admin` role only.
- Increase alerting thresholds only after incident is understood and documented.

## Recovery
1. Confirm successful authenticated requests with valid tokens.
2. Monitor `/metrics` for stabilization of failure rates.
3. Document incident summary and remediation steps.

## Post-Incident
- Add regression tests or monitoring to detect similar patterns.
- Update this runbook with any new signals or steps.


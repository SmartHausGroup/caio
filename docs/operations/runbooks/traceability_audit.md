# Traceability / Audit Workflow Runbook

## Purpose
Provide audit-ready trace and proof evidence for routing decisions.

## Triggers
- Compliance or audit request.
- Missing trace or proof for a decision.
- Scorecard indicates traceability issues.

## Workflow
1. Identify decision id from `/orchestrate` response or system logs.
2. Retrieve trace details: `/trace/{decision_id}`.
3. Query trace records for a time window: `/audit/traces?start_time=...&end_time=...`.
4. Query proofs: `/audit/proofs?decision_id=...`.
5. Validate proof fields (`proof_type`, `valid`, `timestamp`).

## Verification
- Ensure trace entries include `decision_id`, `service_id`, `user_id` (if present), and `timestamp`.
- Confirm proofs match trace and are marked valid.

## Troubleshooting
- Verify storage backend: `CAIO_TRACE_STORAGE` (file or sqlite).
- Check storage path: `CAIO_TRACE_STORAGE_DIR` (default `logs/traceability`).
- Ensure traceability module is using persistent storage.


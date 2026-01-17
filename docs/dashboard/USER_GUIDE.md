# CAIO Configuration Dashboard User Guide

## Getting Started

1. Ensure the CAIO API is running.
2. Set `CAIO_API_URL` in Streamlit secrets or environment variables.
3. Launch the dashboard:
   ```bash
   streamlit run caio/dashboard/app.py
   ```

## Configuration Types

The dashboard manages **operational settings** only:

- **Policies:** rate limits, access rules, compliance rules, priorities.
- **Constraints:** latency, accuracy, cost budgets, resource quotas.
- **SLOs:** latency targets, availability, accuracy, throughput.
- **Tenant Settings:** quotas, feature flags, service access.

**Not configurable:** mathematical coefficients or invariants.

## Policy Configuration

- Use the **Policies** page to create and manage rate limits and access rules.
- Validate before saving to avoid invalid configurations.

## Constraint Configuration

- Use the **Constraints** page to set latency, accuracy, and cost budgets.
- Resource quotas are JSON-formatted.

## SLO Configuration

- Configure latency and availability targets in the **SLOs** page.
- Accuracy thresholds must be between 0 and 1.

## Tenant Management

- Manage tenant-specific quotas and feature flags.
- Service access is a JSON list of service IDs.

## Configuration History

- View versions and change history for each configuration.
- Roll back to a previous version if needed.

## Audit Trail

- Review every create/update/delete operation.
- Filter by configuration ID or change type.

## Best Practices

- Validate configurations before saving.
- Use descriptive names for policies and constraints.
- Review audit logs regularly for compliance tracking.

## Troubleshooting

- **Dashboard errors:** ensure CAIO API is running and `CAIO_API_URL` is correct.
- **Validation failures:** review error messages for required fields or value ranges.
- **Import errors:** ensure JSON payload is a list of configurations.

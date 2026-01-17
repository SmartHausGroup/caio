# CAIO Configuration Dashboard UI Mockups

## Dashboard Home

- **Overview cards:** total configurations, policies, constraints, SLOs, tenants.
- **Quick actions:** export configurations, import configurations.
- **Recent activity:** latest audit trail entries.

## Policies Configuration

- **Policy list** with expandable details.
- **Form fields:** name, rate limit, access rules, compliance rules, priority.
- **Validation status** indicator (client-side + server-side).

## Constraints Configuration

- **Constraint list** with metadata (latency, accuracy, cost).
- **Form fields:** name, max latency, min accuracy, cost budget, resource quotas.
- **Validation feedback** inline.

## SLOs Configuration

- **SLO list** with thresholds.
- **Form fields:** name, latency P95/P99, availability, accuracy threshold, throughput.
- **Validation feedback** inline.

## Tenant Management

- **Tenant list** with quotas and feature flags.
- **Form fields:** name, resource quotas, feature flags, service access.
- **Validation feedback** inline.

## Configuration History

- **Timeline** of versions per configuration.
- **Rollback** button for previous version.
- **Metadata** (changed by, timestamp, reason).

## Audit Trail

- **Change log** showing create/update/delete operations.
- **Filters:** configuration ID, change type.
- **Details:** old/new values, actor, timestamp, reason.

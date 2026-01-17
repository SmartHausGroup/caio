# CAIO License Management

## Overview

This guide documents the Phase 18 license management system for CAIO. The system provides:

- License generation for on-premises customers
- License distribution (optional SMTP email delivery)
- License tracking (activations and expiry monitoring)
- CLI utilities for operators

The license management system stores records in SQLite by default and integrates with Phase 17's
license validation and activation endpoints.

## Database Location

The default license database path is:

```
~/.caio/caio_licenses.db
```

Override with the environment variable:

```
CAIO_LICENSE_DB_PATH=/path/to/caio_licenses.db
```

## Generating Licenses

Use the CLI to generate and export license keys. The generator requires
`CAIO_LICENSE_SECRET` (or `--secret`) to sign keys.

Create a customer record first:

```bash
python scripts/licensing/manage_licenses.py add-customer CUST-001 "Acme Corp" --email ops@acme.test
```

```bash
CAIO_LICENSE_SECRET=your-secret \
python scripts/licensing/manage_licenses.py generate-license \
  CUST-001 standard \
  --expires-days 365 \
  --features analytics audit \
  --max-instances 5 \
  --max-services 100 \
  --max-requests-per-day 10000
```

## Distributing Licenses

To distribute by email, configure SMTP (optional) and use the CLI:

```bash
export CAIO_SMTP_SERVER="smtp.example.com"
export CAIO_SMTP_PORT=587
export CAIO_SMTP_USER="licensing@example.com"
export CAIO_SMTP_PASSWORD="..."
export CAIO_SMTP_SENDER="licensing@example.com"

CAIO_LICENSE_SECRET=your-secret \
python scripts/licensing/manage_licenses.py distribute-license \
  CUST-001 customer@example.com standard \
  --expires-days 365 \
  --send-email
```

If SMTP variables are not set, the license is still generated but email delivery is skipped.

## Tracking Licenses

Record activation events via the CAIO API or the CLI:

```bash
python scripts/licensing/manage_licenses.py track-activation \
  CAIO-v1-CUST-001-... \
  --instance-id instance-001 \
  --ip-address 203.0.113.10
```

View activation records:

```bash
python scripts/licensing/manage_licenses.py list-activations --license-key CAIO-v1-CUST-001-...
```

## License Statistics

```bash
python scripts/licensing/manage_licenses.py stats
```

The statistics summary includes total, active, expired, and expiring-soon license counts.

## Renewal Reminders

Generate a list of licenses expiring soon (default: 30 days):

```bash
python scripts/licensing/manage_licenses.py renewal-reminders --days 30
```

## License Exports

Export licenses for reporting:

```bash
CAIO_LICENSE_SECRET=your-secret \
python scripts/licensing/manage_licenses.py export-licenses --format csv
```

## API Integration

The Phase 17 licensing endpoints remain unchanged. Activation tracking is now recorded whenever
`/api/v1/licensing/activate` is called successfully. For richer tracking, send an instance identifier
via the `X-CAIO-Instance-ID` header.

## Troubleshooting

| Issue | Resolution |
| --- | --- |
| License generation fails | Ensure `CAIO_LICENSE_SECRET` is set |
| Email delivery skipped | Configure SMTP variables (see distribution section) |
| Database not found | Set `CAIO_LICENSE_DB_PATH` or run `init-db` |

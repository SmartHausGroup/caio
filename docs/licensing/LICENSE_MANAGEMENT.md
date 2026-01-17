# CAIO License Management

## Overview

This guide documents the Phase 18 license management system for CAIO. The system provides:

- License generation for on-premises customers
- License distribution (optional SMTP email delivery)
- License tracking (activations and expiry monitoring)
- CLI utilities for operators

The license management system stores records in SQLite by default and integrates with Phase 17's
license validation and activation endpoints.

Phase 21 upgrades license signing to an asymmetric model:
- **Private key**: used only for license generation (operator side).
- **Public key**: used for validation in customer builds.
- **License key**: `CAIO-v2-...` signed payload distributed to customers.

## Key Generation and Custody

Generate an RSA keypair for licensing:

```bash
./scripts/licensing/generate_keypair.sh ./keys
```

Key custody rules:
- Keep `private.pem` only on operator/admin systems or in an HSM/Vault.
- Never commit or ship the private key.
- Public key (`public.pem`) can be embedded in builds or provided via `CAIO_LICENSE_PUBLIC_KEY`.

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
`CAIO_LICENSE_PRIVATE_KEY` (or `--private-key`) to sign keys.

Create a customer record first:

```bash
python scripts/licensing/manage_licenses.py add-customer CUST-001 "Acme Corp" --email ops@acme.test
```

```bash
CAIO_LICENSE_PRIVATE_KEY=/path/to/private.pem \
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

CAIO_LICENSE_PRIVATE_KEY=/path/to/private.pem \
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
  CAIO-v2-CUST-001-... \
  --instance-id instance-001 \
  --ip-address 203.0.113.10
```

View activation records:

```bash
python scripts/licensing/manage_licenses.py list-activations --license-key CAIO-v2-CUST-001-...
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
python scripts/licensing/manage_licenses.py export-licenses --format csv
```

## API Integration

The Phase 17 licensing endpoints remain unchanged. Activation tracking is now recorded whenever
`/api/v1/licensing/activate` is called successfully. For richer tracking, send an instance identifier
via the `X-CAIO-Instance-ID` header.

## Migration Notes (v1 -> v2)

`CAIO-v1` HMAC-signed keys and `CAIO_LICENSE_SECRET` are deprecated. During a transition window,
validation can continue to accept `v1` if explicitly enabled, but all new generation should use `v2`.

## Key Rotation

Follow the runbook at `docs/operations/runbooks/license_key_rotation.md` for scheduled or emergency rotations.

## Troubleshooting

| Issue | Resolution |
| --- | --- |
| License generation fails | Ensure `CAIO_LICENSE_PRIVATE_KEY` is set and points to a valid PEM |
| Email delivery skipped | Configure SMTP variables (see distribution section) |
| Database not found | Set `CAIO_LICENSE_DB_PATH` or run `init-db` |

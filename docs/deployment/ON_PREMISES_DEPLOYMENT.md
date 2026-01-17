# CAIO On-Premises Deployment Guide

**Status:** Phase 17 — On-Premises Licensing Model  
**Last Updated:** 2026-01-12  
**Plan Reference:** `plan:EXECUTION_PLAN:17`

---

## Overview

This guide explains how to deploy CAIO on-premises using the dedicated licensing model. On-premises deployments require a valid license key and access to the CAIO public key used for validation.

---

## Prerequisites

- Docker 20+ installed (`docker --version`)
- A valid CAIO license key
- The CAIO public key (embedded in the build or provided as `public.pem`)
- A registry access token for the private CAIO image
- Access to this repository or the released CAIO on-premises package

---

## Installation (Docker)

1. **Authenticate and pull the private image**

   ```bash
   docker login registry.smarthaus.group
   docker pull registry.smarthaus.group/caio:v0.1.0
   ```

2. **Set license environment variables**

   ```bash
   export CAIO_LICENSE_KEY="your-license-key"
   export CAIO_LICENSE_PUBLIC_KEY="/path/to/public.pem"
   export CAIO_LICENSE_REQUIRED="true"
   ```

3. **Run the container**

   ```bash
   docker run -d \
     --name caio-on-prem \
     -p 8080:8080 \
     -e CAIO_LICENSE_KEY="$CAIO_LICENSE_KEY" \
     -e CAIO_LICENSE_PUBLIC_KEY="$CAIO_LICENSE_PUBLIC_KEY" \
     -e CAIO_LICENSE_REQUIRED="$CAIO_LICENSE_REQUIRED" \
     -e CAIO_ENV=production \
     -v "$CAIO_LICENSE_PUBLIC_KEY:/app/config/license_public.pem:ro" \
     registry.smarthaus.group/caio:v0.1.0
   ```

   For a ready-made compose file, see `deploy/customer/docker-compose.yml`.

---

## License Activation

If your license key is not preloaded, activate it via the licensing API:

```bash
curl -X POST http://localhost:8080/licensing/activate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin-token>" \
  -d '{"license_key": "your-license-key"}'
```

For more details, see `docs/deployment/LICENSE_ACTIVATION.md`.

---

## Configuration

### Required Environment Variables

| Variable | Description |
| --- | --- |
| `CAIO_LICENSE_KEY` | The on-premises license key |
| `CAIO_LICENSE_PUBLIC_KEY` | Public key used to validate license signatures |
| `CAIO_LICENSE_REQUIRED` | Set to `true` to enforce license checks |

### Optional Environment Variables

| Variable | Description | Default |
| --- | --- | --- |
| `CAIO_LICENSE_ENFORCEMENT` | `enforced` or `permissive` | `enforced` |
| `CAIO_ENV` | Runtime environment | `development` |
| `CAIO_API_PORT` | API port | `8080` |

---

## Verification

1. **Check health**
   ```bash
   curl http://localhost:8080/health
   ```

2. **Check license status**
   ```bash
   curl -H "Authorization: Bearer <admin-token>" \
     http://localhost:8080/licensing/status
   ```

---

## Troubleshooting

### License validation failed

- Verify `CAIO_LICENSE_KEY` and `CAIO_LICENSE_PUBLIC_KEY` are correct.
- Ensure the license has not expired.
- Confirm `CAIO_LICENSE_ENFORCEMENT` is set appropriately.

### Service not starting

- Check logs: `docker logs caio-on-prem`
- Ensure port `8080` is available
- Validate that required environment variables are set

---

## Support

For on-premises licensing support, contact **SmartHaus Group** at `info@smarthaus.group`.

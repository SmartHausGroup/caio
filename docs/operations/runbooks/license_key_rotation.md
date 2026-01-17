# Runbook: License Key Rotation

**Status:** Active  
**Last Updated:** 2026-01-17  
**Plan Reference:** `plan:EXECUTION_PLAN:21`

---

## Purpose

Rotate the CAIO licensing keypair when the private key is compromised or as part of a scheduled rotation policy.

---

## Triggers

- Suspected or confirmed private key exposure
- Scheduled key rotation (e.g., annual)
- Cryptography policy change (key size/algorithm)

---

## Prerequisites

- Access to the operator environment holding the current private key
- Access to the release pipeline that embeds or packages the public key
- Ability to notify customers and deliver updated license keys

---

## Procedure

1. **Generate a new keypair**
   ```bash
   ./scripts/licensing/generate_keypair.sh ./keys-rotation-YYYYMMDD
   ```

2. **Secure the new private key**
   - Store `private.pem` in HSM/Vault or a secured offline system.
   - Restrict access to licensing operators only.

3. **Update the public key in builds**
   - Replace the embedded public key or ship a new `public.pem`.
   - Update `CAIO_LICENSE_PUBLIC_KEY` guidance for customers if externalized.

4. **Re-issue licenses**
   - Generate new `CAIO-v2` keys signed with the new private key.
   - Communicate cutover date and deployment steps to customers.

5. **Deploy updated releases**
   - Publish new Docker images and/or wheels.
   - Validate the public key is included in the shipped artifact.

6. **Monitor and validate**
   - Validate activation and status endpoints for rotated licenses.
   - Monitor logs for signature validation failures.

7. **Sunset old keys**
   - Set a clear deadline for old license keys if dual-key validation is supported.
   - Remove legacy public key support after the deadline.

---

## Validation Checklist

- New `CAIO-v2` license key validates with the new public key.
- Existing deployments update to the new build or `CAIO_LICENSE_PUBLIC_KEY`.
- No increase in activation/validation errors post-rotation.

---

## Rollback

- Revert to the previous public key in the build.
- Re-issue licenses signed with the previous private key if required.
- Communicate rollback and revised rotation plan to customers.

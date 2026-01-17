# CAIO License Activation Guide

**Status:** Phase 17 — On-Premises Licensing Model  
**Last Updated:** 2026-01-12  
**Plan Reference:** `plan:EXECUTION_PLAN:17`

---

## Obtaining a License Key

Contact SmartHaus Group to obtain your CAIO license key and registry access. The public key used for
validation is embedded in the build or provided as a PEM file. Keep the license key secure and do
**not** commit it to source control.

---

## Activating a License

1. **Ensure the license public key is configured (if not embedded)**

   ```bash
   export CAIO_LICENSE_PUBLIC_KEY="/path/to/public.pem"
   ```

2. **Activate via API**

   ```bash
   curl -X POST http://localhost:8080/licensing/activate \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <admin-token>" \
     -d '{"license_key": "your-license-key"}'
   ```

3. **Expected response**

   ```json
   {
     "status": "activated",
     "customer_id": "CUST123",
     "expires_at": "2027-01-12T00:00:00+00:00"
   }
   ```

---

## Verifying License Status

```bash
curl -H "Authorization: Bearer <admin-token>" \
  http://localhost:8080/licensing/status
```

---

## License Renewal

If your license expires, obtain a new license key from SmartHaus Group and activate it using the same `/licensing/activate` endpoint.

---

## Troubleshooting

### Invalid license key
- Verify the key was copied correctly.
- Ensure the runtime is using the matching public key.

### License expired
- Request a renewed license from SmartHaus Group.
- Activate the new license key.

### License validation not configured
- Ensure `CAIO_LICENSE_PUBLIC_KEY` is set (or embedded in the build).
- Verify the CAIO service restarted after setting environment variables.

---

## Support

For licensing support, contact **SmartHaus Group** at `info@smarthaus.group`.

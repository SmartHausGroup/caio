# CAIO License Activation Guide

**Status:** Phase 17 — On-Premises Licensing Model  
**Last Updated:** 2026-01-12  
**Plan Reference:** `plan:EXECUTION_PLAN:17`

---

## Obtaining a License Key

Contact SmartHaus Group to obtain your CAIO license key and license secret. Keep both values secure and do **not** commit them to source control.

---

## Activating a License

1. **Ensure the license secret is configured**

   ```bash
   export CAIO_LICENSE_SECRET="your-license-secret"
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
- Ensure you are using the matching license secret.

### License expired
- Request a renewed license from SmartHaus Group.
- Activate the new license key.

### License validation not configured
- Ensure `CAIO_LICENSE_SECRET` is set.
- Verify the CAIO service restarted after setting environment variables.

---

## Support

For licensing support, contact **SmartHaus Group** at `info@smarthaus.group`.

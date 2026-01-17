# Codex Prompt: License Revocation

## Executive Summary
Implement license revocation logic in CAIO to allow operational control over customer access.

## Context & Background
The current licensing system can generate and validate keys but lacks the ability to revoke them. The database has a `status` column, but it's not being used.

## Target State
- Licenses can be marked as 'revoked' via CLI.
- The `LicenseValidator` rejects any license not in 'active' status.
- API activation routes return an error for revoked licenses.

## Implementation Instructions

### Step 1: Update LicenseDatabase
Modify `caio/licensing/database.py`:
- Add `update_license_status(license_key: str, status: str) -> bool` method.
- Ensure it updates the `status` column in the `licenses` table.

### Step 2: Update LicenseGenerationService
Modify `caio/licensing/generation_service.py`:
- Add `revoke_license(license_key: str) -> bool` method that calls `update_license_status(license_key, "revoked")`.

### Step 3: Update LicenseValidator
Modify `caio/licensing/validator.py`:
- Update `load_license` and `validate_license_key` to check the status of the metadata.
- If status is not 'active', return `(False, "License revoked")`.

### Step 4: Add CLI Command
Modify `scripts/licensing/manage_licenses.py`:
- Add a `revoke-license` subparser and command.
- It should take `license_key` as an argument.

### Step 5: Update API Routes
Modify `caio/api/routes/licensing.py`:
- Ensure `activate_license` and `renew_license` check the return value of `validator.load_license` and propagate the "revoked" error.

## Validation Procedures
1. Generate a test license: `python scripts/licensing/manage_licenses.py generate-license ...`
2. Revoke it: `python scripts/licensing/manage_licenses.py revoke-license <key>`
3. Verify rejection via CLI: `python scripts/licensing/manage_licenses.py validate-license <key>` (should fail).
4. Verify rejection via API: `curl -X POST .../activate-license` (should return error).

## Success Criteria
- [ ] License revocation persists in database.
- [ ] Validator rejects revoked licenses.
- [ ] CLI command functional.
- [ ] API endpoints reject revoked keys.

## Plan Reference
`plan:license-revocation`

## North Star Alignment
Aligns with "Security Built into Math" and "Traceability" by ensuring all access decisions are controlled and logged.

# Gateway API Versioning & Compatibility

## Goals

- Maintain stable adapter behavior across provider API changes.
- Keep contract templates aligned with provider versioning policies.
- Provide clear migration steps when endpoints or payloads change.

## Contract Versioning

Each contract template includes a `version` field (semver) for the contract itself, not the
provider’s API version. Increment the contract version when:

- Endpoint paths change.
- Request/response payloads change.
- Capabilities or guarantees change materially.

## Provider API Versioning

Some providers expose explicit API versions (e.g., `v1`, `2023-xx-xx`). Encode the provider version
in one of these locations:

- `api.endpoints[].path` (preferred when version is in the URL path)
- `metadata.api_version` (when version is in headers or query params)

## Compatibility Policy

1. **Minor provider changes:** Update adapter logic and contract metadata without breaking contract
   version compatibility.
2. **Major provider changes:** Create a new contract version and adapter update; keep the previous
   contract available until migrations complete.
3. **Deprecations:** Document deprecation timelines in the contract metadata and
   `docs/gateway/TROUBLESHOOTING.md`.

## Validation Recommendations

- Validate contracts with `caio_sdk.validate_contract` (or the `caio.sdk` compatibility shim).
- Test adapters with provider sandbox or staging endpoints whenever available.

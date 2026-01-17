# External Services Integration Guide

**Status:** Active  
**Last Updated:** 2026-01-08  
**Owner:** @smarthaus

---

## Overview

CAIO supports integration of external services (services not controlled by TAI) via the same contract-based discovery system used for internal services. External services register with CAIO using YAML contracts, enabling them to be discovered, routed, and orchestrated alongside internal services.

---

## Architecture

External services integrate with CAIO through:

1. **Bridge Service (HTTP Wrapper):** External services that do not natively support HTTP/gRPC are wrapped in a bridge service that exposes them via REST API.
2. **Service Contract (YAML):** External services define their capabilities, guarantees, and API details in a YAML contract.
3. **Service Registration:** External services register with CAIO via `POST /api/v1/register-service` or the CAIO SDK.
4. **Service Discovery:** CAIO discovers external services using the same contract-based matching algorithm as internal services.

---

## Integration Pattern

### Step 1: Create Bridge Service (if needed)

If the external service does not natively support HTTP/gRPC, create a bridge service:

```
services/external/{service-name}/
├── api/
│   └── routes.py          # FastAPI routes
├── core/
│   └── {service}_client.py  # Service SDK wrapper
├── main.py                # FastAPI app entry point
├── requirements.txt       # Dependencies
└── README.md              # Service documentation
```

**Example:** See `services/external/codex/` for Codex bridge service implementation.

### Step 2: Create Service Contract

Create a YAML contract following `configs/schemas/service_contract.schema.yaml`:

```yaml
service:
  id: {service-id}
  name: {Service Name}
  version: 1.0.0
  capabilities:
    - type: {capability_type}
  guarantees:
    latency:
      property: p95_latency_ms
      bound:
        max: 5000
  api:
    protocol: http
    base_url: http://localhost:{port}
    endpoints:
      - path: /{endpoint}
        method: POST
```

**Example:** See `configs/services/external/codex.yaml` for Codex contract.

### Step 3: Register Service

Register the service with CAIO:

```python
import json
import yaml
from urllib import request

with open("configs/services/external/{service}.yaml", "r") as f:
    contract = yaml.safe_load(f)

payload = json.dumps({"contract": contract}).encode("utf-8")
req = request.Request("http://localhost:8080/api/v1/register-service", data=payload, headers={"Content-Type": "application/json"})
request.urlopen(req)
```

**Example:** See `scripts/register_codex_service.py` for Codex registration.

---

## Examples

### Codex Integration

Codex is integrated as the first external service example:

- **Bridge Service:** `services/external/codex/`
- **Service Contract:** `configs/services/external/codex.yaml`
- **Registration Script:** `scripts/register_codex_service.py`
- **Integration Tests:** `services/external/codex/tests/test_integration.py`

See `services/external/codex/README.md` for detailed documentation.

---

## Future: Marketplace Integration

In the future, external services will be built separately and registered via the CAIO SDK/marketplace. The initial directory structure (`services/external/`) is for development and examples. Production external services will be deployed independently and register with CAIO via the marketplace API.

---

## References

- **Service Contract Schema:** `configs/schemas/service_contract.schema.yaml`
- **Service Registration API:** `docs/api/API_REFERENCE.md`
- **CAIO SDK:** `docs/SDK_SPECIFICATION.md`
- **North Star:** `docs/NORTH_STAR.md`

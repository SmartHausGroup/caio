# CAIO HTTP API Prototype

This document provides curl examples for CAIO's HTTP API.

## Prerequisites

1. Start the CAIO server (with an admin token):

```bash
export CAIO_AUTH_TOKEN=local-dev-token
export CAIO_AUTH_ROLE=admin
uvicorn caio.api.app:app --port 8080
```

2. Verify health:

```bash
curl http://localhost:8080/health
```

Expected response:

```json
{
  "status": "healthy",
  "version": "1.0.0",
  "uptime_seconds": 12.34,
  "components": {
    "orchestrator": "ok",
    "registry": "ok",
    "traceability": "ok"
  }
}
```

## Authentication

All `/api/v1/*` endpoints require an Authorization header. Use the token you set above:

```bash
-H "Authorization: Bearer local-dev-token"
```

## Service Registration

Register a service contract using JSON.

```bash
curl -X POST http://localhost:8080/api/v1/register-service \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer local-dev-token' \
  -d '{
    "contract": {
      "service_id": "demo-chat-service",
      "name": "Demo Chat Service",
      "version": "1.0.0",
      "description": "A simple demo chat service for CAIO prototype",
      "capabilities": [
        {"type": "chat", "accuracy": {"min": 0.90, "target": 0.95}}
      ],
      "guarantees": {
        "accuracy": 0.95,
        "determinism": true
      },
      "constraints": {
        "requires_gpu": false,
        "requires_internet": false
      },
      "api": {
        "protocol": "http",
        "base_url": "http://localhost:9000",
        "endpoints": [
          {"path": "/chat", "method": "POST"}
        ]
      },
      "metadata": {
        "tags": ["chat", "demo"],
        "category": "ai-service",
        "provider": "demo-provider"
      }
    }
  }'
```

Expected response:

```json
{
  "service_id": "demo-chat-service",
  "status": "registered",
  "message": "Service demo-chat-service registered successfully"
}
```

Optional: convert a YAML contract to JSON before POSTing:

```bash
python - <<'PY'
import json
import yaml

with open("configs/services/external/codex.yaml", "r", encoding="utf-8") as f:
    data = yaml.safe_load(f)

print(json.dumps({"contract": data}, indent=2))
PY
```

## List Services

```bash
curl http://localhost:8080/api/v1/services \
  -H 'Authorization: Bearer local-dev-token'
```

Expected response:

```json
{
  "services": [
    {
      "service_id": "demo-chat-service",
      "service_name": "Demo Chat Service",
      "version": "1.0.0",
      "capabilities": [{"type": "chat", "accuracy": {"min": 0.90, "target": 0.95}}],
      "guarantees": {"accuracy": 0.95, "determinism": true},
      "status": "unknown"
    }
  ],
  "count": 1
}
```

## Orchestration Request

Make an orchestration request to CAIO:

```bash
curl -X POST http://localhost:8080/api/v1/orchestrate \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer local-dev-token' \
  -d '{
    "request": {
      "intent": {"type": "chat", "message": "Hello, CAIO!"},
      "context": {"conversation_id": "demo-123"},
      "requirements": {"capabilities": ["chat"], "guarantees": {"accuracy": {"min": 0.9}}},
      "constraints": {"requires_gpu": false},
      "user": {"trust_level": 1}
    },
    "policies": [],
    "context": {}
  }'
```

Expected response:

```json
{
  "decision_id": "dec-1234567890",
  "service_id": "demo-chat-service",
  "service_name": "demo-chat-service",
  "guarantees": {
    "accuracy": 0.95,
    "determinism": true
  },
  "proofs": [
    {"proof_type": "contract_matching", "valid": true},
    {"proof_type": "rule_satisfaction", "valid": true},
    {"proof_type": "security", "valid": true}
  ],
  "trace": {
    "request": {"intent": {"type": "chat", "message": "Hello, CAIO!"}},
    "decision": {"service_id": "demo-chat-service"},
    "timestamp": "2026-01-08T14:35:29Z"
  }
}
```

## Trace Retrieval

Retrieve trace for a routing decision:

```bash
curl http://localhost:8080/api/v1/trace/dec-1234567890 \
  -H 'Authorization: Bearer local-dev-token'
```

Expected response:

```json
{
  "decision_id": "dec-1234567890",
  "request": {"intent": {"type": "chat", "message": "Hello, CAIO!"}},
  "decision": {"service_id": "demo-chat-service"},
  "proofs": [
    {"proof_type": "contract_matching", "valid": true}
  ],
  "guarantees": {
    "accuracy": 0.95,
    "determinism": true
  },
  "timestamp": "2026-01-08T14:35:29Z"
}
```

## Health Check

```bash
curl http://localhost:8080/health
```

Expected response:

```json
{
  "status": "healthy",
  "components": {
    "orchestrator": "ok",
    "registry": "ok",
    "traceability": "ok"
  }
}
```

## Expected Responses

- `200 OK` for health, list services, trace retrieval
- `200 OK` for register-service and orchestrate when contract and request are valid
- `400 Bad Request` for contract validation errors or no matching services
- `401 Unauthorized` if the Authorization token is missing or invalid
- `404 Not Found` for unknown trace IDs

## Troubleshooting

- **401/403 responses:** Ensure you started the server with `CAIO_AUTH_TOKEN` and include the Authorization header.
- **400 contract validation error:** Verify required fields (service_id, name, version, api, capabilities).
- **No matching services:** Confirm the request requirements match the registered contract capabilities.
- **Trace not found:** Use the `decision_id` returned by the orchestrate response.

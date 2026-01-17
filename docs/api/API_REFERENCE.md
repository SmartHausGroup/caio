# CAIO API Reference

**Status**: Active  
**Last Updated**: 2026-01-15  
**Owner**: @smarthaus

---

## Overview

CAIO provides a REST API for service registration, discovery, routing, and orchestration. The API is designed to be universal, supporting any AI service that registers with a CAIO-compatible contract.

**Note:** Core endpoints are active for local development. Configuration dashboard endpoints are available under `/configurations`.

---

## Base URL

**Default:** `http://localhost:8000` (configurable via `CAIO_URL` environment variable)

---

## Authentication

Currently, CAIO does not require authentication for local development. Production deployments will support authentication via API keys or OAuth2.

---

## Endpoints

### Health Check

#### GET /health

Health check endpoint to verify CAIO is running.

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2025-01-XXT00:00:00Z"
}
```

**Status Codes:**
- `200 OK`: CAIO is healthy
- `503 Service Unavailable`: CAIO is unavailable

---

### Update Management

#### POST /api/v1/update

Initiate the update process for CAIO.

**Authentication:** Admin role required

**Request Body:**
```json
{
  "target_version": "0.1.1"
}
```

**Response:**
```json
{
  "status": "updating",
  "progress": 50,
  "message": "Downloading update package...",
  "requires_restart": true,
  "error": null
}
```

**Status Codes:**
- `200 OK`: Update started or completed
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Non-admin role

---

#### POST /api/v1/restart

Restart CAIO after an update.

**Authentication:** Admin role required

**Request Body:**
```json
{
  "graceful": true
}
```

**Response:**
```json
{
  "status": "restarting",
  "message": "CAIO restarting..."
}
```

**Status Codes:**
- `200 OK`: Restart initiated
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Non-admin role

---

#### GET /api/v1/version

Return the current running version of CAIO.

**Authentication:** None (public)

**Response:**
```json
{
  "version": "0.1.0",
  "build_date": "2026-01-14T10:30:00Z",
  "commit": "abc123def456"
}
```


### Service Discovery

#### POST /api/discover

Discover services by capability using contract-based matching (mathematical set intersection).

**Request Body:**
```json
{
  "capability": "model_inference",
  "constraints": {
    "max_latency_ms": 1000,
    "min_throughput_tokens_per_sec": 10
  },
  "traits": {
    "intent_mode": "chat",
    "trait_mode": "conversational"
  }
}
```

**Response:**
```json
{
  "services": [
    {
      "service_id": "vfe-001",
      "name": "Verbum Field Engine",
      "version": "1.0.0",
      "base_url": "http://localhost:8081",
      "capabilities": ["model_inference"],
      "guarantees": {
        "latency_ms": 500,
        "throughput_tokens_per_sec": 50
      },
      "cost_per_token": 0.0001
    }
  ],
  "proof": {
    "matching_contracts": ["vfe-001"],
    "rule_satisfaction": true,
    "security_verified": true
  }
}
```

**Status Codes:**
- `200 OK`: Discovery successful
- `400 Bad Request`: Invalid request body
- `500 Internal Server Error`: Discovery failed

---

### Service Registration

#### POST /api/services/register

Register a new service with CAIO using a service contract.

**Request Body:**
```json
{
  "service_id": "vfe-001",
  "name": "Verbum Field Engine",
  "version": "1.0.0",
  "base_url": "http://localhost:8081",
  "protocol": "http",
  "contract_path": "/path/to/service_contract.yaml",
  "contract": {
    "capabilities": ["model_inference"],
    "guarantees": {
      "latency_ms": 500,
      "throughput_tokens_per_sec": 50
    },
    "constraints": {
      "max_concurrent_requests": 10
    },
    "cost_per_token": 0.0001
  }
}
```

**Response:**
```json
{
  "service_id": "vfe-001",
  "status": "registered",
  "contract_validated": true,
  "timestamp": "2025-01-XXT00:00:00Z"
}
```

**Status Codes:**
- `201 Created`: Service registered successfully
- `400 Bad Request`: Invalid contract or request body
- `409 Conflict`: Service already registered
- `500 Internal Server Error`: Registration failed

---

### Get Service

#### GET /api/services/{service_id}

Get service details from the registry.

**Response:**
```json
{
  "service_id": "vfe-001",
  "name": "Verbum Field Engine",
  "version": "1.0.0",
  "base_url": "http://localhost:8081",
  "protocol": "http",
  "capabilities": ["model_inference"],
  "guarantees": {
    "latency_ms": 500,
    "throughput_tokens_per_sec": 50
  },
  "status": "active",
  "registered_at": "2025-01-XXT00:00:00Z"
}
```

**Status Codes:**
- `200 OK`: Service found
- `404 Not Found`: Service not found
- `500 Internal Server Error`: Error retrieving service

---

### List Services

#### GET /api/services

List all registered services.

**Query Parameters:**
- `capability` (optional): Filter by capability
- `status` (optional): Filter by status (`active`, `inactive`)

**Response:**
```json
{
  "services": [
    {
      "service_id": "vfe-001",
      "name": "Verbum Field Engine",
      "capabilities": ["model_inference"],
      "status": "active"
    }
  ],
  "total": 1
}
```

---

### Configuration Management

Configuration endpoints support operational settings (policies, constraints, SLOs, tenant settings).

#### POST /configurations
Create a configuration record.

#### GET /configurations
List configurations with optional filters (`tenant_id`, `config_type`).

#### GET /configurations/{config_id}
Get a configuration by ID.

#### PUT /configurations/{config_id}
Update a configuration (versioned).

#### DELETE /configurations/{config_id}
Delete a configuration.

#### GET /configurations/{config_id}/history
Retrieve version history.

#### POST /configurations/{config_id}/rollback/{version}
Rollback to a previous version.

#### POST /configurations/validate
Validate configuration payloads without saving.

#### GET /configurations/audit
List configuration audit changes.

#### GET /configurations/export
Export configuration snapshots.

#### POST /configurations/import
Import configuration snapshots.

See `docs/api/CONFIGURATION_API.md` for full request/response examples.

**Status Codes:**
- `200 OK`: List retrieved successfully
- `500 Internal Server Error`: Error retrieving list

---

### Route Request

#### POST /api/route

Route a request to the optimal service using the master equation.

**Request Body:**
```json
{
  "request": {
    "intent": "chat_completion",
    "traits": {
      "intent_mode": "chat",
      "trait_mode": "conversational"
    },
    "payload": {
      "messages": [
        {"role": "user", "content": "Hello!"}
      ]
    }
  },
  "constraints": {
    "max_latency_ms": 1000,
    "max_cost_per_token": 0.001
  },
  "policies": {
    "require_encryption": true,
    "allow_external_services": false
  }
}
```

**Response:**
```json
{
  "decision": {
    "service_id": "vfe-001",
    "service_url": "http://localhost:8081/v1/chat/completions",
    "method": "POST",
    "headers": {
      "Authorization": "Bearer token"
    }
  },
  "proof": {
    "master_equation_score": 0.95,
    "contract_match": true,
    "rule_satisfaction": true,
    "security_verified": true,
    "guarantee_composition": {
      "latency_ms": 500,
      "throughput_tokens_per_sec": 50
    }
  },
  "trace": {
    "trace_id": "trace-001",
    "timestamp": "2025-01-XXT00:00:00Z",
    "decision_path": [
      "contract_matching",
      "rule_evaluation",
      "security_verification",
      "optimization"
    ]
  }
}
```

**Status Codes:**
- `200 OK`: Routing successful
- `400 Bad Request`: Invalid request
- `404 Not Found`: No matching service found
- `500 Internal Server Error`: Routing failed

---

### Get Trace

#### GET /api/traces/{trace_id}

Retrieve a trace record for a routing decision.

**Response:**
```json
{
  "trace_id": "trace-001",
  "timestamp": "2025-01-XXT00:00:00Z",
  "request": {
    "intent": "chat_completion",
    "traits": {
      "intent_mode": "chat",
      "trait_mode": "conversational"
    }
  },
  "decision": {
    "service_id": "vfe-001",
    "service_url": "http://localhost:8081/v1/chat/completions"
  },
  "proof": {
    "master_equation_score": 0.95,
    "contract_match": true,
    "rule_satisfaction": true,
    "security_verified": true
  },
  "audit_trail": [
    {
      "step": "contract_matching",
      "timestamp": "2025-01-XXT00:00:00Z",
      "result": "matched"
    }
  ]
}
```

**Status Codes:**
- `200 OK`: Trace found
- `404 Not Found`: Trace not found
- `500 Internal Server Error`: Error retrieving trace

---

## Error Responses

All error responses follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      "field": "additional error details"
    }
  }
}
```

**Common Error Codes:**
- `INVALID_CONTRACT`: Service contract is invalid
- `SERVICE_NOT_FOUND`: Service not found in registry
- `NO_MATCHING_SERVICE`: No service matches the request
- `SECURITY_VIOLATION`: Security constraint violated
- `RULE_VIOLATION`: Policy rule violated
- `INTERNAL_ERROR`: Internal server error

---

## Rate Limiting

Rate limiting will be implemented in Phase 6. Current limits (planned):
- 100 requests per minute per API key
- 1000 requests per hour per API key

---

## Versioning

API versioning will be implemented in Phase 6. Current version: `v1` (planned).

---

## References

- **SDK Specification:** `docs/SDK_SPECIFICATION.md` - Service implementation interface
- **North Star:** `docs/NORTH_STAR.md` - Mathematical foundations
- **Master Calculus:** `docs/math/CAIO_MASTER_CALCULUS.md` - Routing mathematics

# CAIO User Guide

**Status**: Active  
**Last Updated**: 2025-01-XX  
**Owner**: @smarthaus

---

## Overview

This guide provides information for users of CAIO, including getting started, service registration, service discovery, and routing requests.

**Note:** CAIO is currently in development. The API and service implementation are planned for Phase 6. This guide describes the expected functionality.

---

## Getting Started

### What is CAIO?

CAIO (Coordinatio Auctus Imperium Ordo) is a universal AI orchestration platform that provides:

- **Mathematical Guarantees:** Every routing decision is provable and traceable
- **Contract-Based Discovery:** Services register with YAML contracts
- **Security Built into Math:** Security properties are mathematical invariants
- **Hot-Swappable Services:** Services can be added/removed dynamically
- **Universal Compatibility:** Works with any AI service

---

## Service Registration

### Creating a Service Contract

Services register with CAIO using YAML contracts. A contract defines:

- **Capabilities:** What the service can do (e.g., `model_inference`, `embeddings`)
- **Guarantees:** Performance guarantees (e.g., latency, throughput)
- **Constraints:** Service constraints (e.g., max concurrent requests)
- **Costs:** Cost per token or per request

**Example Contract:**

```yaml
service_id: vfe-001
name: Verbum Field Engine
version: 1.0.0
base_url: http://localhost:8081
protocol: http

capabilities:
  - model_inference
  - embeddings

guarantees:
  latency_ms: 500
  throughput_tokens_per_sec: 50
  availability: 0.99

constraints:
  max_concurrent_requests: 10
  max_tokens_per_request: 4096

cost_per_token: 0.0001
```

### Registering a Service

**Planned API Endpoint:** `POST /api/services/register`

```bash
curl -X POST http://localhost:8003/api/services/register \
  -H "Content-Type: application/json" \
  -d '{
    "service_id": "vfe-001",
    "name": "Verbum Field Engine",
    "version": "1.0.0",
    "base_url": "http://localhost:8081",
    "protocol": "http",
    "contract": {
      "capabilities": ["model_inference"],
      "guarantees": {
        "latency_ms": 500,
        "throughput_tokens_per_sec": 50
      },
      "cost_per_token": 0.0001
    }
  }'
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

---

## Service Discovery

### Discovering Services by Capability

**Planned API Endpoint:** `POST /api/discover`

CAIO uses mathematical set intersection for service discovery. You specify the capability you need, and CAIO finds all services that match.

**Example:**
```bash
curl -X POST http://localhost:8003/api/discover \
  -H "Content-Type: application/json" \
  -d '{
    "capability": "model_inference",
    "constraints": {
      "max_latency_ms": 1000,
      "min_throughput_tokens_per_sec": 10
    }
  }'
```

**Response:**
```json
{
  "services": [
    {
      "service_id": "vfe-001",
      "name": "Verbum Field Engine",
      "base_url": "http://localhost:8081",
      "capabilities": ["model_inference"],
      "guarantees": {
        "latency_ms": 500,
        "throughput_tokens_per_sec": 50
      }
    }
  ],
  "proof": {
    "matching_contracts": ["vfe-001"],
    "rule_satisfaction": true,
    "security_verified": true
  }
}
```

---

## Routing Requests

### Routing a Request

**Planned API Endpoint:** `POST /api/route`

CAIO routes requests to the optimal service using the master equation, considering:

- **Intent and Traits:** What the request needs
- **Constraints:** Performance and cost constraints
- **Policies:** Security and policy rules
- **Guarantees:** Service guarantees

**Example:**
```bash
curl -X POST http://localhost:8003/api/route \
  -H "Content-Type: application/json" \
  -d '{
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
    }
  }'
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
    "security_verified": true
  },
  "trace": {
    "trace_id": "trace-001",
    "timestamp": "2025-01-XXT00:00:00Z"
  }
}
```

---

## Traceability

### Retrieving a Trace

**Planned API Endpoint:** `GET /api/traces/{trace_id}`

Every routing decision has a trace record with a proof. You can retrieve the trace to audit decisions.

**Example:**
```bash
curl http://localhost:8003/api/traces/trace-001
```

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

---

## Configuration

See `docs/configuration/CONFIGURATION.md` for configuration options.

---

## Troubleshooting

### Service Not Found

- **Check service registration:** Verify the service is registered
- **Check capability match:** Ensure the service has the required capability
- **Check constraints:** Verify constraints are not too restrictive

### Routing Fails

- **Check policies:** Verify policies are not blocking the request
- **Check security:** Ensure security constraints are satisfied
- **Check guarantees:** Verify service guarantees meet requirements

### Trace Not Found

- **Check trace_id:** Verify the trace ID is correct
- **Check retention:** Traces may be expired or archived

---

## FAQ

### Q: How does CAIO guarantee routing decisions?

A: CAIO uses mathematical proofs. Every routing decision is computed using the master equation, and the proof is stored in the trace record.

### Q: Can I use CAIO with external services?

A: Yes! CAIO is designed to work with any AI service. Services register with CAIO using contracts, regardless of whether they're internal or external.

### Q: How do I add a new service?

A: Create a service contract (YAML) and register it with CAIO using the registration API.

### Q: How does CAIO handle security?

A: Security is built into the math. Security properties are mathematical invariants that must be satisfied before routing.

### Q: Can I customize routing rules?

A: Yes! CAIO supports policy rules that can be configured to customize routing behavior.

---

## References

- **API Reference:** `docs/api/API_REFERENCE.md`
- **SDK Specification:** `docs/SDK_SPECIFICATION.md`
- **North Star:** `docs/NORTH_STAR.md`
- **Developer Guide:** `docs/developer/DEVELOPER_GUIDE.md`


# CAIO-TAI Integration Guide

## Overview

CAIO serves as the orchestration layer for TAI, providing mathematical guarantees for routing
decisions between TAI services (RFS, VFE, VEE, NME) and external services.

**CAIO's Role in TAI:**
- **Service Orchestration:** Routes requests to appropriate TAI services or external services.
- **Mathematical Guarantees:** Every routing decision is provable and traceable.
- **Contract-Based Discovery:** TAI services register with CAIO using YAML contracts.
- **Universal Compatibility:** Works with any AI service (internal or external).

**Integration Points:**
- **MAIA:** Uses CAIO for routing decisions based on intent field measurements.
- **TAI Services:** RFS, VFE, VEE, NME register with CAIO as internal services.
- **TAI Frontend:** Uses CAIO API for service orchestration.
- **External Services:** Marketplace services register via same contract system.

## Installation

### Internal TAI Development (Recommended)

Since TAI and CAIO are developed together internally:

```bash
# Clone CAIO repository
git clone https://github.com/SmartHausGroup/CAIO.git
cd CAIO

# Install in editable mode
pip install -e .
```

### Enterprise / Standalone Integration

For TAI deployments in enterprise environments (where source code is not available):

**Option A: Private Docker (Recommended)**
```bash
docker pull smarthaus/caio:v0.1.0
```

**Option B: Python Wheel**
```bash
pip install https://download.smarthaus.group/caio-0.1.0-py3-none-any.whl?token=LICENSE_KEY
```

See `docs/deployment/PACKAGING.md` for detailed distribution strategies.

## Licensing Configuration

CAIO requires a license key for operation (even in embedded mode).

**Environment Variable:**
```bash
export CAIO_LICENSE_KEY="your-license-key"
```

**Programmatic Configuration:**
```python
from caio.config import CAIOConfig

config = CAIOConfig()
config.license_key = "your-license-key"
```

## Programmatic Integration

### Using CAIO Orchestrator Directly

```python
from caio import Orchestrator, Request

# Create orchestrator
orchestrator = Orchestrator()

# Register TAI service (e.g., RFS)
orchestrator.register_service(contract_path="configs/services/internal/rfs.yaml")

# Make orchestration request
request = Request(
    intent={"type": "memory_retrieval", "query": "user preferences"},
    context={"conversation_id": "conv-123"},
    requirements={"capability": "memory", "data_locality": "local"},
    constraints={"requires_gpu": False},
    user={"trust_level": "high"},
)

# Route request
decision = orchestrator.route_request(
    request=request,
    policies=[],
    history={},
    seed=42,
)

# Use routing decision
print(f"Selected service: {decision.service_id}")
print(f"Guarantees: {decision.guarantees}")
```

### Service Registration Pattern

TAI services register with CAIO using YAML contracts:

```yaml
# configs/services/internal/rfs.yaml
service_id: rfs
name: Resonant Field Storage
version: "1.0.0"
capabilities:
  - type: memory_retrieval
  - type: memory_storage
guarantees:
  latency:
    property: p95_latency_ms
    bound:
      max: 50
api:
  protocol: http
  base_url: http://localhost:8001
  endpoints:
    - path: /memory/retrieve
      method: POST
```

**Registration Code:**
```python
from caio import Orchestrator

orchestrator = Orchestrator()
entry = orchestrator.register_service("configs/services/internal/rfs.yaml")
```

See `docs/SDK_SPECIFICATION.md` for complete service contract schema.

## HTTP API Integration

### Start CAIO Server

```bash
uvicorn caio.api.app:app --port 8080
```

### Register TAI Service

```bash
curl -X POST http://localhost:8080/api/v1/register-service \
  -H 'Content-Type: application/yaml' \
  -d @configs/services/internal/rfs.yaml
```

### Make Orchestration Request

```bash
curl -X POST http://localhost:8080/api/v1/orchestrate \
  -H 'Content-Type: application/json' \
  -d '{
    "request": {
      "intent": {"type": "memory_retrieval"},
      "requirements": {"capability": "memory"},
      "constraints": {"data_locality": "local"}
    }
  }'
```

### Retrieve Trace

```bash
curl http://localhost:8080/api/v1/trace/{decision_id}
```

See `docs/prototype/API_PROTOTYPE.md` for detailed API examples.

## MAIA Integration

MAIA uses CAIO for routing decisions based on intent field measurements.

**Integration Pattern:**
1. MAIA measures intent field (Ψ_i)
2. MAIA creates CAIO request with intent field data
3. CAIO routes request using master equation
4. CAIO returns routing decision with control signal (u*)
5. MAIA uses control signal to update intent field evolution

**Example:**
```python
from caio import Orchestrator, Request

# MAIA intent field measurement
intent_modes = {"high_frequency": 0.8, "low_frequency": 0.2}

# Create CAIO request
request = Request(
    intent={"field_modes": intent_modes, "type": "chat"},
    context={"maia_state": "active"},
    requirements={"capability": "chat", "latency": "low"},
    constraints={"requires_gpu": True},
    user={"trust_level": "high"},
)

# Route through CAIO
decision = orchestrator.route_request(request, policies=[], history={}, seed=42)

# Use control signal for MAIA
control_signal = decision.control_signal
# Feed back to MAIA intent field evolution
```

See `docs/math/CAIO_CONTROL_CALCULUS.md` for control signal mathematics.

## Configuration

### Environment Variables

```bash
# CAIO Server Configuration
CAIO_HOST=0.0.0.0
CAIO_PORT=8080
CAIO_LOG_LEVEL=INFO

# Security Configuration
CAIO_API_KEY=<your-api-key-here>
CAIO_ALLOWED_ORIGINS=http://localhost:3000

# Service Registry Configuration
CAIO_REGISTRY_SIZE=10000
CAIO_CONTRACT_CACHE_TTL=3600
```

### Config Files

See `docs/configuration/CONFIGURATION.md` for complete configuration options.

## Examples

- Register each TAI service (RFS, VFE, VEE, NME) with its contract file.
- Use CAIO orchestrator for routing requests with intent, requirements, and constraints.
- Integrate CAIO control signals back into MAIA intent field updates.

## Troubleshooting

**Service registration fails**
- Verify YAML contract matches `docs/SDK_SPECIFICATION.md`.
- Ensure `Content-Type: application/yaml` is set for registration requests.

**Routing returns no matching services**
- Confirm service contracts expose required capabilities.
- Confirm requirements in the request align with contract capability types.

**Authentication errors**
- Verify CAIO auth configuration in `docs/deployment/ENVIRONMENT_VARIABLES.md`.
- Ensure the caller has the required role for the API endpoint.

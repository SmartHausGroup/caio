# CAIO Phase 9: External Service Integration (Codex) Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-07  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:9.1-9.5`

---

## Executive Summary

Integrate Codex as the first external service into CAIO, establishing the pattern for future external service integrations. This phase creates a Bridge Service that wraps Codex (via SDK/API) as an HTTP service, registers it with CAIO using a service contract, and provides integration tests and documentation.

**CRITICAL:** This is service integration work, not mathematical algorithm work. MA process is NOT required. However, notebook-first development still applies for the bridge service code.

**Estimated Time:** 2-3 hours  
**Priority:** High (establishes external service integration pattern)

---

## Context & Background

### Current State

- ✅ **CAIO Service Registry:** Fully operational with contract-based discovery
- ✅ **Service Registration API:** `POST /api/v1/services` accepts YAML contracts
- ✅ **Contract Schema:** `configs/schemas/service_contract.schema.yaml` defines contract structure
- ✅ **Service Contract Parser:** Supports `http` and `grpc` protocols (schema allows `native` but parser doesn't support it yet)
- ❌ **External Services Directory:** `services/external/` does not exist yet
- ❌ **Codex Integration:** Not yet integrated

### North Star Alignment

This task directly supports the CAIO North Star by:

- **External Services & Marketplace:** Establishes the first external service integration, demonstrating CAIO's universal compatibility
- **Contract-Based Discovery:** Codex will register via standard YAML contract, proving the contract system works for external services
- **Hot-Swappable Services:** Codex can be registered/removed dynamically, demonstrating CAIO's flexibility
- **Universal Compatibility:** Proves CAIO can orchestrate any AI service, not just TAI-controlled services

**Reference:** `docs/NORTH_STAR.md` §7.2 External Services (Marketplace)

### Execution Plan Reference

This task implements Phase 9: External Service Integration from `docs/operations/execution_plan.md`:

- **9.1:** Codex Bridge Service (HTTP wrapper)
- **9.2:** Codex Service Contract (YAML)
- **9.3:** Service Registration (programmatic)
- **9.4:** Integration Tests (end-to-end)
- **9.5:** Documentation (external services guide)

---

## Codex Integration Modes

Codex is available in multiple forms:

- **SDK:** Python SDK for programmatic access (recommended for bridge service)
- **Cloud:** Web-based interface (not suitable for API integration)
- **CLI:** Command-line tool (not suitable for HTTP service)
- **MCP:** Model Context Protocol (future consideration)
- **IDE Extensions:** Cursor, VS Code, Windsurf (not suitable for API integration)
- **GitHub Integration:** GitHub Actions/Apps (not suitable for API integration)
- **Agents SDK:** OpenAI Agents SDK (future consideration)

**Decision:** Use Codex SDK (Python) for the bridge service, wrapping it as an HTTP API.

---

## Step-by-Step Implementation Instructions

### Task 9.1: Codex Bridge Service

**Objective:** Create an HTTP wrapper service that exposes Codex functionality via REST API.

#### Step 1.1: Create Directory Structure

Create the external services directory structure:

```bash
mkdir -p services/external/codex
mkdir -p services/external/codex/api
mkdir -p services/external/codex/core
mkdir -p services/external/codex/tests
```

**Files to Create:**
- `services/external/codex/__init__.py`
- `services/external/codex/api/__init__.py`
- `services/external/codex/api/routes.py` (FastAPI routes)
- `services/external/codex/core/__init__.py`
- `services/external/codex/core/codex_client.py` (Codex SDK wrapper)
- `services/external/codex/core/transformer.py` (Request/response transformation)
- `services/external/codex/main.py` (FastAPI app entry point)
- `services/external/codex/requirements.txt` (dependencies)
- `services/external/codex/README.md` (service documentation)

#### Step 1.2: Implement Codex Client (Notebook-First)

**CRITICAL:** Follow notebook-first development. Create `notebooks/ops/codex_client_validation.ipynb` first.

**Notebook Structure:**
```python
# Cell 1: Imports
import json
import pathlib
from typing import Dict, Any, Optional

# Cell 2: Codex Client Implementation
# Write the actual Codex SDK wrapper code here
# DO NOT import from codebase - write code directly in notebook
class CodexClient:
    """Wrapper for Codex SDK/API."""
    def __init__(self, api_key: Optional[str] = None):
        # Implementation here
        pass
    
    def generate_code(self, prompt: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """Generate code using Codex."""
        # Implementation here
        pass
    
    def review_code(self, code: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """Review code using Codex."""
        # Implementation here
        pass

# Cell 3: Test Codex Client
# Test the client with sample requests
# Verify SDK integration works

# Cell 4: Export Code
# Export code to services/external/codex/core/codex_client.py
```

**Key Requirements:**
- Use Codex SDK (Python) - check OpenAI documentation for latest SDK
- Handle authentication (API key from environment variable)
- Implement core methods: `generate_code`, `review_code`, `execute_command` (if applicable)
- Error handling for API failures
- Type hints for all methods

**After Notebook Validation:**
- Extract code using: `python scripts/notebooks/extract_code.py --notebook notebooks/ops/codex_client_validation.ipynb --output services/external/codex/core/codex_client.py --classes CodexClient`

#### Step 1.3: Implement Request/Response Transformer (Notebook-First)

Create `notebooks/ops/codex_transformer_validation.ipynb`:

**Notebook Structure:**
```python
# Cell 1: Imports
from typing import Dict, Any

# Cell 2: Transformer Implementation
# Write the actual transformer code here
class CodexRequestTransformer:
    """Transform CAIO requests to Codex SDK format."""
    def transform_generate_request(self, request: Dict[str, Any]) -> Dict[str, Any]:
        # Implementation here
        pass

class CodexResponseTransformer:
    """Transform Codex SDK responses to CAIO format."""
    def transform_generate_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        # Implementation here
        pass

# Cell 3: Test Transformers
# Test with sample CAIO requests and Codex responses

# Cell 4: Export Code
# Export to services/external/codex/core/transformer.py
```

**After Notebook Validation:**
- Extract code using: `python scripts/notebooks/extract_code.py --notebook notebooks/ops/codex_transformer_validation.ipynb --output services/external/codex/core/transformer.py --classes CodexRequestTransformer CodexResponseTransformer`

#### Step 1.4: Implement FastAPI Routes (Notebook-First)

Create `notebooks/ops/codex_api_routes_validation.ipynb`:

**Notebook Structure:**
```python
# Cell 1: Imports
from fastapi import FastAPI, HTTPException
from typing import Dict, Any

# Cell 2: API Routes Implementation
# Write the actual FastAPI routes here
app = FastAPI(title="Codex Bridge Service")

@app.post("/generate")
async def generate_code(request: Dict[str, Any]) -> Dict[str, Any]:
    """Generate code endpoint."""
    # Implementation here
    pass

@app.post("/review")
async def review_code(request: Dict[str, Any]) -> Dict[str, Any]:
    """Review code endpoint."""
    # Implementation here
    pass

@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """Health check endpoint."""
    return {"status": "healthy", "service": "codex-bridge"}

# Cell 3: Test API Routes
# Test endpoints with sample requests

# Cell 4: Export Code
# Export to services/external/codex/api/routes.py
```

**Key Requirements:**
- FastAPI app with proper error handling
- Endpoints: `/generate`, `/review`, `/health`
- Request/response validation using Pydantic models
- Integration with CodexClient and transformers
- CORS configuration (if needed)
- Health check endpoint

**After Notebook Validation:**
- Extract code using: `python scripts/notebooks/extract_code.py --notebook notebooks/ops/codex_api_routes_validation.ipynb --output services/external/codex/api/routes.py --functions generate_code review_code health_check`

#### Step 1.5: Create Main Application Entry Point

Create `services/external/codex/main.py`:

```python
"""Codex Bridge Service - Main Application Entry Point."""

from fastapi import FastAPI
from services.external.codex.api.routes import app

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8082)
```

#### Step 1.6: Create Requirements File

Create `services/external/codex/requirements.txt`:

```txt
fastapi>=0.104.0
uvicorn>=0.24.0
pydantic>=2.5.0
openai>=1.0.0  # Codex SDK
python-dotenv>=1.0.0  # Environment variables
```

#### Step 1.7: Create Service README

Create `services/external/codex/README.md`:

```markdown
# Codex Bridge Service

HTTP wrapper service for Codex, exposing Codex functionality via REST API for CAIO integration.

## Quick Start

1. Set environment variables:
   ```bash
   export OPENAI_API_KEY="your-api-key"
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run service:
   ```bash
   python main.py
   ```

4. Service runs on `http://localhost:8082`

## API Endpoints

- `POST /generate` - Generate code
- `POST /review` - Review code
- `GET /health` - Health check

## Configuration

- `OPENAI_API_KEY`: OpenAI API key for Codex access
- `CODEX_BRIDGE_PORT`: Port for bridge service (default: 8082)
```

---

### Task 9.2: Codex Service Contract

**Objective:** Create a YAML service contract that defines Codex's capabilities, guarantees, and API details.

#### Step 2.1: Create Contract File

Create `configs/services/external/codex.yaml`:

```yaml
service:
  id: codex-bridge-001
  name: Codex Bridge Service
  version: 1.0.0
  description: "HTTP bridge service for OpenAI Codex, providing code generation and review capabilities"

  capabilities:
    - type: code_generation
      accuracy:
        min: 0.85
        target: 0.95
      capacity:
        max_tokens: 4096
    - type: code_review
      accuracy:
        min: 0.80
        target: 0.90
    - type: code_execution
      accuracy:
        min: 0.75
        target: 0.85
    - type: file_operations
    - type: command_execution
    - type: web_search

  guarantees:
    latency:
      property: p95_latency_ms
      bound:
        max: 5000
      invariant: INV-CODEX-0001
    accuracy:
      property: classification_accuracy
      bound:
        min: 0.85
      invariant: INV-CODEX-0002
    determinism:
      property: deterministic_output
      bound:
        seed_required: false
      invariant: INV-CODEX-0003

  cost:
    model: per_token
    token_cost: 0.0001
    currency: USD

  privacy:
    data_locality: cloud
    encryption: true
    encryption_type: tls
    data_retention: session
    gdpr_compliant: true
    hipaa_compliant: false

  alignment:
    safety_level: high
    content_filtering: true
    bias_mitigation: true
    toxicity_filtering: true

  constraints:
    max_concurrent_requests: 10
    rate_limit:
      per_minute: 60
      per_hour: 1000
    context_length:
      max_tokens: 4096
    requires_internet: true

  api:
    protocol: http
    base_url: http://localhost:8082
    endpoints:
      - path: /generate
        method: POST
        input_schema: schemas/codex_generate_request.json
        output_schema: schemas/codex_generate_response.json
      - path: /review
        method: POST
        input_schema: schemas/codex_review_request.json
        output_schema: schemas/codex_review_response.json
      - path: /health
        method: GET

  invariants:
    - id: INV-CODEX-0001
      description: "Codex response latency P95 <= 5000ms"
      formula: "P95(latency) <= 5000"
      verification: notebooks/ops/codex_latency_validation.ipynb
      artifact: configs/generated/codex_latency_metrics.json
    - id: INV-CODEX-0002
      description: "Codex code generation accuracy >= 0.85"
      formula: "accuracy >= 0.85"
      verification: notebooks/ops/codex_accuracy_validation.ipynb
      artifact: configs/generated/codex_accuracy_metrics.json
    - id: INV-CODEX-0003
      description: "Codex output is deterministic (no seed required)"
      formula: "deterministic == true"
      verification: notebooks/ops/codex_determinism_validation.ipynb
      artifact: configs/generated/codex_determinism_metrics.json

  metadata:
    tags:
      - code-generation
      - code-review
      - external-service
      - openai
    category: code-assistant
    provider: OpenAI
    documentation_url: https://developers.openai.com/codex
```

**Key Requirements:**
- Follow `configs/schemas/service_contract.schema.yaml` structure
- Define realistic capabilities based on Codex's actual features
- Set realistic guarantees (latency, accuracy, determinism)
- Include cost model (per-token pricing)
- Privacy settings (cloud-based, TLS encryption)
- Alignment settings (high safety, content filtering)
- Constraints (rate limits, context length)
- API endpoints matching the bridge service routes
- Invariants (can be placeholders for now, verification notebooks created later)

#### Step 2.2: Validate Contract Schema

Validate the contract against the schema:

```bash
python -c "
import yaml
import json
from jsonschema import validate

# Load contract
with open('configs/services/external/codex.yaml', 'r') as f:
    contract = yaml.safe_load(f)

# Load schema
with open('configs/schemas/service_contract.schema.yaml', 'r') as f:
    schema = yaml.safe_load(f)

# Validate
validate(instance=contract, schema=schema)
print('Contract is valid!')
"
```

---

### Task 9.3: Service Registration

**Objective:** Register the Codex service with CAIO programmatically.

#### Step 3.1: Create Registration Script

Create `scripts/register_codex_service.py`:

```python
"""Register Codex service with CAIO."""

import yaml
from pathlib import Path
from caio.sdk.client import CAIOClient

def register_codex_service():
    """Register Codex service contract with CAIO."""
    # Load contract
    contract_path = Path("configs/services/external/codex.yaml")
    with open(contract_path, "r") as f:
        contract = yaml.safe_load(f)
    
    # Initialize CAIO client
    client = CAIOClient(base_url="http://localhost:8080")
    
    # Register service
    response = client.register_service(contract=contract)
    print(f"Service registered: {response}")
    return response

if __name__ == "__main__":
    register_codex_service()
```

#### Step 3.2: Test Registration

Run the registration script:

```bash
# Ensure CAIO is running
# Start Codex bridge service
cd services/external/codex
python main.py &

# Register service
python scripts/register_codex_service.py
```

**Expected Output:**
```json
{
  "service_id": "codex-bridge-001",
  "status": "registered",
  "message": "Service codex-bridge-001 registered successfully"
}
```

#### Step 3.3: Verify Registration

Verify the service is registered:

```bash
curl -X GET http://localhost:8080/api/v1/services | jq .
```

**Expected Output:**
```json
{
  "services": [
    {
      "service_id": "codex-bridge-001",
      "service_name": "Codex Bridge Service",
      "version": "1.0.0",
      "capabilities": ["code_generation", "code_review", ...],
      "status": "active"
    }
  ],
  "count": 1
}
```

---

### Task 9.4: Integration Tests

**Objective:** Create end-to-end tests for the Codex Bridge Service integration.

#### Step 4.1: Create Test File

Create `services/external/codex/tests/test_integration.py`:

```python
"""Integration tests for Codex Bridge Service."""

import pytest
import requests
from pathlib import Path
import yaml
from caio.sdk.client import CAIOClient

BASE_URL = "http://localhost:8082"
CAIO_URL = "http://localhost:8080"

def test_codex_bridge_health():
    """Test Codex bridge service health endpoint."""
    response = requests.get(f"{BASE_URL}/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "codex-bridge"

def test_codex_bridge_generate():
    """Test Codex bridge service code generation."""
    request = {
        "prompt": "Write a Python function to add two numbers",
        "context": {"language": "python"}
    }
    response = requests.post(f"{BASE_URL}/generate", json=request)
    assert response.status_code == 200
    data = response.json()
    assert "code" in data or "result" in data

def test_codex_service_registration():
    """Test Codex service registration with CAIO."""
    # Load contract
    contract_path = Path("configs/services/external/codex.yaml")
    with open(contract_path, "r") as f:
        contract = yaml.safe_load(f)
    
    # Register service
    client = CAIOClient(base_url=CAIO_URL)
    response = client.register_service(contract=contract)
    assert response["status"] == "registered"
    assert response["service_id"] == "codex-bridge-001"

def test_codex_service_discovery():
    """Test Codex service discovery via CAIO."""
    client = CAIOClient(base_url=CAIO_URL)
    services = client.list_services(capability="code_generation")
    assert len(services["services"]) > 0
    codex_service = next(
        (s for s in services["services"] if s["service_id"] == "codex-bridge-001"),
        None
    )
    assert codex_service is not None
    assert "code_generation" in codex_service["capabilities"]

def test_codex_service_routing():
    """Test CAIO routing to Codex service."""
    client = CAIOClient(base_url=CAIO_URL)
    request = {
        "requirements": ["code_generation"],
        "context": {
            "prompt": "Write a Python function",
            "language": "python"
        }
    }
    result = client.route_request(request=request)
    assert result["service_id"] == "codex-bridge-001"
    assert result["guarantees"] is not None
```

#### Step 4.2: Run Integration Tests

Run the tests:

```bash
# Ensure CAIO is running
# Ensure Codex bridge service is running
pytest services/external/codex/tests/test_integration.py -v
```

**Expected Output:**
```
test_codex_bridge_health PASSED
test_codex_bridge_generate PASSED
test_codex_service_registration PASSED
test_codex_service_discovery PASSED
test_codex_service_routing PASSED
```

---

### Task 9.5: Documentation

**Objective:** Update documentation to include external services guide and developer guide.

#### Step 5.1: Create External Services Guide

Create `docs/external_services.md`:

```markdown
# External Services Integration Guide

**Status:** Active  
**Last Updated:** 2026-01-07  
**Owner:** @smarthaus

---

## Overview

CAIO supports integration of external services (services not controlled by TAI) via the same contract-based discovery system used for internal services. External services register with CAIO using YAML contracts, enabling them to be discovered, routed, and orchestrated alongside internal services.

---

## Architecture

External services integrate with CAIO through:

1. **Bridge Service (HTTP Wrapper):** External services that don't natively support HTTP/gRPC are wrapped in a bridge service that exposes them via REST API.
2. **Service Contract (YAML):** External services define their capabilities, guarantees, and API details in a YAML contract.
3. **Service Registration:** External services register with CAIO via `POST /api/v1/services` or the CAIO SDK.
4. **Service Discovery:** CAIO discovers external services using the same contract-based matching algorithm as internal services.

---

## Integration Pattern

### Step 1: Create Bridge Service (if needed)

If the external service doesn't natively support HTTP/gRPC, create a bridge service:

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
from caio.sdk.client import CAIOClient
import yaml

# Load contract
with open("configs/services/external/{service}.yaml", "r") as f:
    contract = yaml.safe_load(f)

# Register
client = CAIOClient(base_url="http://localhost:8080")
response = client.register_service(contract=contract)
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
- **North Star:** `docs/NORTH_STAR.md` §7.2 External Services (Marketplace)
```

#### Step 5.2: Update Developer Guide

Update `docs/developer/DEVELOPER_GUIDE.md` (if it exists) to include external services integration section, or create it if it doesn't exist.

---

## Validation Procedures

### Pre-execution Checklist

- [ ] CAIO service is running (`http://localhost:8080`)
- [ ] OpenAI API key is set (`OPENAI_API_KEY` environment variable)
- [ ] Python 3.11+ is available
- [ ] All dependencies are installed (`pip install -r requirements.txt`)

### Post-execution Checklist

- [ ] Codex bridge service directory structure created (`services/external/codex/`)
- [ ] Codex bridge service code implemented (notebook-first, then extracted)
- [ ] Codex bridge service runs successfully (`python main.py`)
- [ ] Codex bridge service health endpoint returns 200 (`curl http://localhost:8082/health`)
- [ ] Codex service contract created (`configs/services/external/codex.yaml`)
- [ ] Codex service contract validates against schema
- [ ] Codex service registered with CAIO (`scripts/register_codex_service.py`)
- [ ] Codex service appears in CAIO service list (`curl http://localhost:8080/api/v1/services`)
- [ ] Integration tests pass (`pytest services/external/codex/tests/test_integration.py`)
- [ ] Documentation updated (`docs/external_services.md`)

---

## Troubleshooting Guide

### Codex Bridge Service Issues

- **"ModuleNotFoundError: No module named 'openai'"**: Install dependencies: `pip install -r services/external/codex/requirements.txt`
- **"401 Unauthorized"**: Check `OPENAI_API_KEY` environment variable is set correctly
- **"Connection refused"**: Ensure Codex bridge service is running on port 8082

### Service Registration Issues

- **"Contract validation failed"**: Check contract YAML syntax and schema compliance
- **"Service already registered"**: Service ID must be unique. Change `service.id` in contract or unregister existing service
- **"CAIO service not running"**: Start CAIO service: `make demo-run` or `uvicorn caio.api.app:app --port 8080`

### Integration Test Issues

- **"Connection refused"**: Ensure both CAIO and Codex bridge services are running
- **"Test timeout"**: Increase timeout in test configuration or check service health
- **"AssertionError"**: Review test expectations and actual service responses

---

## Success Criteria

1. ✅ Codex bridge service runs and responds to health checks
2. ✅ Codex bridge service exposes `/generate` and `/review` endpoints
3. ✅ Codex service contract validates against schema
4. ✅ Codex service registers successfully with CAIO
5. ✅ Codex service appears in CAIO service discovery
6. ✅ CAIO can route requests to Codex service
7. ✅ Integration tests pass
8. ✅ Documentation is complete and accurate

---

## Next Steps

After Phase 9 completion:

1. **Phase 10 (Future):** Additional external service integrations (e.g., GitHub Copilot, Cursor, etc.)
2. **Marketplace Development:** Build CAIO marketplace for external service registration
3. **SDK Enhancements:** Enhance CAIO SDK for external service developers
4. **Invariant Verification:** Create verification notebooks for Codex invariants (INV-CODEX-0001, INV-CODEX-0002, INV-CODEX-0003)

---

## Notes and References

- **Codex Documentation:** https://developers.openai.com/codex
- **Codex SDK:** OpenAI Python SDK (latest version)
- **CAIO Service Contract Schema:** `configs/schemas/service_contract.schema.yaml`
- **CAIO Service Registration API:** `caio/api/routes/services.py`
- **CAIO SDK:** `caio/sdk/client.py`
- **North Star:** `docs/NORTH_STAR.md`
- **Execution Plan:** `docs/operations/execution_plan.md` Phase 9

---

**This plan establishes the pattern for all future external service integrations. Codex is the first example, demonstrating CAIO's universal compatibility and contract-based discovery system.**


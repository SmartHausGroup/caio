# CAIO Phase 16: Open Integration Layer Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-12  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:16`

---

## Executive Summary

Create an open-source integration layer (SDK, APIs, documentation) that allows external developers to connect their custom AI services to CAIO. This enables CAIO to serve as a universal AI orchestration platform while keeping the core mathematical engine proprietary.

**Key Deliverables:**
1. Open-source SDK package (`caio-integration-sdk`) installable via PyPI or GitHub
2. Public integration APIs (service registration, discovery, validation)
3. Contract templates and examples for common service types
4. Comprehensive developer documentation (integration guide, SDK reference, API reference)
5. Example service implementations
6. Open-source repository setup (if needed)

**Estimated Time:** 1-2 weeks  
**Priority:** High (enables ecosystem growth and marketplace integration)

**CRITICAL:** The integration layer is open-source. The core mathematical engine (orchestrator, master equation, guarantee enforcement) remains proprietary.

---

## Context & Background

### Current State

- ✅ **CAIO Core:** Fully implemented and production-ready (Phases 0-15 complete)
- ✅ **SDK Interface:** `AIUCPService` interface defined (`caio/sdk/service.py`)
- ✅ **SDK Client:** `CAIOClient` implemented (`caio/sdk/client.py`)
- ✅ **Contract System:** YAML contract schema and parser functional
- ✅ **API Endpoints:** Service registration and discovery endpoints exist
- ❌ **Open-Source Package:** No separate open-source package exists
- ❌ **Public APIs:** No public-facing integration APIs documented
- ❌ **Developer Documentation:** No comprehensive integration guide for external developers
- ❌ **Examples:** No example service implementations for external developers

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Universal Compatibility:** Open integration layer enables any AI service to connect to CAIO
- **Contract-Based Discovery:** External services register with same contract system
- **Mathematical Guarantees:** External services benefit from CAIO's mathematical guarantees
- **Ecosystem Growth:** Open-source integration layer encourages marketplace development
- **Proprietary Core:** Core mathematical engine remains proprietary (SaaS/on-premises licensing)

**Reference:** `docs/NORTH_STAR.md` - Universal AI orchestration platform

### Execution Plan Reference

This task implements Phase 16: Open Integration Layer from `docs/operations/EXECUTION_PLAN.md`:

- **16.1:** Prepare open-source SDK package
- **16.2:** Create integration APIs
- **16.3:** Create contract templates & examples
- **16.4:** Create developer documentation
- **16.5:** Create example implementations
- **16.6:** Set up open-source repository (if needed)

---

## Step-by-Step Implementation Instructions

### Task 16.1: Prepare Open-Source SDK Package

**Objective:** Extract and package the integration layer as an open-source SDK.

#### Step 1.1: Create Open-Source Package Structure

**Directory:** `caio-integration-sdk/` (new directory for open-source package)

**Structure:**
```
caio-integration-sdk/
├── caio_integration/
│   ├── __init__.py
│   ├── service.py          # AIUCPService interface
│   ├── client.py           # CAIOClient
│   ├── exceptions.py       # SDK exceptions
│   └── contracts.py        # Contract validation utilities
├── examples/
│   ├── simple_service.py
│   ├── advanced_service.py
│   └── README.md
├── tests/
│   ├── test_service.py
│   ├── test_client.py
│   └── test_contracts.py
├── docs/
│   ├── README.md
│   ├── QUICK_START.md
│   └── API_REFERENCE.md
├── pyproject.toml
├── setup.py
├── LICENSE                 # MIT or Apache 2.0
├── README.md
└── .gitignore
```

#### Step 1.2: Extract SDK Components

**Files to Extract:**

1. **Service Interface:** `caio_integration/service.py`
   - Copy `AIUCPService` from `caio/sdk/service.py`
   - Remove any proprietary dependencies
   - Keep interface abstract and clean

2. **Client Library:** `caio_integration/client.py`
   - Copy `CAIOClient` from `caio/sdk/client.py`
   - Remove any proprietary implementation details
   - Keep only public API methods

3. **Exceptions:** `caio_integration/exceptions.py`
   - Copy exceptions from `caio/sdk/exceptions.py`
   - Keep exception definitions

4. **Contract Utilities:** `caio_integration/contracts.py`
   - Contract validation functions
   - Contract schema definitions
   - YAML parsing utilities (non-proprietary)

**File:** `caio-integration-sdk/caio_integration/service.py`

```python
"""CAIO Integration SDK - Service Interface.

This is the open-source integration layer for connecting services to CAIO.
The core mathematical engine remains proprietary.
"""

from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any, Dict, Optional


class AIUCPService(ABC):
    """
    Base interface for CAIO-compatible services.
    All services must implement this interface.
    """

    @abstractmethod
    def initialize(self, contract_path: Path) -> None:
        """
        Initialize service with contract.

        Args:
            contract_path: Path to service contract YAML file

        Raises:
            ContractValidationError: If contract is invalid
            ServiceInitializationError: If service fails to initialize
        """
        pass

    @abstractmethod
    async def execute(
        self, request: Dict[str, Any], context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Execute request.

        Args:
            request: Request data (format defined by contract)
            context: Optional context (user, session, etc.)

        Returns:
            Result data (format defined by contract)

        Raises:
            ServiceExecutionError: If execution fails
            GuaranteeViolationError: If guarantees are violated
        """
        pass

    @abstractmethod
    async def verify_guarantees(
        self, result: Dict[str, Any], contract: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Verify guarantees are met.

        Args:
            result: Execution result
            contract: Service contract

        Returns:
            Verification proof with guarantee status

        Raises:
            GuaranteeViolationError: If guarantees are violated
        """
        pass

    @abstractmethod
    def get_health_status(self) -> Dict[str, Any]:
        """
        Get service health status.

        Returns:
            Health status dictionary
        """
        pass
```

#### Step 1.3: Create Package Configuration

**File:** `caio-integration-sdk/pyproject.toml`

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "caio-integration-sdk"
version = "1.0.0"
description = "CAIO Integration SDK for connecting AI services to CAIO orchestration platform"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}
authors = [
    {name = "SmartHaus", email = "info@smarthaus.ai"}
]
keywords = ["ai", "orchestration", "sdk", "integration"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

dependencies = [
    "pydantic>=2.0",
    "pyyaml>=6.0",
    "httpx>=0.24.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-asyncio>=0.21.0",
    "black>=23.0",
    "ruff>=0.1.0",
]

[project.urls]
Homepage = "https://github.com/smarthaus/caio-integration-sdk"
Documentation = "https://caio-integration-sdk.readthedocs.io"
Repository = "https://github.com/smarthaus/caio-integration-sdk"
Issues = "https://github.com/smarthaus/caio-integration-sdk/issues"

[tool.setuptools.packages.find]
where = ["."]
include = ["caio_integration*"]

[tool.black]
line-length = 100
target-version = ['py310']

[tool.ruff]
line-length = 100
target-version = "py310"
```

**File:** `caio-integration-sdk/LICENSE`

```text
MIT License

Copyright (c) 2026 SmartHaus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**Validation:**
- Package structure created
- SDK components extracted
- Package configuration complete
- LICENSE file added

---

### Task 16.2: Create Integration APIs

**Objective:** Create public REST APIs for service integration.

#### Step 2.1: Create Public Integration Endpoints

**File:** `caio/api/routes/integration.py`

**Endpoints:**
```python
from fastapi import APIRouter, Depends, HTTPException, File, UploadFile
from caio.api.schemas import (
    ServiceRegistrationRequest,
    ServiceRegistrationResponse,
    ServiceDiscoveryRequest,
    ServiceDiscoveryResponse,
    ContractValidationRequest,
    ContractValidationResponse,
)

router = APIRouter(prefix="/api/v1/integration", tags=["Integration"])

@router.post("/register-service", response_model=ServiceRegistrationResponse)
async def register_service_public(
    request: ServiceRegistrationRequest,
    orchestrator: Orchestrator = Depends(get_orchestrator),
):
    """
    Public endpoint for registering services with CAIO.
    No authentication required (service registration is public).
    """
    try:
        entry = orchestrator.register_service(
            contract_path=request.contract_path,
            service_id=request.service_id,
        )
        return ServiceRegistrationResponse(
            service_id=entry.service_id,
            status="registered",
            contract=entry.contract.dict(),
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/discover-services", response_model=ServiceDiscoveryResponse)
async def discover_services_public(
    request: ServiceDiscoveryRequest,
    orchestrator: Orchestrator = Depends(get_orchestrator),
):
    """
    Public endpoint for discovering services.
    No authentication required (service discovery is public).
    """
    services = orchestrator.discover_services(
        capabilities=request.capabilities,
        guarantees=request.guarantees,
        constraints=request.constraints,
    )
    return ServiceDiscoveryResponse(
        services=[s.dict() for s in services],
        count=len(services),
    )

@router.post("/validate-contract", response_model=ContractValidationResponse)
async def validate_contract_public(
    request: ContractValidationRequest,
):
    """
    Public endpoint for validating service contracts.
    No authentication required (contract validation is public).
    """
    from caio.contracts.parser import parse_contract, validate_contract_invariants
    
    try:
        contract = parse_contract(Path(request.contract_path))
        if not contract:
            return ContractValidationResponse(
                is_valid=False,
                errors=["Failed to parse contract"],
            )
        
        is_valid, errors = validate_contract_invariants(contract)
        return ContractValidationResponse(
            is_valid=is_valid,
            errors=errors,
        )
    except Exception as e:
        return ContractValidationResponse(
            is_valid=False,
            errors=[str(e)],
        )

@router.post("/upload-contract")
async def upload_contract(
    file: UploadFile = File(...),
    orchestrator: Orchestrator = Depends(get_orchestrator),
):
    """
    Public endpoint for uploading and registering contracts.
    Accepts YAML file upload.
    """
    # Save uploaded file temporarily
    # Parse contract
    # Register service
    # Return registration response
    pass
```

#### Step 2.2: Document Integration APIs

**File:** `docs/api/INTEGRATION_API.md`

**Sections:**
1. Overview
2. Authentication (public endpoints, no auth required)
3. Endpoints
4. Request/Response Schemas
5. Error Handling
6. Examples

**Validation:**
- Integration APIs created
- API documentation complete
- Examples provided

---

### Task 16.3: Create Contract Templates & Examples

**Objective:** Provide templates and examples for service contracts.

#### Step 3.1: Create Contract Templates

**Directory:** `caio-integration-sdk/templates/`

**Templates:**

1. **Simple Service Template:** `templates/simple_service.yaml`
```yaml
service_id: my-service
name: My AI Service
version: 1.0.0

capabilities:
  - text_generation
  - text_embedding

guarantees:
  latency:
    p95_ms: 100
    p99_ms: 200
  accuracy:
    min: 0.95

constraints:
  max_tokens: 4096
  supported_languages:
    - en
    - es

cost:
  per_request: 0.001
  per_token: 0.0001
```

2. **Advanced Service Template:** `templates/advanced_service.yaml`
```yaml
service_id: advanced-service
name: Advanced AI Service
version: 1.0.0

capabilities:
  - text_generation
  - text_embedding
  - image_generation
  - code_generation

guarantees:
  latency:
    p95_ms: 50
    p99_ms: 100
  accuracy:
    min: 0.99
  availability:
    target: 99.9

constraints:
  max_tokens: 8192
  max_images: 4
  supported_languages:
    - en
    - es
    - fr
    - de

cost:
  per_request: 0.002
  per_token: 0.0002
  per_image: 0.01
```

#### Step 3.2: Create Contract Examples

**Directory:** `caio-integration-sdk/examples/contracts/`

**Examples:**
- OpenAI-compatible service
- Anthropic-compatible service
- Custom LLM service
- Embedding service
- Code generation service

**Validation:**
- Contract templates created
- Examples provided
- Documentation complete

---

### Task 16.4: Create Developer Documentation

**Objective:** Create comprehensive documentation for external developers.

#### Step 4.1: Create Integration Guide

**File:** `caio-integration-sdk/docs/INTEGRATION_GUIDE.md`

**Sections:**
1. Getting Started
2. Installation
3. Quick Start (5-minute tutorial)
4. Service Implementation
5. Contract Creation
6. Service Registration
7. Service Discovery
8. Best Practices
9. Troubleshooting

#### Step 4.2: Create SDK Reference

**File:** `caio-integration-sdk/docs/SDK_REFERENCE.md`

**Sections:**
1. AIUCPService Interface
2. CAIOClient API
3. Contract Validation
4. Error Handling
5. Examples

#### Step 4.3: Create API Reference

**File:** `caio-integration-sdk/docs/API_REFERENCE.md`

**Sections:**
1. Integration Endpoints
2. Request/Response Schemas
3. Error Codes
4. Examples

**Validation:**
- Integration guide complete
- SDK reference complete
- API reference complete

---

### Task 16.5: Create Example Implementations

**Objective:** Provide reference implementations for common service types.

#### Step 5.1: Create Simple Service Example

**File:** `caio-integration-sdk/examples/simple_service.py`

```python
"""Simple service example for CAIO integration."""

from caio_integration import AIUCPService
from pathlib import Path
from typing import Any, Dict, Optional


class SimpleService(AIUCPService):
    """Simple example service implementation."""

    def initialize(self, contract_path: Path) -> None:
        """Initialize service with contract."""
        # Load and validate contract
        # Initialize service resources
        pass

    async def execute(
        self, request: Dict[str, Any], context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Execute request."""
        # Process request
        # Return result
        return {"result": "success"}

    async def verify_guarantees(
        self, result: Dict[str, Any], contract: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Verify guarantees are met."""
        # Verify guarantees
        return {"guarantees_met": True}

    def get_health_status(self) -> Dict[str, Any]:
        """Get service health status."""
        return {"status": "healthy"}
```

#### Step 5.2: Create Integration Test Example

**File:** `caio-integration-sdk/examples/test_integration.py`

```python
"""Integration test example."""

import pytest
from caio_integration import CAIOClient
from pathlib import Path


@pytest.mark.asyncio
async def test_service_registration():
    """Test service registration."""
    client = CAIOClient(base_url="https://api.caio.ai")
    
    # Register service
    service_id = await client.register_service(
        contract_path=Path("contracts/my_service.yaml"),
    )
    
    assert service_id is not None


@pytest.mark.asyncio
async def test_service_discovery():
    """Test service discovery."""
    client = CAIOClient(base_url="https://api.caio.ai")
    
    # Discover services
    services = await client.discover_services(
        capabilities=["text_generation"],
    )
    
    assert len(services) > 0
```

**Validation:**
- Example implementations created
- Integration test examples provided
- Examples documented

---

### Task 16.6: Set Up Open-Source Repository (if needed)

**Objective:** Create separate repository for integration layer (optional).

#### Step 6.1: Create GitHub Repository

**Repository Name:** `caio-integration-sdk`

**Repository Contents:**
- SDK package code
- Examples
- Documentation
- LICENSE (MIT)
- README.md
- CONTRIBUTING.md

#### Step 6.2: Create README

**File:** `caio-integration-sdk/README.md`

**Sections:**
1. Overview
2. Installation
3. Quick Start
4. Documentation
5. Examples
6. Contributing
7. License

**Validation:**
- Repository structure created
- README complete
- Contributing guidelines added

---

## Validation Procedures

### Package Installation Test

**Commands:**
```bash
cd caio-integration-sdk
pip install -e .
python -c "from caio_integration import AIUCPService, CAIOClient; print('OK')"
```

### Integration API Tests

**Commands:**
```bash
# Test service registration
curl -X POST https://api.caio.ai/api/v1/integration/register-service \
  -H "Content-Type: application/json" \
  -d '{"contract_path": "contracts/my_service.yaml"}'

# Test service discovery
curl -X POST https://api.caio.ai/api/v1/integration/discover-services \
  -H "Content-Type: application/json" \
  -d '{"capabilities": ["text_generation"]}'
```

### Example Implementation Tests

**Commands:**
```bash
cd caio-integration-sdk/examples
pytest test_integration.py -v
```

---

## Success Criteria

**SDK Package:**
- [ ] Package installable via `pip install caio-integration-sdk`
- [ ] All SDK components functional
- [ ] No proprietary code in open-source package

**Integration APIs:**
- [ ] Public endpoints accessible
- [ ] Service registration working
- [ ] Service discovery working
- [ ] Contract validation working

**Documentation:**
- [ ] Integration guide complete
- [ ] SDK reference complete
- [ ] API reference complete
- [ ] Examples working

**Examples:**
- [ ] Example implementations functional
- [ ] Integration tests passing
- [ ] Examples documented

---

## Risks and Mitigation

**Risk 1: IP leakage**
- **Mitigation:** Code review to ensure no proprietary code
- **Mitigation:** Clear separation between open-source and proprietary

**Risk 2: Documentation gaps**
- **Mitigation:** Comprehensive documentation with examples
- **Mitigation:** Developer feedback and iteration

**Risk 3: API compatibility**
- **Mitigation:** Version API endpoints
- **Mitigation:** Maintain backward compatibility

---

## Notes and References

- **CAIO SDK Specification:** `docs/SDK_SPECIFICATION.md`
- **CAIO API Reference:** `docs/api/API_REFERENCE.md`
- **Contract Schema:** `docs/contracts/CONTRACT_SCHEMA.md`
- **PyPI Publishing Guide:** https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/

---

**Last Updated:** 2026-01-12
**Version:** 1.0

# Codex Prompt: Phase 7 - SDK & API Surface

**Plan Reference:** `plan:phase-7-sdk-api`  
**Execution Plan Reference:** `plan:EXECUTION_PLAN:7.1-7.4`  
**Status:** Ready for Implementation  
**North Star Alignment:** Exposes CAIO functionality via SDK and HTTP/gRPC APIs per `docs/NORTH_STAR.md` (Section 1.1, Core Characteristics; Section 3, Integration Points)

---

## Executive Summary

Complete Phase 7 (SDK & API Surface) by implementing the CAIO SDK interface, HTTP/REST API endpoints, client utilities, and integration tests. This exposes CAIO functionality to external services and enables service registration, orchestration, and traceability via well-defined APIs.

**Note:** This is implementation work following notebook-first development. SDK and API code should be written in notebooks first, then extracted. MA process is NOT required for API/SDK code, but you must follow the mandatory workflow (North Star alignment, Execution Plan verification, change approval). All tests must use real implementations (no mocks for core behavior).

---

## Context & Background

**Current State:**
- Phases 0-6 are **COMPLETE** ✅ (Foundation, Math, Invariants, Notebooks, CI Enforcement, Orchestrator Implementation)
- Phase 6 complete: All orchestrator components implemented and integrated
- Orchestrator core functional: `caio.orchestrator.core.Orchestrator` class available
- Phase 7 is **NOT STARTED** ❌

**Why This Matters:**
- Enables external services to register with CAIO
- Provides HTTP/gRPC APIs for orchestration requests
- Enables service discovery and routing via APIs
- Provides SDK for service developers to implement CAIO-compatible services
- Enables traceability and audit via API endpoints

**Related Work:**
- Execution Plan: `docs/operations/EXECUTION_PLAN.md` (Phase 7: SDK & API Surface)
- North Star: `docs/NORTH_STAR.md` (Section 1.1: Core Characteristics; Section 3: Integration Points)
- SDK Specification: `docs/SDK_SPECIFICATION.md` (Service interface and contract schema)
- Status Plan: `docs/operations/STATUS_PLAN.md` (Phase 7: Pending)
- Orchestrator: `caio/orchestrator/core.py` (Orchestrator class)

---

## Current State Analysis

**What Exists:**

**Orchestrator Core:**
- `caio/orchestrator/core.py` - Main Orchestrator class
- `caio/contracts/parser.py` - Contract parser & validator
- `caio/registry/registry.py` - Service registry
- `caio/rules/engine.py` - Rule engine
- `caio/security/verifier.py` - Security verifier
- `caio/guarantees/enforcer.py` - Guarantee enforcer
- `caio/traceability/tracer.py` - Traceability system
- `caio/control/integration.py` - Control integration

**Contract Schema:**
- `configs/schemas/service_contract.schema.yaml` - Contract schema
- `configs/schemas/service_contract.example.yaml` - Contract example

**SDK Specification:**
- `docs/SDK_SPECIFICATION.md` - Complete SDK interface specification

**What's Missing:**

**SDK:**
- `caio/sdk/` directory doesn't exist
- `caio/sdk/service.py` - AIUCPService interface
- `caio/sdk/exceptions.py` - SDK exceptions
- `caio/sdk/client.py` - CAIOClient for API calls
- `caio/sdk/helpers.py` - Contract validation helpers

**HTTP API:**
- `caio/api/` directory doesn't exist
- `caio/api/app.py` - FastAPI application
- `caio/api/routes/orchestrate.py` - Orchestration endpoint
- `caio/api/routes/services.py` - Service registration/listing endpoints
- `caio/api/routes/trace.py` - Traceability endpoint
- `caio/api/routes/health.py` - Health check endpoint
- `caio/api/routes/metrics.py` - Metrics endpoint
- `caio/api/schemas.py` - Pydantic request/response schemas

**Integration Tests:**
- `tests/integration/test_sdk.py` - SDK interface tests
- `tests/integration/test_api.py` - API endpoint tests
- `tests/e2e/test_sdk_integration.py` - E2E SDK integration tests

**Documentation:**
- OpenAPI spec generation
- SDK usage examples
- API documentation

---

## Target State

**After Completion:**
- ✅ Complete `caio/sdk/` directory with SDK interface and client
- ✅ Complete `caio/api/` directory with HTTP/REST API endpoints
- ✅ SDK interface (`AIUCPService`) implemented
- ✅ CAIOClient for API calls implemented
- ✅ All HTTP endpoints functional (orchestrate, register-service, services, trace, health, metrics)
- ✅ OpenAPI spec generated
- ✅ All integration tests passing
- ✅ All E2E tests passing
- ✅ All quality gates pass (tests, linting, OpenAPI validation)

---

## Step-by-Step Implementation Instructions

### TASK 7.1: Create SDK Directory Structure and Interface

**Purpose:** Create SDK directory structure and implement `AIUCPService` interface.

**Steps:**

1. **Create SDK directory:**
   ```bash
   mkdir -p caio/sdk
   touch caio/sdk/__init__.py
   ```

2. **Create SDK interface notebook:**
   - Create `notebooks/math/sdk_interface.ipynb`
   - Implement `AIUCPService` abstract base class
   - Implement exceptions: `ContractValidationError`, `ServiceExecutionError`, `GuaranteeViolationError`, `ServiceInitializationError`
   - Write code directly in notebook (notebook-first development)

3. **Extract SDK interface:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/sdk_interface.ipynb \
       --output caio/sdk/service.py \
       --classes AIUCPService
   ```

4. **Extract exceptions:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/sdk_interface.ipynb \
       --output caio/sdk/exceptions.py \
       --classes ContractValidationError ServiceExecutionError GuaranteeViolationError ServiceInitializationError
   ```

5. **Update `caio/sdk/__init__.py`:**
   ```python
   """CAIO SDK - Service Interface and Client."""
   
   from caio.sdk.service import AIUCPService
   from caio.sdk.exceptions import (
       ContractValidationError,
       ServiceExecutionError,
       GuaranteeViolationError,
       ServiceInitializationError,
   )
   
   __all__ = [
       "AIUCPService",
       "ContractValidationError",
       "ServiceExecutionError",
       "GuaranteeViolationError",
       "ServiceInitializationError",
   ]
   ```

**Validation:**
- SDK directory structure exists
- AIUCPService interface extracted
- All exceptions extracted
- Imports work correctly
- No linting errors

---

### TASK 7.2: Implement SDK Client and Helpers

**Purpose:** Implement CAIOClient for API calls and contract validation helpers.

**Steps:**

1. **Create SDK client notebook:**
   - Create `notebooks/math/sdk_client.ipynb`
   - Implement `CAIOClient` class with methods:
     - `register_service(contract_path)` - Register service contract
     - `orchestrate(request, policies, context)` - Orchestrate request
     - `get_trace(decision_id)` - Get trace for decision
     - `list_services(filters)` - List registered services
     - `get_health()` - Get CAIO health status
     - `get_metrics()` - Get CAIO metrics
   - Implement contract validation helper: `validate_contract(contract_path)`
   - Write code directly in notebook

2. **Extract SDK client:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/sdk_client.ipynb \
       --output caio/sdk/client.py \
       --classes CAIOClient \
       --functions validate_contract
   ```

3. **Update `caio/sdk/__init__.py`:**
   ```python
   """CAIO SDK - Service Interface and Client."""
   
   from caio.sdk.service import AIUCPService
   from caio.sdk.exceptions import (
       ContractValidationError,
       ServiceExecutionError,
       GuaranteeViolationError,
       ServiceInitializationError,
   )
   from caio.sdk.client import CAIOClient, validate_contract
   
   __all__ = [
       "AIUCPService",
       "ContractValidationError",
       "ServiceExecutionError",
       "GuaranteeViolationError",
       "ServiceInitializationError",
       "CAIOClient",
       "validate_contract",
   ]
   ```

**Validation:**
- CAIOClient extracted
- Contract validation helper extracted
- All methods functional
- Imports work correctly
- No linting errors

---

### TASK 7.3: Implement HTTP/REST API

**Purpose:** Implement FastAPI application with all required endpoints.

**Steps:**

1. **Create API directory:**
   ```bash
   mkdir -p caio/api/routes
   touch caio/api/__init__.py
   touch caio/api/routes/__init__.py
   ```

2. **Create API schemas notebook:**
   - Create `notebooks/math/api_schemas.ipynb`
   - Implement Pydantic schemas:
     - `OrchestrateRequest` - Request schema for /orchestrate
     - `OrchestrateResponse` - Response schema for /orchestrate
     - `RegisterServiceRequest` - Request schema for /register-service
     - `RegisterServiceResponse` - Response schema for /register-service
     - `ServiceListResponse` - Response schema for /services
     - `TraceResponse` - Response schema for /trace/{decision_id}
     - `HealthResponse` - Response schema for /health
     - `MetricsResponse` - Response schema for /metrics
   - Write code directly in notebook

3. **Extract API schemas:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_schemas.ipynb \
       --output caio/api/schemas.py \
       --classes OrchestrateRequest OrchestrateResponse RegisterServiceRequest RegisterServiceResponse ServiceListResponse TraceResponse HealthResponse MetricsResponse
   ```

4. **Create API routes notebook:**
   - Create `notebooks/math/api_routes.ipynb`
   - Implement route handlers:
     - `POST /orchestrate` - Orchestrate request
     - `POST /register-service` - Register service contract
     - `GET /services` - List registered services
     - `GET /trace/{decision_id}` - Get trace for decision
     - `GET /health` - Health check
     - `GET /metrics` - Metrics endpoint
   - Write code directly in notebook

5. **Extract API routes:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_routes.ipynb \
       --output caio/api/routes/orchestrate.py \
       --functions orchestrate_request
   
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_routes.ipynb \
       --output caio/api/routes/services.py \
       --functions register_service list_services
   
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_routes.ipynb \
       --output caio/api/routes/trace.py \
       --functions get_trace
   
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_routes.ipynb \
       --output caio/api/routes/health.py \
       --functions get_health
   
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_routes.ipynb \
       --output caio/api/routes/metrics.py \
       --functions get_metrics
   ```

6. **Create FastAPI app notebook:**
   - Create `notebooks/math/api_app.ipynb`
   - Implement FastAPI application:
     - Initialize FastAPI app
     - Register all route handlers
     - Add CORS middleware
     - Add error handlers
     - Configure OpenAPI metadata
   - Write code directly in notebook

7. **Extract FastAPI app:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/api_app.ipynb \
       --output caio/api/app.py \
       --functions create_app
   ```

8. **Create API entry point:**
   - Create `caio/api/__init__.py`:
   ```python
   """CAIO HTTP/REST API."""
   
   from caio.api.app import create_app
   
   __all__ = ["create_app"]
   ```

**Validation:**
- All API directories exist
- All schemas extracted
- All routes extracted
- FastAPI app extracted
- All endpoints functional
- OpenAPI spec generated
- No linting errors

---

### TASK 7.4: Create Integration Tests

**Purpose:** Create integration tests for SDK and API.

**Steps:**

1. **Create SDK integration tests:**
   - Create `tests/integration/test_sdk.py`
   - Test `AIUCPService` interface implementation
   - Test `CAIOClient` methods
   - Test contract validation helper
   - Use real implementations (no mocks)

2. **Create API integration tests:**
   - Create `tests/integration/test_api.py`
   - Test all API endpoints:
     - `POST /orchestrate`
     - `POST /register-service`
     - `GET /services`
     - `GET /trace/{decision_id}`
     - `GET /health`
     - `GET /metrics`
   - Use real implementations (no mocks)

3. **Create E2E SDK integration tests:**
   - Create `tests/e2e/test_sdk_integration.py`
   - Test complete flow:
     - Register service via SDK
     - Orchestrate request via SDK
     - Get trace via SDK
     - Verify guarantees
   - Use real implementations (no mocks)

**Validation:**
- All tests created
- All tests passing
- No mocks for core behavior
- Tests use real orchestrator

---

### TASK 7.5: Generate OpenAPI Documentation

**Purpose:** Generate OpenAPI spec and update documentation.

**Steps:**

1. **Generate OpenAPI spec:**
   - FastAPI automatically generates OpenAPI spec
   - Export to `docs/api/openapi.json`
   - Verify spec is valid

2. **Update API documentation:**
   - Update `docs/api/API_REFERENCE.md` with endpoint details
   - Add request/response examples
   - Add authentication details

3. **Create SDK documentation:**
   - Create `docs/sdk/SDK_GUIDE.md`
   - Document `AIUCPService` interface
   - Document `CAIOClient` usage
   - Add code examples

**Validation:**
- OpenAPI spec generated
- API documentation updated
- SDK documentation created
- All examples work

---

### TASK 7.6: Quality Validation

**Purpose:** Validate all code quality and functionality.

**Steps:**

1. **Run linting:**
   ```bash
   make lint-all
   ```

2. **Run tests:**
   ```bash
   pytest tests/integration/test_sdk.py
   pytest tests/integration/test_api.py
   pytest tests/e2e/test_sdk_integration.py
   ```

3. **Verify OpenAPI spec:**
   - Check that OpenAPI spec is valid
   - Verify all endpoints documented

4. **Verify imports:**
   - Check that all imports work
   - Check that SDK can be imported
   - Check that API can be imported

**Validation:**
- All linting passes
- All tests pass
- OpenAPI spec valid
- All imports work

---

## Notes and References

**Key Principles:**
- **Notebooks are source of truth** - Code is extracted FROM notebooks TO Python files
- **Real implementations** - All tests use real implementations (no mocks for core behavior)
- **SDK specification alignment** - Code must implement `docs/SDK_SPECIFICATION.md`
- **API contract alignment** - APIs must match OpenAPI spec

**References:**
- Execution Plan: `docs/operations/EXECUTION_PLAN.md` (Phase 7)
- North Star: `docs/NORTH_STAR.md` (Section 1.1, 3)
- SDK Specification: `docs/SDK_SPECIFICATION.md`
- Contract Schema: `configs/schemas/service_contract.schema.yaml`
- Extraction Script: `scripts/notebooks/extract_code.py`
- Integration Tests: `tests/integration/test_sdk.py`, `tests/integration/test_api.py`
- E2E Tests: `tests/e2e/test_sdk_integration.py`

**Plan Reference:** `plan:EXECUTION_PLAN:7.1-7.4`

---

**Last Updated:** 2026-01-02  
**Version:** 1.0


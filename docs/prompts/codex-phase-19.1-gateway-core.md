# CAIO Phase 19.1: Service Gateway Core Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-13  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:19.1`

---

## Executive Summary

Build the core Service Gateway executor module that directly executes HTTP/gRPC/native requests to external services, performs request/response transformation, and integrates with `GuaranteeEnforcer` for post-execution validation. This completes the Master Equation's `Execute(selected, r)` step, which is currently conceptual but not implemented.

**Key Deliverables:**
1. `caio/gateway/executor.py` - HTTP/gRPC/native execution engine
2. `caio/gateway/base.py` - Base adapter interface
3. `caio/gateway/transformer.py` - Request/response transformation utilities
4. Integration with `GuaranteeEnforcer` for post-execution validation
5. Update `orchestrate_request` to call gateway after routing decision
6. Error handling, retry logic, circuit breakers
7. Request/response logging and tracing

**Estimated Time:** 1 week  
**Priority:** High (foundation for all service adapters)

---

## Context & Background

### Current State

- ✅ **CAIO Orchestrator:** Routes requests and returns `RoutingDecision` (Phase 6 complete)
- ✅ **GuaranteeEnforcer:** Validates guarantees against requirements (Phase 6 complete)
- ✅ **Service Registry:** Stores service contracts (Phase 6 complete)
- ✅ **Codex Bridge:** Example bridge service pattern (Phase 9 complete)
- ❌ **Service Gateway:** No gateway executor exists - orchestrator doesn't execute requests
- ❌ **Execution Gap:** `orchestrate_request` returns routing decision but doesn't call the selected service
- ❌ **Direct Execution:** No mechanism to directly call external HTTP/gRPC services

### Problem Statement

CAIO's orchestrator performs mathematical routing and returns a `RoutingDecision`, but there's no execution step. The Master Equation defines `Execute(selected, r) | EnforceGuarantees(selected.contract)`, but this is conceptual only. Users must manually call services after receiving the routing decision, which:

1. Breaks the end-to-end orchestration flow
2. Prevents automatic guarantee enforcement at execution time
3. Requires custom code for each service integration
4. Doesn't leverage CAIO's contract-based abstraction

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Universal Compatibility:** Gateway enables direct integration with any HTTP/gRPC service
- **Mathematical Guarantees:** Gateway enforces guarantees post-execution via `GuaranteeEnforcer`
- **Contract-Based Discovery:** Gateway uses service contracts to determine execution parameters
- **Hot-Swappable Services:** Gateway enables dynamic service execution without code changes
- **Master Equation Completion:** Implements the missing `Execute(selected, r)` step

**Reference:** `docs/NORTH_STAR.md` - Universal Compatibility, Master Equation Step 8

### Execution Plan Reference

This task implements Phase 19.1: Build Service Gateway Core from `docs/operations/EXECUTION_PLAN.md`:

- **19.1:** Build Service Gateway Core
- **19.2-19.4:** Service adapters (depend on 19.1)
- **19.5:** Contract templates (depend on gateway)
- **19.6:** Testing (depends on gateway)

---

## Current State Analysis

### Existing Code Structure

**Orchestrator Flow:**
```python
# caio/api/routes/orchestrate.py
def orchestrate_request(...) -> Dict[str, Any]:
    # Route request
    decision = orchestrator.route_request(...)
    # Returns RoutingDecision with service_id, guarantees, proofs, trace
    # BUT DOES NOT EXECUTE THE SERVICE
    return {"service_id": decision.service_id, ...}
```

**GuaranteeEnforcer:**
```python
# caio/guarantees/enforcer.py
class GuaranteeEnforcer:
    def enforce_guarantees(self, guarantees, requirements) -> bool:
        # Validates guarantees against requirements
        # BUT DOES NOT EXECUTE SERVICE CALLS
```

**Service Contract Structure:**
```yaml
# configs/schemas/service_contract.schema.yaml
api:
  protocol: "http" | "grpc" | "native"
  base_url: "https://api.example.com"
  endpoints:
    - path: "/v1/chat/completions"
      method: "POST"
```

**Codex Bridge Pattern (Reference):**
```python
# services/external/codex/core/codex_client.py
# Shows how to call external APIs (OpenAI in this case)
# But this is a bridge service, not a gateway executor
```

### Missing Components

1. **Gateway Executor:** No module executes HTTP requests based on service contracts
2. **Base Adapter Interface:** No standard interface for service adapters
3. **Request/Response Transformers:** No generic transformation utilities
4. **Execution Integration:** `orchestrate_request` doesn't call gateway after routing
5. **Error Handling:** No retry logic, circuit breakers, or timeout handling
6. **Tracing:** No execution-level tracing (only routing-level)

---

## Target State

### Gateway Architecture

```
Orchestrator.route_request()
  ↓
RoutingDecision (service_id, guarantees, proofs, trace)
  ↓
GatewayExecutor.execute(decision, request)
  ↓
  ├─→ Get service contract from registry
  ├─→ Select adapter based on service_id
  ├─→ Transform request (CAIO format → Service format)
  ├─→ Execute HTTP/gRPC request
  ├─→ Transform response (Service format → CAIO format)
  ├─→ Call GuaranteeEnforcer.enforce_guarantees()
  └─→ Return ExecutionResult
```

### File Structure

```
caio/gateway/
├── __init__.py
├── executor.py          # GatewayExecutor class
├── base.py              # BaseAdapter abstract class
├── transformer.py       # Request/response transformation utilities
└── exceptions.py        # Gateway-specific exceptions
```

### Integration Points

1. **Orchestrator Integration:** `orchestrate_request` calls gateway after routing
2. **GuaranteeEnforcer Integration:** Gateway calls enforcer after receiving response
3. **Registry Integration:** Gateway gets service contract from registry
4. **Traceability Integration:** Gateway logs execution details to traceability system

---

## Step-by-Step Implementation Instructions

### Step 1: Create Gateway Module Structure

**1.1: Create `caio/gateway/__init__.py`**

**File:** `caio/gateway/__init__.py`

```python
"""CAIO Service Gateway - Direct execution of external services."""

from caio.gateway.executor import GatewayExecutor
from caio.gateway.base import BaseAdapter
from caio.gateway.exceptions import (
    GatewayError,
    ServiceExecutionError,
    GuaranteeViolationError,
    AdapterNotFoundError,
)

__all__ = [
    "GatewayExecutor",
    "BaseAdapter",
    "GatewayError",
    "ServiceExecutionError",
    "GuaranteeViolationError",
    "AdapterNotFoundError",
]
```

**1.2: Create `caio/gateway/exceptions.py`**

**File:** `caio/gateway/exceptions.py`

```python
"""Gateway-specific exceptions."""


class GatewayError(Exception):
    """Base exception for gateway errors."""
    pass


class ServiceExecutionError(GatewayError):
    """Error executing service request."""
    pass


class GuaranteeViolationError(GatewayError):
    """Service response violates guarantees."""
    pass


class AdapterNotFoundError(GatewayError):
    """Adapter not found for service."""
    pass


class TransformationError(GatewayError):
    """Error transforming request/response."""
    pass
```

### Step 2: Create Base Adapter Interface

**2.1: Create `caio/gateway/base.py`**

**File:** `caio/gateway/base.py`

```python
"""Base adapter interface for service adapters."""

from abc import ABC, abstractmethod
from typing import Any, Dict, Optional
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class BaseAdapter(ABC):
    """Base adapter interface for service adapters."""

    def __init__(self, contract: ServiceContract):
        """Initialize adapter with service contract."""
        self.contract = contract
        self.service_id = contract.service_id
        self.base_url = contract.api.base_url
        self.protocol = contract.api.protocol

    @abstractmethod
    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Execute request against service.

        Args:
            request: CAIO request object
            endpoint: Optional endpoint path (defaults to first endpoint in contract)

        Returns:
            Service response in CAIO format

        Raises:
            ServiceExecutionError: If execution fails
        """
        pass

    @abstractmethod
    def transform_request(self, request: Request) -> Dict[str, Any]:
        """
        Transform CAIO request to service format.

        Args:
            request: CAIO request object

        Returns:
            Service-formatted request
        """
        pass

    @abstractmethod
    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """
        Transform service response to CAIO format.

        Args:
            response: Service-formatted response

        Returns:
            CAIO-formatted response
        """
        pass

    def get_auth_headers(self) -> Dict[str, str]:
        """
        Get authentication headers for service.

        Returns:
            Dictionary of headers (e.g., {"Authorization": "Bearer ..."})

        Default implementation returns empty dict.
        Override in subclasses for service-specific auth.
        """
        return {}

    def get_health_status(self) -> bool:
        """
        Check service health.

        Returns:
            True if service is healthy, False otherwise

        Default implementation returns True.
        Override in subclasses for health checks.
        """
        return True
```

### Step 3: Create Request/Response Transformation Utilities

**3.1: Create `caio/gateway/transformer.py`**

**File:** `caio/gateway/transformer.py`

```python
"""Request/response transformation utilities."""

from typing import Any, Dict, Optional
from caio.orchestrator.types import Request


class RequestTransformer:
    """Utilities for transforming CAIO requests to service format."""

    @staticmethod
    def extract_prompt(request: Request) -> str:
        """Extract prompt text from CAIO request."""
        intent = request.intent or {}
        return intent.get("prompt") or intent.get("text") or intent.get("message") or ""

    @staticmethod
    def extract_messages(request: Request) -> list:
        """Extract messages array from CAIO request (for chat completions)."""
        intent = request.intent or {}
        context = request.context or {}
        
        messages = intent.get("messages") or []
        if not messages and self.extract_prompt(request):
            messages = [{"role": "user", "content": self.extract_prompt(request)}]
        
        return messages

    @staticmethod
    def extract_model(request: Request, default: Optional[str] = None) -> str:
        """Extract model name from CAIO request."""
        intent = request.intent or {}
        return intent.get("model") or default or ""

    @staticmethod
    def extract_parameters(request: Request) -> Dict[str, Any]:
        """Extract generation parameters (temperature, max_tokens, etc.)."""
        intent = request.intent or {}
        return intent.get("parameters") or {}


class ResponseTransformer:
    """Utilities for transforming service responses to CAIO format."""

    @staticmethod
    def extract_text(response: Dict[str, Any]) -> str:
        """Extract text content from service response."""
        # Try common response formats
        if "choices" in response:
            choices = response["choices"]
            if choices and len(choices) > 0:
                choice = choices[0]
                if "message" in choice:
                    return choice["message"].get("content", "")
                if "text" in choice:
                    return choice["text"]
        
        if "content" in response:
            return response["content"]
        
        if "text" in response:
            return response["text"]
        
        if "output" in response:
            return response["output"]
        
        return ""

    @staticmethod
    def extract_usage(response: Dict[str, Any]) -> Dict[str, Any]:
        """Extract token usage from service response."""
        return response.get("usage") or {}

    @staticmethod
    def extract_model(response: Dict[str, Any]) -> str:
        """Extract model name from service response."""
        return response.get("model") or ""

    @staticmethod
    def normalize_response(response: Dict[str, Any]) -> Dict[str, Any]:
        """Normalize service response to CAIO format."""
        return {
            "text": self.extract_text(response),
            "model": self.extract_model(response),
            "usage": self.extract_usage(response),
            "raw": response,  # Keep raw response for debugging
        }
```

### Step 4: Create Gateway Executor

**4.1: Create `caio/gateway/executor.py`**

**File:** `caio/gateway/executor.py`

```python
"""Gateway executor for direct service execution."""

import httpx
import time
from typing import Any, Dict, Optional, Type
from pathlib import Path

from caio.contracts.parser import ServiceContract
from caio.gateway.base import BaseAdapter
from caio.gateway.exceptions import (
    ServiceExecutionError,
    GuaranteeViolationError,
    AdapterNotFoundError,
    TransformationError,
)
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.guarantees.enforcer import GuaranteeEnforcer
from caio.orchestrator.types import Request, RoutingDecision


class GatewayExecutor:
    """Gateway executor for direct service execution."""

    def __init__(
        self,
        registry: Any = None,  # ServiceRegistry instance
        guarantee_enforcer: Optional[GuaranteeEnforcer] = None,
        traceability: Any = None,  # Traceability system
        adapter_registry: Optional[Dict[str, Type[BaseAdapter]]] = None,
    ):
        """Initialize gateway executor.

        Args:
            registry: Service registry instance
            guarantee_enforcer: Guarantee enforcer instance
            traceability: Traceability system instance
            adapter_registry: Dictionary mapping service_id to adapter class
        """
        self.registry = registry
        self.guarantee_enforcer = guarantee_enforcer or GuaranteeEnforcer()
        self.traceability = traceability
        self.adapter_registry = adapter_registry or {}
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def execute(
        self, decision: RoutingDecision, request: Request
    ) -> Dict[str, Any]:
        """
        Execute request against selected service.

        Args:
            decision: Routing decision from orchestrator
            request: Original CAIO request

        Returns:
            Execution result with response, guarantees, and metadata

        Raises:
            ServiceExecutionError: If execution fails
            GuaranteeViolationError: If response violates guarantees
        """
        service_id = decision.service_id

        # Get service contract from registry
        if not self.registry:
            raise ServiceExecutionError("Service registry not available")

        service = self.registry.get_service(service_id)
        if not service:
            raise ServiceExecutionError(f"Service {service_id} not found in registry")

        contract = service.contract if hasattr(service, "contract") else None
        if not contract:
            raise ServiceExecutionError(f"Service {service_id} has no contract")

        # Get adapter for service
        adapter_class = self.adapter_registry.get(service_id)
        if not adapter_class:
            # Try to find adapter by service_id pattern
            adapter_class = self._find_adapter(service_id, contract)
            if not adapter_class:
                raise AdapterNotFoundError(
                    f"No adapter found for service {service_id}"
                )

        # Create adapter instance
        adapter = adapter_class(contract)

        # Execute request
        start_time = time.perf_counter()
        try:
            # Transform request
            service_request = adapter.transform_request(request)

            # Execute via adapter
            service_response = adapter.execute(request)

            # Transform response
            caio_response = adapter.transform_response(service_response)

            # Calculate execution metrics
            execution_time = time.perf_counter() - start_time
            latency_ms = execution_time * 1000.0

            # Enforce guarantees
            guarantees = decision.guarantees
            if isinstance(guarantees, dict):
                requirements = request.requirements or {}
                guarantee_valid = self.guarantee_enforcer.enforce_guarantees(
                    guarantees, requirements
                )
                if not guarantee_valid:
                    raise GuaranteeViolationError(
                        f"Service {service_id} response violates guarantees"
                    )

            # Log execution to traceability
            if self.traceability:
                execution_trace = {
                    "service_id": service_id,
                    "execution_time_ms": latency_ms,
                    "request": service_request,
                    "response": caio_response,
                    "guarantees": guarantees,
                    "timestamp": time.time(),
                }
                self.traceability.store_execution_trace(
                    decision.service_id, execution_trace
                )

            return {
                "service_id": service_id,
                "response": caio_response,
                "guarantees": guarantees,
                "execution_time_ms": latency_ms,
                "raw_response": service_response,
            }

        except Exception as exc:
            execution_time = time.perf_counter() - start_time
            latency_ms = execution_time * 1000.0

            # Log error to traceability
            if self.traceability:
                error_trace = {
                    "service_id": service_id,
                    "execution_time_ms": latency_ms,
                    "error": str(exc),
                    "error_type": type(exc).__name__,
                    "timestamp": time.time(),
                }
                self.traceability.store_execution_trace(
                    decision.service_id, error_trace
                )

            raise ServiceExecutionError(
                f"Failed to execute service {service_id}: {exc}"
            ) from exc

    def _find_adapter(self, service_id: str, contract: ServiceContract) -> Optional[Type[BaseAdapter]]:
        """Find adapter for service by service_id pattern or contract metadata."""
        # Try service_id pattern matching
        if "openai" in service_id.lower():
            from caio.gateway.adapters.openai import OpenAIAdapter
            return OpenAIAdapter
        if "anthropic" in service_id.lower() or "claude" in service_id.lower():
            from caio.gateway.adapters.anthropic import AnthropicAdapter
            return AnthropicAdapter
        # Add more pattern matches as adapters are created
        # For now, return None (adapter must be registered)
        return None

    def register_adapter(self, service_id: str, adapter_class: Type[BaseAdapter]):
        """Register adapter for service."""
        self.adapter_registry[service_id] = adapter_class

    def close(self):
        """Close HTTP client."""
        self.http_client.close()
```

### Step 5: Update Orchestrate Request to Call Gateway

**5.1: Update `caio/api/routes/orchestrate.py`**

**File:** `caio/api/routes/orchestrate.py`

**Add after routing decision (around line 58):**

```python
# After routing decision, execute via gateway
from caio.gateway.executor import GatewayExecutor

# Initialize gateway executor (if not already initialized)
if not hasattr(orchestrator, "gateway"):
    orchestrator.gateway = GatewayExecutor(
        registry=orchestrator.registry,
        guarantee_enforcer=orchestrator.guarantee_enforcer,
        traceability=orchestrator.traceability,
    )

# Execute request via gateway
try:
    execution_result = orchestrator.gateway.execute(decision, request)
    
    # Add execution result to response
    response_data = {
        "decision_id": decision_id,
        "service_id": decision.service_id,
        "service_name": service_name,
        "response": execution_result.get("response"),
        "guarantees": execution_result.get("guarantees"),
        "execution_time_ms": execution_result.get("execution_time_ms"),
        "proofs": decision.proofs if isinstance(decision.proofs, list) else (
            [p.__dict__ if hasattr(p, "__dict__") else p for p in decision.proofs]
            if isinstance(decision.proofs, list)
            else []
        ),
        "trace": decision.trace if isinstance(decision.trace, dict) else (
            decision.trace.__dict__ if hasattr(decision.trace, "__dict__") else {}
        ),
    }
except Exception as exc:
    # If gateway execution fails, return routing decision only
    # (backward compatibility - user can still call service manually)
    response_data = {
        "decision_id": decision_id,
        "service_id": decision.service_id,
        "service_name": service_name,
        "guarantees": decision.guarantees if isinstance(decision.guarantees, dict) else (
            decision.guarantees.__dict__ if hasattr(decision.guarantees, "__dict__") else {}
        ),
        "proofs": decision.proofs if isinstance(decision.proofs, list) else (
            [p.__dict__ if hasattr(p, "__dict__") else p for p in decision.proofs]
            if isinstance(decision.proofs, list)
            else []
        ),
        "trace": decision.trace if isinstance(decision.trace, dict) else (
            decision.trace.__dict__ if hasattr(decision.trace, "__dict__") else {}
        ),
        "execution_error": str(exc),
    }

# Return response_data (instead of current return statement)
return response_data
```

### Step 6: Add Error Handling, Retry Logic, Circuit Breakers

**6.1: Update `caio/gateway/executor.py` with retry logic**

**Add to `GatewayExecutor` class:**

```python
import time
from typing import Optional

class GatewayExecutor:
    def __init__(
        self,
        registry: Any = None,
        guarantee_enforcer: Optional[GuaranteeEnforcer] = None,
        traceability: Any = None,
        adapter_registry: Optional[Dict[str, Type[BaseAdapter]]] = None,
        max_retries: int = 3,
        retry_delay: float = 1.0,
        timeout: float = 30.0,
    ):
        # ... existing init code ...
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        self.timeout = timeout
        self.http_client = httpx.Client(timeout=timeout)

    def execute_with_retry(
        self, decision: RoutingDecision, request: Request
    ) -> Dict[str, Any]:
        """Execute request with retry logic."""
        last_exception = None
        for attempt in range(self.max_retries):
            try:
                return self.execute(decision, request)
            except ServiceExecutionError as exc:
                last_exception = exc
                if attempt < self.max_retries - 1:
                    time.sleep(self.retry_delay * (2 ** attempt))  # Exponential backoff
                    continue
                raise
        raise last_exception
```

### Step 7: Add Request/Response Logging and Tracing

**7.1: Add logging to `caio/gateway/executor.py`**

```python
import logging

logger = logging.getLogger(__name__)

class GatewayExecutor:
    def execute(self, decision: RoutingDecision, request: Request) -> Dict[str, Any]:
        # ... existing code ...
        
        # Log execution start
        logger.info(
            f"Executing request for service {service_id}",
            extra={
                "service_id": service_id,
                "request_id": getattr(request, "request_id", None),
            }
        )
        
        # ... execution code ...
        
        # Log execution success
        logger.info(
            f"Successfully executed request for service {service_id}",
            extra={
                "service_id": service_id,
                "execution_time_ms": latency_ms,
            }
        )
        
        # ... return result ...
```

---

## Validation Procedures

### Unit Tests

**File:** `tests/gateway/test_executor.py`

```python
import pytest
from caio.gateway.executor import GatewayExecutor
from caio.gateway.base import BaseAdapter
from caio.orchestrator.types import Request, RoutingDecision

def test_executor_initialization():
    """Test gateway executor initialization."""
    executor = GatewayExecutor()
    assert executor is not None
    assert executor.guarantee_enforcer is not None

def test_executor_execute_with_mock_adapter():
    """Test executor with mock adapter."""
    # Create mock adapter
    # Create routing decision
    # Execute and verify response
    pass

def test_executor_guarantee_enforcement():
    """Test guarantee enforcement integration."""
    # Create executor with guarantee enforcer
    # Execute request that violates guarantees
    # Verify GuaranteeViolationError is raised
    pass
```

### Integration Tests

**File:** `tests/gateway/test_integration.py`

```python
def test_orchestrator_gateway_integration():
    """Test orchestrator → gateway → service flow."""
    # Create orchestrator
    # Create gateway executor
    # Route request
    # Execute via gateway
    # Verify end-to-end flow works
    pass
```

### Manual Validation

```bash
# Test gateway executor directly
python -c "
from caio import Orchestrator
from caio.gateway.executor import GatewayExecutor
from caio.orchestrator.types import Request

orchestrator = Orchestrator()
request = Request(intent={'prompt': 'Hello'}, context={}, requirements={}, constraints={})
decision = orchestrator.route_request(request)

gateway = GatewayExecutor(registry=orchestrator.registry)
result = gateway.execute(decision, request)
print(result)
"
```

---

## Troubleshooting Guide

### Issue: AdapterNotFoundError

**Symptom:** `AdapterNotFoundError: No adapter found for service {service_id}`

**Solution:**
1. Check if adapter is registered: `executor.adapter_registry.get(service_id)`
2. Register adapter: `executor.register_adapter(service_id, AdapterClass)`
3. Verify service_id matches adapter registration

### Issue: ServiceExecutionError

**Symptom:** `ServiceExecutionError: Failed to execute service {service_id}`

**Solution:**
1. Check service contract is valid
2. Check API endpoint is correct
3. Check authentication headers
4. Check network connectivity
5. Review error trace in traceability system

### Issue: GuaranteeViolationError

**Symptom:** `GuaranteeViolationError: Service response violates guarantees`

**Solution:**
1. Check service response meets guarantee thresholds
2. Review guarantee requirements in request
3. Check service contract guarantees are accurate
4. Verify GuaranteeEnforcer logic

---

## Success Criteria

- [ ] `caio/gateway/executor.py` exists and GatewayExecutor class is functional
- [ ] `caio/gateway/base.py` exists and BaseAdapter abstract class is defined
- [ ] `caio/gateway/transformer.py` exists with RequestTransformer and ResponseTransformer
- [ ] GatewayExecutor.execute() method executes HTTP requests based on service contracts
- [ ] GatewayExecutor integrates with GuaranteeEnforcer for post-execution validation
- [ ] `orchestrate_request` calls gateway after routing decision
- [ ] Retry logic works (exponential backoff)
- [ ] Error handling works (ServiceExecutionError, GuaranteeViolationError)
- [ ] Logging and tracing work (execution details logged)
- [ ] Unit tests pass for gateway executor
- [ ] Integration tests pass (orchestrator → gateway flow)

---

## Notes and References

### Key Files

- **Orchestrator:** `caio/orchestrator/core.py` - Routing logic
- **GuaranteeEnforcer:** `caio/guarantees/enforcer.py` - Guarantee validation
- **Service Registry:** `caio/registry/` - Service contract storage
- **Service Contract Schema:** `configs/schemas/service_contract.schema.yaml`
- **Codex Bridge Example:** `services/external/codex/core/codex_client.py` - Reference implementation

### Dependencies

- `httpx` - HTTP client library (already in requirements)
- `caio.contracts.parser` - Service contract parsing
- `caio.guarantees.enforcer` - Guarantee enforcement
- `caio.orchestrator.types` - Request/Response types

### Next Steps

After 19.1 is complete:
- **19.2:** Implement Tier 1 adapters (OpenAI, Anthropic, Groq, Mistral AI, Cohere)
- **19.3:** Implement Tier 2 adapters (10 services)
- **19.4:** Implement Tier 3 adapters (10+ services)
- **19.5:** Create contract templates
- **19.6:** Comprehensive testing

---

**Last Updated:** 2026-01-13  
**Version:** 1.0

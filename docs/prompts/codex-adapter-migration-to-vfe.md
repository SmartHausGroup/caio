# CAIO Adapter Migration to VFE - Tier 1 Inference Adapters

**Status:** Ready for Execution  
**Date:** 2026-01-13  
**Owner:** Codex  
**Plan Reference:** `plan:adapter-migration-to-vfe:unified-inference-architecture`

---

## Executive Summary

Migrate Tier 1 inference adapters (OpenAI, Anthropic, Groq, Mistral AI, Cohere) from CAIO's gateway adapters to VFE's unified inference engine. This migration removes inference execution from CAIO and establishes VFE as the sole inference execution layer, with CAIO focusing on orchestration and routing decisions.

**Key Deliverables:**
1. Remove Tier 1 adapter files from `caio/gateway/adapters/`
2. Update `caio/gateway/executor.py` to route inference requests to VFE
3. Update `caio/orchestrator/core.py` to use VFE for inference execution
4. Create VFE client integration in CAIO
5. Update tests and documentation

**Estimated Time:** 1-2 weeks  
**Priority:** High (completes unified inference architecture)

---

## Context & Background

### Current State

- ✅ **Tier 1 Adapters Exist:** OpenAI, Anthropic, Groq, Mistral AI, Cohere adapters in `caio/gateway/adapters/`
- ✅ **Gateway Executor:** `caio/gateway/executor.py` executes adapters directly
- ✅ **Orchestrator:** `caio/orchestrator/core.py` routes to gateway executor
- ❌ **VFE Integration:** No VFE client integration exists
- ❌ **Routing Logic:** No distinction between inference and marketplace requests

### Problem Statement

CAIO currently executes inference requests directly via gateway adapters. With the unified inference architecture, all inference execution should be handled by VFE, with CAIO focusing on orchestration and routing. Tier 1 adapters need to be removed from CAIO and inference requests need to be routed to VFE.

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Universal AI Controller:** CAIO focuses on orchestration, not inference execution
- **Mathematical Guarantees:** Guarantee enforcement continues via CAIO's GuaranteeEnforcer
- **Contract-Based Discovery:** Marketplace agent contracts remain in CAIO (non-inference)
- **Service Separation:** Clear separation between orchestration (CAIO) and inference (VFE)

**Reference:** `docs/NORTH_STAR.md` - Universal AI Controller, Service Orchestration Architecture

### Execution Plan Reference

This task implements the adapter migration from unified inference architecture ADR (`docs/adr/ADR-0001-unified-inference-architecture.md`).

**Dependencies:**
- VFE plan: `external-api-backends-integration` must be complete
- Unified inference architecture ADRs approved
- API key management system functional

---

## Step-by-Step Implementation Instructions

### Step 1: Verify VFE Backends Are Ready

**Before starting, verify:**
- [ ] VFE external API backends are implemented (check VFE plan status)
- [ ] VFE API is accessible from CAIO
- [ ] VFE API endpoints are documented

**If VFE backends are not ready:**
- Coordinate with VFE plan execution
- Use VFE stub/mock for CAIO testing
- Proceed with adapter removal first, routing second

### Step 2: Remove Tier 1 Adapters from CAIO

**2.1: Delete Adapter Files**

Delete the following files:
- `caio/gateway/adapters/openai.py`
- `caio/gateway/adapters/anthropic.py`
- `caio/gateway/adapters/groq.py`
- `caio/gateway/adapters/mistral.py`
- `caio/gateway/adapters/cohere.py`

**2.2: Update `caio/gateway/adapters/__init__.py`**

**File:** `caio/gateway/adapters/__init__.py`

Remove Tier 1 adapter imports and exports:

```python
# BEFORE:
from .openai import OpenAIAdapter
from .anthropic import AnthropicAdapter
from .groq import GroqAdapter
from .mistral import MistralAdapter
from .cohere import CohereAdapter

__all__ = [
    "BaseAdapter",
    "OpenAIAdapter",
    "AnthropicAdapter",
    "GroqAdapter",
    "MistralAdapter",
    "CohereAdapter",
]

# AFTER:
from .base import BaseAdapter

__all__ = [
    "BaseAdapter",
]
```

**2.3: Update `caio/gateway/executor.py`**

**File:** `caio/gateway/executor.py`

Remove Tier 1 adapter imports:

```python
# BEFORE:
from caio.gateway.adapters.anthropic import AnthropicAdapter
from caio.gateway.adapters.cohere import CohereAdapter
from caio.gateway.adapters.groq import GroqAdapter
from caio.gateway.adapters.mistral import MistralAdapter
from caio.gateway.adapters.openai import OpenAIAdapter

# AFTER:
# Tier 1 adapters removed - inference routed to VFE
```

Remove Tier 1 adapter registry entries:

```python
# BEFORE:
self.adapter_registry = {
    "openai": OpenAIAdapter,
    "anthropic": AnthropicAdapter,
    "groq": GroqAdapter,
    "mistral": MistralAdapter,
    "cohere": CohereAdapter,
}

# AFTER:
self.adapter_registry = {
    # Tier 1 adapters removed - inference routed to VFE
    # Marketplace agent adapters remain here
}
```

### Step 3: Create VFE Client Integration

**3.1: Create VFE Client**

**File:** `caio/integrations/vfe_client.py` (create new file)

```python
"""VFE client for inference execution."""

import httpx
import logging
import os
from typing import Any, Dict, Optional

logger = logging.getLogger(__name__)


class VFEClient:
    """Client for VFE unified inference engine."""

    def __init__(self, base_url: Optional[str] = None, api_key: Optional[str] = None):
        """Initialize VFE client."""
        self.base_url = base_url or os.getenv("VFE_API_URL", "http://localhost:8000")
        self.api_key = api_key or os.getenv("VFE_API_KEY", "")
        self.timeout = 30.0
        self.http_client = httpx.Client(timeout=self.timeout)

    def _get_headers(self) -> Dict[str, str]:
        """Get request headers."""
        headers = {"Content-Type": "application/json"}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        return headers

    def generate(
        self, messages: list[Dict[str, str]], model: str, **kwargs
    ) -> Dict[str, Any]:
        """Generate completion via VFE."""
        url = f"{self.base_url.rstrip('/')}/v1/inference/generate"
        payload = {
            "messages": messages,
            "model": model,
            **kwargs,
        }
        headers = self._get_headers()

        try:
            response = self.http_client.post(url, json=payload, headers=headers)
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError as e:
            logger.error(f"VFE API error: {e}")
            raise ServiceExecutionError(f"VFE API error: {e}") from e

    def generate_stream(
        self, messages: list[Dict[str, str]], model: str, **kwargs
    ) -> Any:
        """Generate streaming completion via VFE."""
        url = f"{self.base_url.rstrip('/')}/v1/inference/generate/stream"
        payload = {
            "messages": messages,
            "model": model,
            **kwargs,
        }
        headers = self._get_headers()

        try:
            with self.http_client.stream(
                "POST", url, json=payload, headers=headers
            ) as response:
                response.raise_for_status()
                for line in response.iter_lines():
                    if line:
                        yield json.loads(line)
        except httpx.HTTPError as e:
            logger.error(f"VFE API error: {e}")
            raise ServiceExecutionError(f"VFE API error: {e}") from e

    def list_models(self) -> Dict[str, Any]:
        """List available models from VFE."""
        url = f"{self.base_url.rstrip('/')}/v1/models"
        headers = self._get_headers()

        try:
            response = self.http_client.get(url, headers=headers)
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError as e:
            logger.error(f"VFE API error: {e}")
            raise ServiceExecutionError(f"VFE API error: {e}") from e
```

**3.2: Update Executor to Route to VFE**

**File:** `caio/gateway/executor.py`

Add VFE client import and routing logic:

```python
from caio.integrations.vfe_client import VFEClient

class Executor:
    def __init__(self):
        # ... existing code ...
        self.vfe_client = VFEClient()

    def _is_inference_request(self, service_id: str, request: Request) -> bool:
        """Determine if request is inference (should route to VFE)."""
        # Tier 1 services are inference
        inference_services = {"openai", "anthropic", "groq", "mistral", "cohere"}
        return service_id.lower() in inference_services

    def execute(
        self, service_id: str, contract: ParsedServiceContract, request: Request
    ) -> Dict[str, Any]:
        """Execute request - route to VFE for inference, gateway for marketplace."""
        # Check if this is an inference request
        if self._is_inference_request(service_id, request):
            # Route to VFE
            return self._execute_vfe(request, service_id)
        else:
            # Route to gateway (marketplace agents)
            return self._execute_gateway(service_id, contract, request)

    def _execute_vfe(self, request: Request, service_id: str) -> Dict[str, Any]:
        """Execute inference request via VFE."""
        # Transform CAIO request to VFE format
        messages = RequestTransformer.extract_messages(request)
        model = RequestTransformer.extract_model(request, service_id)
        parameters = RequestTransformer.extract_parameters(request)

        # Execute via VFE
        response = self.vfe_client.generate(
            messages=messages,
            model=model,
            **parameters,
        )

        # Transform VFE response to CAIO format
        return ResponseTransformer.normalize_response(response)

    def _execute_gateway(
        self, service_id: str, contract: ParsedServiceContract, request: Request
    ) -> Dict[str, Any]:
        """Execute marketplace agent request via gateway."""
        # Existing gateway execution logic (unchanged)
        adapter = self._get_adapter(service_id, contract)
        # ... rest of gateway execution ...
```

### Step 4: Update Orchestrator Integration

**File:** `caio/orchestrator/core.py`

Update orchestrator to use VFE routing:

```python
# Update routing decision logic to distinguish inference vs. marketplace
# Update traceability to include VFE routing
# Maintain guarantee enforcement with VFE responses
```

### Step 5: Update Tests

**5.1: Remove Tier 1 Adapter Tests**

Delete or update:
- `tests/unit/test_openai_adapter.py`
- `tests/unit/test_anthropic_adapter.py`
- `tests/unit/test_groq_adapter.py`
- `tests/unit/test_mistral_adapter.py`
- `tests/unit/test_cohere_adapter.py`

**5.2: Add VFE Integration Tests**

Create `tests/integration/test_vfe_integration.py`:

```python
"""Tests for CAIO-VFE integration."""

import pytest
from caio.integrations.vfe_client import VFEClient
from caio.gateway.executor import Executor

def test_vfe_routing():
    """Test that inference requests route to VFE."""
    # Test implementation
    pass

def test_marketplace_routing():
    """Test that marketplace requests route to gateway."""
    # Test implementation
    pass
```

### Step 6: Update Documentation

**6.1: Update Gateway Documentation**

**File:** `docs/gateway/README.md`

Update to clarify:
- Gateway adapters are for marketplace agents (non-inference)
- Inference requests route to VFE
- Adapter scope and responsibilities

**6.2: Update Execution Plan**

**File:** `docs/operations/EXECUTION_PLAN.md`

Update status:
- Mark adapter migration as complete
- Update routing architecture section

---

## Validation Procedures

### Removal Validation

```bash
# Verify adapter files are deleted
ls caio/gateway/adapters/openai.py  # Should fail (file not found)
ls caio/gateway/adapters/anthropic.py  # Should fail (file not found)
# ... etc

# Verify imports are removed
grep -r "from caio.gateway.adapters.openai import" caio/  # Should return nothing
grep -r "from caio.gateway.adapters.anthropic import" caio/  # Should return nothing
# ... etc
```

### Routing Validation

```bash
# Run integration tests
pytest tests/integration/test_vfe_integration.py -v

# Verify VFE routing works
# Test inference request routes to VFE
# Test marketplace request routes to gateway
```

### Integration Validation

```bash
# Run E2E tests
pytest tests/e2e/test_caio_vfe_integration.py -v

# Verify full flow works
# CAIO → VFE → External API → Response → GuaranteeEnforcer
```

---

## Troubleshooting Guide

### Issue: VFE API Not Accessible

**Symptoms:** VFE client fails to connect

**Solutions:**
- Verify VFE API URL is correct
- Check VFE service is running
- Verify network connectivity
- Check API key configuration

### Issue: Guarantee Enforcement Fails

**Symptoms:** GuaranteeEnforcer rejects VFE responses

**Solutions:**
- Verify VFE response format matches CAIO format
- Check response transformation logic
- Update GuaranteeEnforcer if needed
- Verify guarantee definitions are correct

### Issue: Routing Logic Incorrect

**Symptoms:** Requests route to wrong destination

**Solutions:**
- Verify `_is_inference_request()` logic
- Check service ID matching
- Test routing with different service IDs
- Update routing logic if needed

---

## Success Criteria

- [ ] All Tier 1 adapter files deleted
- [ ] `__init__.py` updated (no Tier 1 exports)
- [ ] Executor updated (VFE routing implemented)
- [ ] Orchestrator updated (VFE integration)
- [ ] VFE client created and functional
- [ ] Tests updated and passing
- [ ] Documentation updated
- [ ] Execution plan updated

---

## Notes and References

- **CAIO Plan:** `plans/adapter-migration-to-vfe/`
- **VFE Plan:** `../VerbumFieldEngine/plans/external-api-backends-integration/`
- **ADR:** `docs/adr/ADR-0001-unified-inference-architecture.md`
- **North Star:** `docs/NORTH_STAR.md`
- **BaseAdapter:** `caio/gateway/base.py`
- **Executor:** `caio/gateway/executor.py`
- **Orchestrator:** `caio/orchestrator/core.py`

---

**Last Updated:** 2026-01-13
**Version:** 1.0

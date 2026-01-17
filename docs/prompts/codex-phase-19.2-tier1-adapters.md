# CAIO Phase 19.2: Tier 1 Adapters (5 Services) - MVP Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-13  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:19.2`

---

## Executive Summary

Implement service adapters for Tier 1 (5 core LLM providers): OpenAI, Anthropic, Groq, Mistral AI, and Cohere. These are the most popular and widely-used LLM services, forming the MVP foundation for CAIO's universal gateway.

**Key Deliverables:**
1. OpenAI adapter (`caio/gateway/adapters/openai.py`)
2. Anthropic adapter (`caio/gateway/adapters/anthropic.py`)
3. Groq adapter (`caio/gateway/adapters/groq.py`)
4. Mistral AI adapter (`caio/gateway/adapters/mistral.py`)
5. Cohere adapter (`caio/gateway/adapters/cohere.py`)
6. Contract templates for all 5 services in `configs/services/external/`
7. Unit tests for each adapter
8. Integration tests with real API calls (where API keys available)

**Estimated Time:** 1 week  
**Priority:** High (MVP foundation)

**CRITICAL:** Use web search during implementation to get current API documentation for each service. Research as we build each adapter.

---

## Context & Background

### Current State

- ✅ **Phase 19.1 Complete:** Service Gateway Core implemented (GatewayExecutor, BaseAdapter, transformers)
- ✅ **Base Adapter Interface:** `caio/gateway/base.py` defines adapter pattern
- ✅ **Gateway Executor:** `caio/gateway/executor.py` ready to execute adapters
- ❌ **Service Adapters:** No adapters exist yet
- ❌ **Contract Templates:** No contract templates for Tier 1 services

### Problem Statement

Gateway executor is ready but has no adapters to execute. We need adapters for the 5 most popular LLM providers to enable CAIO to orchestrate real-world AI services.

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Universal Compatibility:** Enables CAIO to orchestrate OpenAI, Anthropic, Groq, Mistral AI, and Cohere
- **Mathematical Guarantees:** Each adapter enforces guarantees via GatewayExecutor → GuaranteeEnforcer
- **Contract-Based Discovery:** Contract templates enable service registration and discovery
- **Hot-Swappable Services:** Adapters enable dynamic service execution

**Reference:** `docs/NORTH_STAR.md` - Universal Compatibility

### Execution Plan Reference

This task implements Phase 19.2: Tier 1 Adapters (5 services) - MVP from `docs/operations/EXECUTION_PLAN.md`.

**Dependencies:**
- Phase 19.1 complete (Gateway Core)

---

## Step-by-Step Implementation Instructions

### Step 1: Research Current API Documentation

**For each service, use web search to get:**
- Current API endpoint URLs
- Authentication methods (API keys, headers, etc.)
- Request/response formats
- Model names and capabilities
- Rate limits and constraints

**Web Search Queries:**
- "OpenAI API documentation 2025 chat completions authentication"
- "Anthropic Claude API documentation 2025 messages endpoint"
- "Groq API documentation 2025 chat completions"
- "Mistral AI API documentation 2025 chat completions"
- "Cohere API documentation 2025 chat completions"

### Step 2: Create OpenAI Adapter

**2.1: Create `caio/gateway/adapters/openai.py`**

**File:** `caio/gateway/adapters/openai.py`

```python
"""OpenAI service adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class OpenAIAdapter(BaseAdapter):
    """Adapter for OpenAI API."""

    def __init__(self, contract: ServiceContract):
        """Initialize OpenAI adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("OPENAI_API_KEY", "")
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get OpenAI authentication headers."""
        if not self.api_key:
            raise ValueError("OPENAI_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to OpenAI format."""
        messages = self.request_transformer.extract_messages(request)
        model = self.request_transformer.extract_model(request, "gpt-4")
        parameters = self.request_transformer.extract_parameters(request)

        openai_request = {
            "model": model,
            "messages": messages,
        }

        # Add optional parameters
        if "temperature" in parameters:
            openai_request["temperature"] = parameters["temperature"]
        if "max_tokens" in parameters:
            openai_request["max_tokens"] = parameters["max_tokens"]
        if "top_p" in parameters:
            openai_request["top_p"] = parameters["top_p"]

        return openai_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform OpenAI response to CAIO format."""
        return self.response_transformer.normalize_response(response)

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against OpenAI API."""
        # Get endpoint from contract or use default
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/v1/chat/completions"

        # Transform request
        openai_request = self.transform_request(request)

        # Get auth headers
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        # Execute HTTP request
        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=openai_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**2.2: Create OpenAI Contract Template**

**File:** `configs/services/external/openai.yaml`

```yaml
service_id: openai
name: OpenAI
version: 1.0.0
api:
  protocol: http
  base_url: https://api.openai.com
  endpoints:
    - path: /v1/chat/completions
      method: POST
  health_endpoint: /health
capabilities:
  - type: text_generation
    parameters:
      models:
        - gpt-4
        - gpt-4o
        - gpt-3.5-turbo
guarantees:
  accuracy: 0.95
  latency:
    p95: 2000
    p99: 5000
  determinism: false
constraints:
  cost: 0.003
  risk: 0.05
metadata:
  provider: OpenAI
  documentation: https://platform.openai.com/docs/api-reference
```

### Step 3: Create Anthropic Adapter

**3.1: Create `caio/gateway/adapters/anthropic.py`**

**File:** `caio/gateway/adapters/anthropic.py`

```python
"""Anthropic service adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class AnthropicAdapter(BaseAdapter):
    """Adapter for Anthropic Claude API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Anthropic adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("ANTHROPIC_API_KEY", "")
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Anthropic authentication headers."""
        if not self.api_key:
            raise ValueError("ANTHROPIC_API_KEY environment variable not set")
        return {
            "x-api-key": self.api_key,
            "anthropic-version": "2023-06-01",
        }

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Anthropic format."""
        messages = self.request_transformer.extract_messages(request)
        model = self.request_transformer.extract_model(
            request, "claude-3-5-sonnet-20241022"
        )
        parameters = self.request_transformer.extract_parameters(request)

        anthropic_request = {
            "model": model,
            "messages": messages,
            "max_tokens": parameters.get("max_tokens", 1024),
        }

        # Add optional parameters
        if "temperature" in parameters:
            anthropic_request["temperature"] = parameters["temperature"]
        if "top_p" in parameters:
            anthropic_request["top_p"] = parameters["top_p"]

        return anthropic_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Anthropic response to CAIO format."""
        # Anthropic uses "content" array in message
        if "content" in response:
            content_array = response["content"]
            if content_array and len(content_array) > 0:
                text = content_array[0].get("text", "")
            else:
                text = ""
        else:
            text = self.response_transformer.extract_text(response)

        return {
            "text": text,
            "model": response.get("model"),
            "usage": response.get("usage"),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Anthropic API."""
        # Get endpoint from contract or use default
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/v1/messages"

        # Transform request
        anthropic_request = self.transform_request(request)

        # Get auth headers
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        # Execute HTTP request
        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=anthropic_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**3.2: Create Anthropic Contract Template**

**File:** `configs/services/external/anthropic.yaml`

```yaml
service_id: anthropic
name: Anthropic Claude
version: 1.0.0
api:
  protocol: http
  base_url: https://api.anthropic.com
  endpoints:
    - path: /v1/messages
      method: POST
  health_endpoint: /health
capabilities:
  - type: text_generation
    parameters:
      models:
        - claude-3-5-sonnet-20241022
        - claude-3-opus-20240229
        - claude-3-sonnet-20240229
guarantees:
  accuracy: 0.96
  latency:
    p95: 2500
    p99: 6000
  determinism: false
constraints:
  cost: 0.0035
  risk: 0.05
metadata:
  provider: Anthropic
  documentation: https://docs.anthropic.com/claude/reference
```

### Step 4: Create Groq Adapter

**4.1: Create `caio/gateway/adapters/groq.py`**

**File:** `caio/gateway/adapters/groq.py`

```python
"""Groq service adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class GroqAdapter(BaseAdapter):
    """Adapter for Groq API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Groq adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("GROQ_API_KEY", "")
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Groq authentication headers."""
        if not self.api_key:
            raise ValueError("GROQ_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Groq format."""
        messages = self.request_transformer.extract_messages(request)
        model = self.request_transformer.extract_model(request, "llama-3.1-70b-versatile")
        parameters = self.request_transformer.extract_parameters(request)

        groq_request = {
            "model": model,
            "messages": messages,
        }

        # Add optional parameters
        if "temperature" in parameters:
            groq_request["temperature"] = parameters["temperature"]
        if "max_tokens" in parameters:
            groq_request["max_tokens"] = parameters["max_tokens"]

        return groq_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Groq response to CAIO format."""
        return self.response_transformer.normalize_response(response)

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Groq API."""
        # Get endpoint from contract or use default
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/v1/chat/completions"

        # Transform request
        groq_request = self.transform_request(request)

        # Get auth headers
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        # Execute HTTP request
        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=groq_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**4.2: Create Groq Contract Template**

**File:** `configs/services/external/groq.yaml`

```yaml
service_id: groq
name: Groq
version: 1.0.0
api:
  protocol: http
  base_url: https://api.groq.com
  endpoints:
    - path: /v1/chat/completions
      method: POST
  health_endpoint: /health
capabilities:
  - type: text_generation
    parameters:
      models:
        - llama-3.1-70b-versatile
        - llama-3.1-8b-instant
        - mixtral-8x7b-32768
guarantees:
  accuracy: 0.92
  latency:
    p95: 500
    p99: 1000
  determinism: false
constraints:
  cost: 0.0007
  risk: 0.03
metadata:
  provider: Groq
  documentation: https://console.groq.com/docs
```

### Step 5: Create Mistral AI Adapter

**5.1: Create `caio/gateway/adapters/mistral.py`**

**File:** `caio/gateway/adapters/mistral.py`

```python
"""Mistral AI service adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class MistralAdapter(BaseAdapter):
    """Adapter for Mistral AI API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Mistral adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("MISTRAL_API_KEY", "")
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Mistral authentication headers."""
        if not self.api_key:
            raise ValueError("MISTRAL_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Mistral format."""
        messages = self.request_transformer.extract_messages(request)
        model = self.request_transformer.extract_model(request, "mistral-medium-latest")
        parameters = self.request_transformer.extract_parameters(request)

        mistral_request = {
            "model": model,
            "messages": messages,
        }

        # Add optional parameters
        if "temperature" in parameters:
            mistral_request["temperature"] = parameters["temperature"]
        if "max_tokens" in parameters:
            mistral_request["max_tokens"] = parameters["max_tokens"]
        if "top_p" in parameters:
            mistral_request["top_p"] = parameters["top_p"]

        return mistral_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Mistral response to CAIO format."""
        return self.response_transformer.normalize_response(response)

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Mistral API."""
        # Get endpoint from contract or use default
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/v1/chat/completions"

        # Transform request
        mistral_request = self.transform_request(request)

        # Get auth headers
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        # Execute HTTP request
        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=mistral_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**5.2: Create Mistral Contract Template**

**File:** `configs/services/external/mistral.yaml`

```yaml
service_id: mistral
name: Mistral AI
version: 1.0.0
api:
  protocol: http
  base_url: https://api.mistral.ai
  endpoints:
    - path: /v1/chat/completions
      method: POST
  health_endpoint: /health
capabilities:
  - type: text_generation
    parameters:
      models:
        - mistral-medium-latest
        - mistral-large-latest
        - mistral-small-latest
guarantees:
  accuracy: 0.94
  latency:
    p95: 1800
    p99: 4000
  determinism: false
constraints:
  cost: 0.0025
  risk: 0.04
metadata:
  provider: Mistral AI
  documentation: https://docs.mistral.ai/api
```

### Step 6: Create Cohere Adapter

**6.1: Create `caio/gateway/adapters/cohere.py`**

**File:** `caio/gateway/adapters/cohere.py`

```python
"""Cohere service adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class CohereAdapter(BaseAdapter):
    """Adapter for Cohere API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Cohere adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("COHERE_API_KEY", "")
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Cohere authentication headers."""
        if not self.api_key:
            raise ValueError("COHERE_API_KEY environment variable not set")
        return {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Cohere format."""
        prompt = self.request_transformer.extract_prompt(request)
        model = self.request_transformer.extract_model(request, "command-r-plus")
        parameters = self.request_transformer.extract_parameters(request)

        cohere_request = {
            "model": model,
            "message": prompt,
        }

        # Add optional parameters
        if "temperature" in parameters:
            cohere_request["temperature"] = parameters["temperature"]
        if "max_tokens" in parameters:
            cohere_request["max_tokens"] = parameters["max_tokens"]

        return cohere_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Cohere response to CAIO format."""
        # Cohere uses "text" field
        text = response.get("text", "")
        
        return {
            "text": text,
            "model": response.get("model"),
            "usage": response.get("usage"),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Cohere API."""
        # Get endpoint from contract or use default
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/v1/chat"

        # Transform request
        cohere_request = self.transform_request(request)

        # Get auth headers
        headers = self.get_auth_headers()

        # Execute HTTP request
        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=cohere_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**6.2: Create Cohere Contract Template**

**File:** `configs/services/external/cohere.yaml`

```yaml
service_id: cohere
name: Cohere
version: 1.0.0
api:
  protocol: http
  base_url: https://api.cohere.com
  endpoints:
    - path: /v1/chat
      method: POST
  health_endpoint: /health
capabilities:
  - type: text_generation
    parameters:
      models:
        - command-r-plus
        - command-r
        - command
guarantees:
  accuracy: 0.93
  latency:
    p95: 1500
    p99: 3500
  determinism: false
constraints:
  cost: 0.002
  risk: 0.04
metadata:
  provider: Cohere
  documentation: https://docs.cohere.com
```

### Step 7: Register Adapters in Gateway Executor

**7.1: Update Gateway Executor to Auto-Register Adapters**

**File:** `caio/gateway/executor.py`

**Add to `__init__` method:**

```python
from caio.gateway.adapters.openai import OpenAIAdapter
from caio.gateway.adapters.anthropic import AnthropicAdapter
from caio.gateway.adapters.groq import GroqAdapter
from caio.gateway.adapters.mistral import MistralAdapter
from caio.gateway.adapters.cohere import CohereAdapter

class GatewayExecutor:
    def __init__(self, ...):
        # ... existing init code ...
        
        # Auto-register Tier 1 adapters
        self.register_adapter("openai", OpenAIAdapter)
        self.register_adapter("anthropic", AnthropicAdapter)
        self.register_adapter("groq", GroqAdapter)
        self.register_adapter("mistral", MistralAdapter)
        self.register_adapter("cohere", CohereAdapter)
```

### Step 8: Create Unit Tests

**8.1: Create `tests/gateway/adapters/test_openai.py`**

**File:** `tests/gateway/adapters/test_openai.py`

```python
"""Tests for OpenAI adapter."""

import pytest
from unittest.mock import Mock, patch
from caio.gateway.adapters.openai import OpenAIAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


@pytest.fixture
def openai_contract():
    """Create OpenAI service contract."""
    return ServiceContract(
        service_id="openai",
        name="OpenAI",
        version="1.0.0",
        api={
            "protocol": "http",
            "base_url": "https://api.openai.com",
            "endpoints": [{"path": "/v1/chat/completions", "method": "POST"}],
        },
        capabilities=[{"type": "text_generation"}],
    )


@pytest.fixture
def openai_adapter(openai_contract):
    """Create OpenAI adapter instance."""
    with patch.dict("os.environ", {"OPENAI_API_KEY": "test-key"}):
        return OpenAIAdapter(openai_contract)


def test_openai_adapter_initialization(openai_adapter):
    """Test OpenAI adapter initialization."""
    assert openai_adapter.service_id == "openai"
    assert openai_adapter.base_url == "https://api.openai.com"


def test_openai_adapter_auth_headers(openai_adapter):
    """Test OpenAI adapter auth headers."""
    headers = openai_adapter.get_auth_headers()
    assert "Authorization" in headers
    assert headers["Authorization"].startswith("Bearer ")


def test_openai_adapter_transform_request(openai_adapter):
    """Test OpenAI adapter request transformation."""
    request = Request(
        intent={"prompt": "Hello", "model": "gpt-4"},
        context={},
        requirements={},
        constraints={},
    )
    transformed = openai_adapter.transform_request(request)
    assert "model" in transformed
    assert "messages" in transformed
    assert transformed["model"] == "gpt-4"


def test_openai_adapter_transform_response(openai_adapter):
    """Test OpenAI adapter response transformation."""
    response = {
        "choices": [{"message": {"content": "Hello!"}}],
        "model": "gpt-4",
        "usage": {"total_tokens": 10},
    }
    transformed = openai_adapter.transform_response(response)
    assert "text" in transformed
    assert transformed["text"] == "Hello!"
```

**Repeat for other adapters:**
- `tests/gateway/adapters/test_anthropic.py`
- `tests/gateway/adapters/test_groq.py`
- `tests/gateway/adapters/test_mistral.py`
- `tests/gateway/adapters/test_cohere.py`

---

## Validation Procedures

### Unit Tests

```bash
# Run all adapter unit tests
pytest tests/gateway/adapters/ -v
```

### Integration Tests (with API keys)

```bash
# Set API keys
export OPENAI_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"
export GROQ_API_KEY="your-key"
export MISTRAL_API_KEY="your-key"
export COHERE_API_KEY="your-key"

# Run integration tests
pytest tests/gateway/adapters/test_integration.py -v
```

### Manual Validation

```python
# Test each adapter
from caio.gateway.adapters.openai import OpenAIAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request

contract = ServiceContract(...)  # Load from YAML
adapter = OpenAIAdapter(contract)
request = Request(intent={"prompt": "Hello"}, ...)
response = adapter.execute(request)
print(response)
```

---

## Troubleshooting Guide

### Issue: API Key Not Set

**Symptom:** `ValueError: {SERVICE}_API_KEY environment variable not set`

**Solution:**
1. Set environment variable: `export OPENAI_API_KEY="your-key"`
2. Or use `.env` file with API keys
3. Or pass API key via adapter configuration

### Issue: Invalid Request Format

**Symptom:** Service returns 400 Bad Request

**Solution:**
1. Check request transformation logic
2. Verify service API documentation (use web search)
3. Check required fields in request
4. Review service contract endpoint configuration

### Issue: Authentication Failed

**Symptom:** Service returns 401 Unauthorized

**Solution:**
1. Verify API key is correct
2. Check auth header format (Bearer token, x-api-key, etc.)
3. Review service-specific auth requirements
4. Check API key permissions/scopes

---

## Success Criteria

- [ ] All 5 adapters exist in `caio/gateway/adapters/`
- [ ] All 5 contract templates exist in `configs/services/external/`
- [ ] Each adapter implements BaseAdapter interface
- [ ] Each adapter transforms requests correctly
- [ ] Each adapter transforms responses correctly
- [ ] Each adapter handles authentication correctly
- [ ] Adapters are registered in GatewayExecutor
- [ ] Unit tests pass for all adapters
- [ ] Integration tests pass (where API keys available)
- [ ] Contract templates validate against schema

---

## Notes and References

### Key Files

- **Base Adapter:** `caio/gateway/base.py` - Adapter interface
- **Gateway Executor:** `caio/gateway/executor.py` - Execution engine
- **Transformers:** `caio/gateway/transformer.py` - Request/response utilities
- **Service Contract Schema:** `configs/schemas/service_contract.schema.yaml`

### Web Search for API Documentation

During implementation, search for:
- "[Service Name] API documentation 2025"
- "[Service Name] authentication"
- "[Service Name] chat completions endpoint"
- "[Service Name] request format"

### Next Steps

After 19.2 is complete:
- **19.3:** Implement Tier 2 adapters (10 services)
- **19.4:** Implement Tier 3 adapters (10+ services)
- **19.5:** Create contract templates for all services
- **19.6:** Comprehensive testing

---

**Last Updated:** 2026-01-13  
**Version:** 1.0

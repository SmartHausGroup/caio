# CAIO Phase 19.3: Tier 2 Adapters (10 Services) - Phase 1 Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-13  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:19.3`

---

## Executive Summary

Implement service adapters for Tier 2 (10 specialized + local services): Ollama, LM Studio, Google Gemini, xAI Grok, Perplexity, Hugging Face Inference API, Together AI, Replicate, Azure OpenAI, and AWS Bedrock. These services provide specialized capabilities (local models, search-augmented, enterprise) and expand CAIO's orchestration coverage.

**Key Deliverables:**
1. 10 adapter files in `caio/gateway/adapters/`
2. 10 contract templates in `configs/services/external/`
3. Unit tests for each adapter
4. Integration tests with real API calls (where API keys available)

**Estimated Time:** 1.5 weeks  
**Priority:** High (expands service coverage)

**CRITICAL:** Use web search during implementation to get current API documentation for each service.

---

## Context & Background

### Current State

- ✅ **Phase 19.1 Complete:** Service Gateway Core implemented
- ✅ **Phase 19.2 Complete:** Tier 1 adapters (5 services) implemented
- ❌ **Tier 2 Adapters:** No adapters exist for specialized/local services
- ❌ **Contract Templates:** No contract templates for Tier 2 services

### Problem Statement

Tier 1 adapters provide core LLM coverage, but we need specialized services (local models, search-augmented, enterprise) to enable comprehensive orchestration scenarios.

### North Star Alignment

- **Universal Compatibility:** Enables CAIO to orchestrate specialized and local services
- **Mathematical Guarantees:** Each adapter enforces guarantees
- **Contract-Based Discovery:** Contract templates enable service registration

**Reference:** `docs/NORTH_STAR.md` - Universal Compatibility

### Execution Plan Reference

This task implements Phase 19.3: Tier 2 Adapters (10 services) - Phase 1 from `docs/operations/EXECUTION_PLAN.md`.

**Dependencies:**
- Phase 19.1 complete (Gateway Core)
- Phase 19.2 complete (Tier 1 Adapters)

---

## Step-by-Step Implementation Instructions

### Step 1: Research Current API Documentation

**For each service, use web search:**
- "Ollama API documentation 2025 local models chat completions"
- "LM Studio API documentation 2025 local models"
- "Google Gemini API documentation 2025 chat completions"
- "xAI Grok API documentation 2025"
- "Perplexity API documentation 2025 search-augmented"
- "Hugging Face Inference API documentation 2025"
- "Together AI API documentation 2025"
- "Replicate API documentation 2025 model hosting"
- "Azure OpenAI API documentation 2025"
- "AWS Bedrock API documentation 2025"

### Step 2: Create Ollama Adapter

**2.1: Create `caio/gateway/adapters/ollama.py`**

**File:** `caio/gateway/adapters/ollama.py`

```python
"""Ollama service adapter for local models."""

from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class OllamaAdapter(BaseAdapter):
    """Adapter for Ollama local models API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Ollama adapter."""
        super().__init__(contract)
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=60.0)  # Longer timeout for local models

    def get_auth_headers(self) -> Dict[str, str]:
        """Ollama doesn't require authentication for local models."""
        return {}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Ollama format."""
        messages = self.request_transformer.extract_messages(request)
        model = self.request_transformer.extract_model(request, "llama2")
        parameters = self.request_transformer.extract_parameters(request)

        ollama_request = {
            "model": model,
            "messages": messages,
            "stream": False,
        }

        # Add optional parameters
        if "temperature" in parameters:
            ollama_request["options"] = {"temperature": parameters["temperature"]}

        return ollama_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Ollama response to CAIO format."""
        return self.response_transformer.normalize_response(response)

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Ollama API."""
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/api/chat"

        ollama_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=ollama_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**2.2: Create Ollama Contract Template**

**File:** `configs/services/external/ollama.yaml`

```yaml
service_id: ollama
name: Ollama
version: 1.0.0
api:
  protocol: http
  base_url: http://localhost:11434
  endpoints:
    - path: /api/chat
      method: POST
  health_endpoint: /api/tags
capabilities:
  - type: text_generation
    parameters:
      models:
        - llama2
        - mistral
        - codellama
guarantees:
  accuracy: 0.90
  latency:
    p95: 3000
    p99: 8000
  determinism: false
constraints:
  cost: 0.0
  risk: 0.02
metadata:
  provider: Ollama
  documentation: https://ollama.ai/docs/api
  local: true
```

### Step 3: Create LM Studio Adapter

**3.1: Create `caio/gateway/adapters/lm_studio.py`**

**File:** `caio/gateway/adapters/lm_studio.py`

```python
"""LM Studio service adapter for local models."""

from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class LMStudioAdapter(BaseAdapter):
    """Adapter for LM Studio local models API (OpenAI-compatible)."""

    def __init__(self, contract: ServiceContract):
        """Initialize LM Studio adapter."""
        super().__init__(contract)
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=60.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """LM Studio doesn't require authentication."""
        return {}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to LM Studio format (OpenAI-compatible)."""
        messages = self.request_transformer.extract_messages(request)
        model = self.request_transformer.extract_model(request, "local-model")
        parameters = self.request_transformer.extract_parameters(request)

        lm_studio_request = {
            "model": model,
            "messages": messages,
        }

        if "temperature" in parameters:
            lm_studio_request["temperature"] = parameters["temperature"]
        if "max_tokens" in parameters:
            lm_studio_request["max_tokens"] = parameters["max_tokens"]

        return lm_studio_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform LM Studio response to CAIO format."""
        return self.response_transformer.normalize_response(response)

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against LM Studio API."""
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/v1/chat/completions"

        lm_studio_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=lm_studio_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**3.2: Create LM Studio Contract Template**

**File:** `configs/services/external/lm_studio.yaml`

```yaml
service_id: lm-studio
name: LM Studio
version: 1.0.0
api:
  protocol: http
  base_url: http://localhost:1234
  endpoints:
    - path: /v1/chat/completions
      method: POST
  health_endpoint: /v1/models
capabilities:
  - type: text_generation
    parameters:
      models:
        - local-model
guarantees:
  accuracy: 0.90
  latency:
    p95: 3000
    p99: 8000
  determinism: false
constraints:
  cost: 0.0
  risk: 0.02
metadata:
  provider: LM Studio
  documentation: https://lmstudio.ai/docs
  local: true
```

### Step 4: Create Google Gemini Adapter

**4.1: Create `caio/gateway/adapters/gemini.py`**

**File:** `caio/gateway/adapters/gemini.py`

```python
"""Google Gemini service adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class GeminiAdapter(BaseAdapter):
    """Adapter for Google Gemini API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Gemini adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("GOOGLE_API_KEY", "")
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Gemini authentication (API key in query param or header)."""
        if not self.api_key:
            raise ValueError("GOOGLE_API_KEY environment variable not set")
        return {}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Gemini format."""
        messages = self.request_transformer.extract_messages(request)
        model = self.request_transformer.extract_model(request, "gemini-pro")
        parameters = self.request_transformer.extract_parameters(request)

        gemini_request = {
            "contents": messages,  # Gemini uses "contents" not "messages"
        }

        if "temperature" in parameters:
            gemini_request["temperature"] = parameters["temperature"]
        if "max_tokens" in parameters:
            gemini_request["maxOutputTokens"] = parameters["max_tokens"]

        return gemini_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Gemini response to CAIO format."""
        # Gemini uses "candidates" array
        text = ""
        if "candidates" in response:
            candidates = response["candidates"]
            if candidates and len(candidates) > 0:
                candidate = candidates[0]
                if "content" in candidate:
                    parts = candidate["content"].get("parts", [])
                    if parts:
                        text = parts[0].get("text", "")

        return {
            "text": text,
            "model": response.get("model"),
            "usage": response.get("usageMetadata"),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Gemini API."""
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/v1/models/gemini-pro:generateContent"

        gemini_request = self.transform_request(request)
        headers = {"Content-Type": "application/json"}

        # Gemini uses API key in query param
        url = f"{self.base_url.rstrip('/')}{endpoint}?key={self.api_key}"
        http_response = self.http_client.post(
            url, json=gemini_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**4.2: Create Gemini Contract Template**

**File:** `configs/services/external/gemini.yaml`

```yaml
service_id: gemini
name: Google Gemini
version: 1.0.0
api:
  protocol: http
  base_url: https://generativelanguage.googleapis.com
  endpoints:
    - path: /v1/models/gemini-pro:generateContent
      method: POST
  health_endpoint: /v1/models
capabilities:
  - type: text_generation
    parameters:
      models:
        - gemini-pro
        - gemini-ultra
guarantees:
  accuracy: 0.95
  latency:
    p95: 2200
    p99: 5500
  determinism: false
constraints:
  cost: 0.0028
  risk: 0.05
metadata:
  provider: Google
  documentation: https://ai.google.dev/docs
```

### Step 5: Create Remaining Tier 2 Adapters

**5.1: Create xAI Grok Adapter**

**File:** `caio/gateway/adapters/grok.py`

```python
"""xAI Grok service adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class GrokAdapter(BaseAdapter):
    """Adapter for xAI Grok API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Grok adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("XAI_API_KEY", "")
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Grok authentication headers."""
        if not self.api_key:
            raise ValueError("XAI_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Grok format (OpenAI-compatible)."""
        messages = self.request_transformer.extract_messages(request)
        model = self.request_transformer.extract_model(request, "grok-beta")
        parameters = self.request_transformer.extract_parameters(request)

        grok_request = {
            "model": model,
            "messages": messages,
        }

        if "temperature" in parameters:
            grok_request["temperature"] = parameters["temperature"]
        if "max_tokens" in parameters:
            grok_request["max_tokens"] = parameters["max_tokens"]

        return grok_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Grok response to CAIO format."""
        return self.response_transformer.normalize_response(response)

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Grok API."""
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/v1/chat/completions"

        grok_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=grok_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**5.2: Create Perplexity Adapter**

**File:** `caio/gateway/adapters/perplexity.py`

```python
"""Perplexity service adapter (search-augmented)."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class PerplexityAdapter(BaseAdapter):
    """Adapter for Perplexity API (search-augmented)."""

    def __init__(self, contract: ServiceContract):
        """Initialize Perplexity adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("PERPLEXITY_API_KEY", "")
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Perplexity authentication headers."""
        if not self.api_key:
            raise ValueError("PERPLEXITY_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Perplexity format."""
        messages = self.request_transformer.extract_messages(request)
        model = self.request_transformer.extract_model(request, "llama-3.1-sonar-large-32k-online")
        parameters = self.request_transformer.extract_parameters(request)

        perplexity_request = {
            "model": model,
            "messages": messages,
        }

        if "temperature" in parameters:
            perplexity_request["temperature"] = parameters["temperature"]
        if "max_tokens" in parameters:
            perplexity_request["max_tokens"] = parameters["max_tokens"]

        return perplexity_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Perplexity response to CAIO format."""
        return self.response_transformer.normalize_response(response)

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Perplexity API."""
        if not endpoint:
            endpoints = self.contract.api.endpoints or []
            if endpoints:
                endpoint = endpoints[0].path
            else:
                endpoint = "/chat/completions"

        perplexity_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=perplexity_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**5.3: Create Hugging Face Inference API Adapter**

**File:** `caio/gateway/adapters/huggingface.py`

```python
"""Hugging Face Inference API adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.gateway.transformer import RequestTransformer, ResponseTransformer
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class HuggingFaceAdapter(BaseAdapter):
    """Adapter for Hugging Face Inference API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Hugging Face adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("HUGGINGFACE_API_KEY", "")
        self.request_transformer = RequestTransformer()
        self.response_transformer = ResponseTransformer()
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Hugging Face authentication headers."""
        if not self.api_key:
            raise ValueError("HUGGINGFACE_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Hugging Face format."""
        prompt = self.request_transformer.extract_prompt(request)
        parameters = self.request_transformer.extract_parameters(request)

        hf_request = {
            "inputs": prompt,
        }

        if "parameters" in parameters:
            hf_request["parameters"] = parameters["parameters"]

        return hf_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Hugging Face response to CAIO format."""
        # HF returns array or object depending on model
        if isinstance(response, list):
            text = response[0].get("generated_text", "") if response else ""
        else:
            text = response.get("generated_text", "")

        return {
            "text": text,
            "model": response.get("model"),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Hugging Face API."""
        if not endpoint:
            # HF uses model-specific endpoints
            model = self.request_transformer.extract_model(request)
            endpoint = f"/models/{model}"

        hf_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=hf_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**5.4: Create Together AI, Replicate, Azure OpenAI, AWS Bedrock Adapters**

**Follow similar pattern:**
- `caio/gateway/adapters/together.py`
- `caio/gateway/adapters/replicate.py`
- `caio/gateway/adapters/azure_openai.py`
- `caio/gateway/adapters/aws_bedrock.py`

**Use web search to get current API documentation for each.**

### Step 6: Create Contract Templates

**Create contract templates for all 10 services:**
- `configs/services/external/ollama.yaml`
- `configs/services/external/lm_studio.yaml`
- `configs/services/external/gemini.yaml`
- `configs/services/external/grok.yaml`
- `configs/services/external/perplexity.yaml`
- `configs/services/external/huggingface.yaml`
- `configs/services/external/together.yaml`
- `configs/services/external/replicate.yaml`
- `configs/services/external/azure_openai.yaml`
- `configs/services/external/aws_bedrock.yaml`

### Step 7: Register Adapters

**Update `caio/gateway/executor.py` to auto-register Tier 2 adapters:**

```python
from caio.gateway.adapters.ollama import OllamaAdapter
from caio.gateway.adapters.lm_studio import LMStudioAdapter
from caio.gateway.adapters.gemini import GeminiAdapter
from caio.gateway.adapters.grok import GrokAdapter
from caio.gateway.adapters.perplexity import PerplexityAdapter
from caio.gateway.adapters.huggingface import HuggingFaceAdapter
from caio.gateway.adapters.together import TogetherAdapter
from caio.gateway.adapters.replicate import ReplicateAdapter
from caio.gateway.adapters.azure_openai import AzureOpenAIAdapter
from caio.gateway.adapters.aws_bedrock import AWSBedrockAdapter

# In __init__:
self.register_adapter("ollama", OllamaAdapter)
self.register_adapter("lm-studio", LMStudioAdapter)
self.register_adapter("gemini", GeminiAdapter)
self.register_adapter("grok", GrokAdapter)
self.register_adapter("perplexity", PerplexityAdapter)
self.register_adapter("huggingface", HuggingFaceAdapter)
self.register_adapter("together", TogetherAdapter)
self.register_adapter("replicate", ReplicateAdapter)
self.register_adapter("azure-openai", AzureOpenAIAdapter)
self.register_adapter("aws-bedrock", AWSBedrockAdapter)
```

### Step 8: Create Unit Tests

**Create test files for each adapter:**
- `tests/gateway/adapters/test_ollama.py`
- `tests/gateway/adapters/test_lm_studio.py`
- `tests/gateway/adapters/test_gemini.py`
- `tests/gateway/adapters/test_grok.py`
- `tests/gateway/adapters/test_perplexity.py`
- `tests/gateway/adapters/test_huggingface.py`
- `tests/gateway/adapters/test_together.py`
- `tests/gateway/adapters/test_replicate.py`
- `tests/gateway/adapters/test_azure_openai.py`
- `tests/gateway/adapters/test_aws_bedrock.py`

---

## Validation Procedures

### Unit Tests

```bash
pytest tests/gateway/adapters/test_tier2*.py -v
```

### Integration Tests

```bash
# Set API keys for services that require them
export GOOGLE_API_KEY="your-key"
export XAI_API_KEY="your-key"
export PERPLEXITY_API_KEY="your-key"
# ... etc

pytest tests/gateway/adapters/test_integration_tier2.py -v
```

---

## Troubleshooting Guide

### Issue: Local Service Not Running

**Symptom:** Connection refused for Ollama/LM Studio

**Solution:**
1. Start Ollama: `ollama serve`
2. Start LM Studio server
3. Verify base_url in contract matches running service
4. Check port numbers

### Issue: Enterprise Service Authentication

**Symptom:** Azure OpenAI or AWS Bedrock auth fails

**Solution:**
1. Check Azure/AWS credentials are configured
2. Verify service endpoints are correct
3. Review enterprise-specific auth requirements
4. Check IAM roles/permissions

---

## Success Criteria

- [ ] All 10 Tier 2 adapters exist in `caio/gateway/adapters/`
- [ ] All 10 contract templates exist in `configs/services/external/`
- [ ] Each adapter implements BaseAdapter interface
- [ ] Adapters are registered in GatewayExecutor
- [ ] Unit tests pass for all adapters
- [ ] Integration tests pass (where API keys available)
- [ ] Contract templates validate against schema

---

## Notes and References

### Web Search for API Documentation

Search for current API docs for each service during implementation.

### Next Steps

After 19.3 is complete:
- **19.4:** Implement Tier 3 adapters (10+ services)
- **19.5:** Create contract templates for all services
- **19.6:** Comprehensive testing

---

**Last Updated:** 2026-01-13  
**Version:** 1.0

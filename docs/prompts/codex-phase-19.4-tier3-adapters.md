# CAIO Phase 19.4: Tier 3 Adapters (10+ Services) - Extended Ecosystem Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-13  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:19.4`

---

## Executive Summary

Implement service adapters for Tier 3 (10+ extended ecosystem services): Embedding services (OpenAI Embeddings, Cohere Embed, Voyage AI), Code services (GitHub Copilot API, Cursor API), Search services (Tavily, Serper), Voice services (ElevenLabs, Deepgram), Image services (Midjourney API, Stability AI, DALL-E), and additional LLMs (Meta AI, Google PaLM, Aleph Alpha). These services expand CAIO's capabilities beyond text generation to embeddings, code, search, voice, and image generation.

**Key Deliverables:**
1. 10+ adapter files in `caio/gateway/adapters/`
2. 10+ contract templates in `configs/services/external/`
3. Unit tests for each adapter
4. Integration tests with real API calls (where API keys available)

**Estimated Time:** 1 week  
**Priority:** Medium (extends capabilities beyond core LLM)

**CRITICAL:** Use web search during implementation to get current API documentation for each service.

---

## Context & Background

### Current State

- ✅ **Phase 19.1 Complete:** Service Gateway Core implemented
- ✅ **Phase 19.2 Complete:** Tier 1 adapters (5 services) implemented
- ✅ **Phase 19.3 Complete:** Tier 2 adapters (10 services) implemented
- ❌ **Tier 3 Adapters:** No adapters exist for extended ecosystem services
- ❌ **Contract Templates:** No contract templates for Tier 3 services

### Problem Statement

Tier 1 and 2 provide LLM coverage, but we need specialized services (embeddings, code, search, voice, image) to enable comprehensive AI orchestration scenarios beyond text generation.

### North Star Alignment

- **Universal Compatibility:** Enables CAIO to orchestrate any AI service type
- **Mathematical Guarantees:** Each adapter enforces guarantees
- **Contract-Based Discovery:** Contract templates enable service registration

**Reference:** `docs/NORTH_STAR.md` - Universal Compatibility

### Execution Plan Reference

This task implements Phase 19.4: Tier 3 Adapters (10+ services) - Extended Ecosystem from `docs/operations/EXECUTION_PLAN.md`.

**Dependencies:**
- Phase 19.1 complete (Gateway Core)
- Phase 19.2 complete (Tier 1 Adapters)
- Phase 19.3 complete (Tier 2 Adapters)

---

## Step-by-Step Implementation Instructions

### Step 1: Research Current API Documentation

**For each service category, use web search:**
- Embedding services: "OpenAI embeddings API 2025", "Cohere embed API 2025", "Voyage AI embeddings API 2025"
- Code services: "GitHub Copilot API 2025", "Cursor API 2025"
- Search services: "Tavily API 2025", "Serper API 2025"
- Voice services: "ElevenLabs API 2025", "Deepgram API 2025"
- Image services: "Midjourney API 2025", "Stability AI API 2025", "DALL-E API 2025"
- Additional LLMs: "Meta AI API 2025", "Google PaLM API 2025", "Aleph Alpha API 2025"

### Step 2: Create Embedding Service Adapters

**2.1: OpenAI Embeddings Adapter**

**File:** `caio/gateway/adapters/openai_embeddings.py`

```python
"""OpenAI Embeddings service adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class OpenAIEmbeddingsAdapter(BaseAdapter):
    """Adapter for OpenAI Embeddings API."""

    def __init__(self, contract: ServiceContract):
        """Initialize OpenAI Embeddings adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("OPENAI_API_KEY", "")
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get OpenAI authentication headers."""
        if not self.api_key:
            raise ValueError("OPENAI_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to OpenAI Embeddings format."""
        intent = request.intent or {}
        text = intent.get("text") or intent.get("input") or ""
        model = intent.get("model") or "text-embedding-3-small"

        return {
            "input": text if isinstance(text, str) else text,
            "model": model,
        }

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform OpenAI Embeddings response to CAIO format."""
        embeddings = []
        if "data" in response:
            embeddings = [item.get("embedding", []) for item in response["data"]]
        elif "embedding" in response:
            embeddings = [response["embedding"]]

        return {
            "embeddings": embeddings,
            "model": response.get("model"),
            "usage": response.get("usage"),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against OpenAI Embeddings API."""
        if not endpoint:
            endpoint = "/v1/embeddings"

        embeddings_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=embeddings_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**2.2: Cohere Embed Adapter**

**File:** `caio/gateway/adapters/cohere_embed.py`

```python
"""Cohere Embed service adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class CohereEmbedAdapter(BaseAdapter):
    """Adapter for Cohere Embed API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Cohere Embed adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("COHERE_API_KEY", "")
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
        """Transform CAIO request to Cohere Embed format."""
        intent = request.intent or {}
        texts = intent.get("texts") or [intent.get("text", "")]
        model = intent.get("model") or "embed-english-v3.0"

        return {
            "texts": texts if isinstance(texts, list) else [texts],
            "model": model,
        }

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Cohere Embed response to CAIO format."""
        return {
            "embeddings": response.get("embeddings", []),
            "model": response.get("model"),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Cohere Embed API."""
        if not endpoint:
            endpoint = "/v1/embed"

        cohere_request = self.transform_request(request)
        headers = self.get_auth_headers()

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=cohere_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**2.3: Voyage AI Adapter**

**File:** `caio/gateway/adapters/voyage.py`

```python
"""Voyage AI embeddings adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class VoyageAdapter(BaseAdapter):
    """Adapter for Voyage AI Embeddings API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Voyage adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("VOYAGE_API_KEY", "")
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Voyage authentication headers."""
        if not self.api_key:
            raise ValueError("VOYAGE_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Voyage format."""
        intent = request.intent or {}
        input_text = intent.get("input") or intent.get("text") or ""
        model = intent.get("model") or "voyage-3"

        return {
            "input": input_text if isinstance(input_text, list) else [input_text],
            "model": model,
        }

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Voyage response to CAIO format."""
        return {
            "embeddings": response.get("data", []),
            "model": response.get("model"),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Voyage API."""
        if not endpoint:
            endpoint = "/v1/embeddings"

        voyage_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=voyage_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

### Step 3: Create Code Service Adapters

**3.1: GitHub Copilot Adapter**

**File:** `caio/gateway/adapters/github_copilot.py`

```python
"""GitHub Copilot API adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class GitHubCopilotAdapter(BaseAdapter):
    """Adapter for GitHub Copilot API."""

    def __init__(self, contract: ServiceContract):
        """Initialize GitHub Copilot adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("GITHUB_COPILOT_API_KEY", "")
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get GitHub Copilot authentication headers."""
        if not self.api_key:
            raise ValueError("GITHUB_COPILOT_API_KEY environment variable not set")
        return {
            "Authorization": f"Bearer {self.api_key}",
            "Accept": "application/json",
        }

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to GitHub Copilot format."""
        intent = request.intent or {}
        prompt = intent.get("prompt") or intent.get("code") or ""
        context = intent.get("context") or {}

        return {
            "messages": [
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            "context": context,
        }

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform GitHub Copilot response to CAIO format."""
        return {
            "code": response.get("choices", [{}])[0].get("message", {}).get("content", ""),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against GitHub Copilot API."""
        if not endpoint:
            endpoint = "/v1/completions"

        copilot_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=copilot_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**3.2: Cursor API Adapter**

**File:** `caio/gateway/adapters/cursor.py`

```python
"""Cursor API adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class CursorAdapter(BaseAdapter):
    """Adapter for Cursor API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Cursor adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("CURSOR_API_KEY", "")
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Cursor authentication headers."""
        if not self.api_key:
            raise ValueError("CURSOR_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Cursor format."""
        intent = request.intent or {}
        messages = intent.get("messages") or [
            {"role": "user", "content": intent.get("prompt", "")}
        ]

        return {"messages": messages}

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Cursor response to CAIO format."""
        return {
            "code": response.get("choices", [{}])[0].get("message", {}).get("content", ""),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Cursor API."""
        if not endpoint:
            endpoint = "/v1/chat/completions"

        cursor_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=cursor_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

### Step 4: Create Search Service Adapters

**4.1: Tavily Adapter**

**File:** `caio/gateway/adapters/tavily.py`

```python
"""Tavily search API adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class TavilyAdapter(BaseAdapter):
    """Adapter for Tavily Search API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Tavily adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("TAVILY_API_KEY", "")
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Tavily authentication headers."""
        if not self.api_key:
            raise ValueError("TAVILY_API_KEY environment variable not set")
        return {"api-key": self.api_key}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Tavily format."""
        intent = request.intent or {}
        query = intent.get("query") or intent.get("prompt") or ""

        return {
            "api_key": self.api_key,
            "query": query,
            "search_depth": intent.get("search_depth", "basic"),
        }

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Tavily response to CAIO format."""
        return {
            "results": response.get("results", []),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Tavily API."""
        if not endpoint:
            endpoint = "/search"

        tavily_request = self.transform_request(request)
        headers = {"Content-Type": "application/json"}

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=tavily_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**4.2: Serper Adapter**

**File:** `caio/gateway/adapters/serper.py`

```python
"""Serper search API adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class SerperAdapter(BaseAdapter):
    """Adapter for Serper Search API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Serper adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("SERPER_API_KEY", "")
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Serper authentication headers."""
        if not self.api_key:
            raise ValueError("SERPER_API_KEY environment variable not set")
        return {
            "X-API-KEY": self.api_key,
            "Content-Type": "application/json",
        }

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Serper format."""
        intent = request.intent or {}
        query = intent.get("query") or intent.get("prompt") or ""

        return {"q": query}

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Serper response to CAIO format."""
        return {
            "results": response.get("organic", []),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Serper API."""
        if not endpoint:
            endpoint = "/search"

        serper_request = self.transform_request(request)
        headers = self.get_auth_headers()

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=serper_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

### Step 5: Create Voice Service Adapters

**5.1: ElevenLabs Adapter**

**File:** `caio/gateway/adapters/elevenlabs.py`

```python
"""ElevenLabs voice API adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class ElevenLabsAdapter(BaseAdapter):
    """Adapter for ElevenLabs Text-to-Speech API."""

    def __init__(self, contract: ServiceContract):
        """Initialize ElevenLabs adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("ELEVENLABS_API_KEY", "")
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get ElevenLabs authentication headers."""
        if not self.api_key:
            raise ValueError("ELEVENLABS_API_KEY environment variable not set")
        return {"xi-api-key": self.api_key}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to ElevenLabs format."""
        intent = request.intent or {}
        text = intent.get("text") or intent.get("prompt") or ""
        voice_id = intent.get("voice_id") or "21m00Tcm4TlvDq8ikWAM"

        return {
            "text": text,
            "voice_id": voice_id,
            "model_id": intent.get("model_id", "eleven_monolingual_v1"),
        }

    def transform_response(self, response: Any) -> Dict[str, Any]:
        """Transform ElevenLabs response to CAIO format."""
        # ElevenLabs returns audio bytes, not JSON
        return {
            "audio": response if isinstance(response, bytes) else None,
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against ElevenLabs API."""
        if not endpoint:
            endpoint = "/v1/text-to-speech/{voice_id}"

        elevenlabs_request = self.transform_request(request)
        voice_id = elevenlabs_request.pop("voice_id")
        endpoint = endpoint.replace("{voice_id}", voice_id)

        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=elevenlabs_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.content  # Returns audio bytes
```

**5.2: Deepgram Adapter**

**File:** `caio/gateway/adapters/deepgram.py`

```python
"""Deepgram speech-to-text API adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class DeepgramAdapter(BaseAdapter):
    """Adapter for Deepgram Speech-to-Text API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Deepgram adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("DEEPGRAM_API_KEY", "")
        self.http_client = httpx.Client(timeout=30.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Deepgram authentication headers."""
        if not self.api_key:
            raise ValueError("DEEPGRAM_API_KEY environment variable not set")
        return {"Authorization": f"Token {self.api_key}"}

    def transform_request(self, request: Request) -> bytes:
        """Transform CAIO request to Deepgram format (audio bytes)."""
        intent = request.intent or {}
        audio_data = intent.get("audio") or intent.get("audio_bytes") or b""
        return audio_data if isinstance(audio_data, bytes) else bytes(audio_data)

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Deepgram response to CAIO format."""
        transcript = ""
        if "results" in response:
            results = response["results"]
            if results and "channels" in results:
                channels = results["channels"]
                if channels:
                    alternatives = channels[0].get("alternatives", [])
                    if alternatives:
                        transcript = alternatives[0].get("transcript", "")

        return {
            "text": transcript,
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Deepgram API."""
        if not endpoint:
            endpoint = "/v1/listen"

        audio_data = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "audio/wav"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, content=audio_data, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

### Step 6: Create Image Service Adapters

**6.1: DALL-E Adapter**

**File:** `caio/gateway/adapters/dalle.py`

```python
"""DALL-E image generation adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class DALLEAdapter(BaseAdapter):
    """Adapter for DALL-E Image Generation API."""

    def __init__(self, contract: ServiceContract):
        """Initialize DALL-E adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("OPENAI_API_KEY", "")
        self.http_client = httpx.Client(timeout=60.0)  # Longer timeout for image generation

    def get_auth_headers(self) -> Dict[str, str]:
        """Get DALL-E authentication headers."""
        if not self.api_key:
            raise ValueError("OPENAI_API_KEY environment variable not set")
        return {"Authorization": f"Bearer {self.api_key}"}

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to DALL-E format."""
        intent = request.intent or {}
        prompt = intent.get("prompt") or intent.get("text") or ""
        model = intent.get("model") or "dall-e-3"
        parameters = intent.get("parameters") or {}

        dalle_request = {
            "model": model,
            "prompt": prompt,
            "n": parameters.get("n", 1),
            "size": parameters.get("size", "1024x1024"),
        }

        return dalle_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform DALL-E response to CAIO format."""
        images = []
        if "data" in response:
            images = [item.get("url", "") for item in response["data"]]

        return {
            "images": images,
            "model": response.get("model"),
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against DALL-E API."""
        if not endpoint:
            endpoint = "/v1/images/generations"

        dalle_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=dalle_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

**6.2: Stability AI Adapter**

**File:** `caio/gateway/adapters/stability.py`

```python
"""Stability AI image generation adapter."""

import os
from typing import Any, Dict, Optional
import httpx

from caio.gateway.base import BaseAdapter
from caio.contracts.parser import ServiceContract
from caio.orchestrator.types import Request


class StabilityAdapter(BaseAdapter):
    """Adapter for Stability AI Image Generation API."""

    def __init__(self, contract: ServiceContract):
        """Initialize Stability adapter."""
        super().__init__(contract)
        self.api_key = os.getenv("STABILITY_API_KEY", "")
        self.http_client = httpx.Client(timeout=60.0)

    def get_auth_headers(self) -> Dict[str, str]:
        """Get Stability authentication headers."""
        if not self.api_key:
            raise ValueError("STABILITY_API_KEY environment variable not set")
        return {
            "Authorization": f"Bearer {self.api_key}",
            "Accept": "application/json",
        }

    def transform_request(self, request: Request) -> Dict[str, Any]:
        """Transform CAIO request to Stability format."""
        intent = request.intent or {}
        prompt = intent.get("prompt") or intent.get("text") or ""
        parameters = intent.get("parameters") or {}

        stability_request = {
            "text_prompts": [{"text": prompt}],
            "cfg_scale": parameters.get("cfg_scale", 7),
            "width": parameters.get("width", 512),
            "height": parameters.get("height", 512),
        }

        return stability_request

    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Transform Stability response to CAIO format."""
        images = []
        if "artifacts" in response:
            images = [item.get("base64", "") for item in response["artifacts"]]

        return {
            "images": images,
            "raw": response,
        }

    def execute(
        self, request: Request, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """Execute request against Stability AI API."""
        if not endpoint:
            endpoint = "/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image"

        stability_request = self.transform_request(request)
        headers = self.get_auth_headers()
        headers["Content-Type"] = "application/json"

        url = f"{self.base_url.rstrip('/')}{endpoint}"
        http_response = self.http_client.post(
            url, json=stability_request, headers=headers
        )
        http_response.raise_for_status()

        return http_response.json()
```

### Step 7: Create Additional LLM Adapters

**7.1: Meta AI Adapter**

**File:** `caio/gateway/adapters/meta_ai.py`

```python
"""Meta AI (Llama) adapter."""

# Similar pattern to other LLM adapters
# Use web search to get current Meta AI API documentation
```

**7.2: Google PaLM Adapter**

**File:** `caio/gateway/adapters/palm.py`

```python
"""Google PaLM adapter."""

# Similar pattern to Gemini adapter
# Use web search to get current PaLM API documentation
```

**7.3: Aleph Alpha Adapter**

**File:** `caio/gateway/adapters/aleph_alpha.py`

```python
"""Aleph Alpha adapter."""

# Similar pattern to other LLM adapters
# Use web search to get current Aleph Alpha API documentation
```

### Step 8: Create Contract Templates

**Create contract templates for all Tier 3 services:**
- `configs/services/external/openai_embeddings.yaml`
- `configs/services/external/cohere_embed.yaml`
- `configs/services/external/voyage.yaml`
- `configs/services/external/github_copilot.yaml`
- `configs/services/external/cursor.yaml`
- `configs/services/external/tavily.yaml`
- `configs/services/external/serper.yaml`
- `configs/services/external/elevenlabs.yaml`
- `configs/services/external/deepgram.yaml`
- `configs/services/external/dalle.yaml`
- `configs/services/external/stability.yaml`
- `configs/services/external/meta_ai.yaml`
- `configs/services/external/palm.yaml`
- `configs/services/external/aleph_alpha.yaml`

### Step 9: Register Adapters

**Update `caio/gateway/executor.py` to auto-register Tier 3 adapters.**

### Step 10: Create Unit Tests

**Create test files for each Tier 3 adapter.**

---

## Validation Procedures

### Unit Tests

```bash
pytest tests/gateway/adapters/test_tier3*.py -v
```

### Integration Tests

```bash
# Set API keys for services that require them
pytest tests/gateway/adapters/test_integration_tier3.py -v
```

---

## Troubleshooting Guide

### Issue: Specialized Service Formats

**Symptom:** Embedding/image/voice services have different request/response formats

**Solution:**
1. Review service-specific API documentation (web search)
2. Adjust transformer logic for service-specific formats
3. Test with real API calls to verify format

### Issue: Binary Data Handling

**Symptom:** Voice/image services return binary data, not JSON

**Solution:**
1. Handle binary responses in adapter
2. Return base64-encoded data or file paths
3. Document binary response handling

---

## Success Criteria

- [ ] All 10+ Tier 3 adapters exist in `caio/gateway/adapters/`
- [ ] All contract templates exist in `configs/services/external/`
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

After 19.4 is complete:
- **19.5:** Create contract templates for all services
- **19.6:** Comprehensive testing

---

**Last Updated:** 2026-01-13  
**Version:** 1.0

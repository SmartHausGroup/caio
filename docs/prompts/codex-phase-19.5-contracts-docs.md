# CAIO Phase 19.5: Contract Templates & Documentation Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-13  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:19.5`

---

## Executive Summary

Create contract templates for all 25+ services implemented in Phases 19.2-19.4, and comprehensive documentation for the gateway system including adapter patterns, integration examples, and troubleshooting guides.

**Key Deliverables:**
1. Contract templates for all 25+ services in `configs/services/external/`
2. Documentation in `docs/gateway/` (adapter patterns, usage, examples)
3. Integration examples for each tier
4. Troubleshooting guides

**Estimated Time:** 3-4 days  
**Priority:** High (enables service registration)

---

## Context & Background

### Current State

- ✅ **Phase 19.1-19.4 Complete:** Gateway core and all adapters implemented
- ❌ **Contract Templates:** Missing templates for many services
- ❌ **Documentation:** No gateway documentation exists

### North Star Alignment

- **Contract-Based Discovery:** Templates enable service registration
- **Universal Compatibility:** Documentation enables external developers

**Reference:** `docs/NORTH_STAR.md` - Contract-Based Discovery

---

## Step-by-Step Implementation Instructions

### Step 1: Create Contract Templates for All Services

**For each service from Phases 19.2-19.4, create YAML contract in `configs/services/external/`:**

**Template Structure:**
```yaml
service_id: <service-id>
name: <Service Name>
version: 1.0.0
api:
  protocol: http
  base_url: <base-url>
  endpoints:
    - path: <endpoint-path>
      method: POST
  health_endpoint: <health-endpoint>
capabilities:
  - type: <capability-type>
    parameters:
      models: [<model-list>]
guarantees:
  accuracy: <value>
  latency:
    p95: <ms>
    p99: <ms>
  determinism: <bool>
constraints:
  cost: <cost-per-token>
  risk: <risk-score>
metadata:
  provider: <Provider Name>
  documentation: <API-docs-url>
```

**Services to create templates for:**
- Tier 1 (5): openai.yaml, anthropic.yaml, groq.yaml, mistral.yaml, cohere.yaml
- Tier 2 (10): ollama.yaml, lm_studio.yaml, gemini.yaml, grok.yaml, perplexity.yaml, huggingface.yaml, together.yaml, replicate.yaml, azure_openai.yaml, aws_bedrock.yaml
- Tier 3 (10+): openai_embeddings.yaml, cohere_embed.yaml, voyage.yaml, github_copilot.yaml, cursor.yaml, tavily.yaml, serper.yaml, elevenlabs.yaml, deepgram.yaml, dalle.yaml, stability.yaml, meta_ai.yaml, palm.yaml, aleph_alpha.yaml

### Step 2: Validate All Contract Templates

**Run validation script:**
```bash
python scripts/validate_contracts.py configs/services/external/*.yaml
```

**Ensure all templates:**
- Validate against `configs/schemas/service_contract.schema.yaml`
- Have correct service_id, name, version
- Have valid api.base_url and api.endpoints
- Have capabilities defined
- Have guarantees defined
- Have constraints defined

### Step 3: Create Gateway Documentation

**3.1: Create `docs/gateway/README.md`**

**File:** `docs/gateway/README.md`

```markdown
# CAIO Service Gateway

## Overview

The CAIO Service Gateway provides direct execution of external services via adapters, eliminating the need for custom bridge services for HTTP/gRPC services.

## Architecture

- **GatewayExecutor:** Core execution engine
- **BaseAdapter:** Adapter interface
- **Service Adapters:** Service-specific implementations
- **Transformers:** Request/response transformation utilities

## Supported Services

### Tier 1: Core LLM Providers
- OpenAI, Anthropic, Groq, Mistral AI, Cohere

### Tier 2: Specialized + Local
- Ollama, LM Studio, Google Gemini, xAI Grok, Perplexity, Hugging Face, Together AI, Replicate, Azure OpenAI, AWS Bedrock

### Tier 3: Extended Ecosystem
- Embeddings, Code, Search, Voice, Image services

## Usage

See integration examples in `docs/gateway/examples/`.
```

**3.2: Create `docs/gateway/ADAPTER_PATTERNS.md`**

**File:** `docs/gateway/ADAPTER_PATTERNS.md`

```markdown
# Adapter Patterns

## Base Adapter Interface

All adapters must implement `BaseAdapter`:

```python
class MyAdapter(BaseAdapter):
    def transform_request(self, request: Request) -> Dict[str, Any]:
        # Transform CAIO request to service format
        pass
    
    def transform_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        # Transform service response to CAIO format
        pass
    
    def execute(self, request: Request, endpoint: Optional[str] = None) -> Dict[str, Any]:
        # Execute HTTP request
        pass
```

## Common Patterns

### OpenAI-Compatible Services
Many services use OpenAI-compatible API format.

### Custom Formats
Some services require custom request/response formats.

See examples in `docs/gateway/examples/`.
```

**3.3: Create `docs/gateway/examples/` directory with integration examples**

### Step 4: Create Troubleshooting Guide

**File:** `docs/gateway/TROUBLESHOOTING.md`

Common issues and solutions for gateway usage.

---

## Validation Procedures

```bash
# Validate all contract templates
python scripts/validate_contracts.py configs/services/external/*.yaml

# Verify documentation links
make docs-check
```

---

## Success Criteria

- [ ] All 25+ contract templates exist and validate
- [ ] Gateway documentation complete
- [ ] Integration examples created
- [ ] Troubleshooting guide complete

---

**Last Updated:** 2026-01-13  
**Version:** 1.0

# CAIO Phase 10: Prototype Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-08  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:10`

---

## ⚠️ CRITICAL: Cleanup Required First

**IMPORTANT:** You previously executed Phase 10 prototype work in the **WRONG repository** (VerbumFieldEngine/VFE). Before proceeding with CAIO Phase 10, you MUST clean up the VFE work.

### Cleanup Task: Remove VFE Phase 10 Work

**Repository:** `/Users/smarthaus/Projects/GitHub/VerbumFieldEngine`

**Files to Remove:**
1. `vfe_phase10_prototype_demo.py` (repository root)
2. `docs/prototype/PHASE10_API_PROTOTYPE.md`
3. `docs/prototype/README.md`
4. `docs/prototype/` directory (if empty after removing files)

**Files to Revert:**
1. `README.md` - Remove the "Quick Start - Phase 10 Prototype Demo" section (lines ~187-198)
2. `plans/vfe-phase-10-prototype/vfe-phase-10-prototype.md` - Revert status from "Complete" to "Proposed"
3. `plans/vfe-phase-10-prototype/vfe-phase-10-prototype.yaml` - Revert status from "complete" to "proposed"
4. `plans/vfe-phase-10-prototype/vfe-phase-10-prototype.json` - Revert status from "complete" to "proposed"
5. `docs/operations/EXECUTION_PLAN.md` - Remove any Phase 10 completion entries
6. `docs/operations/STATUS_PLAN.md` - Remove Phase 10 completion status
7. `CODEX_ACTION_LOG` - Remove the entry about completing Phase 10 in VFE

**Cleanup Steps:**

1. **Navigate to VFE repository:**
   ```bash
   cd /Users/smarthaus/Projects/GitHub/VerbumFieldEngine
   ```

2. **Remove prototype files:**
   ```bash
   rm -f vfe_phase10_prototype_demo.py
   rm -rf docs/prototype/
   ```

3. **Revert README.md changes:**
   ```bash
   git checkout README.md
   # OR manually remove the "Quick Start - Phase 10 Prototype Demo" section
   ```

4. **Revert plan status files:**
   ```bash
   git checkout plans/vfe-phase-10-prototype/vfe-phase-10-prototype.md
   git checkout plans/vfe-phase-10-prototype/vfe-phase-10-prototype.yaml
   git checkout plans/vfe-phase-10-prototype/vfe-phase-10-prototype.json
   ```

5. **Revert execution plan and status plan:**
   ```bash
   git checkout docs/operations/EXECUTION_PLAN.md
   git checkout docs/operations/STATUS_PLAN.md
   ```

6. **Clean up action log:**
   - Remove the entry: "2026-01-08 15:17:23 EST — Implemented Phase 10 prototype demonstrations and validation..."
   - Keep the entry about the blocked request (that was correct)

7. **Verify cleanup:**
   ```bash
   git status
   # Should show no uncommitted changes related to Phase 10
   ```

**After cleanup is complete, proceed with CAIO Phase 10 implementation below.**

---

## Executive Summary

Create standalone prototype demonstrations that show CAIO working end-to-end. This phase produces two prototypes:
1. **Standalone Python Prototype:** Programmatic API demonstration script
2. **HTTP API Prototype:** HTTP/REST API demonstration with curl examples

These prototypes serve as proof of concept, integration examples, developer onboarding tools, and stakeholder demonstrations.

**CRITICAL:** This is demonstration/prototype work, not mathematical algorithm work. MA process is NOT required. However, prototypes must be functional and demonstrate real CAIO capabilities.

**Estimated Time:** 1-2 days  
**Priority:** High (enables CAIO demonstration and integration)

**CRITICAL:** You are working in the **CAIO repository** (`/Users/smarthaus/Projects/GitHub/CAIO`), NOT VerbumFieldEngine. All files created must be in the CAIO repository.

---

## Context & Background

### Current State

- ✅ **CAIO Orchestrator:** Fully implemented and operational
- ✅ **Service Registry:** Contract-based discovery working
- ✅ **API Endpoints:** HTTP/REST API fully functional
- ✅ **Service Contracts:** Schema defined, parser working
- ✅ **Integration Tests:** Tests demonstrate API usage
- ❌ **Standalone Prototype:** No standalone demo script exists
- ❌ **HTTP API Prototype Docs:** No curl examples documentation exists

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Universal Compatibility:** Prototypes demonstrate CAIO can be used by any system (TAI or external)
- **Contract-Based Discovery:** Prototypes show service registration and discovery in action
- **Mathematical Guarantees:** Prototypes display routing decisions with guarantees, proofs, and traceability
- **Integration Examples:** Prototypes serve as integration guides for TAI and other systems

**Reference:** `docs/NORTH_STAR.md` - Universal AI orchestration platform

### Execution Plan Reference

This task implements Phase 10: Prototype from `docs/operations/execution_plan.md`:

- **10.1:** Create standalone Python prototype script
- **10.2:** Create HTTP API prototype documentation
- **10.3:** Create prototype README
- **10.4:** Update main README

---

## Step-by-Step Implementation Instructions

### Task 10.1: Create Standalone Python Prototype Script

**File:** `caio_prototype_demo.py` (repository root)

**Objective:** Create an executable Python script that demonstrates CAIO working end-to-end using the programmatic API.

#### Step 1.1: Create Script Structure

**File:** `caio_prototype_demo.py`

**Shebang and Imports:**
```python
#!/usr/bin/env python3
"""
CAIO Standalone Prototype Demo

This script demonstrates CAIO working end-to-end:
1. Create an Orchestrator
2. Register a service with a contract
3. Make an orchestration request
4. Show the routing decision with guarantees, proofs, and trace

Run: python caio_prototype_demo.py
"""

import json
import tempfile
from pathlib import Path

# Import CAIO components
from caio import Orchestrator, Request
```

#### Step 1.2: Create Demo Service Contract Function

**Function:** `create_demo_service_contract() -> str`

**Purpose:** Generate a simple demo service contract YAML string.

**Reference:** Use `configs/schemas/service_contract.example.yaml` or `configs/services/external/codex.yaml` as template.

**Required Fields:**
- `service_id`: "demo-chat-service"
- `name`: "Demo Chat Service"
- `version`: "1.0.0"
- `capabilities`: At least one capability (e.g., "chat")
- `guarantees`: Latency, accuracy, determinism bounds
- `constraints`: Rate limits, context length, etc.
- `api`: Base URL and endpoints

**Example Structure:**
```python
def create_demo_service_contract() -> str:
    """Create a simple demo service contract."""
    contract_yaml = """
service_id: demo-chat-service
name: Demo Chat Service
version: "1.0.0"
description: "A simple demo chat service for CAIO prototype"

capabilities:
  - type: chat
    accuracy:
      min: 0.90
      target: 0.95
  - type: text_generation
    accuracy:
      min: 0.85
      target: 0.90

guarantees:
  latency:
    property: p95_latency_ms
    bound:
      max: 1000
  accuracy:
    property: classification_accuracy
    bound:
      min: 0.90
  determinism:
    property: deterministic_output
    bound:
      seed_required: true

cost:
  model: per_token
  base_cost: 0.001
  token_cost: 0.0001
  currency: USD

privacy:
  data_locality: local
  encryption: true
  encryption_type: end_to_end
  data_retention: session
  gdpr_compliant: true

alignment:
  safety_level: high
  content_filtering: true
  bias_mitigation: true

constraints:
  max_concurrent_requests: 10
  rate_limit:
    per_minute: 100
  context_length:
    max_tokens: 4096
  requires_gpu: false
  requires_internet: false

api:
  protocol: http
  base_url: http://localhost:9000
  endpoints:
    - path: /chat
      method: POST
      input_schema: schemas/chat_input.json
      output_schema: schemas/chat_output.json

metadata:
  tags:
    - chat
    - text-generation
    - demo
  category: ai-service
  provider: demo-provider
"""
    return contract_yaml
```

#### Step 1.3: Implement Main Function

**Function:** `main()`

**Steps:**

1. **Step 1: Create Orchestrator**
   ```python
   print("Step 1: Creating CAIO Orchestrator...")
   orchestrator = Orchestrator()
   print("✅ Orchestrator created")
   print(f"   - Registry: {type(orchestrator.registry).__name__}")
   print(f"   - Rule Engine: {type(orchestrator.rule_engine).__name__}")
   print(f"   - Security Verifier: {type(orchestrator.security_verifier).__name__}")
   print(f"   - Guarantee Enforcer: {type(orchestrator.guarantee_enforcer).__name__}")
   print(f"   - Traceability: {type(orchestrator.traceability).__name__}")
   ```

2. **Step 2: Register Service**
   ```python
   print("Step 2: Registering demo service...")
   contract_yaml = create_demo_service_contract()
   
   # Write contract to temporary file
   with tempfile.NamedTemporaryFile(mode="w", suffix=".yaml", delete=False) as f:
       f.write(contract_yaml)
       contract_path = Path(f.name)
   
   try:
       entry = orchestrator.register_service(contract_path)
       print(f"✅ Service registered: {entry.contract.service_id}")
       print(f"   - Name: {entry.contract.name}")
       print(f"   - Version: {entry.contract.version}")
       print(f"   - Capabilities: {[c.get('type', 'unknown') for c in entry.contract.capabilities]}")
   finally:
       contract_path.unlink()
   ```

3. **Step 3: List Registered Services**
   ```python
   print("Step 3: Listing registered services...")
   services = orchestrator.list_services()
   print(f"✅ Found {len(services)} service(s)")
   for service in services:
       print(f"   - {service.contract.service_id}: {service.contract.name}")
   ```

4. **Step 4: Create Request**
   ```python
   print("Step 4: Making orchestration request...")
   request = Request(
       intent={"type": "chat", "message": "Hello, CAIO!"},
       context={"conversation_id": "demo-123", "user_id": "demo-user"},
       requirements={"capability": "chat", "max_latency_ms": 1000},
       constraints={"requires_gpu": False, "data_locality": "local"},
       user={"trust_level": "high", "preferences": {"language": "en"}},
   )
   print(f"   Request intent: {request.intent}")
   print(f"   Request requirements: {request.requirements}")
   ```

5. **Step 5: Route Request**
   ```python
   print("Step 5: Routing request through CAIO...")
   decision = orchestrator.route_request(
       request=request,
       policies=[],
       history={},
       seed=42,  # Deterministic seed
   )
   print("✅ Routing decision made")
   ```

6. **Step 6: Display Routing Decision**
   ```python
   print("Step 6: Routing Decision Results")
   print("-" * 80)
   print(f"Service Selected: {decision.service_id}")
   print(f"Model: {decision.model if hasattr(decision, 'model') else 'N/A'}")
   print(f"Route: {decision.route if hasattr(decision, 'route') else 'N/A'}")
   print()
   
   # Display guarantees
   print("Guarantees:")
   if hasattr(decision, 'guarantees') and decision.guarantees:
       if isinstance(decision.guarantees, dict):
           for key, value in decision.guarantees.items():
               print(f"  - {key}: {value}")
       else:
           print(f"  {decision.guarantees}")
   else:
       print("  (No guarantees specified)")
   print()
   
   # Display proofs
   print("Mathematical Proofs:")
   if hasattr(decision, 'proofs') and decision.proofs:
       for i, proof in enumerate(decision.proofs, 1):
           if isinstance(proof, dict):
               print(f"  Proof {i}:")
               for key, value in proof.items():
                   print(f"    {key}: {value}")
           else:
               print(f"  Proof {i}: {proof}")
   else:
       print("  (Proofs generated by CAIO routing algorithm)")
   print()
   
   # Display trace
   print("Traceability (Decision Trace):")
   if hasattr(decision, 'trace') and decision.trace:
       if isinstance(decision.trace, dict):
           trace_json = json.dumps(decision.trace, indent=2, default=str)
           print(trace_json)
       else:
           print(f"  {decision.trace}")
   else:
       print("  (Trace generated by CAIO traceability system)")
   ```

7. **Step 7: Summary**
   ```python
   print("=" * 80)
   print("Demo Summary")
   print("=" * 80)
   print("✅ CAIO Orchestrator created and initialized")
   print("✅ Service registered with contract-based discovery")
   print("✅ Request routed using mathematical guarantees")
   print("✅ Routing decision includes:")
   print("   - Selected service")
   print("   - Guarantees (latency, accuracy, determinism)")
   print("   - Mathematical proofs")
   print("   - Complete traceability")
   print()
   print("CAIO is working! 🎉")
   print("=" * 80)
   ```

#### Step 1.4: Add Error Handling

**Add try/except blocks:**
- Handle `ImportError` if CAIO not installed
- Handle `FileNotFoundError` if contract file issues
- Handle `ValueError` if contract validation fails
- Handle `AttributeError` if routing decision structure unexpected
- Provide clear error messages for each case

#### Step 1.5: Make Script Executable

**Add to script:**
```python
if __name__ == "__main__":
    main()
```

**Make executable:**
```bash
chmod +x caio_prototype_demo.py
```

#### Step 1.6: Validate Script

**Test Commands:**
```bash
# Test script runs
python caio_prototype_demo.py

# Verify output shows all steps
# Verify routing decision is displayed
# Verify no errors occur
```

**Expected Output:**
- Step-by-step progress messages
- Service registration confirmation
- Routing decision with all components
- Summary at end

### Task 10.2: Create HTTP API Prototype Documentation

**File:** `docs/prototype/API_PROTOTYPE.md`

**Objective:** Create documentation with curl examples demonstrating CAIO HTTP API usage.

#### Step 2.1: Create Documentation Structure

**Sections:**
1. Prerequisites
2. Service Registration
3. Orchestration Request
4. Trace Retrieval
5. Health Check
6. Expected Responses
7. Troubleshooting

#### Step 2.2: Prerequisites Section

**Content:**
```markdown
## Prerequisites

1. **Start CAIO Server:**
   ```bash
   uvicorn caio.api.app:app --port 8080
   ```

2. **Verify Health:**
   ```bash
   curl http://localhost:8080/health
   ```

   Expected response:
   ```json
   {
     "status": "healthy",
     "components": {
       "orchestrator": "healthy",
       "registry": "healthy",
       "rule_engine": "healthy"
     }
   }
   ```
```

#### Step 2.3: Service Registration Section

**Content:**
```markdown
## Service Registration

Register a service with CAIO using a YAML contract:

```bash
curl -X POST http://localhost:8080/api/v1/services \
  -H 'Content-Type: application/yaml' \
  -d @configs/services/external/codex.yaml
```

**Alternative (inline YAML):**
```bash
curl -X POST http://localhost:8080/api/v1/services \
  -H 'Content-Type: application/yaml' \
  --data-binary @- << 'EOF'
service_id: demo-chat-service
name: Demo Chat Service
version: "1.0.0"
capabilities:
  - type: chat
guarantees:
  latency:
    property: p95_latency_ms
    bound:
      max: 1000
api:
  protocol: http
  base_url: http://localhost:9000
  endpoints:
    - path: /chat
      method: POST
EOF
```

**Expected Response:**
```json
{
  "service_id": "demo-chat-service",
  "status": "registered",
  "message": "Service registered successfully"
}
```
```

#### Step 2.4: Orchestration Request Section

**Content:**
```markdown
## Orchestration Request

Make an orchestration request to CAIO:

```bash
curl -X POST http://localhost:8080/api/v1/orchestrate \
  -H 'Content-Type: application/json' \
  -d '{
    "intent": {"type": "chat", "message": "Hello, CAIO!"},
    "context": {"conversation_id": "demo-123"},
    "requirements": {"capability": "chat", "max_latency_ms": 1000},
    "constraints": {"requires_gpu": false},
    "user": {"trust_level": "high"}
  }'
```

**Expected Response:**
```json
{
  "decision_id": "dec-1234567890",
  "service_id": "demo-chat-service",
  "route": "internal",
  "model": "demo-chat-service",
  "guarantees": {
    "latency": {"p95_latency_ms": 1000},
    "accuracy": {"min": 0.90}
  },
  "proofs": {
    "contract_matching": "valid",
    "rule_satisfaction": "valid",
    "security": "valid"
  },
  "trace": {
    "request": {...},
    "decision": {...},
    "timestamp": "2026-01-08T14:35:29Z"
  }
}
```
```

#### Step 2.5: Trace Retrieval Section

**Content:**
```markdown
## Trace Retrieval

Retrieve trace for a routing decision:

```bash
curl http://localhost:8080/api/v1/trace/dec-1234567890
```

**Expected Response:**
```json
{
  "decision_id": "dec-1234567890",
  "request": {...},
  "decision": {...},
  "proofs": {...},
  "guarantees": {...},
  "timestamp": "2026-01-08T14:35:29Z"
}
```
```

#### Step 2.6: Health Check Section

**Content:**
```markdown
## Health Check

Check CAIO service health:

```bash
curl http://localhost:8080/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "components": {
    "orchestrator": "healthy",
    "registry": "healthy",
    "rule_engine": "healthy",
    "security_verifier": "healthy",
    "guarantee_enforcer": "healthy",
    "traceability": "healthy"
  }
}
```
```

#### Step 2.7: Expected Responses Section

**Content:**
- JSON examples for each endpoint
- Error response examples
- Status codes documentation

#### Step 2.8: Troubleshooting Section

**Content:**
- Common issues (server not running, contract validation errors, etc.)
- Debugging tips
- Support resources

### Task 10.3: Create Prototype README

**File:** `docs/prototype/README.md`

**Objective:** Provide instructions for running both prototypes.

**Sections:**
1. Overview
2. Prerequisites
3. Standalone Python Prototype
4. HTTP API Prototype
5. Expected Outputs
6. Troubleshooting

**Content:**
```markdown
# CAIO Prototype Demos

This directory contains prototype demonstrations of CAIO functionality.

## Overview

Two prototypes are available:
1. **Standalone Python Prototype:** Programmatic API demonstration
2. **HTTP API Prototype:** HTTP/REST API demonstration

## Prerequisites

- Python 3.10+
- CAIO installed (`pip install -e .`) or run from source
- For HTTP API prototype: CAIO server running

## Standalone Python Prototype

Run the standalone Python prototype:

```bash
python caio_prototype_demo.py
```

This demonstrates:
- Orchestrator instantiation
- Service registration
- Request orchestration
- Routing decision display

## HTTP API Prototype

See `API_PROTOTYPE.md` for HTTP API examples with curl.

## Expected Outputs

Both prototypes should show:
- Service registration success
- Routing decision with guarantees
- Mathematical proofs
- Complete traceability

## Troubleshooting

See `API_PROTOTYPE.md` troubleshooting section.
```

### Task 10.4: Update Main README

**File:** `README.md`

**Objective:** Add prototype section to main README.

**Location:** After "Installation" or "Getting Started" section

**Content:**
```markdown
## Quick Start - Prototype Demo

See CAIO in action with our standalone prototypes:

- **Standalone Python Demo:** `python caio_prototype_demo.py`
- **HTTP API Demo:** See `docs/prototype/API_PROTOTYPE.md`

For detailed instructions, see `docs/prototype/README.md`.
```

---

## Validation Procedures

### Validation 1: Standalone Python Prototype

**Commands:**
```bash
# Run prototype
python caio_prototype_demo.py

# Verify output
# - All steps complete successfully
# - Service registered
# - Routing decision displayed
# - No errors
```

**Expected Results:**
- Script runs without errors
- All steps show success messages
- Routing decision is displayed with all components
- Summary shows all features working

### Validation 2: HTTP API Prototype

**Commands:**
```bash
# Start CAIO server
uvicorn caio.api.app:app --port 8080

# Test health endpoint
curl http://localhost:8080/health

# Test service registration (use example contract)
curl -X POST http://localhost:8080/api/v1/services \
  -H 'Content-Type: application/yaml' \
  -d @configs/services/external/codex.yaml

# Test orchestration
curl -X POST http://localhost:8080/api/v1/orchestrate \
  -H 'Content-Type: application/json' \
  -d '{"intent": {"type": "chat"}, "requirements": {"capability": "chat"}}'
```

**Expected Results:**
- All curl examples work
- Responses match documented examples
- No errors occur

### Validation 3: Documentation Links

**Commands:**
```bash
# Check all links in README.md
# Check all links in docs/prototype/README.md
# Check all links in docs/prototype/API_PROTOTYPE.md
```

**Expected Results:**
- All links are valid
- All referenced files exist
- No broken links

---

## Troubleshooting Guide

### Issue: Script fails with ImportError

**Cause:** CAIO not installed or not in Python path

**Solution:**
```bash
# Install CAIO in development mode
pip install -e .

# Or run from repository root with PYTHONPATH
PYTHONPATH=. python caio_prototype_demo.py
```

### Issue: Service registration fails

**Cause:** Contract validation error or file path issue

**Solution:**
- Check contract YAML syntax
- Verify contract matches schema
- Check file path is correct

### Issue: Routing decision is None or incomplete

**Cause:** No matching services or routing logic issue

**Solution:**
- Verify service is registered
- Check service capabilities match request requirements
- Review orchestrator logs for errors

### Issue: HTTP API examples don't work

**Cause:** CAIO server not running or wrong port

**Solution:**
- Start CAIO server: `uvicorn caio.api.app:app --port 8080`
- Verify server is running: `curl http://localhost:8080/health`
- Check port matches examples (8080)

---

## Success Criteria

- [ ] Standalone Python prototype script created (`caio_prototype_demo.py`)
- [ ] Script runs successfully: `python caio_prototype_demo.py`
- [ ] Script demonstrates all core CAIO features
- [ ] HTTP API prototype documentation created (`docs/prototype/API_PROTOTYPE.md`)
- [ ] All curl examples work when CAIO server is running
- [ ] Prototype README created (`docs/prototype/README.md`)
- [ ] Main README updated with prototype section
- [ ] All documentation links validated
- [ ] Both prototypes validated locally
- [ ] Execution Plan updated with Phase 10 completion
- [ ] Status Plan updated with Phase 10 status

---

## Notes

- This is a **demonstration/prototype** phase - focus on clarity and functionality
- Prototypes should be simple and clear, not comprehensive
- Focus on showing CAIO works, not on edge cases
- Prototypes serve as examples for integration and onboarding
- Use existing test patterns as reference (`tests/integration/test_orchestrator_components.py`)

---

## References

- **Plan Document:** `plans/phase-10-prototype/phase-10-prototype.md`
- **North Star:** `docs/NORTH_STAR.md`
- **Execution Plan:** `docs/operations/execution_plan.md`
- **Orchestrator API:** `caio/orchestrator/core.py`
- **Request Type:** `caio/orchestrator/types.py`
- **Service Contracts:** `configs/schemas/service_contract.schema.yaml`
- **Integration Tests:** `tests/integration/test_orchestrator_components.py`
- **API Reference:** `docs/api/API_REFERENCE.md`

# Codex Prompt: Phase 6 - Orchestrator Implementation

**Plan Reference:** `plan:phase-6-orchestrator`  
**Execution Plan Reference:** `plan:EXECUTION_PLAN:6.1-6.8`  
**Status:** Ready for Implementation  
**North Star Alignment:** Implements CAIO orchestrator core per `docs/NORTH_STAR.md` (Section 1.1, Core Characteristics; Section 2, Mathematical Foundation)

---

## Executive Summary

Complete Phase 6 (Orchestrator Implementation) by extracting code from all 8 implementation notebooks to Python files, creating the proper directory structure, integrating all components, and testing the complete orchestrator. This implements the CAIO orchestrator core that realizes the master control equation and sub-calculi in code.

**Note:** This is code extraction and integration work. All code already exists in notebooks (notebook-first development). MA process is NOT required for extraction, but you must follow the mandatory workflow (North Star alignment, Execution Plan verification, change approval). All tests must use real implementations (no mocks for core behavior).

---

## Context & Background

**Current State:**
- Phases 0-5 are **COMPLETE** ✅ (Foundation, Math, Invariants, Notebooks, CI Enforcement)
- Phase 6 is **~75% complete** (All 8 implementation notebooks created and committed)
- All implementation notebooks exist:
  - `orchestrator_routing.ipynb` (12 modular parts)
  - `contract_parser.ipynb` (9 parts)
  - `service_registry.ipynb` (9 parts)
  - `rule_engine.ipynb` (8 parts)
  - `security_verifier.ipynb` (8 parts)
  - `guarantee_enforcer.ipynb` (5 parts)
  - `traceability.ipynb` (5 parts)
  - `control_integration.ipynb` (5 parts)
- Code extraction script exists: `scripts/notebooks/extract_code.py`
- No `caio/` directory structure exists yet (code needs to be extracted)

**Why This Matters:**
- Implements the core CAIO orchestrator that realizes the master equation
- Enables contract-based service discovery and routing
- Provides mathematical guarantees for all routing decisions
- Enables hot-swappable services via contract registration
- Provides provability and traceability for all decisions

**Related Work:**
- Execution Plan: `docs/operations/EXECUTION_PLAN.md` (Phase 6: Orchestrator Implementation)
- North Star: `docs/NORTH_STAR.md` (Section 1.1: Core Characteristics; Section 2: Mathematical Foundation)
- Status Plan: `docs/operations/STATUS_PLAN.md` (Phase 6: ~75% complete - notebooks created, extraction pending)
- SDK Specification: `docs/SDK_SPECIFICATION.md` (Contract schema and service interface)
- Master Calculus: `docs/math/CAIO_MASTER_CALCULUS.md` (Mathematical foundation)
- Control Calculus: `docs/math/CAIO_CONTROL_CALCULUS.md` (Control signal generation)

---

## Current State Analysis

**What Exists:**

**Notebooks (Source of Truth):**
- `notebooks/math/orchestrator_routing.ipynb` - Core routing engine (12 parts: Data Structures, Field State Extraction, Contract Matching, Rule Constraint Satisfaction, Security Verification, Trait Constraint Verification, Optimization/Scoring, Control Signal Generation, Guarantee Composition, Proof Generation, Traceability, Main Routing Function)
- `notebooks/math/contract_parser.ipynb` - Contract parser & validator (9 parts)
- `notebooks/math/service_registry.ipynb` - Service registry (9 parts)
- `notebooks/math/rule_engine.ipynb` - Rule engine (8 parts)
- `notebooks/math/security_verifier.ipynb` - Security verifier (8 parts)
- `notebooks/math/guarantee_enforcer.ipynb` - Guarantee enforcer (5 parts)
- `notebooks/math/traceability.ipynb` - Traceability & proof generation (5 parts)
- `notebooks/math/control_integration.ipynb` - Control integration with MAIA (5 parts)

**Extraction Script:**
- `scripts/notebooks/extract_code.py` - Extracts code from notebooks to Python files

**Tests:**
- `tests/integration/test_orchestrator_components.py` - Integration tests for orchestrator components
- `tests/e2e/test_routing_flow.py` - E2E tests for routing flow
- `tests/mathematical/test_notebook_verification.py` - Mathematical validation tests

**What's Missing:**

**Directory Structure:**
- `caio/` directory doesn't exist
- `caio/orchestrator/` - Core routing engine
- `caio/contracts/` - Contract parser & validator
- `caio/registry/` - Service registry
- `caio/rules/` - Rule engine
- `caio/security/` - Security verifier
- `caio/guarantees/` - Guarantee enforcer
- `caio/traceability/` - Traceability & proof generation
- `caio/control/` - Control integration

**Extracted Code:**
- No Python files extracted from notebooks yet
- All code still lives in notebooks (source of truth)

**Integration:**
- Components not integrated together
- No main orchestrator entry point
- No end-to-end routing flow implementation

**Testing:**
- Integration tests exist but need extracted code to test
- E2E tests exist but need complete orchestrator to test

---

## Target State

**After Completion:**
- ✅ Complete `caio/` directory structure with all components
- ✅ All code extracted from notebooks to Python files
- ✅ All components integrated together
- ✅ Main orchestrator entry point (`caio/orchestrator/routing.py` with `caio_route` function)
- ✅ Complete orchestrator functional (can route requests end-to-end)
- ✅ All integration tests passing
- ✅ All E2E tests passing
- ✅ All quality gates pass (tests, invariants, artifacts, linting)

---

## Step-by-Step Implementation Instructions

### TASK 6.1: Create Directory Structure

**Purpose:** Create the `caio/` directory structure for all orchestrator components.

**Steps:**

1. **Create base `caio/` directory:**
   ```bash
   mkdir -p caio
   touch caio/__init__.py
   ```

2. **Create component directories:**
   ```bash
   mkdir -p caio/orchestrator
   mkdir -p caio/contracts
   mkdir -p caio/registry
   mkdir -p caio/rules
   mkdir -p caio/security
   mkdir -p caio/guarantees
   mkdir -p caio/traceability
   mkdir -p caio/control
   ```

3. **Create `__init__.py` files:**
   ```bash
   touch caio/orchestrator/__init__.py
   touch caio/contracts/__init__.py
   touch caio/registry/__init__.py
   touch caio/rules/__init__.py
   touch caio/security/__init__.py
   touch caio/guarantees/__init__.py
   touch caio/traceability/__init__.py
   touch caio/control/__init__.py
   ```

**Validation:**
- All directories exist
- All `__init__.py` files exist
- Directory structure matches planned structure

---

### TASK 6.2: Extract Contract Parser (`contract_parser.ipynb`)

**Purpose:** Extract contract parser & validator from notebook to Python file.

**Steps:**

1. **Extract code from notebook:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/contract_parser.ipynb \
       --output caio/contracts/parser.py \
       --classes ContractParser ContractValidator
   ```

2. **Verify extraction:**
   - Check that `caio/contracts/parser.py` exists
   - Check that extracted code matches notebook code
   - Check that imports are correct

3. **Update `caio/contracts/__init__.py`:**
   ```python
   """CAIO Contract Parser & Validator."""
   
   from caio.contracts.parser import ContractParser, ContractValidator
   
   __all__ = ["ContractParser", "ContractValidator"]
   ```

**Validation:**
- Code extracted successfully
- Extracted code matches notebook code
- Imports work correctly
- No linting errors

---

### TASK 6.3: Extract Service Registry (`service_registry.ipynb`)

**Purpose:** Extract service registry from notebook to Python file.

**Steps:**

1. **Extract code from notebook:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/service_registry.ipynb \
       --output caio/registry/registry.py \
       --classes ServiceRegistry ServiceEntry
   ```

2. **Verify extraction:**
   - Check that `caio/registry/registry.py` exists
   - Check that extracted code matches notebook code
   - Check that imports are correct

3. **Update `caio/registry/__init__.py`:**
   ```python
   """CAIO Service Registry."""
   
   from caio.registry.registry import ServiceRegistry, ServiceEntry
   
   __all__ = ["ServiceRegistry", "ServiceEntry"]
   ```

**Validation:**
- Code extracted successfully
- Extracted code matches notebook code
- Imports work correctly
- No linting errors

---

### TASK 6.4: Extract Rule Engine (`rule_engine.ipynb`)

**Purpose:** Extract rule engine from notebook to Python file.

**Steps:**

1. **Extract code from notebook:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/rule_engine.ipynb \
       --output caio/rules/engine.py \
       --classes RuleEngine Rule
   ```

2. **Verify extraction:**
   - Check that `caio/rules/engine.py` exists
   - Check that extracted code matches notebook code
   - Check that imports are correct

3. **Update `caio/rules/__init__.py`:**
   ```python
   """CAIO Rule Engine."""
   
   from caio.rules.engine import RuleEngine, Rule
   
   __all__ = ["RuleEngine", "Rule"]
   ```

**Validation:**
- Code extracted successfully
- Extracted code matches notebook code
- Imports work correctly
- No linting errors

---

### TASK 6.5: Extract Security Verifier (`security_verifier.ipynb`)

**Purpose:** Extract security verifier from notebook to Python file.

**Steps:**

1. **Extract code from notebook:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/security_verifier.ipynb \
       --output caio/security/verifier.py \
       --classes SecurityVerifier
   ```

2. **Verify extraction:**
   - Check that `caio/security/verifier.py` exists
   - Check that extracted code matches notebook code
   - Check that imports are correct

3. **Update `caio/security/__init__.py`:**
   ```python
   """CAIO Security Verifier."""
   
   from caio.security.verifier import SecurityVerifier
   
   __all__ = ["SecurityVerifier"]
   ```

**Validation:**
- Code extracted successfully
- Extracted code matches notebook code
- Imports work correctly
- No linting errors

---

### TASK 6.6: Extract Guarantee Enforcer (`guarantee_enforcer.ipynb`)

**Purpose:** Extract guarantee enforcer from notebook to Python file.

**Steps:**

1. **Extract code from notebook:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/guarantee_enforcer.ipynb \
       --output caio/guarantees/enforcer.py \
       --classes GuaranteeEnforcer
   ```

2. **Verify extraction:**
   - Check that `caio/guarantees/enforcer.py` exists
   - Check that extracted code matches notebook code
   - Check that imports are correct

3. **Update `caio/guarantees/__init__.py`:**
   ```python
   """CAIO Guarantee Enforcer."""
   
   from caio.guarantees.enforcer import GuaranteeEnforcer
   
   __all__ = ["GuaranteeEnforcer"]
   ```

**Validation:**
- Code extracted successfully
- Extracted code matches notebook code
- Imports work correctly
- No linting errors

---

### TASK 6.7: Extract Traceability (`traceability.ipynb`)

**Purpose:** Extract traceability & proof generation from notebook to Python file.

**Steps:**

1. **Extract code from notebook:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/traceability.ipynb \
       --output caio/traceability/tracer.py \
       --classes TraceabilitySystem Trace Proof
   ```

2. **Verify extraction:**
   - Check that `caio/traceability/tracer.py` exists
   - Check that extracted code matches notebook code
   - Check that imports are correct

3. **Update `caio/traceability/__init__.py`:**
   ```python
   """CAIO Traceability & Proof Generation."""
   
   from caio.traceability.tracer import TraceabilitySystem, Trace, Proof
   
   __all__ = ["TraceabilitySystem", "Trace", "Proof"]
   ```

**Validation:**
- Code extracted successfully
- Extracted code matches notebook code
- Imports work correctly
- No linting errors

---

### TASK 6.8: Extract Control Integration (`control_integration.ipynb`)

**Purpose:** Extract control integration from notebook to Python file.

**Steps:**

1. **Extract code from notebook:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/control_integration.ipynb \
       --output caio/control/integration.py \
       --classes ControlIntegrator
   ```

2. **Verify extraction:**
   - Check that `caio/control/integration.py` exists
   - Check that extracted code matches notebook code
   - Check that imports are correct

3. **Update `caio/control/__init__.py`:**
   ```python
   """CAIO Control Integration with MAIA."""
   
   from caio.control.integration import ControlIntegrator
   
   __all__ = ["ControlIntegrator"]
   ```

**Validation:**
- Code extracted successfully
- Extracted code matches notebook code
- Imports work correctly
- No linting errors

---

### TASK 6.9: Extract Orchestrator Routing (`orchestrator_routing.ipynb`)

**Purpose:** Extract core routing engine from notebook to Python file. This is the main orchestrator function.

**Steps:**

1. **Extract data structures first:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/orchestrator_routing.ipynb \
       --output caio/orchestrator/types.py \
       --classes Request ServiceContract ServiceEntry RoutingDecision
   ```

2. **Extract helper functions:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/orchestrator_routing.ipynb \
       --output caio/orchestrator/helpers.py \
       --functions extract_field_state contract_intersection find_matching_services \
       evaluate_rule satisfies_rule_action filter_by_rules verify_authentication \
       verify_authorization verify_privacy verify_access_control verify_security \
       verify_trait_constraints filter_by_trait_constraints compute_intent_score \
       compute_attention_score compute_rl_score compute_resonance_score \
       compute_cost_penalty compute_risk_penalty compute_latency_penalty score_service \
       generate_control_signal compose_guarantees generate_proof create_trace
   ```

3. **Extract main routing function:**
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/orchestrator_routing.ipynb \
       --output caio/orchestrator/routing.py \
       --functions caio_route
   ```

4. **Update `caio/orchestrator/__init__.py`:**
   ```python
   """CAIO Orchestrator - Core Routing Engine."""
   
   from caio.orchestrator.routing import caio_route
   from caio.orchestrator.types import Request, ServiceContract, ServiceEntry, RoutingDecision
   
   __all__ = [
       "caio_route",
       "Request",
       "ServiceContract",
       "ServiceEntry",
       "RoutingDecision",
   ]
   ```

**Validation:**
- All code extracted successfully
- Extracted code matches notebook code
- Imports work correctly
- No linting errors
- Main `caio_route` function is accessible

---

### TASK 6.10: Integrate All Components

**Purpose:** Integrate all extracted components together to create a complete orchestrator.

**Steps:**

1. **Update `caio/orchestrator/routing.py` to import all components:**
   - Import from `caio.contracts.parser`
   - Import from `caio.registry.registry`
   - Import from `caio.rules.engine`
   - Import from `caio.security.verifier`
   - Import from `caio.guarantees.enforcer`
   - Import from `caio.traceability.tracer`
   - Import from `caio.control.integration`

2. **Update `caio_route` function to use integrated components:**
   - Use `ContractParser` for contract parsing
   - Use `ServiceRegistry` for service registration and discovery
   - Use `RuleEngine` for rule evaluation
   - Use `SecurityVerifier` for security verification
   - Use `GuaranteeEnforcer` for guarantee composition
   - Use `TraceabilitySystem` for trace generation
   - Use `ControlIntegrator` for control signal generation

3. **Create main orchestrator entry point (`caio/__init__.py`):**
   ```python
   """CAIO - Universal AI Orchestration Platform."""
   
   from caio.orchestrator import caio_route, Request, ServiceEntry, RoutingDecision
   from caio.contracts import ContractParser, ContractValidator
   from caio.registry import ServiceRegistry
   from caio.rules import RuleEngine
   from caio.security import SecurityVerifier
   from caio.guarantees import GuaranteeEnforcer
   from caio.traceability import TraceabilitySystem
   from caio.control import ControlIntegrator
   
   __version__ = "0.1.0"
   
   __all__ = [
       "caio_route",
       "Request",
       "ServiceEntry",
       "RoutingDecision",
       "ContractParser",
       "ContractValidator",
       "ServiceRegistry",
       "RuleEngine",
       "SecurityVerifier",
       "GuaranteeEnforcer",
       "TraceabilitySystem",
       "ControlIntegrator",
   ]
   ```

**Validation:**
- All components import correctly
- `caio_route` function uses all integrated components
- Main entry point exports all public APIs
- No circular import errors
- No linting errors

---

### TASK 6.11: Update Integration Tests

**Purpose:** Update integration tests to use extracted code instead of notebooks.

**Steps:**

1. **Update `tests/integration/test_orchestrator_components.py`:**
   - Import from `caio.contracts.parser` instead of notebooks
   - Import from `caio.registry.registry` instead of notebooks
   - Import from `caio.rules.engine` instead of notebooks
   - Import from `caio.security.verifier` instead of notebooks
   - Import from `caio.guarantees.enforcer` instead of notebooks
   - Import from `caio.traceability.tracer` instead of notebooks
   - Update all test methods to use extracted code

2. **Run integration tests:**
   ```bash
   pytest tests/integration/test_orchestrator_components.py -v
   ```

3. **Fix any import or test failures:**
   - Fix import errors
   - Fix test failures
   - Ensure all tests pass

**Validation:**
- All integration tests pass
- Tests use extracted code (not notebooks)
- No import errors
- All test methods work correctly

---

### TASK 6.12: Update E2E Tests

**Purpose:** Update E2E tests to use complete orchestrator with extracted code.

**Steps:**

1. **Update `tests/e2e/test_routing_flow.py`:**
   - Import `caio_route` from `caio.orchestrator`
   - Import all components from `caio` package
   - Update all test methods to use extracted code
   - Test complete routing flow end-to-end

2. **Run E2E tests:**
   ```bash
   pytest tests/e2e/test_routing_flow.py -v
   ```

3. **Fix any import or test failures:**
   - Fix import errors
   - Fix test failures
   - Ensure all tests pass

**Validation:**
- All E2E tests pass
- Tests use extracted code (not notebooks)
- Complete routing flow works end-to-end
- No import errors
- All test methods work correctly

---

### TASK 6.13: Quality Validation

**Purpose:** Ensure all quality gates pass after code extraction and integration.

**Steps:**

1. **Run linting:**
   ```bash
   make lint-all
   ```
   - Fix any linting errors
   - Ensure all checks pass

2. **Run tests:**
   ```bash
   pytest tests/ -v
   ```
   - Fix any test failures
   - Ensure all tests pass

3. **Run MA validation:**
   ```bash
   make ma-validate-quiet
   ```
   - Verify scorecard is GREEN
   - Verify all artifacts are valid
   - Verify all invariants pass

4. **Run local validation:**
   ```bash
   make validate-local
   ```
   - Verify all gates pass
   - Verify no errors

**Validation:**
- All linting checks pass
- All tests pass
- MA validation passes (GREEN scorecard)
- Local validation passes
- All quality gates pass

---

## Validation Procedures

### After Each Extraction Task (6.2-6.9)

1. **Verify extraction:**
   - Check that Python file exists
   - Check that extracted code matches notebook code
   - Check that imports are correct
   - Run linting: `ruff check caio/`
   - Fix any linting errors

2. **Verify imports:**
   - Try importing the extracted code
   - Check for circular import errors
   - Fix any import errors

### After Integration Task (6.10)

1. **Verify integration:**
   - Check that all components import correctly
   - Check that `caio_route` function uses all components
   - Check that main entry point exports all APIs
   - Run linting: `ruff check caio/`
   - Fix any linting errors

2. **Verify functionality:**
   - Try calling `caio_route` with a simple request
   - Check that all components are used
   - Check that routing decision is generated
   - Fix any runtime errors

### After Testing Tasks (6.11-6.12)

1. **Verify tests:**
   - Run integration tests: `pytest tests/integration/test_orchestrator_components.py -v`
   - Run E2E tests: `pytest tests/e2e/test_routing_flow.py -v`
   - Fix any test failures
   - Ensure all tests pass

### After Quality Validation (6.13)

1. **Verify quality gates:**
   - Run linting: `make lint-all`
   - Run tests: `pytest tests/ -v`
   - Run MA validation: `make ma-validate-quiet`
   - Run local validation: `make validate-local`
   - Fix any failures
   - Ensure all gates pass

---

## Troubleshooting Guide

### Issue: Extraction script fails

**Symptoms:**
- `extract_code.py` raises errors
- Code not extracted

**Solutions:**
1. Check notebook format (must be valid JSON)
2. Check that functions/classes exist in notebook
3. Check that notebook path is correct
4. Check that output path is writable

### Issue: Import errors after extraction

**Symptoms:**
- `ImportError` when importing extracted code
- Circular import errors

**Solutions:**
1. Check that all imports are correct
2. Check that `__init__.py` files exist
3. Check for circular dependencies
4. Fix import paths

### Issue: Tests fail after extraction

**Symptoms:**
- Tests fail with `AttributeError` or `TypeError`
- Tests fail with import errors

**Solutions:**
1. Check that extracted code matches notebook code
2. Check that all functions/classes are extracted
3. Check that imports are correct
4. Update test imports to use extracted code

### Issue: Linting errors

**Symptoms:**
- `ruff check` reports errors
- Formatting issues

**Solutions:**
1. Run `ruff format caio/` to auto-format
2. Run `ruff check --fix caio/` to auto-fix
3. Fix any remaining errors manually

---

## Success Criteria

**Phase 6 is complete when:**

- ✅ All 8 notebooks extracted to Python files
- ✅ Complete `caio/` directory structure exists
- ✅ All components integrated together
- ✅ Main `caio_route` function works end-to-end
- ✅ All integration tests pass
- ✅ All E2E tests pass
- ✅ All quality gates pass (linting, tests, MA validation, local validation)
- ✅ Code matches notebook code exactly (notebooks are source of truth)
- ✅ All imports work correctly
- ✅ No circular dependencies
- ✅ Complete orchestrator functional (can route requests end-to-end)

---

## Notes and References

**Key Principles:**
- **Notebooks are source of truth** - Code is extracted FROM notebooks TO Python files
- **Real implementations** - All tests use real implementations (no mocks for core behavior)
- **Mathematical alignment** - Code must implement the math from `CAIO_MASTER_CALCULUS.md`
- **Invariant compliance** - Code must satisfy all invariants (INV-CAIO-0001 through INV-CAIO-SEC-0006)

**References:**
- Execution Plan: `docs/operations/EXECUTION_PLAN.md` (Phase 6)
- North Star: `docs/NORTH_STAR.md` (Section 1.1, 2)
- Master Calculus: `docs/math/CAIO_MASTER_CALCULUS.md`
- Control Calculus: `docs/math/CAIO_CONTROL_CALCULUS.md`
- SDK Specification: `docs/SDK_SPECIFICATION.md`
- Extraction Script: `scripts/notebooks/extract_code.py`
- Integration Tests: `tests/integration/test_orchestrator_components.py`
- E2E Tests: `tests/e2e/test_routing_flow.py`

**Plan Reference:** `plan:EXECUTION_PLAN:6.1-6.8`

---

**Last Updated:** 2026-01-02  
**Version:** 1.0


# CAIO Developer Guide

**Status**: Active  
**Last Updated**: 2026-01-08  
**Owner**: @smarthaus

---

## Overview

This guide provides information for developers working on CAIO, including development setup, project structure, core components, testing guidelines, and contribution process.

---

## Development Setup

### Prerequisites

- Python 3.14+ (or 3.11+)
- Jupyter Notebook (for running verification notebooks)
- Git
- Make (for running Makefile targets)

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/SmartHausGroup/CAIO.git
cd CAIO

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install development dependencies
pip install pytest pytest-asyncio httpx jupyter

# Run pre-commit hooks setup (if available)
pre-commit install
```

### Verify Setup

```bash
# Run MA validation
make ma-validate-quiet

# Run notebooks
make notebooks-plan

# Check status
make ma-status
```

---

## Project Structure

```
CAIO/
├── docs/                    # Documentation
│   ├── NORTH_STAR.md        # Strategic vision
│   ├── math/                # Mathematical foundations
│   ├── operations/          # Execution plans and status
│   ├── api/                 # API documentation
│   ├── developer/           # Developer documentation
│   └── user/                # User documentation
├── notebooks/               # Jupyter notebooks
│   └── math/                # Verification and implementation notebooks
├── invariants/              # YAML invariant definitions
├── configs/                 # Configuration files
│   ├── generated/           # Generated artifacts (JSON)
│   └── schemas/             # Schema definitions
├── services/                # External service bridges
│   └── external/            # External service examples (Codex, etc.)
├── tests/                   # Test suites
│   ├── integration/         # Integration tests
│   ├── e2e/                 # End-to-end tests
│   └── mathematical/        # Mathematical validation tests
├── scripts/                 # Utility scripts
│   ├── ci/                  # CI/CD scripts
│   ├── local/               # Local validation scripts
│   └── notebooks/           # Notebook utilities
└── tools/                   # Development tools
```

---

## External Service Integration

CAIO integrates external services through bridge services and YAML contracts. The first example is the Codex bridge service.

**Key locations:**
- Bridge service: `services/external/codex/`
- Service contract: `configs/services/external/codex.yaml`
- Registration script: `scripts/register_codex_service.py`
- Guide: `docs/external_services.md`

**Quick flow:**
1. Start CAIO API service.
2. Start the Codex bridge service.
3. Register the contract with CAIO.
4. Run integration tests under `services/external/codex/tests/`.

See `docs/external_services.md` for full details and patterns for additional services.

## Core Components

### 1. Orchestrator Routing

**Notebook:** `notebooks/math/orchestrator_routing.ipynb`

Implements the core CAIO routing engine (`caio_route`) that realizes the master control equation.

**Key Functions:**
- Field State Extraction
- Contract Matching (mathematical set intersection)
- Rule Constraint Satisfaction
- Security Verification
- Trait Constraint Verification
- Optimization (master equation scoring)
- Control Signal Generation
- Guarantee Composition
- Proof Generation
- Traceability

**Extraction Target:** `caio/orchestrator/routing.py` (Phase 6)

---

### 2. Contract Parser

**Notebook:** `notebooks/math/contract_parser.ipynb`

Parses and validates service contracts (YAML format).

**Key Functions:**
- YAML contract parsing
- Schema validation
- Contract normalization
- Capability extraction

**Extraction Target:** `caio/contracts/parser.py` (Phase 6)

---

### 3. Service Registry

**Notebook:** `notebooks/math/service_registry.ipynb`

In-memory service registry for registered services.

**Key Functions:**
- Service registration
- Service lookup
- Service discovery (capability-based)
- Service health tracking

**Extraction Target:** `caio/registry/service_registry.py` (Phase 6)

---

### 4. Rule Engine

**Notebook:** `notebooks/math/rule_engine.ipynb`

Policy and constraint evaluation engine.

**Key Functions:**
- Rule parsing
- Constraint satisfaction checking
- Policy evaluation
- Rule conflict detection

**Extraction Target:** `caio/rules/rule_engine.py` (Phase 6)

---

### 5. Security Verifier

**Notebook:** `notebooks/math/security_verifier.ipynb`

Runtime security verification (authentication, authorization, privacy, access control).

**Key Functions:**
- Authentication verification
- Authorization checks
- Privacy preservation verification
- Access control enforcement

**Extraction Target:** `caio/security/verifier.py` (Phase 6)

---

### 6. Guarantee Enforcer

**Notebook:** `notebooks/math/guarantee_enforcer.ipynb`

Guarantee composition and enforcement.

**Key Functions:**
- Guarantee composition
- Guarantee validation
- Guarantee preservation checking

**Extraction Target:** `caio/guarantees/enforcer.py` (Phase 6)

---

### 7. Traceability

**Notebook:** `notebooks/math/traceability.ipynb`

Proof and trace object generation, storage, and retrieval.

**Key Functions:**
- Trace generation
- Proof creation
- Audit trail recording
- Trace retrieval

**Extraction Target:** `caio/traceability/traceability.py` (Phase 6)

---

## Development Workflow

### MA Doc-First Methodology

CAIO follows the Mathematical Autopsy (MA) Doc-First methodology:

1. **Math** - Define mathematical foundations (`docs/math/`)
2. **Invariants** - Create YAML invariants (`invariants/`)
3. **Notebooks** - Write verification/implementation notebooks (`notebooks/math/`)
4. **Artifacts** - Generate JSON artifacts (`configs/generated/`)
5. **Code** - Extract code from notebooks (Phase 6)

**CRITICAL:** Code lives in notebooks first. Python files are extracted from notebooks, not the other way around.

---

### Notebook-First Development

**Rule:** Code changes go in notebooks first, then extract to Python files.

**Workflow:**
1. Find or create the notebook for the code
2. Write/update code directly in the notebook (DO NOT import from codebase)
3. Test and validate in the notebook
4. Extract code from notebook to Python file using `scripts/notebooks/extract_code.py`
5. Verify extraction worked

**Forbidden:**
- ❌ Editing Python files directly
- ❌ Importing from codebase into notebooks
- ❌ Writing code without completing MA process first

---

### Testing Guidelines

**Test Categories:**
- **Unit Tests:** Individual component tests
- **Integration Tests:** Component integration tests
- **E2E Tests:** End-to-end routing flow tests
- **Mathematical Tests:** Notebook verification and artifact validation

**Test Requirements:**
- All tests must use real implementations (no mocks for core behavior)
- Tests must fail fast (no silent skips)
- Tests must be deterministic (seeded randomness)

**Running Tests:**
```bash
# Run all tests
pytest tests/ -v

# Run specific category
pytest tests/integration/ -v
pytest tests/e2e/ -v
pytest tests/mathematical/ -v
```

---

## Code Style and Conventions

### Python Style

- Follow PEP 8
- Use type hints
- Use dataclasses for data structures
- Use `pathlib.Path` for file paths
- Use `typing` module for type annotations

### Naming Conventions

- **Functions:** `snake_case`
- **Classes:** `PascalCase`
- **Constants:** `UPPER_SNAKE_CASE`
- **Files:** `snake_case.py`

### Documentation

- Use docstrings for all functions and classes
- Include type hints in docstrings
- Document mathematical foundations in `docs/math/`
- Update invariants when adding new guarantees

---

## Contributing Guidelines

### Before Contributing

1. Read `docs/NORTH_STAR.md` - Understand the vision
2. Read `docs/operations/execution_plan.md` - Check planned work
3. Read `docs/MA_PROCESS_STATUS.md` - Understand MA process
4. Read `.cursor/rules/agent-workflow-mandatory.mdc` - Follow workflow

### Contribution Process

1. **Check Execution Plan** - Verify work is in plan
2. **Follow MA Process** - Complete Phases 1-5 before code
3. **Write in Notebooks** - Code lives in notebooks first
4. **Test Thoroughly** - Run all tests and validation
5. **Update Documentation** - Keep docs in sync with code
6. **Run Pre-Commit** - `pre-commit run --all-files` before committing

### Pull Request Requirements

- All tests must pass
- Scorecard must be green (or yellow for development branch)
- All artifacts must be fresh (no NaN/Inf)
- Documentation must be updated
- MA process must be complete (if applicable)

---

## Makefile Targets

```bash
make help              # Show all available targets
make notebooks-plan    # Execute all verification notebooks
make ma-validate-quiet # Run MA validation (notebooks + gates)
make ma-status        # Show MA process status

# Local CI (reduces GitHub Actions costs)
make validate-local    # Run local validation
make promote-local     # Promote branches locally
make ci-local          # Complete CI replication
```

---

## Troubleshooting

### Notebook Execution Fails

1. Check seed is set: `CAIO_NOTEBOOK_SEED=42`
2. Check Python version: `python3 --version` (3.14+ or 3.11+)
3. Check dependencies: `pip install -r requirements.txt`
4. Check notebook paths: Ensure `REPO_ROOT` is correct

### Artifacts Have NaN/Inf

1. Check notebook execution: `make notebooks-plan`
2. Check invariants: `make ma-validate-quiet`
3. Check scorecard: `cat scorecard.json`

### Tests Fail

1. Check pytest is installed: `pip install pytest`
2. Check test dependencies: `pip install pytest-asyncio httpx`
3. Run tests individually: `pytest tests/integration/test_orchestrator_components.py -v`

---

## References

- **North Star:** `docs/NORTH_STAR.md`
- **Master Calculus:** `docs/math/CAIO_MASTER_CALCULUS.md`
- **SDK Specification:** `docs/SDK_SPECIFICATION.md`
- **MA Process:** `docs/MA_PROCESS_STATUS.md`
- **Execution Plan:** `docs/operations/execution_plan.md`

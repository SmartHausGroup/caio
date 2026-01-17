# Codex Profile for CAIO

- **Repository:** SmartHausGroup/CAIO
- **Primary Languages:** Python 3.12 (baseline), Python 3.13 (preview)
- **Primary Runtime(s):** Python 3.12+ via `.venv/`
- **Owner / Point of Contact:** SmartHaus Group (info@smarthaus.group)
- **Status:** active

**Maintenance Note:** This document reflects the repository structure and practices as of 2025-01-XX. Paths, commands, and organizational patterns are authoritative; specific counts (notebooks, tests) may change over time. When in doubt, verify current state by inspecting the repository.

---

## Purpose

CAIO (Coordinatio Auctus Imperium Ordo) is a universal AI orchestration platform that provides mathematical guarantees for all routing decisions, contract-based service discovery, security built into the math, provable and traceable actions, and hot-swappable service registration.

**Key responsibilities:**
- Mathematical guarantees for all routing decisions
- Contract-based service discovery
- Security built into the math
- Provable and traceable actions
- Hot-swappable service registration
- Control calculus for routing and orchestration

**What this repo is NOT responsible for:**
- Individual service implementations (lives in respective service repositories)
- Frontend/UI (lives in TAI repository)
- Storage implementation (lives in ResonantFieldStorage repository)

**Normative design:** `docs/NORTH_STAR.md` is the source of truth that guides all code.

---

## Source of Truth Hierarchy

Codex MUST treat this order as the authority for behavior:

1. **Specs / Design Docs**
   - Location(s): `docs/NORTH_STAR.md` (normative), `docs/math/` (master calculus)
   - **MANDATORY:** All code must align with North Star

2. **Math / Invariants (CRITICAL - MA Process)**
   - Location(s): `docs/math/` (calculus, lemmas), `invariants/` (YAML contracts)
   - **MANDATORY:** The Mathematical Autopsy (MA) process applies to all **new or modified** mathematical operations, algorithms, or performance guarantees
   - **Scope:** See the "Mathematical Autopsy (MA) Process Integration" section below for what is mandatory vs. recommended
   - **Process:** For math/algorithm/perf changes, Phases 1-5 must complete before promoting code to staging/main
   - **Notebook-First:** Code is written in notebooks first, then extracted to codebase

3. **Notebooks**
   - Location(s): `notebooks/math/` (verification notebooks)
   - **MANDATORY:** Implementation notebooks MUST NOT import from codebase (`from src.`, etc.)
   - Verification notebooks (named `*_implementation_verification.ipynb`) CAN import from codebase to verify extracted code

4. **Tests**
   - Location(s): `tests/` (unit and integration tests)
   - Test naming: `test_*.py` in `tests/` subdirectories

5. **Production Code**
   - Location(s): `src/` (if present) or root-level modules
   - **MANDATORY:** Code must implement math from Phase 2, validate against Phase 4 notebook, match Phase 3 invariant telemetry

6. **CI / Tooling**
   - Location(s): `.github/workflows/`, `Makefile` (and fragment Makefiles), `scripts/`, `configs/`
   - **MANDATORY:** Pre-commit hooks must pass before committing

**MA Process Enforcement:**
- When changing code, first check relevant spec/math/invariant docs
- When adding features, ensure MA Phases 1-5 are complete (if math/algorithm/perf related)
- Do NOT contradict existing specs/invariants without explicit instruction
- **For mathematical operations, algorithms, or performance guarantees:** Code implementation comes AFTER all 5 phases complete

---

## Directory Map

- `src/`: Production code (if present)
- `tests/`: Unit and integration tests
- `docs/`: North Star, math appendices, operations guides
- `docs/math/`: Mathematical foundations (master calculus, control calculus, lemmas)
- `notebooks/math/`: Verification notebooks (source of truth for implementation)
- `scripts/ci/`: CI gate scripts (notebooks, scorecard, artifacts, ADR, determinism)
- `scripts/local/`: Local validation scripts (validate, promote, ci-replicate)
- `configs/generated/`: Generated artifacts (JSON from notebooks) - **DO NOT hand-edit**
- `configs/schemas/`: JSON schemas for artifacts (service contracts)
- `invariants/`: YAML invariant contracts (INV-CAIO-XXXX.yaml)
- `logs/quality/`: Quality logs, notebooks logs, scorecard logs
- `tools/`: Utility scripts (aggregate_scorecard.py)

### File / Module Patterns

- Main entrypoints:
  - Check `docs/` for service entrypoints

- Core modules:
  - Check `src/` or root-level for core modules (if present)

- Test naming patterns: `test_*.py` in `tests/` subdirectories
- Config patterns: `*.yaml` in `invariants/`, `*.json` in `configs/generated/` (generated, not hand-edited)
- Notebook patterns: `notebooks/math/*.ipynb` (verification)

---

## Tooling and Runtime

### Languages and Versions
- Python version(s): 3.12 (baseline), 3.13 (preview) - from `pyproject.toml` (`requires-python = ">=3.10,<3.14"`)
- Other runtimes: None

### Package Managers
- Python: pip (via `requirements.txt`)
- Other: None

### Standard Commands

**Run tests:**
- `pytest tests/` - Run all tests

**Run lints / formatters:**
- `ruff check .` - Check with ruff
- `mypy src` - Type check (if configured)

**Run type checks:**
- `mypy src` - Type check (if configured)

**Run the main app:**
- Check `docs/` for service entrypoints

**MA Process Commands (MANDATORY for math/algorithm/perf changes):**
- `make ma-validate-quiet` - Run MA validation
- `make ma-status` - Show MA process status
- `make notebooks-plan` - Execute CI-ready notebooks
- `python3 scripts/ci/notebooks_ci_run.py --plan configs/generated/notebook_plan.json` - Run notebook plan

**Local CI (reduces GitHub Actions costs):**
- `make validate-local` - Run local validation
- `make promote-local SOURCE=development TARGET=staging` - Promote branches locally
- `make ci-local` - Complete CI replication

**Pre-commit workflow (MANDATORY):**
- `pre-commit run --all-files` - Run all pre-commit hooks before committing
- `make commit-and-push MSG="feat: description"` - Commit with validation (MA-compliant)

Codex should suggest and align to these commands when:
- Telling the user how to verify changes
- Planning how to validate patches
- Ensuring MA process compliance (when applicable)

---

## Environment Variables and Secrets

List relevant env vars that affect behavior (NO secret values):

- `CAIO_SERVICE_URL`: CAIO service URL (if applicable)
- `PYTHONPATH`: Set to `.` or appropriate path for imports

**Secrets (NEVER hardcode or log):**
- API keys for external services
- Service authentication tokens

Rules for Codex:
- Never invent fake secret values
- Never hardcode secrets into code or configs
- If an env var is required, mention it and assume it's set by the user, not created by Codex

---

## Coding Standards and Patterns

### Style
- Language style: PEP8, Black (line-length 100), Ruff, isort
- Naming conventions:
  - Modules: `snake_case.py`
  - Classes: `PascalCase`
  - Functions: `snake_case`
  - Tests: `test_*.py`, `Test*` classes, `test_*` functions

### Architectural Patterns
- **Notebook-First Development:** Code written in notebooks first, then extracted to codebase
- **Mathematical Autopsy (MA):** Phases 1-5 must complete before code implementation (for math/algorithm/perf changes)
- **Control Calculus:** Mathematical guarantees for routing and orchestration
- **Contract-Based Service Discovery:** Service contracts in `configs/schemas/`

### Testing Standards
- Unit tests expected for: All core modules
- Integration tests for: Service contracts, routing decisions
- **MA Process Testing:** Tests must validate against Phase 4 notebook artifacts (when applicable)

Codex should:
- Follow existing style and patterns
- Prefer extending patterns already present over inventing new ones
- **Follow MA process for mathematical operations, algorithms, or performance guarantees**
- **Write implementation code in notebooks first** (notebook-first development, when applicable)

---

## Codex Permissions

### Allowed
- Read any file in the repository
- Propose changes as patch-style edits
- Add or modify:
  - Implementation code under `src/` (after MA Phases 1-5 complete, if math/algorithm/perf related)
  - Tests under `tests/` (after MA Phases 1-5 complete, if applicable)
  - Documentation under `docs/`
  - Notebooks under `notebooks/` (implementation notebooks - source of truth)
- Suggest new files when clearly needed (e.g. new test modules, new notebooks)
- **MA Process Work:** Complete MA Phases 1-5 for mathematical operations, algorithms, or performance guarantees
- **Perform trivial, non-math bugfixes and wiring changes** using Workflow 0 (see Playbook), without running the full MA process, as long as tests and lint/quality-gate commands are run

### NOT Allowed (without explicit user instruction)
- Deleting files or entire directories
- Large-scale refactors that touch many files at once
- Changing CI workflows (`.github/workflows/`, etc.) unless asked
- Updating dependency versions (`pyproject.toml`, `requirements.txt`, etc.) unless asked
- **Modifying math/spec/invariant documents unless explicitly requested** (these are source of truth)
  - **Exception:** Trivial fixes (typos, formatting) are allowed
- **Hand-editing `configs/generated/` artifacts** (must regenerate via notebooks/scripts)
- **Skipping MA process phases for mathematical operations, algorithms, or performance guarantees**
  - **Exception:** Trivial bugfixes don't require MA process (see Workflow 0 in Playbook)
- Introducing new external services or dependencies on its own

Codex must always:
- Explain why each non-trivial change is needed
- Reference specific files and sections it is basing decisions on
- **Follow MA process for mathematical operations, algorithms, or performance guarantees**
- **Write implementation code in notebooks first** (notebook-first development, when applicable)

---

## Verification Checklist After Changes

After any non-trivial change, Codex should instruct the user to:

1. **Run pre-commit hooks (MANDATORY):**
   - `pre-commit run --all-files`

2. **Run tests:**
   - `pytest tests/` (all tests)

3. **Run linters / formatters:**
   - `ruff check .`
   - `mypy src` (if configured)

4. **Run MA validation (if math/code changed):**
   - `make ma-validate-quiet` (MA validation)
   - `make ma-status` (MA status)

5. **Run notebooks (if math/notebooks changed):**
   - `make notebooks-plan` (execute CI-ready notebooks)
   - `python3 scripts/ci/notebooks_ci_run.py --plan configs/generated/notebook_plan.json` (run notebook plan)

6. **Run critical integration checks:**
   - `make validate-local` (local validation before push - reduces CI costs)

**Mandatory CI gates (must pass before merging):**
- `MA Validate (development) / validate` - Development branch
- `MA Validate (staging) / validate` - Staging branch (must be green)
- `MA Validate (main) / validate` - Main branch (must be green)

**MA Process Verification:**
- Verify MA Phases 1-5 are complete before code implementation (if math/algorithm/perf related)
- Verify notebooks execute successfully and emit artifacts
- Verify artifacts are schema-valid and fresh
- Verify scorecard decision is "green" for staging/main

---

## Known Gaps / TODOs for Codex

Based on docs/tests/code:

- **Code implementation:** Phase 6 (Code Implementation) is pending - MA Phases 1-5 are complete
- **Some invariants in draft status:** Check `invariants/INDEX.yaml` for current status

Codex should:
- Prefer working in modern/active parts of the codebase
- Avoid extending deprecated areas unless explicitly requested
- **Complete MA process for any new mathematical operations, algorithms, or performance guarantees**
- **Follow notebook-first development** (write code in notebooks first, then extract, when applicable)

---

## Mathematical Autopsy (MA) Process Integration

**MANDATORY:** Codex must follow the MA process for mathematical operations, algorithms, or performance guarantees.

### Scope of MA Enforcement

- **Mandatory for:**
  - New mathematical operators or algorithms
  - Changes affecting control calculus, routing decisions, or service contracts
  - Modifications to invariants, lemmas, or security guarantees
  - Performance guarantee changes
  - Changes to telemetry that affect invariant validation

- **Recommended but not strictly required for:**
  - Trivial bug fixes (off-by-one, typo, logging, import fixes)
  - Pure wiring, dependency injection, or configuration changes
  - Test-only refactors that do not alter behavior
  - Documentation-only changes
  - Renaming variables/functions without changing behavior

**MANDATORY:** For mathematical operations, algorithms, or performance guarantees, Codex MUST complete MA Phases 1-5 before code implementation.

**Exception:** Trivial changes that don't affect mathematical behavior, algorithms, or performance guarantees may proceed without full MA process, but must still pass tests and linting.

**Single rule of thumb:** Notebook-first is mandatory for new or changed **math/algorithm/perf behavior**, not for every line of code in the repo.

### MA Process Phases (MUST Complete in Order)

1. **Phase 1: Intent & Description**
   - Problem statement written (what, why, context, success criteria)
   - Conceptual significance documented (plain-English, stakeholders)
   - **Location:** New section in appropriate spec document (e.g., `docs/math/CAIO_MASTER_CALCULUS.md`, `docs/math/CAIO_CONTROL_CALCULUS.md`)

2. **Phase 2: Mathematical Foundation**
   - Master equation defined (`docs/math/CAIO_MASTER_CALCULUS.md`)
   - Contract calculus formalized
   - Rule application calculus formalized
   - Security calculus formalized
   - Guarantee composition calculus formalized
   - Proof generation calculus formalized

3. **Phase 3: Lemma Development**
   - YAML Invariant created (`invariants/INV-CAIO-XXXX.yaml`) - use `invariants/INV_TEMPLATE.yaml`
   - Markdown Lemma written (`docs/math/CAIO_LEMMAS_APPENDIX.md`)
   - Added to `invariants/INDEX.yaml`
   - Added to lemmas quick index
   - Cross-references between YAML and markdown

4. **Phase 4: Verification (Notebook-First Development)**
   - Verification notebook created (`notebooks/math/verify_*.ipynb`)
   - **Write implementation code directly in notebook** (notebook-first development)
   - **MUST NOT import from codebase** (`from src.`, etc.) in implementation notebooks
   - VERIFY:L<N> cell with assertions
   - Artifact JSON exported (`configs/generated/*_verification.json`)
   - Notebook runs successfully locally
   - Notebook added to `configs/generated/notebook_plan.json`
   - **Exception:** For trivial bugfixes to existing code, you may edit codebase directly without notebook-first workflow

5. **Phase 5: CI Enforcement**
   - Artifact registered in `docs/math/README.md`
   - Notebook added to plan (`configs/generated/notebook_plan.json`)
   - Local CI validation passes (`make validate-local`)
   - CI workflow configured (GitHub Actions)
   - Scorecard gates configured
   - Invariant status: `draft` → `accepted` in `invariants/INV-CAIO-XXXX.yaml`
   - Lemma status: `Draft` → `Rev X.Y` in `docs/math/CAIO_LEMMAS_APPENDIX.md`

### After Phases 1-5 Complete: Code Implementation

- **Extract code from notebook** (notebook-first development)
- Code implements the math from Phase 2
- Tests validate against Phase 4 notebook
- Telemetry matches Phase 3 invariant
- Code review verifies alignment with invariant/lemma

### Enforcement

**MANDATORY for Production Code:** Phases 1-5 MUST be complete before any production code implementation (for math/algorithm/perf changes).

**Minimum for Experimental Code:** Phases 1-3 must be complete (intent → foundation → invariant + lemma). Phases 4-5 required before promotion to staging/main.

**NEVER skip phases for mathematical operations, algorithms, or performance guarantees.** If you find yourself writing code before completing the required phases, STOP and complete the MA process first.

**Exceptions:**
- Trivial bug fixes or refactoring that doesn't change mathematical behavior
- Documentation-only changes
- Configuration changes that don't affect math
- Pure wiring, dependency injection, or test-only refactors

### References

- **Full MA Process:** `docs/operations/MA_PROCESS_MANDATORY_RULE.md`
- **Math Development Process:** `docs/math/` (if available)
- **Local CI:** `docs/LOCAL_CI.md`
- **Promotion Workflow:** `docs/PROMOTION_WORKFLOW.md`
- **Branch Structure:** `docs/BRANCH_STRUCTURE.md`
- **Invariant Template:** `invariants/INV_TEMPLATE.yaml`

---

**This rule is MANDATORY and applies to ALL AI assistants working on CAIO.**


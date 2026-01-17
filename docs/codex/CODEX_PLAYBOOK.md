# Codex Playbook for CAIO

This document describes common workflows Codex should follow when working in this repository: how to add features, fix bugs, extend tests, and update documentation in a predictable way, with mandatory Mathematical Autopsy (MA) process integration.

**Maintenance Note:** This document reflects the repository structure and practices as of 2025-01-XX. Paths, commands, and organizational patterns are authoritative; specific counts (notebooks, tests) may change over time. When in doubt, verify current state by inspecting the repository.

---

## Workflow 0: Trivial Bugfix / Non-Math Refactor

**Use this for:** Simple fixes that don't affect math, algorithms, or performance guarantees.

**When to use:**
- Typo fixes, import corrections, log message updates
- Pure wiring, dependency injection, configuration changes
- Test-only refactors that don't alter behavior
- Documentation-only changes
- Renaming variables/functions without changing behavior

**When NOT to use:**
- Any change affecting mathematical behavior
- Changes to algorithms or performance guarantees
- Modifications to invariants, lemmas, or telemetry
- → Use Workflow 1 (with MA process) instead

### Steps

1. **Verify scope:**
   - Confirm this is truly trivial (no math/algorithm/perf impact)
   - If uncertain → Use Workflow 1 with MA process

2. **Make minimal change:**
   - Fix the specific issue
   - Maintain existing patterns and style

3. **Verification (MA process NOT required):**
   - Run pre-commit: `pre-commit run --all-files`
   - Run tests: `pytest tests/` (or `pytest path/to/test_file.py`)
   - Run lint: `ruff check .`
   - **Skip:** MA validation, notebook execution, artifact regeneration

4. **Commit:**
   - `make commit-and-push MSG="fix: description"` (MA-compliant workflow)
   - Or standard git workflow if validation passes

### Example Scenarios

✅ **Use this workflow:**
- Fix typo in error message
- Add missing import statement
- Update log level from DEBUG to INFO
- Rename variable for clarity (no behavior change)
- Fix test assertion that was wrong

❌ **Use Workflow 1 (with MA) instead:**
- Change control calculus
- Modify routing decision algorithm
- Update security guarantees
- Change telemetry computation
- Add new mathematical operator

---

## Workflow 1: Add or Change a Feature

**CRITICAL:** For mathematical operations, algorithms, or performance guarantees, Codex MUST complete MA Phases 1-5 before code implementation.

1. **Check if MA process is required:**
   - If feature involves math, algorithms, or performance guarantees → **MANDATORY MA process**
   - If feature is trivial bug fix or refactoring → Use Workflow 0 instead
   - If uncertain → Assume MA process is required

2. **If MA process required, complete Phases 1-5:**

   **For complete MA phase definitions, artifact locations, and enforcement rules, see `docs/codex/CODEX_PROFILE.md` (section "Mathematical Autopsy (MA) Process Integration").**

   **Quick Reference:**
   - **Phase 1:** Intent & Description → Problem statement in `docs/math/` or appropriate spec doc
   - **Phase 2:** Mathematical Foundation → Master equation and calculi in `docs/math/CAIO_MASTER_CALCULUS.md`
   - **Phase 3:** Lemma Development → Invariant YAML (`invariants/INV-CAIO-XXXX.yaml`) + Lemma markdown (`docs/math/CAIO_LEMMAS_APPENDIX.md`)
   - **Phase 4:** Verification → Notebook with implementation code (notebook-first) in `notebooks/math/`
   - **Phase 5:** CI Enforcement → Artifact registration, ADR if needed, status updates

   For detailed steps, artifact locations, and file paths for each phase, follow the definitions in `docs/codex/CODEX_PROFILE.md` under "Mathematical Autopsy (MA) Process Integration." This playbook only describes how MA fits into feature workflow; the Profile is the canonical source for MA phase details.

3. **After MA Phases 1-5 complete: Code Implementation**
   - **Extract code from notebook** (notebook-first development)
   - Implement in appropriate location (check repo structure)
   - Ensure code implements math from Phase 2
   - Ensure telemetry matches Phase 3 invariant

4. **Identify the relevant spec/design:**
   - Search in `docs/` for feature name, module name, or related concepts
   - Check `docs/NORTH_STAR.md` (normative design)
   - Check `docs/math/CAIO_MASTER_CALCULUS.md` for master equation
   - If specs exist, summarize them before proposing changes

5. **Locate existing implementation:**
   - Check root-level for modules
   - Check `src/` if present
   - Avoid reinventing structures already in use

6. **Plan the change:**
   - List affected files and functions
   - State what tests should already exist or need to be created
   - Reference MA process artifacts (invariants, lemmas, notebooks)

7. **Modify code:**
   - Apply minimal, focused changes
   - Maintain style and patterns of the surrounding code

8. **Add or update tests:**
   - Place tests in `tests/` directory
   - Cover both success and failure paths when reasonable
   - **Tests must validate against Phase 4 notebook** (if MA process was followed)

9. **Update docs (if needed):**
   - If the change affects public behavior, update relevant docs in `docs/`
   - Update master equation or calculi if math changed

10. **Verification:**
    - Run pre-commit hooks: `pre-commit run --all-files`
    - Run tests: `pytest tests/`
    - Run MA validation: `make ma-validate-quiet` (if math changed)
    - Run notebooks: `make notebooks-plan` (if notebooks changed)
    - Run local validation: `make validate-local` (reduces CI costs)

---

## Workflow 2: Fix a Failing Test

1. Read the failing test file and error message
   - Test files in `tests/`

2. Identify whether:
   - The test is wrong (outdated expectation), or
   - The implementation is wrong

3. Check relevant docs/specs to see intended behavior:
   - Check `docs/NORTH_STAR.md` (normative design)
   - Check `docs/math/` for mathematical definitions (master calculus, control calculus)
   - Check `invariants/` for invariant contracts
   - Check `notebooks/math/` for verification notebooks

4. **If math-related, check MA process artifacts:**
   - Verify invariant (`invariants/INV-CAIO-XXXX.yaml`) matches expected behavior
   - Verify lemma (`docs/math/CAIO_LEMMAS_APPENDIX.md`) matches expected behavior
   - Verify notebook (`notebooks/math/verify_*.ipynb`) validates expected behavior

5. Prefer fixing implementation when docs/specs/tests agree on behavior

6. If test expectations conflict with specs:
   - Explain the conflict
   - Propose which to align (specs/invariants are source of truth)
   - May require MA process update (invariant/lemma change requires ADR)

7. Make minimal changes needed to satisfy:
   - Specs (first)
   - Then tests
   - Then invariants/lemmas (if math-related)

8. Instruct the user to re-run:
   - `pytest path/to/test_file.py` (exact failing test)
   - `pytest tests/` (all tests)
   - `make ma-validate-quiet` (if math-related)

---

## Workflow 3: Add Tests for Existing Code

1. Identify the target module and its responsibilities
   - Check root-level for modules
   - Check `src/` if present

2. Check if a test file already exists:
   - If yes, extend it
   - If no, create a new test file following naming conventions (`test_*.py`)

3. **If code has MA process artifacts, reference them:**
   - Check `invariants/` for related invariants
   - Check `docs/math/CAIO_LEMMAS_APPENDIX.md` for related lemmas
   - Check `notebooks/math/` for verification notebooks
   - **Tests should validate against notebook artifacts** (if applicable)

4. Cover:
   - Normal, expected behavior
   - Edge cases identified in docs or code comments
   - Error conditions, where appropriate
   - **Mathematical bounds from invariants** (if applicable)

5. Keep tests:
   - Deterministic (no external network or non-deterministic behavior unless mocked)
   - Focused (one main assertion per test where possible)
   - **Validated against notebook artifacts** (if MA process was followed)

6. Instruct the user to run:
   - `pytest path/to/test_file.py` (new test file)
   - `pytest tests/` (all tests)
   - `make ma-validate-quiet` (if math-related)

---

## Workflow 4: Refactor Existing Code

1. Confirm the goal: performance, readability, API cleanup, etc.

2. **Check if refactor affects math:**
   - If yes → May require MA process update (invariant/lemma change requires ADR)
   - If no → Proceed with refactor (may use Workflow 0 if trivial)

3. Identify:
   - All call sites for the code to be refactored
   - Relevant tests
   - **Relevant MA process artifacts** (invariants, lemmas, notebooks)

4. Propose a minimal refactor plan:
   - What will change
   - What will stay the same (public behavior, APIs)
   - **Impact on MA process artifacts** (if applicable)

5. Apply changes in small steps:
   - Prefer multiple small patches over one huge rewrite
   - Preserve function signatures unless explicitly allowed to change
   - **Preserve mathematical behavior** (if math-related)

6. Ensure tests still express the same intentional behavior:
   - Run tests: `pytest tests/`
   - **Run notebooks: `make notebooks-plan`** (if math-related)
   - **Run MA validation: `make ma-validate-quiet`** (if math-related)

7. Instruct the user to:
   - Run full tests for the affected area: `pytest tests/path/to/tests.py`
   - Run all tests: `pytest tests/`
   - Run MA validation: `make ma-validate-quiet` (if math-related)

---

## Workflow 5: Working with Docs and Notebooks

**CRITICAL:** Notebooks are the source of truth for implementation code. Code is written in notebooks first, then extracted to codebase.

1. **When behavior is unclear:**
   - Look for relevant content in `docs/` and `notebooks/`
   - Summarize the intent before proposing changes
   - Check `docs/NORTH_STAR.md` (normative design)
   - Check `docs/math/CAIO_MASTER_CALCULUS.md` for master equation

2. **Implementation Notebooks (MANDATORY for new math/algorithm code):**
   - Notebook-first applicability and exceptions are defined in `CODEX_PROFILE.md`. Use that as law.
   - Place in `notebooks/math/` for math-related code
   - Named: `verify_*.ipynb` for verification notebooks
   - **MUST NOT import from codebase** (`from src.`, etc.)
   - Write implementation code directly in notebook
   - Include VERIFY:L<N> cell with assertions
   - Export artifact JSON to `configs/generated/*_verification.json`
   - Test locally: `python3 scripts/ci/notebooks_ci_run.py --notebook notebooks/math/verify_<name>.ipynb`

3. **Verification Notebooks (Optional - for verifying extracted code):**
   - Named: `*_implementation_verification.ipynb`
   - **CAN import from codebase** to verify extracted code
   - Verify that extracted code matches math definition

4. **Do NOT:**
   - Rewrite math/spec notebooks without explicit instruction
   - Remove cells that encode invariants or verification unless instructed
   - Hand-edit `configs/generated/` artifacts (must regenerate via notebooks)

5. **If creating new notebooks:**
   - Place them in `notebooks/math/`
   - Explain their purpose at the top (markdown cell)
   - Include metadata: `metadata.ci.ready = true`
   - Include VERIFY:L<N> cell with assertions
   - Export artifact JSON to `configs/generated/<name>.json`

6. **Notebook execution:**
   - Single notebook: `python3 scripts/ci/notebooks_ci_run.py --notebook notebooks/math/verify_<name>.ipynb`
   - All CI-ready notebooks: `make notebooks-plan`

---

## Workflow 6: Mathematical Autopsy (MA) Process

**MANDATORY:** Codex must follow the MA process for mathematical operations, algorithms, or performance guarantees.

**For complete MA phase definitions, artifact locations, and enforcement rules, see `docs/codex/CODEX_PROFILE.md` (section "Mathematical Autopsy (MA) Process Integration").**

### Quick Reference

- **Phase 1:** Intent & Description → Problem statement in `docs/math/` or appropriate spec doc
- **Phase 2:** Mathematical Foundation → Master equation and calculi in `docs/math/CAIO_MASTER_CALCULUS.md`
- **Phase 3:** Lemma Development → Invariant YAML (`invariants/INV-CAIO-XXXX.yaml`) + Lemma markdown (`docs/math/CAIO_LEMMAS_APPENDIX.md`)
- **Phase 4:** Verification → Notebook with implementation code (notebook-first) in `notebooks/math/`
- **Phase 5:** CI Enforcement → Artifact registration, ADR if needed, status updates

### Starting a New Mathematical Development

1. **Create feature branch** from `development` (see `docs/BRANCH_STRUCTURE.md`)

2. **Verify MA is required:** Check if change affects math/algorithms/perf guarantees

3. **Complete Phases 1-5:** See Profile for detailed steps
   - Phase 1: Intent & Description
   - Phase 2: Mathematical Foundation (master equation, contract calculus, security calculus, etc.)
   - Phase 3: Lemma Development
   - Phase 4: Verification (notebook-first)
   - Phase 5: CI Enforcement

4. **Extract code from notebook:** Use `scripts/notebooks/extract_code.py`
   ```bash
   python3 scripts/notebooks/extract_code.py \
       --notebook notebooks/math/<notebook>.ipynb \
       --output caio/<module>/<file>.py \
       --functions <function_name>
   ```

5. **Implement in codebase:** Ensure code matches Phase 2 math

6. **Validate:** Run `make ma-validate-quiet` and test suite

### Modifying Existing Math

1. **Identify change:** What needs to be updated?

2. **Create ADR:** ALL invariant changes require an ADR (per MA process)
   - Location: `adr/ADR-XXXX.md` (if adr directory exists)
   - Template: See ADR template if available

3. **Assess impact:** Which phases are affected?

4. **Update phases:** Revise affected documentation (invariant YAML + lemma markdown)

5. **Re-verify:** Run verification notebooks
   - `python3 scripts/ci/notebooks_ci_run.py --notebook notebooks/math/verify_<name>.ipynb`
   - `make notebooks-plan`

6. **Update version:** Increment revision numbers

7. **Regenerate scorecard:** Run `make ma-status` (if available)

8. **Document change:** Link ADR in PR

---

## Commands Reference

Codex must use and recommend these commands when proposing how to run or verify work:

**Run unit tests:**
- `pytest tests/` - Run all tests

**Run lint/format:**
- `ruff check .` - Run linting
- `mypy src` - Type check (if configured)
- `pre-commit run --all-files` - Run pre-commit hooks (MANDATORY before commit)

**Run MA validation:**
- `make ma-validate-quiet` - Run MA validation
- `make ma-status` - Show MA status
- `make notebooks-plan` - Execute CI-ready notebooks
- `python3 scripts/ci/notebooks_ci_run.py --plan configs/generated/notebook_plan.json` - Run notebook plan

**Local CI (reduces GitHub Actions costs):**
- `make validate-local` - Run local validation
- `make promote-local SOURCE=development TARGET=staging` - Promote branches locally
- `make ci-local` - Complete CI replication

**Pre-commit workflow (MANDATORY):**
- `pre-commit run --all-files` - Run all pre-commit hooks before committing
- `make commit-and-push MSG="feat: description"` - Commit with validation (MA-compliant)

---

## Repo-Specific Quirks and Pitfalls

**Directories that should NOT be edited:**
- `configs/generated/` - Generated artifacts (must regenerate via notebooks/scripts)
- `logs/` - Generated logs
- `.venv/` - Virtual environment (auto-generated)

**Legacy modules:**
- None explicitly deprecated, but check `docs/` for status

**Files that are extremely large:**
- Some notebooks may be large; avoid rewriting unless necessary
- Artifact JSON files in `configs/generated/` should not be hand-edited

**Patterns that must be preserved:**
- **Notebook-first development:** Code written in notebooks first, then extracted (for math/algorithm code)
- **MA process:** Phases 1-5 must complete before code implementation (for math/algorithm/perf changes)
- **Control Calculus:** Mathematical guarantees for routing and orchestration
- **Contract-Based Service Discovery:** Service contracts in `configs/schemas/`
- **Mathematical hierarchy:** Intent → Foundation → Lemmas & Invariants → Notebooks → Codebase

**Critical warnings:**
- **NEVER skip MA process phases** for mathematical operations, algorithms, or performance guarantees
- **NEVER write code before completing MA Phases 1-5** (for math/algorithm/perf changes)
- **NEVER import from codebase in implementation notebooks** (`from src.`, etc.) - exception: verification notebooks
- **NEVER hand-edit `configs/generated/` artifacts** (must regenerate via notebooks)
- **ALWAYS run pre-commit hooks before committing** (`pre-commit run --all-files`)

**Note:** These "NEVER" rules apply only to math/algorithm/perf changes. Workflow 0 defines the allowed trivial-change path where MA is not required.

---

## Example Prompts for This Repo

List a few example tasks a user might ask Codex for this repo, and how Codex is expected to respond:

1. **"Add a unit test for routing decision logic."**
   - Codex should: Check if MA process artifacts exist (invariants, lemmas, notebooks), create test in `tests/test_routing.py`, validate against notebook artifacts if applicable, instruct user to run `pytest tests/test_routing.py`

2. **"Refactor service contract validation to reduce duplication while preserving behavior."**
   - Codex should: Check if refactor affects math (may require MA process update), identify call sites and tests, propose minimal refactor plan, preserve mathematical behavior, instruct user to run `pytest tests/` and `make ma-validate-quiet` (if math-related)

3. **"Document the control calculus in docs/."**
   - Codex should: Check `docs/math/CAIO_CONTROL_CALCULUS.md` for control calculus, check `invariants/` for related invariants, create/update docs, reference related lemmas/invariants

4. **"Add a new security guarantee with mathematical proof."**
   - Codex should: **Follow MA process Phases 1-5**, create intent in `docs/math/CAIO_MASTER_CALCULUS.md`, create invariant in `invariants/INV-CAIO-XXXX.yaml`, create lemma in `docs/math/CAIO_LEMMAS_APPENDIX.md`, create verification notebook in `notebooks/math/verify_<name>.ipynb`, write implementation code in notebook (notebook-first), extract code after Phases 1-5 complete, instruct user to run `make ma-validate-quiet`

5. **"Fix the failing test `test_invariants_index` in `tests/test_invariants_index.py`."**
   - Codex should: Read test file and error, check `docs/math/` and `invariants/` for expected behavior, check `notebooks/math/` for verification notebooks, prefer fixing implementation when specs/tests agree, instruct user to run `pytest tests/test_invariants_index.py`

6. **"Fix a typo in the error message."**
   - Codex should: Use Workflow 0 (trivial bugfix), make minimal change, run `pre-commit run --all-files` and `pytest tests/`, skip MA process, commit with standard workflow


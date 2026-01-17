# CAIO Phase 12: Operational Improvements Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-10  
**Owner:** Codex  
**Plan Reference:** `plan:phase-12-operational-improvements:12.1-12.4`

---

## Executive Summary

Address remaining operational improvements and documentation sync issues identified after Phase 11 completion. This phase synchronizes North Star documentation, fixes pre-commit hook false positives, ensures test environment consistency, and tunes ADR gate to reduce false positives.

**CRITICAL:** This is operational improvements work, not mathematical algorithm work. MA process is NOT required. However, all changes must be validated and tested.

**Estimated Time:** 1-2 days  
**Priority:** Medium (quality of life improvements, non-blocking)

---

## Context & Background

### Current State

- ✅ **Phase 11 Complete:** All productionization tasks done
- ✅ **CAIO Functional:** Core functionality working
- ❌ **Documentation Sync:** North Star Section 8 shows Phases 3-6 as "Pending" (should be "Complete")
- ❌ **Pre-Commit Hooks:** Secret scan flags 5 false positives; deprecated stage names need migration
- ❌ **Test Environment:** Pre-push hooks fail due to missing `pydantic_settings` in system Python
- ❌ **ADR Gate:** False positive for Phase 11 documentation changes

### North Star Alignment

This task directly supports the CAIO North Star by:

- **CI Gates Enforce Math:** Fixing pre-commit hooks ensures CI gates function correctly
- **Docs are Normative:** Syncing North Star ensures documentation accuracy
- **Operational Excellence:** Improving hooks and test environment ensures smooth development workflow

**Reference:** `docs/NORTH_STAR.md` - CI gates enforce math, docs are normative

### Execution Plan Reference

This task implements Phase 12: Operational Improvements from `plans/phase-12-operational-improvements/`:

- **12.1:** Documentation sync (North Star Section 8)
- **12.2:** Pre-commit hook improvements (secret scan whitelist, config migration)
- **12.3:** Test environment consistency (pre-push hook dependencies)
- **12.4:** ADR gate tuning (reduce false positives)

---

## Step-by-Step Implementation Instructions

### Task 12.1: Documentation Sync

**File:** `docs/NORTH_STAR.md`

**Objective:** Update Section 8 (MA Process) to mark Phases 3-6 as "✅ Complete" to match execution plan.

#### Step 1.1: Read Current State

**Read North Star Section 8:**
```bash
# View Section 8 (MA Process)
grep -A 30 "## 8. Mathematical Autopsy" docs/NORTH_STAR.md
```

**Current Status (WRONG):**
- Phase 3: "Pending"
- Phase 4: "Pending"
- Phase 5: "Pending"
- Phase 6: "Pending"

#### Step 1.2: Verify Execution Plan Status

**Check execution plan to confirm phase completion:**
```bash
# Check Phase 3-6 status in execution plan
grep -A 5 "Phase 3" docs/operations/execution_plan.md | grep -i "complete"
grep -A 5 "Phase 4" docs/operations/execution_plan.md | grep -i "complete"
grep -A 5 "Phase 5" docs/operations/execution_plan.md | grep -i "complete"
grep -A 5 "Phase 6" docs/operations/execution_plan.md | grep -i "complete"
```

**Expected:** All phases should show "✅ Complete" in execution plan.

#### Step 1.3: Update North Star Section 8

**Update Phase 3 Status:**
```markdown
### Phase 3: Invariants & Lemmas ✅
- Create `invariants/INV-CAIO-XXXX.yaml` for each guarantee
- Write lemmas proving properties
- Link to master equation
```

**Update Phase 4 Status:**
```markdown
### Phase 4: Verification Notebooks ✅
- Service discovery verification
- Routing optimization verification
- Guarantee enforcement verification
- Rule application verification
- Security verification
```

**Update Phase 5 Status:**
```markdown
### Phase 5: CI Enforcement ✅
- Artifacts from notebooks
- Scorecard gates
- Contract validation
```

**Update Phase 6 Status:**
```markdown
### Phase 6: Code Implementation ✅
- Implement master equation
- Contract parser (YAML)
- Rule engine
- Service registry
- Guarantee enforcer
- Security verifier
```

#### Step 1.4: Validate Cross-References

**Check all cross-references are valid:**
```bash
# Verify no broken links
grep -r "\[.*\](" docs/NORTH_STAR.md | grep -v "http" | while read line; do
  link=$(echo "$line" | sed 's/.*\[.*\](\(.*\))/\1/')
  if [ ! -f "$link" ] && [ ! -d "$link" ]; then
    echo "BROKEN: $line"
  fi
done
```

**Expected:** No broken cross-references.

#### Step 1.5: Verify Alignment

**Confirm North Star matches execution plan:**
```bash
# Compare phase status
echo "North Star Phase 3:" && grep -A 2 "Phase 3:" docs/NORTH_STAR.md | grep -i "complete\|pending"
echo "Execution Plan Phase 3:" && grep -A 2 "Phase 3" docs/operations/execution_plan.md | grep -i "complete\|pending"
```

**Expected:** Both show "Complete".

---

### Task 12.2: Pre-Commit Hook Improvements

**File:** `.pre-commit-config.yaml`

**Objective:** Review secret scan false positives, whitelist them, and migrate deprecated hook configuration.

#### Step 2.1: Run Secret Scan to Identify Flagged Items

**Run secret scan:**
```bash
# Run secret scan to see what's flagged
pre-commit run secret-scan-stub --all-files
```

**Expected Output:** Should show 5 flagged items with file paths and line numbers.

#### Step 2.2: Review Each Flagged Item

**For each flagged item, determine if it's a false positive:**

**False Positive Indicators:**
- Example keys in documentation (`docs/**/*.md`)
- Test data in examples
- Placeholder values (e.g., `sk-...` in README examples)
- Configuration examples

**Actual Secret Indicators:**
- Real API keys in code
- Hardcoded passwords
- Production credentials

**Action for Each Item:**
1. **If false positive:** Add to whitelist in `.pre-commit-config.yaml`
2. **If actual secret:** Remove or replace with placeholder

#### Step 2.3: Whitelist False Positives

**Update `.pre-commit-config.yaml` to whitelist false positives:**

**Option 1: File-Level Exclusion (Recommended for docs)**
```yaml
- id: secret-scan-stub
  name: Secret scan (gitleaks stub)
  entry: scripts/secret_scan_stub.sh
  language: script
  pass_filenames: false
  exclude: |
    (?x)^(
      docs/.*\.md|
      README\.md|
      .*_example\.py|
      .*_test\.py
    )$
```

**Option 2: Pattern Exclusion (If needed)**
```yaml
- id: secret-scan-stub
  args: ['--exclude-pattern', 'sk-test-.*', '--exclude-pattern', 'example.*']
```

**Recommendation:** Use file-level exclusion for documentation files.

#### Step 2.4: Migrate Deprecated Hook Configuration

**Run pre-commit migrate-config:**
```bash
# Migrate deprecated stage names
pre-commit migrate-config
```

**Expected Changes:**
- `stages: [commit]` → `stages: [pre-commit]`
- `stages: [push]` → `stages: [pre-push]`

**Verify migration:**
```bash
# Check for remaining deprecated stages
grep -E "stages:.*\[(commit|push)\]" .pre-commit-config.yaml
```

**Expected:** No deprecated stages remain.

#### Step 2.5: Validate Hooks Run Successfully

**Run all hooks:**
```bash
# Run all pre-commit hooks
pre-commit run --all-files
```

**Expected Results:**
- All hooks pass
- No secret scan false positives
- No deprecated stage warnings
- All validation gates pass

---

### Task 12.3: Test Environment Consistency

**Files:** `.pre-commit-config.yaml`, `docs/operations/LOCAL_VALIDATION_SETUP.md`

**Objective:** Document pre-push hook dependencies and ensure test environment has proper setup.

#### Step 3.1: Identify Pre-Push Hook Dependencies

**List pre-push hooks and their dependencies:**
```bash
# Check pre-push hooks
grep -A 10 "stages:.*push" .pre-commit-config.yaml
```

**Known Dependencies:**
- `pydantic_settings` (for unit-tests-quick hook)
- Python 3.10+ (for all hooks)
- Other dependencies from `requirements.txt` or `pyproject.toml`

#### Step 3.2: Verify Dependencies in Requirements

**Check dependencies are listed:**
```bash
# Check pydantic-settings is in requirements
grep "pydantic-settings" requirements.txt
grep "pydantic-settings" pyproject.toml
```

**Expected:** `pydantic-settings>=2.0.0` should be in both files.

#### Step 3.3: Create or Update Hook Environment Documentation

**Create or update `docs/operations/LOCAL_VALIDATION_SETUP.md`:**

**If file exists, add section:**
```markdown
## Pre-Push Hook Environment Setup

Pre-push hooks require the following dependencies to be installed:

### Required Dependencies

- `pydantic-settings>=2.0.0` (for unit-tests-quick hook)
- All dependencies from `requirements.txt`
- Python 3.10+ (for all hooks)

### Setup Instructions

1. **Create virtual environment:**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   pip install -e .  # Install CAIO package
   ```

3. **Install pre-commit hooks:**
   ```bash
   pre-commit install --hook-type pre-commit --hook-type pre-push
   ```

4. **Verify hooks work:**
   ```bash
   pre-commit run --all-files
   ```

### CI Environment

CI environments must have:
- All dependencies from `requirements.txt` installed
- `pydantic-settings` available in Python path
- Pre-commit hooks installed

### Troubleshooting

**Error: `ModuleNotFoundError: No module named 'pydantic_settings'`**
- **Solution:** Install dependencies: `pip install -r requirements.txt`

**Error: Pre-push hooks fail in CI**
- **Solution:** Ensure CI environment installs all dependencies before running hooks
```

**If file doesn't exist, create it with full structure.**

#### Step 3.4: Document Hook Environment in README (Optional)

**Add note to README.md if needed:**
```markdown
## Development Setup

See `docs/operations/LOCAL_VALIDATION_SETUP.md` for pre-commit hook environment setup.
```

---

### Task 12.4: ADR Gate Tuning

**Files:** `.pre-commit-config.yaml`, `scripts/ci/adr_gate.py`, `docs/operations/` (ADR documentation)

**Objective:** Review and tune ADR gate to reduce false positives for documentation changes.

#### Step 4.1: Review ADR Gate Logic

**Read ADR gate script:**
```bash
# Read ADR gate script
cat scripts/ci/adr_gate.py
```

**Current Logic:**
- Checks if guardrail files changed: `configs/constants/`, `invariants/INV-CAIO-CONTROL`
- Requires ADR reference in PR body if guardrail files changed
- Runs in CI only (skips in local pre-push)

**Issue:** Phase 11 documentation changes triggered ADR gate (false positive).

#### Step 4.2: Identify False Positive Cause

**Check what files triggered ADR gate in Phase 11:**
```bash
# Check Phase 11 commit files
git show --name-only HEAD~1 | grep -E "(docs/|README|pyproject)"
```

**Likely Cause:** ADR gate logic might be too broad or checking wrong file patterns.

#### Step 4.3: Update ADR Gate Logic (If Needed)

**Review guardrail file patterns:**

**Current Guardrail Patterns:**
- `configs/constants/`
- `invariants/INV-CAIO-CONTROL`

**Should NOT Trigger ADR:**
- Documentation files (`docs/**/*.md`, `README.md`)
- Packaging files (`pyproject.toml`, `requirements.txt` - unless adding new dependencies)
- Example files (`*_example.py`, `*_test.py`)

**Update `scripts/ci/adr_gate.py` if needed:**

**Add exclusion patterns:**
```python
def any_guardrail_changed(paths: Iterable[str]) -> bool:
    # ... existing code ...
    
    # Exclude documentation and packaging files
    excluded_patterns = [
        "docs/",
        "README.md",
        "pyproject.toml",  # Unless adding new dependencies
        "requirements.txt",  # Unless adding new dependencies
        "*_example.py",
        "*_test.py",
    ]
    
    for path in changed:
        # Skip excluded patterns
        if any(path.startswith(exclude.replace("*", "")) or 
               path.endswith(exclude.replace("*", "")) 
               for exclude in excluded_patterns):
            continue
            
        # ... rest of logic ...
```

**OR:** Update guardrail file patterns to be more specific:
```python
# Only check actual guardrail files
guardrail_files = [
    "configs/constants/",  # Control constants
    "invariants/INV-CAIO-CONTROL",  # Control invariants
    "caio/control/",  # Control module (if it exists)
]
```

#### Step 4.4: Document ADR Gate Scope

**Create or update ADR documentation:**

**File:** `docs/operations/ADR_GATE_SCOPE.md` (or add to existing ADR doc)

**Content:**
```markdown
# ADR Gate Scope

## When ADR is Required

ADR is required when **guardrail files** are changed:

- `configs/constants/` - Control constants and thresholds
- `invariants/INV-CAIO-CONTROL*` - Control-related invariants
- `caio/control/` - Control module (if applicable)

## When ADR is NOT Required

ADR is **NOT** required for:

- Documentation-only changes (`docs/**/*.md`, `README.md`)
- Packaging changes (`pyproject.toml`, `requirements.txt` - unless adding new dependencies)
- Example/test files (`*_example.py`, `*_test.py`)
- Configuration changes (unless affecting guardrails)
- Code changes (unless affecting control/guardrail logic)

## Examples

**Requires ADR:**
- Changing `configs/constants/routing_thresholds.yaml`
- Adding new control invariant `invariants/INV-CAIO-CONTROL-0002.yaml`
- Modifying control logic in `caio/control/`

**Does NOT Require ADR:**
- Updating `docs/NORTH_STAR.md`
- Adding `pydantic-settings` to `requirements.txt`
- Creating `docs/integration/TAI_INTEGRATION.md`
- Fixing `pyproject.toml` package discovery
```

#### Step 4.5: Test ADR Gate

**Test with documentation change (should NOT trigger):**
```bash
# Create test documentation change
echo "# Test" >> docs/test.md
git add docs/test.md
git commit -m "docs: test ADR gate"

# ADR gate should NOT trigger for docs/test.md
```

**Test with guardrail change (should trigger):**
```bash
# Create test guardrail change (if possible)
# ADR gate SHOULD trigger for configs/constants/ changes
```

**Expected:**
- Documentation changes: ADR gate does NOT trigger
- Guardrail changes: ADR gate DOES trigger

---

## Validation Procedures

### Pre-Work Validation

1. **Verify Prerequisites:**
   ```bash
   # Check Phase 11 is complete
   grep -A 5 "Phase 11" docs/operations/EXECUTION_PLAN.md | grep "Complete"
   
   # Check pre-commit is installed
   pre-commit --version
   ```

2. **Baseline Current State:**
   ```bash
   # Document current secret scan results
   pre-commit run secret-scan-stub --all-files > /tmp/secret-scan-baseline.txt
   
   # Document current hook config
   cat .pre-commit-config.yaml > /tmp/pre-commit-baseline.yaml
   ```

### Post-Work Validation

1. **Documentation Sync:**
   ```bash
   # Verify North Star phase status matches execution plan
   grep -A 2 "Phase 3:" docs/NORTH_STAR.md | grep "Complete"
   grep -A 2 "Phase 4:" docs/NORTH_STAR.md | grep "Complete"
   grep -A 2 "Phase 5:" docs/NORTH_STAR.md | grep "Complete"
   grep -A 2 "Phase 6:" docs/NORTH_STAR.md | grep "Complete"
   ```

2. **Pre-Commit Hooks:**
   ```bash
   # Run all hooks
   pre-commit run --all-files
   
   # Verify no secret scan false positives
   pre-commit run secret-scan-stub --all-files
   
   # Verify no deprecated stage warnings
   pre-commit migrate-config --dry-run
   ```

3. **Test Environment:**
   ```bash
   # Verify dependencies are listed
   grep "pydantic-settings" requirements.txt
   grep "pydantic-settings" pyproject.toml
   
   # Verify documentation exists
   test -f docs/operations/LOCAL_VALIDATION_SETUP.md
   ```

4. **ADR Gate:**
   ```bash
   # Test with documentation change (should not trigger)
   echo "# Test" >> docs/test.md
   git add docs/test.md
   git commit -m "docs: test ADR gate"
   # ADR gate should not trigger
   ```

---

## Success Criteria

- [ ] **Documentation Sync Complete:**
  - `docs/NORTH_STAR.md` Section 8 shows Phases 3-6 as "✅ Complete"
  - All cross-references are valid
  - Documentation is consistent across all files

- [ ] **Pre-Commit Hooks Fixed:**
  - Secret scan no longer flags false positives
  - Hook configuration uses current API (no deprecated stages)
  - All hooks run successfully: `pre-commit run --all-files` passes

- [ ] **Test Environment Documented:**
  - Pre-push hook dependencies are documented
  - Hook environment setup is documented
  - CI environment requirements are clear

- [ ] **ADR Gate Tuned:**
  - ADR gate does not trigger for documentation-only changes
  - ADR gate triggers for actual guardrail changes
  - ADR gate scope is documented

---

## Troubleshooting

### Issue: Secret Scan Still Flags Items After Whitelisting

**Solution:**
- Check whitelist patterns are correct
- Verify file paths match exclusion patterns
- Review gitleaks documentation for pattern syntax

### Issue: Pre-Commit Migrate-Config Doesn't Work

**Solution:**
- Update pre-commit: `pip install --upgrade pre-commit`
- Check pre-commit version: `pre-commit --version`
- Manually update stage names if needed

### Issue: ADR Gate Still Triggers for Documentation

**Solution:**
- Review ADR gate script logic
- Check guardrail file patterns
- Verify exclusion patterns are correct

### Issue: Pre-Push Hooks Fail in CI

**Solution:**
- Ensure CI installs dependencies: `pip install -r requirements.txt`
- Check CI Python version matches requirements
- Verify pre-commit hooks are installed in CI

---

## Notes

- This phase is **operational improvements**, not new features
- All tasks are **non-blocking** for CAIO functionality
- Focus is on **quality of life** improvements for development workflow
- Optional enhancements (gRPC API, etc.) are **explicitly out of scope** for this phase

---

**Plan Reference:** `plan:phase-12-operational-improvements:12.1-12.4`  
**North Star Alignment:** CI gates enforce math, docs are normative, operational excellence

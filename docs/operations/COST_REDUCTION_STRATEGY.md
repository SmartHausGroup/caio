# GitHub Actions Cost Reduction Strategy

**Status:** Active  
**Purpose:** Reduce GitHub Actions costs through local CI replication  
**Replicable:** Yes - Pattern can be applied to any MA project  
**Last Updated:** 2025-01-XX

---

## Problem Statement

**Issue:** GitHub Actions costs money per minute. Every push triggers CI, and failed runs consume minutes even when issues could be caught locally.

**Solution:** Run CI checks locally before pushing, reducing GitHub Actions usage by 50-75%.

---

## The Simplification

### Before (Expensive)

```
Developer makes changes
    ↓
Push to GitHub
    ↓
GitHub Actions triggers
    ↓
Install dependencies (2-3 min)
    ↓
Run notebooks (5-10 min)
    ↓
Run gates (1-2 min)
    ↓
If fails → Fix → Push again → Repeat
```

**Cost per feature:** ~10-20 CI runs × 2-5 min = 20-100 minutes = $0.16-$0.80

### After (Cost-Effective)

```
Developer makes changes
    ↓
Run local validation (make validate-local)
    ↓
Fix issues locally (no CI cost)
    ↓
Push only when local validation passes
    ↓
GitHub Actions runs (usually passes quickly)
```

**Cost per feature:** ~2-3 CI runs × 2-5 min = 4-15 minutes = $0.032-$0.12

**Savings:** 80% reduction in GitHub Actions minutes

---

## Implementation Pattern

### Step 1: Create Local Validation Script

**File:** `scripts/local/validate.sh`

**What it does:**
- Sets up virtual environment (if needed)
- Installs dependencies (cached locally)
- Runs notebooks (`make notebooks-plan`)
- Runs artifacts NaN/Inf gate
- Aggregates scorecard
- Runs scorecard gate (staging/main only)

**Key:** Uses the SAME scripts as CI (no duplication)

### Step 2: Create Local Promotion Script

**File:** `scripts/local/promote.sh`

**What it does:**
- Validates source branch locally
- Validates target branch locally (stricter gates)
- Merges source → target
- Provides push instructions

**Key:** Replicates promotion workflows locally

### Step 3: Create Complete CI Replication Script

**File:** `scripts/local/ci-replicate.sh`

**What it does:**
- Runs complete CI workflow locally
- All checks that GitHub Actions would run
- Branch-specific extra checks

**Key:** Complete CI replication

### Step 4: Add Makefile Targets

**File:** `Makefile`

**Add targets:**
```makefile
validate-local:
	@./scripts/local/validate.sh $(BRANCH)

promote-local:
	@./scripts/local/promote.sh $(SOURCE) $(TARGET)

ci-local:
	@./scripts/local/ci-replicate.sh $(BRANCH)
```

### Step 5: Document the Approach

**File:** `docs/operations/LOCAL_CI_MA_INTEGRATION.md`

**What to document:**
- Gate parity requirements
- MA process compliance
- Cost reduction strategy
- Usage patterns
- Troubleshooting

---

## Key Principles

### 1. Gate Parity (CRITICAL)

**Requirement:** Local gates must be IDENTICAL to CI gates.

**How:**
- Use the SAME scripts in both environments
- Same seed for determinism
- Same artifact paths
- Same scorecard evaluation

**Example:**
```bash
# Local
python3 scripts/ci/artifacts_nan_gate.py

# CI (in workflow)
python3 scripts/ci/artifacts_nan_gate.py
```

**NOT:**
```bash
# Local (WRONG - different script)
python3 scripts/local/artifacts_nan_gate.py

# CI (WRONG - different script)
python3 scripts/ci/artifacts_nan_gate.py
```

### 2. No Script Duplication

**Requirement:** Don't duplicate CI scripts for local use.

**How:**
- CI scripts live in `scripts/ci/`
- Local scripts call CI scripts
- Local scripts handle environment setup only

**Example:**
```bash
# scripts/local/validate.sh
source venv/bin/activate
make notebooks-plan                    # Calls CI script
python3 scripts/ci/artifacts_nan_gate.py  # Uses CI script
python3 tools/aggregate_scorecard.py     # Uses CI script
```

### 3. Environment Consistency

**Requirement:** Local environment should match CI environment.

**How:**
- Same Python version (3.11)
- Same dependencies
- Same seed
- Same execution paths

**Example:**
```bash
# Local script sets up environment
python3 -m venv venv
source venv/bin/activate
pip install nbconvert jupyter ipykernel

# CI workflow does the same
- uses: actions/setup-python@v5
  with:
    python-version: '3.11'
- run: pip install nbconvert jupyter ipykernel
```

---

## Replication Guide for RFS

### Step 1: Create Local Scripts Directory

```bash
mkdir -p scripts/local
```

### Step 2: Create validate.sh

**File:** `scripts/local/validate.sh`

```bash
#!/bin/bash
# Local MA validation script - replicates CI workflow locally
# Usage: ./scripts/local/validate.sh [branch]

set -euo pipefail

BRANCH="${1:-development}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

# Check if venv exists, create if not
if [ ! -d "venv" ]; then
    echo "[setup] Creating virtual environment..."
    python3 -m venv venv
fi

# Activate venv
source venv/bin/activate

# Install dependencies if needed
if ! python3 -c "import nbconvert" 2>/dev/null; then
    echo "[setup] Installing dependencies..."
    pip install --quiet --upgrade pip nbconvert jupyter ipykernel
fi

echo "[1/4] Running notebooks..."
make notebooks-plan  # Or: python3 scripts/notebooks_ci_run.py

echo ""
echo "[2/4] Running artifacts NaN/Inf gate..."
python3 scripts/ci/artifacts_nan_gate.py  # Use CI script

echo ""
echo "[3/4] Aggregating scorecard..."
python3 tools/aggregate_scorecard.py  # Use CI script

echo ""
echo "[4/4] Scorecard gate check..."
if [ "$BRANCH" = "staging" ] || [ "$BRANCH" = "main" ]; then
    echo "[gate] Staging/main branch - enforcing green scorecard..."
    python3 scripts/ci/scorecard_gate.py  # Use CI script
else
    echo "[gate] Development branch - checking scorecard..."
    SCORECARD_DECISION=$(python3 -c "import json; print(json.load(open('scorecard.json'))['decision']['overall'])")
    echo "[gate] Scorecard decision: $SCORECARD_DECISION"
fi

echo ""
echo "✅ Local validation complete"
```

### Step 3: Create promote.sh

**File:** `scripts/local/promote.sh`

```bash
#!/bin/bash
# Local branch promotion script
# Usage: ./scripts/local/promote.sh [source] [target]

set -euo pipefail

SOURCE_BRANCH="${1:-development}"
TARGET_BRANCH="${2:-staging}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

# Validate source branch
git checkout "$SOURCE_BRANCH"
./scripts/local/validate.sh "$SOURCE_BRANCH"

# Validate target branch
git checkout "$TARGET_BRANCH"
./scripts/local/validate.sh "$TARGET_BRANCH"

# Merge
git merge --no-ff "$SOURCE_BRANCH" -m "Local promotion: $SOURCE_BRANCH → $TARGET_BRANCH"

echo "✅ Local promotion complete"
echo "Next: git push origin $TARGET_BRANCH"
```

### Step 4: Update Makefile

**Add to Makefile:**

```makefile
validate-local:
	@./scripts/local/validate.sh $(BRANCH)

promote-local:
	@./scripts/local/promote.sh $(SOURCE) $(TARGET)

ci-local:
	@./scripts/local/ci-replicate.sh $(BRANCH)
```

### Step 5: Update Documentation

**Create:** `docs/operations/LOCAL_CI_MA_INTEGRATION.md`

Copy the pattern from CAIO and adapt for RFS:
- Update script paths
- Update branch names
- Update artifact counts
- Update invariant IDs

---

## Cost Reduction Metrics

### Before Local CI

**Per Feature:**
- Average CI runs: 10-20
- Average run time: 2-5 minutes
- Total minutes: 20-100
- Cost: $0.16-$0.80

**Per Month (10 features):**
- Total minutes: 200-1000
- Cost: $1.60-$8.00

### After Local CI

**Per Feature:**
- Average CI runs: 2-3
- Average run time: 2-5 minutes
- Total minutes: 4-15
- Cost: $0.032-$0.12

**Per Month (10 features):**
- Total minutes: 40-150
- Cost: $0.32-$1.20

**Savings:** 80% reduction ($1.28-$6.80 per month)

---

## Workflow Comparison

### Old Workflow (Expensive)

```
1. Make changes
2. Push to GitHub
3. Wait for CI (5-10 min)
4. CI fails
5. Fix locally
6. Push again
7. Wait for CI (5-10 min)
8. Repeat until passes
```

**Total time:** 30-60 minutes  
**CI minutes:** 20-100 minutes  
**Cost:** $0.16-$0.80

### New Workflow (Cost-Effective)

```
1. Make changes
2. Run local validation (2-5 min)
3. Fix issues locally (no CI cost)
4. Run local validation again (2-5 min)
5. Push only when passes
6. CI runs (usually passes quickly)
```

**Total time:** 10-20 minutes  
**CI minutes:** 4-15 minutes  
**Cost:** $0.032-$0.12

**Savings:** 80% reduction in CI minutes

---

## Key Success Factors

### 1. Gate Parity

**Critical:** Local gates must match CI gates exactly.

**How to verify:**
- Same scripts used
- Same seed
- Same artifact paths
- Same scorecard evaluation

### 2. No Script Duplication

**Critical:** Don't duplicate CI scripts.

**How to verify:**
- CI scripts in `scripts/ci/`
- Local scripts call CI scripts
- No duplicate logic

### 3. Environment Consistency

**Critical:** Local environment matches CI.

**How to verify:**
- Same Python version
- Same dependencies
- Same execution paths

### 4. Developer Adoption

**Critical:** Developers must use local validation.

**How to encourage:**
- Make it easy (`make validate-local`)
- Document benefits (cost savings)
- Show quick feedback (faster than CI)

---

## Replication Checklist for RFS

- [ ] Create `scripts/local/` directory
- [ ] Create `scripts/local/validate.sh` (replicates CI validation)
- [ ] Create `scripts/local/promote.sh` (replicates promotion)
- [ ] Create `scripts/local/ci-replicate.sh` (complete CI replication)
- [ ] Update `Makefile` with local targets
- [ ] Create `docs/operations/LOCAL_CI_MA_INTEGRATION.md`
- [ ] Update `docs/operations/MA_PROCESS_MANDATORY_RULE.md` to reference local CI
- [ ] Test local scripts work correctly
- [ ] Verify gate parity (local = CI)
- [ ] Document usage patterns
- [ ] Update README with local CI quick start

---

## Example: RFS Adaptation

### RFS-Specific Changes

**Script paths:**
- CAIO: `scripts/ci/notebooks_ci_run.py`
- RFS: `scripts/notebooks_ci_run.py` (check actual path)

**Seed environment variable:**
- CAIO: `CAIO_NOTEBOOK_SEED`
- RFS: `RFS_NOTEBOOK_SEED` (check actual variable)

**Artifact count:**
- CAIO: 12 artifacts
- RFS: Check `configs/generated/notebook_plan.json` for count

**Branch names:**
- CAIO: `development`, `staging`, `main`
- RFS: Check actual branch names

**Makefile targets:**
- CAIO: `make notebooks-plan`
- RFS: `make ai-validate` or `make notebooks-plan` (check actual)

---

## Summary

**The Simplification:**
1. Create local scripts that call CI scripts (no duplication)
2. Run validation locally before pushing
3. Push only when local validation passes
4. CI becomes quick verification step

**The Result:**
- 80% reduction in GitHub Actions minutes
- Faster feedback (no CI queue)
- Same quality gates (gate parity)
- Full MA compliance maintained

**The Pattern:**
- Local scripts handle environment setup
- CI scripts handle validation logic
- Same scripts used in both environments
- Gate parity enforced

**Replication:**
- Copy pattern from CAIO
- Adapt paths/variables for RFS
- Verify gate parity
- Document usage

---

## References

- **CAIO Implementation:** `scripts/local/` directory
- **CAIO Documentation:** `docs/operations/LOCAL_CI_MA_INTEGRATION.md`
- **CAIO MA Rule:** `docs/operations/MA_PROCESS_MANDATORY_RULE.md`
- **RFS Current CI:** Check `.github/workflows/` and `Makefile`


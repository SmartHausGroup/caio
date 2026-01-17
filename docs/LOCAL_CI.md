# Local CI Replication

**Status:** Active  
**Purpose:** Reduce GitHub Actions costs by running CI locally  
**Last Updated:** 2025-01-XX

---

## Overview

CAIO provides local scripts that replicate GitHub Actions workflows, allowing you to:
- Run all CI checks locally before pushing
- Reduce GitHub Actions usage and costs
- Catch issues early without waiting for CI
- Promote branches locally

---

## Quick Start

### Run Local Validation

```bash
# Validate current branch (defaults to development)
make validate-local

# Or specify branch
./scripts/local/validate.sh staging
```

### Run Complete CI Replication

```bash
# Replicate entire CI workflow locally
make ci-local

# Or specify branch
./scripts/local/ci-replicate.sh main
```

### Promote Branches Locally

```bash
# Promote development → staging
make promote-local SOURCE=development TARGET=staging

# Or use script directly
./scripts/local/promote.sh development staging
```

---

## Local Scripts

### `scripts/local/validate.sh`

Replicates the MA validation workflow locally.

**What it does:**
1. Sets up virtual environment (if needed)
2. Installs dependencies (nbconvert, jupyter, etc.)
3. Runs notebooks (`make notebooks-plan`)
4. Runs artifacts NaN/Inf gate
5. Aggregates scorecard
6. Runs scorecard gate (staging/main only)

**Usage:**
```bash
./scripts/local/validate.sh [branch]
```

**Example:**
```bash
./scripts/local/validate.sh development
```

---

### `scripts/local/ci-replicate.sh`

Complete CI replication - runs all checks that GitHub Actions would run.

**What it does:**
1. Checks out specified branch
2. Runs full validation
3. Branch-specific checks:
   - Staging/Main: Verifies all artifacts present
   - Staging/Main: Verifies scorecard programmatically

**Usage:**
```bash
./scripts/local/ci-replicate.sh [branch]
```

**Example:**
```bash
./scripts/local/ci-replicate.sh staging
```

---

### `scripts/local/promote.sh`

Replicates branch promotion workflows locally.

**What it does:**
1. Validates source branch
2. Validates target branch (with stricter gates)
3. Merges source → target
4. Provides push instructions

**Usage:**
```bash
./scripts/local/promote.sh [source] [target]
```

**Example:**
```bash
# Promote development → staging
./scripts/local/promote.sh development staging

# Promote staging → main
./scripts/local/promote.sh staging main
```

---

## Makefile Targets

### `make validate-local`
Run local validation (replicates CI validation)

```bash
make validate-local BRANCH=development
```

### `make promote-local`
Promote branches locally

```bash
make promote-local SOURCE=development TARGET=staging
```

### `make ci-local`
Complete CI replication

```bash
make ci-local BRANCH=staging
```

---

## Cost Reduction Strategy

### Before Pushing

1. **Run local validation:**
   ```bash
   make validate-local
   ```

2. **Fix any issues locally**

3. **Push only when local validation passes**

4. **GitHub Actions will verify, but should pass quickly**

### For Branch Promotion

1. **Promote locally first:**
   ```bash
   ./scripts/local/promote.sh development staging
   ```

2. **Verify everything works**

3. **Push to GitHub:**
   ```bash
   git push origin staging
   ```

4. **GitHub Actions will run, but should pass**

---

## Workflow Comparison

### GitHub Actions Workflow
```
Push → GitHub Actions → Install deps → Run notebooks → Gates → Scorecard
```

### Local Workflow
```
Local → Install deps (cached) → Run notebooks → Gates → Scorecard → Push → GitHub Actions (quick verify)
```

**Benefits:**
- Faster feedback (no queue time)
- No GitHub Actions minutes for failed runs
- Can iterate locally without pushing
- GitHub Actions becomes a final verification step

---

## Dependencies

Local scripts require:
- Python 3.11+
- Virtual environment (auto-created in `venv/`)
- Dependencies auto-installed:
  - nbconvert
  - jupyter
  - ipykernel

---

## Troubleshooting

### "venv not found"
**Fix:** Scripts auto-create venv, but if issues occur:
```bash
python3 -m venv venv
source venv/bin/activate
pip install nbconvert jupyter ipykernel
```

### "Notebook execution fails"
**Fix:** Check that notebooks are valid:
```bash
python3 -m nbconvert --to notebook --execute notebooks/math/verify_determinism.ipynb
```

### "Scorecard gate fails"
**Fix:** Check scorecard.json for failing invariants:
```bash
cat scorecard.json | python3 -m json.tool
```

---

## Best Practices

1. **Always run local validation before pushing**
   - Catches issues early
   - Reduces GitHub Actions failures
   - Saves CI minutes

2. **Use local promotion for testing**
   - Test promotion flow locally
   - Verify gates work correctly
   - Push only when confident

3. **Keep venv updated**
   - Scripts auto-install, but update periodically:
   ```bash
   source venv/bin/activate
   pip install --upgrade nbconvert jupyter ipykernel
   ```

4. **Check scorecard before pushing**
   - Review scorecard.json locally
   - Ensure all invariants pass
   - Fix issues before pushing

---

## Related Documentation

- **CI/CD Gates:** `.github/workflows/ma-validate-*.yml`
- **Promotion Workflow:** `docs/PROMOTION_WORKFLOW.md`
- **Branch Structure:** `docs/BRANCH_STRUCTURE.md`
- **MA Process:** `docs/MA_PROCESS_STATUS.md`


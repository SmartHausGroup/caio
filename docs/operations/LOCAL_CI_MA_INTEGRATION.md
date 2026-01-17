# Local CI Integration with MA Process

**Status:** Active  
**Purpose:** Reduce GitHub Actions costs while maintaining MA process integrity  
**Owner:** @smarthaus  
**Last Updated:** 2025-01-XX  
**Related:** MA Process Mandatory Rule, CI/CD Gates

---

## Executive Summary

CAIO implements local CI replication scripts that allow developers to run the complete Mathematical Autopsy (MA) validation pipeline locally before pushing to GitHub. This reduces GitHub Actions usage and costs while maintaining full MA process compliance and gate enforcement.

**Core Principle:** Local CI must replicate GitHub Actions exactly, ensuring MA gates are enforced identically in both environments.

---

## MA Process Integration

### Mandatory MA Gates (Enforced Locally and in CI)

All MA gates must pass both locally and in CI:

1. **Notebook Execution Gate**
   - Local: `make notebooks-plan` or `./scripts/local/validate.sh`
   - CI: `MA Validate (development) / validate` workflow
   - Requirement: All notebooks execute successfully, artifacts generated

2. **Artifacts NaN/Inf Gate**
   - Local: `scripts/ci/artifacts_nan_gate.py`
   - CI: Same script in workflow
   - Requirement: No NaN or Inf values in artifacts

3. **Scorecard Aggregation**
   - Local: `tools/aggregate_scorecard.py`
   - CI: Same script in workflow
   - Requirement: All invariants evaluated, decision generated

4. **Scorecard Gate** (staging/main only)
   - Local: `scripts/ci/scorecard_gate.py`
   - CI: Same script in workflow
   - Requirement: Decision must be GREEN

### MA Process Compliance

**Local CI maintains full MA compliance:**

- ✅ **Phase 1-3:** Math → Lemmas → Invariants (already complete)
- ✅ **Phase 4:** Verification notebooks execute locally
- ✅ **Phase 5:** CI gates enforced locally (identical to CI)
- ⏳ **Phase 6:** Code implementation (pending)

**No shortcuts:** Local validation must pass the same gates as CI. If local validation passes, CI should pass (barring environment differences).

---

## Local CI Architecture

### Script Hierarchy

```
scripts/local/
├── validate.sh          # MA validation (replicates CI validation workflow)
├── promote.sh           # Branch promotion (replicates promotion workflows)
└── ci-replicate.sh      # Complete CI replication (all checks)
```

### Gate Enforcement Flow

```
Local Validation
    ↓
[1] Notebook Execution (make notebooks-plan)
    ↓
[2] Artifacts NaN/Inf Gate (scripts/ci/artifacts_nan_gate.py)
    ↓
[3] Scorecard Aggregation (tools/aggregate_scorecard.py)
    ↓
[4] Scorecard Gate (scripts/ci/scorecard_gate.py) [staging/main only]
    ↓
✅ All Gates Pass → Safe to Push
```

### Branch-Specific Gates

**Development:**
- Notebooks execute
- Artifacts clean (no NaN/Inf)
- Scorecard generated
- Scorecard can be yellow (advisory failures allowed)

**Staging:**
- All development gates +
- Scorecard must be GREEN (blocks on yellow/red)
- All artifacts verified

**Main:**
- All staging gates +
- Artifact count verified (12/12)
- Scorecard decision verified programmatically

---

## Usage Patterns

### Pattern 1: Commit-and-Push Workflow (Recommended)

**Workflow:**
```bash
# Single command - commits, validates, and pushes
make commit-and-push MSG="feat: add feature"
```

**What it does:**
1. Stages all changes
2. Commits with message
3. Runs local validation automatically
4. Pushes only if validation passes
5. GitHub Actions runs as final verification

**Benefits:**
- Single command workflow
- Automatic validation before push
- Blocks push if validation fails
- Reduces GitHub Actions failures
- Faster feedback loop
- Saves CI minutes

**MA Compliance:** ✅ Full compliance maintained

### Pattern 2: Pre-Push Validation (Manual)

**Workflow:**
1. Make code changes
2. Run `make validate-local` or `./scripts/local/validate.sh`
3. Fix any issues locally
4. Commit: `git commit -m "feat: add feature"`
5. Push: `git push` (optional pre-push hook validates automatically)
6. GitHub Actions runs as final verification

**Benefits:**
- More control over commit process
- Optional pre-push hook provides safety net
- Catches issues before pushing
- Reduces GitHub Actions failures

**MA Compliance:** ✅ Full compliance maintained

### Pattern 3: Local Branch Promotion

**Workflow:**
1. Validate source branch locally
2. Run `./scripts/local/promote.sh development staging`
3. Verify promotion locally
4. Push target branch
5. GitHub Actions verifies promotion

**Benefits:**
- Test promotion flow locally
- Verify gates work correctly
- Catch promotion issues early

**MA Compliance:** ✅ Full compliance maintained

### Pattern 4: Complete CI Replication

**Workflow:**
1. Run `make ci-local` or `./scripts/local/ci-replicate.sh staging`
2. All CI checks run locally
3. Push only if all checks pass
4. GitHub Actions becomes quick verification

**Benefits:**
- Complete CI replication
- Highest confidence before pushing
- Minimal GitHub Actions usage

**MA Compliance:** ✅ Full compliance maintained

### Pattern 5: Override (Emergency Only)

**Workflow:**
```bash
# Override local validation (use sparingly)
SKIP_VALIDATION=1 make commit-and-push MSG="docs: update README"

# Or for direct git push
SKIP_LOCAL_VALIDATION=1 git push
```

**When to use:**
- Documentation-only changes
- Emergency hotfixes (with justification)
- CI infrastructure fixes

**Warning:** Override should be documented in commit message or PR description.

**MA Compliance:** ⚠️ Override bypasses gates - use only when justified

---

## MA Gate Verification

### Gate Equivalence Check

Local gates must be **identical** to CI gates:

| Gate | Local Script | CI Script | Equivalent? |
|------|--------------|-----------|------------|
| Notebook Execution | `scripts/ci/notebooks_ci_run.py` | Same | ✅ Yes |
| NaN/Inf Detection | `scripts/ci/artifacts_nan_gate.py` | Same | ✅ Yes |
| Scorecard Aggregation | `tools/aggregate_scorecard.py` | Same | ✅ Yes |
| Scorecard Gate | `scripts/ci/scorecard_gate.py` | Same | ✅ Yes |

**Verification:** All gates use the same scripts in both local and CI environments.

### Artifact Consistency

**Requirement:** Local artifacts must match CI artifacts (given same seed).

**Enforcement:**
- Same notebook plan (`configs/generated/notebook_plan.json`)
- Same seed (`CAIO_NOTEBOOK_SEED=42`)
- Same notebook execution (`nbconvert --execute`)
- Same artifact paths (`configs/generated/*_verification.json`)

**Verification:**
```bash
# Local
CAIO_NOTEBOOK_SEED=42 make notebooks-plan

# CI
CAIO_NOTEBOOK_SEED=42 (set in workflow)
```

---

## Cost Reduction Strategy

### GitHub Actions Usage Reduction

**Before Local CI:**
- Every push triggers CI
- Failed runs consume minutes
- Iterative fixes trigger multiple CI runs
- Estimated: ~10-20 minutes per feature

**After Local CI:**
- Push only after local validation passes
- CI becomes final verification (usually passes)
- Failed runs rare (caught locally)
- Estimated: ~2-5 minutes per feature

**Savings:** ~50-75% reduction in GitHub Actions minutes

### Cost Calculation

**Assumptions:**
- GitHub Actions: $0.008 per minute (Linux)
- Average feature: 10 CI runs (before) → 2 CI runs (after)
- Average run: 2 minutes

**Before:** 10 runs × 2 min × $0.008 = $0.16 per feature  
**After:** 2 runs × 2 min × $0.008 = $0.032 per feature  
**Savings:** $0.128 per feature (80% reduction)

---

## MA Process Mandatory Requirements

### Requirement 1: Gate Parity

**Mandatory:** Local gates must be identical to CI gates.

**Enforcement:**
- Same scripts used in both environments
- Same seed for determinism
- Same artifact paths
- Same scorecard evaluation

**Verification:**
- Scripts are shared (not duplicated)
- Environment variables match
- Execution paths identical

### Requirement 2: No Bypassing Gates

**Mandatory:** Local CI cannot bypass MA gates.

**Enforcement:**
- All gates must pass locally
- Scorecard gate enforced (staging/main)
- No "skip gates" option
- Same failure conditions

**Verification:**
- Scripts exit on gate failure
- No bypass flags
- Gates are mandatory

### Requirement 3: Artifact Consistency

**Mandatory:** Local artifacts must be consistent with CI artifacts.

**Enforcement:**
- Same notebook plan
- Same seed
- Same execution method
- Same artifact structure

**Verification:**
- Deterministic execution (seed-based)
- Artifact comparison (if needed)
- Same JSON structure

---

## Integration with MA Process Phases

### Phase 4: Verification (Notebooks)

**Local CI Role:**
- Execute notebooks locally
- Generate artifacts
- Verify notebook execution

**MA Compliance:**
- ✅ Notebooks execute successfully
- ✅ Artifacts generated
- ✅ Verification cells pass

### Phase 5: CI Enforcement

**Local CI Role:**
- Run all CI gates locally
- Verify scorecard generation
- Enforce gate requirements

**MA Compliance:**
- ✅ All gates enforced
- ✅ Scorecard generated
- ✅ Gate decisions match CI

### Phase 6: Code Implementation (Future)

**Local CI Role:**
- Validate code against invariants
- Run implementation tests
- Verify mathematical guarantees

**MA Compliance:**
- ✅ Code matches mathematical foundation
- ✅ Invariants verified
- ✅ Guarantees maintained

---

## Troubleshooting

### Local Validation Fails but CI Passes

**Possible Causes:**
- Environment differences (Python version, dependencies)
- Missing dependencies locally
- Different seed (shouldn't happen)

**Fix:**
- Ensure local environment matches CI
- Use same Python version (3.11)
- Install same dependencies
- Verify seed is 42

### CI Fails but Local Passes

**Possible Causes:**
- Local changes not pushed
- CI environment differences
- Timing/race conditions

**Fix:**
- Ensure all changes pushed
- Check CI logs for differences
- Verify artifact consistency

### Artifact Mismatch

**Possible Causes:**
- Different seed
- Notebook execution differences
- Environment differences

**Fix:**
- Verify `CAIO_NOTEBOOK_SEED=42`
- Check notebook execution logs
- Compare artifact structure

---

## Best Practices

### 1. Use Commit-and-Push Workflow (Recommended)

**Why:**
- Single command workflow
- Automatic validation
- Blocks push if validation fails
- Saves GitHub Actions minutes

**How:**
```bash
make commit-and-push MSG="feat: add feature"
```

### 2. Always Run Local Validation Before Pushing

**Why:**
- Catches issues early
- Reduces CI failures
- Saves GitHub Actions minutes

**How:**
```bash
make validate-local
# Fix issues
git commit -m "feat: add feature"
git push
```

### 3. Use Local Promotion for Testing

**Why:**
- Test promotion flow
- Verify gates work
- Catch promotion issues

**How:**
```bash
./scripts/local/promote.sh development staging
# Verify locally
git push origin staging
```

### 3. Keep Local Environment Updated

**Why:**
- Match CI environment
- Avoid environment differences
- Ensure consistency

**How:**
```bash
source venv/bin/activate
pip install --upgrade nbconvert jupyter ipykernel
```

### 4. Verify Scorecard Before Pushing

**Why:**
- Ensure invariants pass
- Catch scorecard issues
- Avoid CI failures

**How:**
```bash
cat scorecard.json | python3 -m json.tool
# Check decision field
```

---

## MA Process Checklist

Before pushing, verify:

- [ ] Local validation passes (`make validate-local` or `make commit-and-push`)
- [ ] All notebooks executed successfully
- [ ] Artifacts generated (12/12 for CAIO)
- [ ] No NaN/Inf in artifacts
- [ ] Scorecard generated
- [ ] Scorecard decision acceptable (green for staging/main)
- [ ] All invariants pass (check scorecard.json)
- [ ] Local environment matches CI (Python 3.11, dependencies)
- [ ] Logs reviewed (`logs/quality/local_validation.log`)

**Recommended:** Use `make commit-and-push MSG="..."` which automatically verifies all checks.

---

## Related Documentation

- **MA Process Mandatory Rule:** `docs/operations/MA_PROCESS_MANDATORY_RULE.md`
- **CI/CD Gates:** `docs/operations/CI_CD_GATES.md` (to be created)
- **Local CI Guide:** `docs/LOCAL_CI.md`
- **Promotion Workflow:** `docs/PROMOTION_WORKFLOW.md`
- **Branch Structure:** `docs/BRANCH_STRUCTURE.md`
- **MA Process Status:** `docs/MA_PROCESS_STATUS.md`

---

## Enforcement

**Mandatory:** All developers must run local validation before pushing.

**Verification:**
- CI logs show if local validation was run (commit messages, timing)
- Failed CI runs indicate local validation may have been skipped
- Code review can verify local validation was performed

**Compliance:**
- Local CI scripts enforce same gates as CI
- No way to bypass gates locally
- Same failure conditions as CI

---

## Summary

Local CI replication is fully integrated with the MA process:

- ✅ **Gate Parity:** Local gates identical to CI gates
- ✅ **MA Compliance:** Full MA process compliance maintained
- ✅ **Cost Reduction:** 50-75% reduction in GitHub Actions usage
- ✅ **Quality:** Same quality gates enforced locally and in CI
- ✅ **Consistency:** Same scripts, same seed, same artifacts

**Result:** Developers can iterate locally with confidence, reducing GitHub Actions costs while maintaining full MA process integrity.


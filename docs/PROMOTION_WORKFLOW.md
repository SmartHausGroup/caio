# CAIO Branch Promotion Workflow

**Status:** Active  
**Last Updated:** 2025-01-XX

---

## Overview

CAIO uses automated branch promotion with increasingly stringent gates at each level:

```
feature/* → development → staging → main
```

Each promotion requires:
1. Successful CI validation
2. Green scorecard (staging/main)
3. All gates passed

---

## Promotion Flow

### Development → Staging

**Trigger:** `MA Validate (development)` workflow completes successfully

**Workflow:** `.github/workflows/promote-staging.yml`

**Gates:**
- ✅ Development CI validation passed
- ✅ Run staging MA validation
- ✅ Scorecard must be GREEN (blocks on yellow/red)
- ✅ All 12 invariants must pass

**Process:**
1. Wait for `MA Validate (development)` to complete successfully
2. Run full MA validation with staging gates
3. Verify scorecard is green
4. Merge `development` → `staging`
5. Push to `staging` branch

**Failure Conditions:**
- Development CI failed
- Staging validation fails
- Scorecard is yellow or red
- Any required invariant fails

---

### Staging → Main

**Trigger:** `MA Validate (staging)` workflow completes successfully

**Workflow:** `.github/workflows/promote-main.yml`

**Gates (Most Stringent):**
- ✅ Staging CI validation passed
- ✅ Run main MA validation
- ✅ Scorecard must be GREEN (blocks on yellow/red)
- ✅ All 12 invariants must pass
- ✅ All 12 artifacts must be present
- ✅ Scorecard decision verified programmatically

**Process:**
1. Wait for `MA Validate (staging)` to complete successfully
2. Run full MA validation with main gates
3. Verify scorecard is green
4. Verify all artifacts present (12/12)
5. Verify scorecard decision programmatically
6. Merge `staging` → `main`
7. Push to `main` branch

**Failure Conditions:**
- Staging CI failed
- Main validation fails
- Scorecard is yellow or red
- Missing artifacts
- Any required invariant fails

---

## Gate Stringency Levels

### Development
- **Scorecard:** Can be yellow (advisory failures allowed)
- **Artifacts:** Generated but not strictly verified
- **Purpose:** Integration and testing

### Staging
- **Scorecard:** Must be GREEN (blocks on yellow/red)
- **Artifacts:** Generated and verified
- **Purpose:** Pre-production validation

### Main
- **Scorecard:** Must be GREEN (blocks on yellow/red)
- **Artifacts:** All 12 must be present and verified
- **Scorecard:** Programmatically verified
- **Purpose:** Production-ready code

---

## Manual Promotion

Both promotion workflows support manual triggering via `workflow_dispatch`:

```bash
# Promote to staging
gh workflow run promote-staging.yml

# Promote to main
gh workflow run promote-main.yml
```

**Note:** Manual promotion still requires all gates to pass.

---

## Promotion Summary

After successful promotion, GitHub Actions creates a summary showing:
- Source branch
- Target branch
- Scorecard status
- Gates passed

---

## Troubleshooting

### Promotion Fails: "Scorecard not green"
**Cause:** Scorecard decision is yellow or red  
**Fix:** Check `scorecard.json` for failing invariants, fix issues, re-run validation

### Promotion Fails: "Artifacts missing"
**Cause:** Not all 12 artifacts generated  
**Fix:** Check notebook execution logs, ensure all notebooks ran successfully

### Promotion Fails: "CI validation failed"
**Cause:** Previous stage CI failed  
**Fix:** Fix CI issues in source branch, wait for successful CI run

---

## Related Documentation

- **Branch Structure:** `docs/BRANCH_STRUCTURE.md`
- **CI/CD Gates:** `.github/workflows/ma-validate-*.yml`
- **Scorecard Gate:** `scripts/ci/scorecard_gate.py`
- **MA Process:** `docs/MA_PROCESS_STATUS.md`


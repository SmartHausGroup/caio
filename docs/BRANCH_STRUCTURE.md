# CAIO Branch Structure

**Status:** Active  
**Last Updated:** 2025-01-XX

---

## Branch Flow

```
feature/* → development → staging → main
```

### Branch Protection Rules

- **development**: Requires `MA Validate (development) / validate`
- **staging**: Requires `MA Validate (staging) / validate` (must be green)
- **main**: Requires `MA Validate (main) / validate` (must be green)

---

## Branches

### `development`
- **Purpose:** Integration branch for feature work
- **Protection:** Requires MA validation check
- **Workflow:** `.github/workflows/ma-validate-development.yml`
- **Scorecard:** Can be yellow (advisory failures allowed)

### `staging`
- **Purpose:** Pre-production testing and validation
- **Protection:** Requires MA validation check (must be green)
- **Workflow:** `.github/workflows/ma-validate-staging.yml`
- **Scorecard:** Must be green (blocks on yellow/red)

### `main`
- **Purpose:** Production-ready code
- **Protection:** Requires MA validation check (must be green)
- **Workflow:** `.github/workflows/ma-validate-main.yml`
- **Scorecard:** Must be green (blocks on yellow/red)

---

## Branch Promotion Process

1. **Feature → Development:**
   - Create PR from `feature/*` to `development`
   - CI runs `MA Validate (development) / validate`
   - Merge when validation passes

2. **Development → Staging:**
   - Create PR from `development` to `staging`
   - CI runs `MA Validate (staging) / validate`
   - Scorecard gate enforces green decision
   - Merge when validation passes and scorecard is green

3. **Staging → Main:**
   - Create PR from `staging` to `main`
   - CI runs `MA Validate (main) / validate`
   - Scorecard gate enforces green decision
   - Merge when validation passes and scorecard is green

---

## Required CI Checks

### Development Branch
- `MA Validate (development) / validate` - Required

### Staging Branch
- `MA Validate (staging) / validate` - Required (must pass)
- Scorecard gate - Must be green

### Main Branch
- `MA Validate (main) / validate` - Required (must pass)
- Scorecard gate - Must be green

---

## GitHub Branch Protection Setup

### Development
```yaml
Required checks:
  - MA Validate (development) / validate
Allow force pushes: false
Require branches to be up to date: true
```

### Staging
```yaml
Required checks:
  - MA Validate (staging) / validate
Allow force pushes: false
Require branches to be up to date: true
Require scorecard green: true
```

### Main
```yaml
Required checks:
  - MA Validate (main) / validate
Allow force pushes: false
Require branches to be up to date: true
Require scorecard green: true
```

---

## Current Status

- ✅ `development` branch created and pushed
- ✅ `staging` branch created and pushed
- ✅ `main` branch created and pushed
- ✅ CI workflows configured for all branches
- ⏳ Branch protection rules need to be configured in GitHub UI

---

## Next Steps

1. Configure branch protection rules in GitHub:
   - Go to Settings → Branches
   - Add rules for `development`, `staging`, `main`
   - Enable required checks as specified above

2. Test branch promotion:
   - Create test PR: `feature/test` → `development`
   - Verify CI runs and passes
   - Promote to `staging` and verify scorecard gate
   - Promote to `main` and verify scorecard gate

---

## References

- **CI Workflows:** `.github/workflows/ma-validate-*.yml`
- **Scorecard Gate:** `scripts/ci/scorecard_gate.py`
- **MA Process:** `docs/MA_PROCESS_STATUS.md`


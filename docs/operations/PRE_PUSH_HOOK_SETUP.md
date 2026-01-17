# Pre-Push Hook Setup (Optional)

**Status:** Optional Enhancement  
**Purpose:** Automatically block push if local validation fails  
**Cost Impact:** Additional safety net for cost reduction

---

## Overview

Pre-push hooks can automatically run local validation before every push, providing an additional safety net beyond the `commit-and-push` workflow.

---

## Installation Options

### Option 1: Git Pre-Push Hook (Recommended)

**File:** `.git/hooks/pre-push` (create in each repo clone)

```bash
#!/bin/bash
# Git pre-push hook - runs local validation before push
# Blocks push if validation fails

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "development")

# Skip if override flag is set
if [ "${SKIP_LOCAL_VALIDATION:-}" = "1" ]; then
    echo "⚠️  SKIP_LOCAL_VALIDATION=1 - skipping local validation"
    exit 0
fi

# Run validation
./scripts/local/pre-push-validation.sh "$CURRENT_BRANCH" || exit 1
```

**Installation:**
```bash
# Copy to git hooks directory
cp scripts/local/pre-push-validation.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

**Note:** Git hooks are not tracked in git, so each developer needs to install them.

### Option 2: Pre-Commit Framework (Advanced)

**File:** `.pre-commit-config.yaml`

```yaml
repos:
  - repo: local
    hooks:
      - id: pre-push-validation
        name: Pre-push MA validation
        entry: ./scripts/local/pre-push-validation.sh
        language: script
        stages: [push]
        pass_filenames: false
```

**Installation:**
```bash
pip install pre-commit
pre-commit install --hook-type pre-push
```

**Note:** Pre-commit framework requires additional setup and may have compatibility issues.

---

## Recommendation

**Use `make commit-and-push` workflow instead of pre-push hooks:**

**Reasons:**
1. **Simpler:** No hook installation required
2. **Explicit:** Developer chooses when to validate
3. **Flexible:** Can skip validation when needed
4. **Portable:** Works across all environments
5. **Documented:** Clear workflow in Makefile

**Pre-push hooks are optional** - the `commit-and-push` workflow provides the same protection with better developer experience.

---

## Usage

### With Pre-Push Hook

```bash
# Normal push (hook validates automatically)
git push

# Override hook
SKIP_LOCAL_VALIDATION=1 git push
```

### Without Pre-Push Hook (Recommended)

```bash
# Use commit-and-push workflow
make commit-and-push MSG="feat: add feature"

# Or manual validation
make validate-local
git commit -m "feat: add feature"
git push
```

---

## Comparison

| Approach | Setup Complexity | Developer Experience | Safety |
|----------|------------------|---------------------|--------|
| **commit-and-push** | None | Excellent | High |
| **Pre-push hook** | Medium | Good | High |
| **Manual validation** | None | Good | Medium |

**Recommendation:** Use `commit-and-push` workflow for best developer experience.

---

## Related Documentation

- **Local CI Integration:** `docs/operations/LOCAL_CI_MA_INTEGRATION.md`
- **Cost Reduction:** `docs/operations/COST_REDUCTION_STRATEGY.md`
- **MA Process:** `docs/operations/MA_PROCESS_MANDATORY_RULE.md`





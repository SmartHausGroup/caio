# CAIO Branch Structure

**Status:** Active  
**Last Updated:** 2026-01-18

---

## Overview

**CAIO Repository Purpose:** This is a **public documentation repository** containing:
- Documentation (user guides, API references, deployment guides)
- Plans and execution roadmaps
- Deployment configurations (Docker Compose, customer examples)
- **NO source code** (source code is in private `caio-core` repository)

**Enterprise Distribution:** Enterprises do **NOT** download packages from this repository. They receive:
- **Docker images** from private registry: `registry.smarthaus.group/caio:v0.1.0`
- **Python wheels** from secure download: `https://download.smarthaus.group/caio-0.1.0-py3-none-any.whl?token=LICENSE_KEY`

---

## Branch Flow

```
feature/* → main
```

**Note:** CAIO repository uses a simplified workflow since it contains only documentation and deployment configs, not source code. All work goes directly to `main` branch.

---

## Branches

### `main`
- **Purpose:** Production-ready documentation and deployment configs
- **Protection:** Standard branch protection (no direct pushes, require PR)
- **Workflow:** Documentation updates, plan updates, deployment config changes
- **Direct commits:** Allowed via PRs from `feature/*` branches

---

## Branch Promotion Process

1. **Feature → Main:**
   - Create PR from `feature/*` to `main`
   - Review documentation changes
   - Merge when approved

**No staging/development branches:** Since this is documentation-only, we work directly on `main` via feature branches.

---

## Required CI Checks

### Main Branch
- Standard PR checks (if configured)
- Documentation linting (if configured)
- No MA validation required (this is documentation-only)

---

## GitHub Branch Protection Setup

### Main
```yaml
Required checks:
  - Standard PR review (if configured)
Allow force pushes: false
Require branches to be up to date: true
```

**Note:** Since this is a documentation repository, CI checks are minimal. The `caio-core` repository (private, source code) uses the full MA validation workflow.

---

## Current Status

- ✅ `main` branch is the primary branch
- ✅ `development` branch removed (2026-01-18)
- ✅ All documentation work goes directly to `main` via feature branches
- ⏳ Branch protection rules should be configured in GitHub UI for `main`

---

## Next Steps

1. Configure branch protection for `main`:
   - Go to Settings → Branches
   - Add rule for `main`
   - Require PR for merges
   - Disallow force pushes

2. Workflow:
   - Create `feature/*` branch for documentation updates
   - Create PR to `main`
   - Review and merge

---

## Repository Structure

**CAIO Repository (This Repo):**
- **Purpose:** Public documentation and deployment configs
- **Content:** Docs, plans, Docker Compose files, README
- **Workflow:** `feature/*` → `main` (simplified)
- **Source Code:** NO (source code is in `caio-core`)

**caio-core Repository (Private):**
- **Purpose:** Internal source code
- **Content:** Python package, tests, notebooks, build infrastructure
- **Workflow:** `feature/*` → `development` → `staging` → `main` (full MA process)
- **Distribution:** Built into Docker images and Python wheels for enterprise customers

## References

- **Packaging & Distribution:** `docs/deployment/PACKAGING.md`
- **On-Premises Deployment:** `docs/deployment/ON_PREMISES_DEPLOYMENT.md`
- **TAI Integration:** `docs/integration/TAI_INTEGRATION.md`


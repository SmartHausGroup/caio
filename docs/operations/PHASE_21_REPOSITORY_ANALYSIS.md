# CAIO Repository Structure Analysis & Phase 21 Action Plan

**Date:** 2026-01-18  
**Purpose:** Deep dive analysis of CAIO vs caio-core repositories to determine Phase 21 completion status and required actions

---

## Repository Structure Confirmed

### 1. **CAIO Repository** (`/Users/smarthaus/Projects/GitHub/CAIO`)
**Purpose:** Public-facing documentation repository  
**Remote:** `https://github.com/SmartHausGroup/caio.git`  
**Branches:** `main`, `development`

**Contents:**
- ✅ `docs/` - Public documentation (North Star, API refs, deployment guides)
- ✅ `plans/` - Planning documents (including Phase 21 plan)
- ✅ `deploy/customer/` - Customer deployment configs (docker-compose.yml)
- ✅ `scripts/licensing/generate_keypair.sh` - Key generation script
- ✅ `scripts/release/push_to_registry.sh` - Registry push script
- ❌ NO Python source code (`caio/` package)
- ❌ NO tests, notebooks, or build infrastructure

**Phase 21 Status:**
- Plan exists: `plans/phase-21-licensing-security-distribution/`
- Prompt exists: `docs/prompts/codex-phase-21-licensing-security-distribution.md`
- Execution plan shows: "In Progress — docs/scripts updated; code/config pending"
- Tasks 21.5 (Distribution Control) and 21.6 (Docs) marked complete
- Tasks 21.1-21.4 reference code files that don't exist in this repo

---

### 2. **caio-core Repository** (`/Users/smarthaus/Projects/GitHub/caio-core`)
**Purpose:** Internal source code repository (proprietary)  
**Remote:** `git@github.com:SmartHausGroup/caio-core.git`  
**Branches:** `main`, `development`, `staging`

**Contents:**
- ✅ `caio/` - Full Python package with all source code
- ✅ `caio/licensing/` - Licensing module (generator.py, validator.py, etc.)
- ✅ `scripts/licensing/manage_licenses.py` - Admin CLI tool
- ✅ `scripts/release/` - Build/release scripts (build_docker.sh, build_wheel.sh, etc.)
- ✅ `tests/` - All test suites
- ✅ `notebooks/` - Math verification notebooks
- ✅ `docs/` - Internal documentation (duplicated from CAIO for development)
- ✅ Full development infrastructure (Makefiles, CI, etc.)

**Phase 21 Status:**
- Plan exists: `plans/phase-21-code-implementation/`
- **COMPLETE** (commit 69613ce, 2026-01-18)
- All code tasks done: RSA refactor, config updates, CLI updates, tests
- Generator uses `private_key_pem` ✅
- Validator uses `public_key_pem` ✅
- Config uses `CAIO_LICENSE_PUBLIC_KEY` and `CAIO_LICENSE_KEY` ✅
- CLI updated for RSA keys ✅

**Remaining Issues in caio-core:**
- ⚠️ Some docs still reference `CAIO_LICENSE_SECRET` (needs cleanup):
  - `docs/deployment/LICENSE_ACTIVATION.md`
  - `docs/deployment/ON_PREMISES_DEPLOYMENT.md`

---

## Phase 21 Task Breakdown by Repository

### **caio-core Repository** (Internal Code)

**✅ COMPLETE:**
- [x] 21.1: Generator refactor (RSA private key signing, v2 format)
- [x] 21.2: Validator refactor (RSA public key verification)
- [x] 21.3: Generation service update (private key PEM)
- [x] 21.4: Config and CLI updates (RSA keys, no SECRET)
- [x] 21.5: Tests and dependencies (`cryptography` added)

**⚠️ REMAINING WORK:**
1. **Documentation Cleanup:**
   - Remove `CAIO_LICENSE_SECRET` references from:
     - `docs/deployment/LICENSE_ACTIVATION.md`
     - `docs/deployment/ON_PREMISES_DEPLOYMENT.md`
   - Update to use `CAIO_LICENSE_PRIVATE_KEY` (for generation) and `CAIO_LICENSE_PUBLIC_KEY` (for validation)

2. **Script Location Decision:**
   - `generate_keypair.sh` currently in CAIO repo
   - `push_to_registry.sh` currently in CAIO repo
   - **Question:** Should these admin tools be in caio-core (internal) or CAIO (public docs)?

---

### **CAIO Repository** (Public Documentation)

**✅ COMPLETE:**
- [x] 21.5: Distribution Control
  - `deploy/customer/docker-compose.yml` exists ✅
  - `scripts/release/push_to_registry.sh` exists ✅
- [x] 21.6: Docs and Runbooks
  - `docs/licensing/LICENSE_MANAGEMENT.md` updated for v2 ✅
  - `docs/deployment/ON_PREMISES_DEPLOYMENT.md` updated ✅
  - `docs/deployment/LICENSE_ACTIVATION.md` updated ✅
  - `docs/operations/runbooks/license_key_rotation.md` exists ✅

**⚠️ REMAINING WORK:**
1. **Plan Update:**
   - Remove code change tasks (21.2, 21.3, 21.4) from CAIO execution plan
   - These tasks are complete in caio-core and don't belong in CAIO repo
   - Update plan to reflect: "Code implementation complete in caio-core; CAIO handles docs/deployment only"

2. **Script Location:**
   - `scripts/licensing/generate_keypair.sh` - Admin tool (should be in caio-core?)
   - `scripts/release/push_to_registry.sh` - Internal release script (should be in caio-core?)

3. **Documentation Sync:**
   - Ensure CAIO docs match caio-core implementation
   - Verify all examples use `CAIO_LICENSE_PRIVATE_KEY` / `CAIO_LICENSE_PUBLIC_KEY` (not SECRET)

---

## Recommended Actions

### **For caio-core Repository:**

1. **Documentation Cleanup (21.6 continuation):**
   ```bash
   # Remove CAIO_LICENSE_SECRET references from:
   - docs/deployment/LICENSE_ACTIVATION.md
   - docs/deployment/ON_PREMISES_DEPLOYMENT.md
   # Update to use CAIO_LICENSE_PRIVATE_KEY and CAIO_LICENSE_PUBLIC_KEY
   ```

2. **Script Migration (if needed):**
   - If `generate_keypair.sh` and `push_to_registry.sh` are admin tools, consider moving from CAIO to caio-core
   - OR: Keep in CAIO if they're meant to be public examples/documentation

### **For CAIO Repository:**

1. **Execution Plan Update:**
   - Mark tasks 21.2, 21.3, 21.4 as "Complete (in caio-core)"
   - Add note: "Code implementation completed in caio-core repo (commit 69613ce)"
   - Update Phase 21 scope to: "Documentation, deployment configs, and distribution control only"

2. **Plan File Update:**
   - Update `plans/phase-21-licensing-security-distribution/phase-21-licensing-security-distribution.md`
   - Remove code change tasks or mark as "See caio-core Phase 21"

3. **Documentation Verification:**
   - Verify all CAIO docs use correct env vars (`CAIO_LICENSE_PRIVATE_KEY`, `CAIO_LICENSE_PUBLIC_KEY`)
   - Ensure no references to deprecated `CAIO_LICENSE_SECRET`

---

## Best Practice Recommendation

Based on industry standards (LangChain, OpenAI, etc.):

**Admin/Internal Tools:**
- `generate_keypair.sh` → **caio-core** (internal admin tool)
- `push_to_registry.sh` → **caio-core** (internal release script)
- `manage_licenses.py` → **caio-core** ✅ (already there)

**Customer-Facing:**
- `deploy/customer/docker-compose.yml` → **CAIO** ✅ (correct)
- Documentation → **CAIO** ✅ (correct)
- Deployment guides → **CAIO** ✅ (correct)

**Decision Needed:**
Should `generate_keypair.sh` and `push_to_registry.sh` be:
- **Option A:** Moved to caio-core (internal admin tools)
- **Option B:** Kept in CAIO (public examples/documentation)

---

## Next Steps

1. **Immediate:** Update CAIO execution plan to reflect code completion in caio-core
2. **Immediate:** Clean up `CAIO_LICENSE_SECRET` references in caio-core docs
3. **Decision:** Determine script location (caio-core vs CAIO)
4. **Final:** Mark Phase 21 complete in both repos with proper cross-references

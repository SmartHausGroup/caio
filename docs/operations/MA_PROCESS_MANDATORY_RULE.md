# MA Process Mandatory Rule

**Status:** ✅ **ACTIVE**  
**Date:** 2025-01-XX  
**Owner:** All AI Assistants (Composer, Codex, GPT-5)

---

## Rule: ALWAYS Follow Mathematical Autopsy (MA) Process

**MANDATORY:** Before implementing ANY code that involves mathematical operations, algorithms, or performance guarantees, you MUST complete the full Mathematical Autopsy (MA) process.

---

## MA Process Steps (MUST Complete in Order)

### Phase 1: Intent & Description ✅
- [ ] Problem statement written (what, why, context, success criteria)
- [ ] Conceptual significance documented (plain-English, stakeholders)

### Phase 2: Mathematical Foundation ✅
- [ ] Master equation defined (`docs/math/CAIO_MASTER_CALCULUS.md`)
- [ ] Contract calculus formalized
- [ ] Rule application calculus formalized
- [ ] Security calculus formalized
- [ ] Guarantee composition calculus formalized
- [ ] Proof generation calculus formalized

### Phase 3: Lemma Development ✅
- [ ] YAML Invariant created (`invariants/INV-CAIO-XXXX.yaml`)
- [ ] Markdown Lemma written (`docs/math/CAIO_LEMMAS_APPENDIX.md`)
- [ ] Added to `invariants/INDEX.yaml`
- [ ] Added to lemmas quick index

### Phase 4: Verification ✅
- [ ] Verification notebook created (`notebooks/math/verify_*.ipynb`)
- [ ] VERIFY:L<N> cell with assertions
- [ ] Artifact JSON exported (`configs/generated/*_verification.json`)
- [ ] Notebook runs successfully locally
- [ ] Notebook added to `configs/generated/notebook_plan.json`

### Phase 5: CI Enforcement ✅
- [ ] Artifact registered in `docs/math/README.md`
- [ ] Notebook added to plan (`configs/generated/notebook_plan.json`)
- [ ] Local CI validation passes (`make validate-local`)
- [ ] CI workflow configured (GitHub Actions)
- [ ] Scorecard gates configured
- [ ] Invariant status: `draft` → `accepted`
- [ ] Lemma status: `Draft` → `Rev X.Y`

### After Phases 1-5 Complete: Code Implementation ✅
- [ ] Code implements the math from Phase 2
- [ ] Tests validate against Phase 4 notebook
- [ ] Telemetry matches Phase 3 invariant
- [ ] Code review verifies alignment with invariant/lemma

---

## Local CI Integration (Cost Reduction)

**MANDATORY:** Run local validation before pushing to reduce GitHub Actions costs.

**Process:**
1. Complete MA Phases 1-4
2. Run `make validate-local` or `./scripts/local/validate.sh`
3. Fix any issues locally
4. Push only when local validation passes
5. GitHub Actions runs as final verification

**MA Compliance:** Local CI maintains full MA process compliance. See `docs/operations/LOCAL_CI_MA_INTEGRATION.md` for details.

**Gate Parity:** Local gates must be identical to CI gates (same scripts, same seed, same artifacts).

---

## Enforcement

**MANDATORY for Production Code:** Phases 1-5 MUST be complete before any production code implementation.

**Minimum for Experimental Code:** Phases 1-3 must be complete (intent → foundation → invariant + lemma). Phases 4-5 required before promotion to staging/main.

**Branch Promotion:** Code must follow git workflow (`feature/*` → `development` → `staging` → `main`) with MA gates enforced at each stage. See `docs/BRANCH_STRUCTURE.md` for complete workflow.

**Local CI:** All developers must run local validation before pushing. Local CI is fully integrated with MA process. See `docs/operations/LOCAL_CI_MA_INTEGRATION.md` for complete requirements and gate parity enforcement.

**NEVER skip phases.** If you find yourself writing code before completing the required phases, STOP and complete the MA process first.

**Exceptions:**
- Trivial bug fixes or refactoring that doesn't change mathematical behavior
- Documentation-only changes
- Configuration changes that don't affect math

---

## Checklist for Every Feature

Before writing code, verify:
- [ ] Phase 1 complete (intent documented)
- [ ] Phase 2 complete (math foundation)
- [ ] Phase 3 complete (invariant + lemma)
- [ ] Phase 4 complete (verification notebook) - REQUIRED for production
- [ ] Phase 5 complete (CI enforcement) - REQUIRED for production
- [ ] Local validation passes (`make validate-local`)
- [ ] Then proceed to code implementation

---

## Reference

- **Full MA Process:** `docs/math/CAIO_MASTER_CALCULUS.md`
- **Local CI Integration:** `docs/operations/LOCAL_CI_MA_INTEGRATION.md`
- **Promotion Workflow:** `docs/PROMOTION_WORKFLOW.md`
- **Branch Structure:** `docs/BRANCH_STRUCTURE.md`
- **MA Process Status:** `docs/MA_PROCESS_STATUS.md`
- **Lemma Creation:** `docs/math/CAIO_LEMMAS_APPENDIX.md`
- **Invariant Template:** `invariants/INV_TEMPLATE.yaml` (to be created)

---

## Examples of MA-Aligned Work

✅ **Correct:** CAIO Master Calculus - completed MA before code
- ✅ North Star → Master Calculus → 12 Lemmas → 12 Invariants → 12 Notebooks → CI Gates

✅ **Correct:** Local CI Integration - documented MA compliance
- ✅ Local CI scripts → Operations doc → MA integration verified

❌ **Incorrect:** Implementing routing without MA
- ❌ Missing: Master equation
- ❌ Missing: Invariants
- ❌ Missing: Verification notebooks
- ❌ Missing: CI enforcement

**Fix:** Complete MA for routing before implementing code.

---

## Local CI Requirements

**Before pushing, verify:**
- [ ] Local validation passes (`make validate-local`)
- [ ] All notebooks executed successfully
- [ ] Artifacts generated (12/12 for CAIO)
- [ ] No NaN/Inf in artifacts
- [ ] Scorecard generated
- [ ] Scorecard decision acceptable (green for staging/main)
- [ ] All invariants pass (check scorecard.json)

**Gate Parity:**
- [ ] Same scripts used locally and in CI
- [ ] Same seed (CAIO_NOTEBOOK_SEED=42)
- [ ] Same artifact paths
- [ ] Same scorecard evaluation

---

## Summary

**MA Process is MANDATORY** for all mathematical code in CAIO.

**Local CI is REQUIRED** before pushing to reduce GitHub Actions costs.

**Gate Parity is ENFORCED** - local gates must match CI gates exactly.

**Full Compliance** - Local CI maintains full MA process compliance.


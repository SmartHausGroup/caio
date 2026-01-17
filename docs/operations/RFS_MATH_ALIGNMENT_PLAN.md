# RFS Math Alignment Plan

**Status:** Proposed  
**Last Updated:** 2025-01-XX  
**Owner:** @smarthaus  
**Source of Truth:** `docs/NORTH_STAR.md`  
**Audience:** CAIO Engineering / Research

This document formalizes the plan to complete mathematical alignment between CAIO and the RFS Math Thesis (`ResonantFieldStorage/docs/thesis/MATH_THESIS_v5-arxiv.md`).

---

## Executive Summary

**Objective:** Formally define the `W(Ψ_i, Ψ_RFS)` term in CAIO's master control equation and map RFS metrics to CAIO's field state extraction, ensuring mathematical consistency with RFS's field-theoretic framework.

**Scope:**
- Add formal mathematical definition of `W(Ψ_i, Ψ_RFS)` to `CAIO_MASTER_CALCULUS.md`
- Map CAIO's `RFS_metrics` to RFS's measured invariants
- Add cross-references to RFS invariants
- Document field reading vs. field generation distinction
- Add energy conservation awareness

**Alignment Status:** ✅ Strong alignment confirmed, gaps identified for formalization

---

## 1. Mathematical Definition of `W(Ψ_i, Ψ_RFS)`

### 1.1 Current State

**Location:** `docs/math/CAIO_MASTER_CALCULUS.md` line 57, 70, 99

**Current Definition:**
- Line 70: `W(Ψ_i, Ψ_RFS)`: Wave/field resonance score (from MAIA)
- **Gap:** No formal mathematical definition

### 1.2 Proposed Addition

**Location:** Add new section after Section 1.1 (Field-Based Control Master Equation), before Section 1.2 (Master Equation Expanded)

**New Section:** "1.1.1 Field Resonance Term Definition"

**Content:**

```markdown
### 1.1.1 Field Resonance Term Definition

**Definition (Def. 1.1):**

The field resonance term `W(Ψ_i, Ψ_RFS)` quantifies the alignment between MAIA's intent field and RFS's memory field using matched-filter correlation:

```math
W(Ψ_i, Ψ_RFS) = \frac{\langle Ψ_i, Ψ_RFS \rangle}{\|Ψ_i\|_2 \cdot \|Ψ_RFS\|_2}
```

Where:
- `Ψ_i ∈ ℂ^D`: MAIA intent field (from upstream MAIA system)
- `Ψ_RFS ∈ ℂ^D`: RFS memory field (from upstream RFS system)
- `⟨·,·⟩`: Inner product in Hilbert space `ℂ^D`
- `||·||_2`: L2 norm (energy)

**Alternative Definition (Def. 1.2):**

If using RFS's resonance quality metric `Q` (measured in dB):

```math
W(Ψ_i, Ψ_RFS) = Q_RFS(Ψ_i, Ψ_RFS) = 20 \log_{10}\left(\frac{\text{peak}(\langle Ψ_i, Ψ_RFS \rangle)}{\text{background}(\langle Ψ_i, Ψ_RFS \rangle)}\right)
```

Where:
- `peak(⟨Ψ_i, Ψ_RFS⟩)`: Maximum correlation value (signal)
- `background(⟨Ψ_i, Ψ_RFS⟩)`: Average correlation value excluding peak (noise)

**RFS Invariant Reference:**
- RFS INV-0003: `Q ≥ 6 dB` for reliable retrieval
- Observed values: `Q ∈ [12, 18] dB` (16-64× power ratios)

**Properties:**
1. **Normalized correlation:** `W(Ψ_i, Ψ_RFS) ∈ [-1, 1]` (Def. 1.1) or `W(Ψ_i, Ψ_RFS) ∈ ℝ` (Def. 1.2)
2. **Symmetry:** `W(Ψ_i, Ψ_RFS) = W(Ψ_RFS, Ψ_i)` (Def. 1.1 only)
3. **Energy awareness:** Uses L2 norms, respecting Parseval's theorem (RFS Theorem 2)

**Implementation Note:**
- CAIO reads `Ψ_i` and `Ψ_RFS` as field snapshots (point-in-time measurements)
- Field evolution is handled by upstream systems (MAIA, RFS)
- CAIO does not generate or evolve fields; it reads and optimizes over field states
```

---

## 2. RFS Metrics Mapping

### 2.1 Current State

**Location:** `docs/math/CAIO_MASTER_CALCULUS.md` line 44, 52, 83

**Current Definition:**
- Line 52: `RFS_metrics`: RFS field metrics (resonance, recall, cost)
- Line 83: `rfs_metrics = GetRFSMetrics()`
- **Gap:** No formal mapping to RFS invariants

### 2.2 Proposed Addition

**Location:** Add new section after Section 1.1.1 (Field Resonance Term Definition)

**New Section:** "1.1.2 RFS Metrics Mapping"

**Content:**

```markdown
### 1.1.2 RFS Metrics Mapping

**Definition (Def. 1.3):**

CAIO's `RFS_metrics` structure maps to RFS's measured invariants:

```math
RFS\_metrics = \begin{cases}
  \text{resonance} & \mapsto Q_{\text{RFS}} \quad \text{(RFS INV-0003: } Q \geq 6 \text{ dB)} \\
  \text{recall} & \mapsto 1 - \eta_{\text{residual}} \quad \text{(RFS INV-0004: } \eta_{\text{residual}} \leq 0.15) \\
  \text{cost} & \mapsto E_{\text{utilization}} / E_{\text{max}} \quad \text{(RFS capacity margin)}
\end{cases}
```

**Detailed Mapping:**

1. **Resonance (`resonance`):**
   - **RFS Metric:** Resonance quality `Q` (dB)
   - **RFS Invariant:** INV-0003: `Q ≥ 6 dB` for reliable retrieval
   - **Observed Range:** `Q ∈ [12, 18] dB` (16-64× power ratios)
   - **CAIO Usage:** Higher `Q` → stronger field alignment → higher `W(Ψ_i, Ψ_RFS)` score
   - **Formula:** `Q = 20 log₁₀(peak/background)`

2. **Recall (`recall`):**
   - **RFS Metric:** Inverse of interference ratio `η_residual`
   - **RFS Invariant:** INV-0004: `η_residual ≤ 0.15` (15% maximum destructive overlap)
   - **CAIO Usage:** Lower interference → higher recall quality → better memory retrieval
   - **Formula:** `recall = 1 - η_residual` where `η_residual = E_destructive / E_total`

3. **Cost (`cost`):**
   - **RFS Metric:** Energy utilization or capacity margin
   - **RFS Invariant:** Capacity margin P99 ≥ 1.3× (30% headroom)
   - **CAIO Usage:** Energy budget for RFS operations, capacity headroom for writes
   - **Formula:** `cost = E_utilization / E_max` or `cost = 1 / capacity_margin`

**RFS Invariant Cross-References:**

| CAIO Metric | RFS Invariant | RFS Threshold | Purpose |
|-------------|---------------|---------------|---------|
| `resonance` | INV-0003 | `Q ≥ 6 dB` | Signal clarity for retrieval |
| `recall` | INV-0004 | `η ≤ 0.15` | Interference control |
| `cost` | Capacity margin | P99 ≥ 1.3× | Energy budget / capacity |

**Energy Conservation Assumption:**

CAIO assumes RFS maintains energy conservation (RFS Theorem 2: Parseval's theorem):
```math
\|E(w)\|_2^2 = \|w\|_2^2
```

CAIO does not enforce this directly; it is validated by RFS's invariants (INV-0001, INV-0002).

**Field Reading vs. Field Generation:**

- **CAIO reads:** Field snapshots `Ψ_i`, `Ψ_t`, `Ψ_RFS` at time `t`
- **CAIO does not:** Generate or evolve fields
- **Field evolution:** Handled by upstream systems:
  - MAIA: Intent field `Ψ_i` evolution (damped wave equation)
  - NME: Trait field `Ψ_t` evolution
  - RFS: Memory field `Ψ_RFS` evolution (damped wave equation, decay dynamics)
```

---

## 3. Field State Extraction Formalization

### 3.1 Current State

**Location:** `docs/math/CAIO_MASTER_CALCULUS.md` line 44, 81-83

**Current Definition:**
- Line 44: `s_t = [modes(Π_high Ψ_i), modes(Π_low Ψ_t), C, M, RFS_metrics]`
- Line 81-83: Field state extraction in expanded equation
- **Gap:** No formal definition of `modes(Π_high Ψ_i)` and `modes(Π_low Ψ_t)`

### 3.2 Proposed Addition

**Location:** Add new section after Section 1.1.2 (RFS Metrics Mapping)

**New Section:** "1.1.3 Field Mode Extraction"

**Content:**

```markdown
### 1.1.3 Field Mode Extraction

**Definition (Def. 1.4):**

Field mode extraction uses frequency-domain projectors to filter field states:

```math
\text{modes}(\Pi_{\text{high}} \Psi_i) = \mathcal{F}^{-1}\left(M_{\text{high}} \odot \mathcal{F}(\Psi_i)\right)
```

```math
\text{modes}(\Pi_{\text{low}} \Psi_t) = \mathcal{F}^{-1}\left(M_{\text{low}} \odot \mathcal{F}(\Psi_t)\right)
```

Where:
- `Π_high`, `Π_low`: Frequency-domain projectors (bandpass filters)
- `M_high`, `M_low`: Binary masks indicating passband frequencies
- `ℱ`: Unitary FFT (norm="ortho")
- `ℱ⁻¹`: Inverse FFT

**Projector Alignment with RFS:**

CAIO's projectors `Π_high` and `Π_low` align with RFS's projector `Π` (RFS Section 3.5):
- **RFS:** `Π = ℱ⁻¹ · M_passband · ℱ` (frequency-domain filter)
- **CAIO:** `Π_high`, `Π_low` use same structure for intent/trait separation

**Conductivity Metric (RFS Definition 1):**

CAIO can measure projector transmission efficiency:

```math
\kappa(\Psi) = \frac{\|\Pi(\Psi)\|_2}{\|\Psi\|_2}
```

Where:
- `κ = 1`: Perfect transmission (all energy in passband)
- `κ = 0`: Complete blocking (all energy out-of-band)
- `0 < κ < 1`: Partial transmission

**RFS Reference:** RFS enforces `κ ≥ 0.95` (95% energy in passband) for signal integrity.

**Frequency Separation:**

- **High-frequency modes (`Π_high`):** Intent field modes (rapid changes, immediate goals)
- **Low-frequency modes (`Π_low`):** Trait field modes (slow changes, persistent preferences)

This separation prevents interference between intent and trait signals, analogous to RFS's guard bands between associative and exact recall channels.
```

---

## 4. Control Signal Feedback Formalization

### 4.1 Current State

**Location:** `docs/math/CAIO_MASTER_CALCULUS.md` line 104, 134

**Current Definition:**
- Line 104: `u(t) = GenerateControlSignal(selected, intent_modes, trait_modes)`
- Line 134: `SendControlSignal(u_control, MAIA)`
- **Gap:** No formal definition of how `u(t)` affects MAIA's field evolution

### 4.2 Proposed Addition

**Location:** Add new section after Section 1.1.3 (Field Mode Extraction)

**New Section:** "1.1.4 Control Signal Feedback"

**Content:**

```markdown
### 1.1.4 Control Signal Feedback

**Definition (Def. 1.5):**

Control signal `u(t)` feeds back to MAIA to shape intent field evolution:

```math
\text{MAIA: } \frac{\partial^2 \Psi_i}{\partial t^2} + \gamma_i \frac{\partial \Psi_i}{\partial t} = c^2 \nabla^2 \Psi_i + B_i u(t)
```

Where:
- `γ_i > 0`: Damping coefficient (MAIA-specific)
- `c`: Wave speed
- `B_i`: Control input matrix (maps `u(t)` to field excitation)
- `u(t) ∈ ℝ^k`: Control signal vector (mode excitation/damping)

**Control Strategies:**

1. **Mode excitation:** `u_j(t) > 0` amplifies mode `j` (e.g., long-term planning)
2. **Mode damping:** `u_j(t) < 0` dampens mode `j` (e.g., impulsive intent)
3. **Mode bias:** `u_j(t)` biases toward certain intent patterns

**Alignment with RFS Persuasion:**

CAIO's control feedback aligns with RFS's persuasion mechanism (RFS Section 6):
- **RFS:** Modifies Hamiltonian `H` or field state `Ψ` to guide behavior
- **CAIO:** Modifies MAIA's field evolution via `u(t)` to shape intent

Both use control signals to reshape field dynamics, enabling "persuasion" rather than direct override.

**Energy Conservation:**

Control signal `u(t)` must respect energy conservation:
```math
\|B_i u(t)\|_2^2 \leq E_{\text{max}} - \|\Psi_i\|_2^2
```

This ensures field energy remains bounded (RFS energy guardrails).
```

---

## 5. Implementation Checklist

### 5.1 Document Updates

- [ ] **Add Section 1.1.1** to `CAIO_MASTER_CALCULUS.md`:
  - [ ] Formal definition of `W(Ψ_i, Ψ_RFS)` (Def. 1.1, Def. 1.2)
  - [ ] RFS invariant references (INV-0003)
  - [ ] Properties and implementation notes

- [ ] **Add Section 1.1.2** to `CAIO_MASTER_CALCULUS.md`:
  - [ ] RFS metrics mapping (Def. 1.3)
  - [ ] Detailed mapping table
  - [ ] RFS invariant cross-references
  - [ ] Energy conservation assumption

- [ ] **Add Section 1.1.3** to `CAIO_MASTER_CALCULUS.md`:
  - [ ] Field mode extraction (Def. 1.4)
  - [ ] Projector alignment with RFS
  - [ ] Conductivity metric
  - [ ] Frequency separation explanation

- [ ] **Add Section 1.1.4** to `CAIO_MASTER_CALCULUS.md`:
  - [ ] Control signal feedback (Def. 1.5)
  - [ ] Control strategies
  - [ ] Alignment with RFS persuasion
  - [ ] Energy conservation constraint

### 5.2 Cross-References

- [ ] **Update Section 0 (Reader's Guide)**:
  - [ ] Add RFS field notation: `Ψ_RFS ∈ ℂ^D`
  - [ ] Add RFS metrics notation: `RFS_metrics = {resonance, recall, cost}`
  - [ ] Add RFS reference: `ResonantFieldStorage/docs/thesis/MATH_THESIS_v5-arxiv.md`

- [ ] **Update Section 1.1 (Field-Based Control Master Equation)**:
  - [ ] Add reference to new Section 1.1.1 (Field Resonance Term)
  - [ ] Add reference to new Section 1.1.2 (RFS Metrics Mapping)

- [ ] **Add References Section**:
  - [ ] RFS Math Thesis: `ResonantFieldStorage/docs/thesis/MATH_THESIS_v5-arxiv.md`
  - [ ] RFS Invariants: `ResonantFieldStorage/invariants/INDEX.yaml`
  - [ ] RFS Master Calculus: `ResonantFieldStorage/docs/math/RFS_MASTER_CALCULUS.md` (if exists)

### 5.3 Validation

- [ ] **Create verification notebook:**
  - [ ] `notebooks/math/caio_rfs_alignment_validation.ipynb`
  - [ ] Verify `W(Ψ_i, Ψ_RFS)` computation matches RFS resonance quality
  - [ ] Verify RFS metrics mapping
  - [ ] Verify field mode extraction
  - [ ] Verify control signal feedback

- [ ] **Create invariant:**
  - [ ] `invariants/INV-CAIO-RFS-0001.yaml`: RFS field alignment invariant
  - [ ] Verify `W(Ψ_i, Ψ_RFS)` respects RFS resonance thresholds
  - [ ] Verify RFS metrics are within RFS invariant bounds

- [ ] **Update lemmas:**
  - [ ] Add lemma to `docs/math/CAIO_LEMMAS_APPENDIX.md`:
    - [ ] Lemma L{N}: CAIO-RFS Field Alignment
    - [ ] References RFS resonance quality and CAIO's `W(Ψ_i, Ψ_RFS)` term

### 5.4 Documentation

- [ ] **Update `CAIO_CONTROL_CALCULUS.md`:**
  - [ ] Add reference to `W(Ψ_i, Ψ_RFS)` definition in `CAIO_MASTER_CALCULUS.md`
  - [ ] Update RFS metrics description to reference formal mapping

- [ ] **Update `EXECUTION_PLAN.md`:**
  - [ ] Add entry for RFS math alignment completion
  - [ ] Mark as complete when all items done

---

## 6. Mathematical Consistency Checks

### 6.1 Field Notation Consistency

- [x] Both use `Ψ ∈ ℂ^D` for field state
- [x] Both use projectors `Π` for frequency-domain filtering
- [x] Both use inner products `⟨·,·⟩` for correlation
- [x] Both use L2 norms `||·||_2` for energy

### 6.2 Operator Consistency

- [x] CAIO reads fields (does not generate)
- [x] RFS generates and evolves fields
- [x] CAIO uses projectors for mode extraction
- [x] RFS uses projectors for band separation

### 6.3 Energy Conservation

- [x] RFS enforces Parseval's theorem (Theorem 2)
- [x] CAIO assumes RFS maintains energy conservation
- [x] CAIO's control signal respects energy bounds

### 6.4 Control Feedback

- [x] CAIO generates `u(t)` to shape MAIA field
- [x] RFS uses persuasion to shape field dynamics
- [x] Both use control signals, not direct override

---

## 7. Success Criteria

### 7.1 Mathematical Completeness

- [ ] `W(Ψ_i, Ψ_RFS)` has formal mathematical definition
- [ ] RFS metrics have explicit mapping to RFS invariants
- [ ] Field mode extraction is formally defined
- [ ] Control signal feedback is formally defined

### 7.2 Cross-Reference Completeness

- [ ] All RFS invariants referenced have correct IDs
- [ ] All RFS theorems referenced have correct numbers
- [ ] All RFS definitions referenced have correct numbers
- [ ] RFS Math Thesis is referenced with correct path

### 7.3 Validation Completeness

- [ ] Verification notebook exists and passes
- [ ] Invariant exists and is validated
- [ ] Lemma exists and references correct invariants
- [ ] All mathematical claims are provable

---

## 8. Timeline

**Phase 1: Document Updates (Day 1-2)**
- Add Sections 1.1.1-1.1.4 to `CAIO_MASTER_CALCULUS.md`
- Update cross-references
- Update references section

**Phase 2: Validation (Day 3-4)**
- Create verification notebook
- Create invariant
- Create lemma
- Run validation

**Phase 3: Documentation (Day 5)**
- Update `CAIO_CONTROL_CALCULUS.md`
- Update `EXECUTION_PLAN.md`
- Final review

---

## 9. References

- **RFS Math Thesis:** `ResonantFieldStorage/docs/thesis/MATH_THESIS_v5-arxiv.md`
- **CAIO Master Calculus:** `docs/math/CAIO_MASTER_CALCULUS.md`
- **CAIO Control Calculus:** `docs/math/CAIO_CONTROL_CALCULUS.md`
- **RFS Invariants:** `ResonantFieldStorage/invariants/INDEX.yaml`
- **CAIO North Star:** `docs/NORTH_STAR.md`

---

**Status:** Ready for implementation  
**Next Step:** Begin Phase 1 (Document Updates)


# Codex Prompt: Math Thesis Alignment Implementation

**Plan Reference:** `plan:math-thesis-alignment`  
**Execution Plan Reference:** `plan:EXECUTION_PLAN:math-thesis-alignment`  
**Status:** Ready for Implementation  
**North Star Alignment:** Aligns CAIO mathematics with Math Thesis framework per `docs/NORTH_STAR.md` (Section 2, Mathematical Foundation; Section 3, Service Registry Architecture)

---

## Executive Summary

Implement formal mathematical definitions for all CAIO sub-equations (`I(Ψ_i)`, `A(Ψ_i, C)`, `RL(Ψ_i, M)`, `W(Ψ_i, Ψ_RFS)`) using Math Thesis operators, ensuring energy conservation, Parseval compliance, and alignment with Math Thesis invariants. Add formal definitions to `CAIO_MASTER_CALCULUS.md`, implement functions in Python, create validation notebooks, and integrate with existing orchestrator code.

**Note:** This is MA process work (math formalization). Follow the mandatory workflow (North Star alignment, Execution Plan verification, change approval). All code must be written in notebooks first (notebook-first development), then extracted to Python files.

---

## Context & Background

**Current State:**
- Math Thesis alignment document exists: `docs/math/MATH_THESIS_ALIGNMENT.md`
- Implementation plan exists: `docs/operations/MATH_THESIS_IMPLEMENTATION_PLAN.md`
- CAIO master calculus exists: `docs/math/CAIO_MASTER_CALCULUS.md`
- Math Thesis reference: `TAI/docs/MATH_THESIS_v5.md`
- Sub-equations `I(Ψ_i)`, `A(Ψ_i, C)`, `RL(Ψ_i, M)`, `W(Ψ_i, Ψ_RFS)` are referenced but not formally defined

**Why This Matters:**
- Ensures all CAIO mathematics aligns with the unified Math Thesis framework
- Provides formal mathematical guarantees for all routing decisions
- Enables grand unification calculus across CAIO, MAIA, NME, RFS, VFE, VEE
- Ensures energy conservation and Parseval compliance
- Maps RFS metrics to Math Thesis invariants

**Related Work:**
- Math Thesis Alignment: `docs/math/MATH_THESIS_ALIGNMENT.md`
- Implementation Plan: `docs/operations/MATH_THESIS_IMPLEMENTATION_PLAN.md`
- CAIO Master Calculus: `docs/math/CAIO_MASTER_CALCULUS.md`
- Math Thesis: `TAI/docs/MATH_THESIS_v5.md`
- North Star: `docs/NORTH_STAR.md` (Section 2: Mathematical Foundation)

---

## Current State Analysis

**What Exists:**

**Documentation:**
- `docs/math/MATH_THESIS_ALIGNMENT.md` - Formal alignment document with all definitions
- `docs/operations/MATH_THESIS_IMPLEMENTATION_PLAN.md` - Detailed implementation plan with code snippets
- `docs/math/CAIO_MASTER_CALCULUS.md` - CAIO master calculus (needs sub-equation definitions added)
- `TAI/docs/MATH_THESIS_v5.md` - Math Thesis framework reference

**Code:**
- `caio/orchestrator/` - Orchestrator code exists (needs field math integration)
- No `field_math.py` module exists yet
- Field extraction exists but not Math Thesis-aligned

**What's Missing:**

**Documentation:**
- Sections 1.1.1-1.1.6 in `CAIO_MASTER_CALCULUS.md` (sub-equation definitions)
- Section 0 updates (Math Thesis notation)

**Code:**
- `caio/orchestrator/field_math.py` - Field math module with all sub-equations
- Integration into orchestrator routing
- Math Thesis-aligned field extraction

**Validation:**
- Validation notebook: `notebooks/math/math_thesis_alignment_validation.ipynb`
- Performance benchmark: `notebooks/math/math_thesis_performance_benchmark.ipynb`
- Unit tests: `tests/unit/test_field_math.py`
- Integration tests: `tests/integration/test_math_thesis_integration.py`

---

## Target State

**Documentation Complete:**
- All sub-equation definitions added to `CAIO_MASTER_CALCULUS.md`
- Math Thesis references included
- Cross-references to Math Thesis invariants
- Energy conservation documented

**Code Complete:**
- `field_math.py` module with all sub-equation functions
- Functions integrated into orchestrator routing
- Math Thesis-aligned field extraction
- Backward compatibility maintained

**Validation Complete:**
- Validation notebook passes all tests
- Performance benchmark meets targets
- Unit tests pass
- Integration tests pass
- Math Thesis invariant checks pass

---

## Step-by-Step Implementation Instructions

### Phase 1: Document Updates (Day 1-2)

#### Step 1.1: Add Section 1.1.1 - Field Resonance Term Definition

**File:** `docs/math/CAIO_MASTER_CALCULUS.md`

**Location:** After Section 1.1 (Field-Based Control Master Equation), before Section 1.2 (Master Equation Expanded)

**Content to Add:**

```markdown
### 1.1.1 Field Resonance Term Definition

**Definition (Def. 1.1):**

The field resonance term `W(Ψ_i, Ψ_RFS)` quantifies the alignment between MAIA's intent field and RFS's memory field using Math Thesis matched-filter correlation:

```math
W(Ψ_i, Ψ_RFS) = \frac{\langle Ψ_i, Ψ_{RFS} \rangle}{\|Ψ_i\|_2 \cdot \|Ψ_{RFS}\|_2}
```

Where:
- `Ψ_i ∈ ℂ^D`: MAIA intent field (from upstream MAIA system)
- `Ψ_RFS ∈ ℂ^D`: RFS memory field (from upstream RFS system)
- `⟨·,·⟩`: Inner product in Hilbert space `ℂ^D` (Math Thesis Section 3.1)
- `||·||_2`: L2 norm (energy)

**Alternative Definition (Def. 1.2):**

Using RFS's resonance quality metric (Math Thesis Section 3.2):

```math
W(Ψ_i, Ψ_RFS) = Q_{RFS}(Ψ_i, Ψ_{RFS}) = 20 \log_{10}\left(\frac{\text{peak}(\langle Ψ_i, Ψ_{RFS} \rangle)}{\text{background}(\langle Ψ_i, Ψ_{RFS} \rangle)}\right)
```

Where:
- `peak(⟨Ψ_i, Ψ_RFS⟩)`: Maximum correlation value (signal)
- `background(⟨Ψ_i, Ψ_RFS⟩)`: Average correlation value excluding peak (noise)

**Math Thesis Invariant Reference:**
- Math Thesis INV-0003: `Q ≥ 6 dB` for reliable retrieval
- Observed values: `Q ∈ [12, 18] dB` (16-64× power ratios)

**Properties:**
1. **Normalized correlation:** `W(Ψ_i, Ψ_RFS) ∈ [-1, 1]` (Def. 1.1) or `W(Ψ_i, Ψ_RFS) ∈ ℝ` (Def. 1.2)
2. **Symmetry:** `W(Ψ_i, Ψ_RFS) = W(Ψ_RFS, Ψ_i)` (Def. 1.1 only)
3. **Energy awareness:** Uses L2 norms, respecting Parseval's theorem (Math Thesis Theorem 2)

**Reference:** `CAIO/docs/math/MATH_THESIS_ALIGNMENT.md` Section 3.4
```

**Acceptance Criteria:**
- [ ] Section added to `CAIO_MASTER_CALCULUS.md`
- [ ] Both definitions (Def. 1.1, Def. 1.2) included
- [ ] Math Thesis references added
- [ ] Math Thesis invariant references (INV-0003) included

---

#### Step 1.2: Add Section 1.1.2 - Intent Understanding Score Definition

**File:** `docs/math/CAIO_MASTER_CALCULUS.md`

**Location:** After Section 1.1.1

**Content to Add:**

```markdown
### 1.1.2 Intent Understanding Score Definition

**Definition (Def. 1.3):**

The intent understanding score measures the energy and clarity of the intent field using Math Thesis matched-filter correlation:

```math
I(Ψ_i) = \|E_i^H \Psi_i\|_2^2 = \|\text{matched\_filter}(\Psi_i)\|_2^2
```

Where:
- `E_i^H`: Matched filter operator (Math Thesis Section 4.1)
- `||·||_2`: L2 norm (energy)

**Alternative Definition (Def. 1.4):**

Using high-frequency mode extraction:

```math
I(Ψ_i) = \|\Pi_{\text{high}} \Psi_i\|_2^2 = \int_{\omega > \omega_{\text{cutoff}}} |\hat{\Psi}_i(\omega)|^2 d\omega
```

Where:
- `Π_high`: High-frequency projector (Math Thesis Section 3.5)
- `ω_cutoff`: Frequency cutoff for high-frequency modes

**Math Thesis Reference:**
- Math Thesis Section 4.1: Matched filter optimality (Theorem 3)
- Math Thesis Section 3.5: Projector structure

**Reference:** `CAIO/docs/math/MATH_THESIS_ALIGNMENT.md` Section 3.1
```

**Acceptance Criteria:**
- [ ] Section added to `CAIO_MASTER_CALCULUS.md`
- [ ] Both definitions (Def. 1.3, Def. 1.4) included
- [ ] Math Thesis references added
- [ ] Matched filter optimality reference (Theorem 3) included

---

#### Step 1.3: Add Section 1.1.3 - Attention-Weighted Context Score Definition

**File:** `docs/math/CAIO_MASTER_CALCULUS.md`

**Location:** After Section 1.1.2

**Content to Add:**

```markdown
### 1.1.3 Attention-Weighted Context Score Definition

**Definition (Def. 1.5):**

The attention-weighted context score measures the alignment between intent field and context using Math Thesis inner product:

```math
A(Ψ_i, C) = \frac{\langle \Psi_i, E_C(C) \rangle}{\|\Psi_i\|_2 \cdot \|E_C(C)\|_2}
```

Where:
- `E_C(C)`: Context encoding operator (Math Thesis Section 3.4)
- `⟨·,·⟩`: Inner product in Hilbert space (Math Thesis Section 3.1)
- `||·||_2`: L2 norm (energy)

**Properties:**
1. **Normalized correlation:** `A(Ψ_i, C) ∈ [-1, 1]` (cosine similarity)
2. **Energy awareness:** Uses L2 norms, respecting Parseval's theorem

**Math Thesis Reference:**
- Math Thesis Section 3.1: Inner product structure
- Math Thesis Section 3.4: Encoding operator

**Reference:** `CAIO/docs/math/MATH_THESIS_ALIGNMENT.md` Section 3.2
```

**Acceptance Criteria:**
- [ ] Section added to `CAIO_MASTER_CALCULUS.md`
- [ ] Definition (Def. 1.5) included
- [ ] Context encoding operator defined
- [ ] Math Thesis inner product reference included

---

#### Step 1.4: Add Section 1.1.4 - RL Policy Score Definition

**File:** `docs/math/CAIO_MASTER_CALCULUS.md`

**Location:** After Section 1.1.3

**Content to Add:**

```markdown
### 1.1.4 RL Policy Score Definition

**Definition (Def. 1.6):**

The RL policy score measures the optimal action value from MAIA's reinforcement learning policy:

```math
RL(Ψ_i, M) = \max_{m \in M} Q(\text{encode}(\Psi_i), m, θ)
```

Where:
- `Q(s, m, θ)`: Q-function from MAIA/VEE (MAIA Intent Calculus)
- `encode(Ψ_i)`: Intent field encoding for RL state
- `M`: Marketplace of available services/models

**Alternative Definition (Def. 1.7):**

Using matched-filter correlation with marketplace encodings:

```math
RL(Ψ_i, M) = \max_{m \in M} \frac{\langle \Psi_i, E_m(m) \rangle}{\|\Psi_i\|_2 \cdot \|E_m(m)\|_2}
```

Where:
- `E_m(m)`: Marketplace service encoding operator

**Math Thesis Reference:**
- Math Thesis Section 4.1: Matched filter optimality
- MAIA Intent Calculus: `MAIA(q, H) = VEE_Classify(q, H, θ)`

**Reference:** `CAIO/docs/math/MATH_THESIS_ALIGNMENT.md` Section 3.3
```

**Acceptance Criteria:**
- [ ] Section added to `CAIO_MASTER_CALCULUS.md`
- [ ] Both definitions (Def. 1.6, Def. 1.7) included
- [ ] MAIA/VEE reference included
- [ ] Math Thesis matched filter reference included

---

#### Step 1.5: Add Section 1.1.5 - Field Mode Extraction

**File:** `docs/math/CAIO_MASTER_CALCULUS.md`

**Location:** After Section 1.1.4

**Content to Add:**

```markdown
### 1.1.5 Field Mode Extraction

**Definition (Def. 1.8):**

Field mode extraction uses Math Thesis projector structure:

```math
\text{modes}(\Pi_{\text{high}} \Psi_i) = \Pi_{\text{high}}(\Psi_i) = \mathcal{F}^{-1}\left(M_{\text{high}} \odot \mathcal{F}(\Psi_i)\right)
```

```math
\text{modes}(\Pi_{\text{low}} \Psi_t) = \Pi_{\text{low}}(\Psi_t) = \mathcal{F}^{-1}\left(M_{\text{low}} \odot \mathcal{F}(\Psi_t)\right)
```

Where:
- `Π_high`, `Π_low`: Frequency-domain projectors (bandpass filters)
- `M_high`, `M_low`: Binary masks indicating passband frequencies
- `ℱ`: Unitary FFT (norm="ortho") (Math Thesis requirement)
- `ℱ⁻¹`: Inverse FFT

**Projector Alignment with Math Thesis:**

CAIO's projectors `Π_high` and `Π_low` align with Math Thesis projector structure (Math Thesis Section 3.5):
- **Math Thesis:** `Π = ℱ⁻¹ · M_passband · ℱ` (frequency-domain filter)
- **CAIO:** `Π_high`, `Π_low` use same structure for intent/trait separation

**Conductivity Metric (Math Thesis Definition 1):**

CAIO can measure projector transmission efficiency:

```math
\kappa(\Psi) = \frac{\|\Pi(\Psi)\|_2}{\|\Psi\|_2}
```

Where:
- `κ = 1`: Perfect transmission (all energy in passband)
- `κ = 0`: Complete blocking (all energy out-of-band)
- `0 < κ < 1`: Partial transmission

**Math Thesis Reference:** Math Thesis INV-0018: `κ ≥ 0.95` (95% energy in passband) for signal integrity.

**Frequency Separation:**

- **High-frequency modes (`Π_high`):** Intent field modes (rapid changes, immediate goals)
- **Low-frequency modes (`Π_low`):** Trait field modes (slow changes, persistent preferences)

This separation prevents interference between intent and trait signals, analogous to Math Thesis guard bands.

**Reference:** `CAIO/docs/math/MATH_THESIS_ALIGNMENT.md` Section 4
```

**Acceptance Criteria:**
- [ ] Section added to `CAIO_MASTER_CALCULUS.md`
- [ ] Both mode extraction definitions included
- [ ] Math Thesis projector structure reference included
- [ ] Conductivity metric reference included

---

#### Step 1.6: Add Section 1.1.6 - RFS Metrics Mapping

**File:** `docs/math/CAIO_MASTER_CALCULUS.md`

**Location:** After Section 1.1.5

**Content to Add:**

```markdown
### 1.1.6 RFS Metrics Mapping

**Definition (Def. 1.9):**

CAIO's `RFS_metrics` structure maps to Math Thesis measured invariants:

```math
RFS\_metrics = \begin{cases}
  \text{resonance} & \mapsto Q_{\text{RFS}} \quad \text{(Math Thesis INV-0003: } Q \geq 6 \text{ dB)} \\
  \text{recall} & \mapsto 1 - \eta_{\text{residual}} \quad \text{(Math Thesis INV-0004: } \eta_{\text{residual}} \leq 0.15) \\
  \text{cost} & \mapsto E_{\text{utilization}} / E_{\text{max}} \quad \text{(Math Thesis capacity margin)}
\end{cases}
```

**Detailed Mapping:**

1. **Resonance (`resonance`):**
   - **Math Thesis Metric:** Resonance quality `Q` (dB)
   - **Math Thesis Invariant:** INV-0003: `Q ≥ 6 dB` for reliable retrieval
   - **Observed Range:** `Q ∈ [12, 18] dB` (16-64× power ratios)
   - **CAIO Usage:** Higher `Q` → stronger field alignment → higher `W(Ψ_i, Ψ_RFS)` score
   - **Formula:** `Q = 20 log₁₀(peak/background)`

2. **Recall (`recall`):**
   - **Math Thesis Metric:** Inverse of interference ratio `η_residual`
   - **Math Thesis Invariant:** INV-0004: `η_residual ≤ 0.15` (15% maximum destructive overlap)
   - **CAIO Usage:** Lower interference → higher recall quality → better memory retrieval
   - **Formula:** `recall = 1 - η_residual` where `η_residual = E_destructive / E_total`

3. **Cost (`cost`):**
   - **Math Thesis Metric:** Energy utilization or capacity margin
   - **Math Thesis Invariant:** Capacity margin P99 ≥ 1.3× (30% headroom)
   - **CAIO Usage:** Energy budget for RFS operations, capacity headroom for writes
   - **Formula:** `cost = E_utilization / E_max` or `cost = 1 / capacity_margin`

**Math Thesis Invariant Cross-References:**

| CAIO Metric | Math Thesis Invariant | Math Thesis Threshold | Purpose |
|-------------|----------------------|----------------------|---------|
| `resonance` | INV-0003 | `Q ≥ 6 dB` | Signal clarity for retrieval |
| `recall` | INV-0004 | `η ≤ 0.15` | Interference control |
| `cost` | Capacity margin | P99 ≥ 1.3× | Energy budget / capacity |

**Energy Conservation Assumption:**

CAIO assumes Math Thesis maintains energy conservation (Math Thesis Theorem 2: Parseval's theorem):
```math
\|E(w)\|_2^2 = \|w\|_2^2
```

CAIO does not enforce this directly; it is validated by Math Thesis invariants (INV-0001, INV-0002).

**Reference:** `CAIO/docs/math/MATH_THESIS_ALIGNMENT.md` Section 5
```

**Acceptance Criteria:**
- [ ] Section added to `CAIO_MASTER_CALCULUS.md`
- [ ] Mapping table included
- [ ] Math Thesis invariant references included
- [ ] Energy conservation assumption documented

---

#### Step 1.7: Update Section 0 - Reader's Guide

**File:** `docs/math/CAIO_MASTER_CALCULUS.md`

**Location:** Section 0 (Reader's Guide)

**Additions:**
- Math Thesis field notation: `Ψ_i, Ψ_t, Ψ_RFS ∈ ℂ^D`
- Math Thesis operators: `E`, `E^H`, `Π`
- Math Thesis reference: `TAI/docs/MATH_THESIS_v5.md`

**Acceptance Criteria:**
- [ ] Notation section updated
- [ ] Math Thesis reference added
- [ ] Field notation documented

---

### Phase 2: Implementation (Day 3-4)

**CRITICAL:** Follow notebook-first development. Write code in notebooks first, then extract to Python files.

#### Step 2.1: Create Field Math Notebook

**File:** `notebooks/math/field_math_implementation.ipynb`

**Purpose:** Implement all Math Thesis-aligned sub-equations in notebook first

**Code Snippet (Notebook Cells):**

```python
# Cell 1: Imports
import numpy as np
from typing import Dict, Any, List, Tuple
from scipy.fft import fft, ifft
import json
from pathlib import Path

# Cell 2: Setup
FIELD_DIM = 1024
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

# Cell 3: Intent Understanding Score I(Ψ_i)
def compute_intent_score(psi_i: np.ndarray, use_high_freq: bool = True) -> float:
    """
    Compute intent understanding score I(Ψ_i).
    
    Implements Def. 1.3 (matched filter) or Def. 1.4 (high-frequency modes).
    
    Reference: CAIO/docs/math/MATH_THESIS_ALIGNMENT.md Section 3.1
    Math Thesis Section 4.1 (Matched Filter Optimality)
    """
    if use_high_freq:
        # Def. 1.4: High-frequency mode extraction
        # I(Ψ_i) = ||Π_high Ψ_i||²
        psi_i_fft = fft(psi_i, norm='ortho')
        omega_cutoff = len(psi_i) // 2  # High-frequency cutoff
        high_freq_mask = np.zeros_like(psi_i_fft)
        high_freq_mask[omega_cutoff:] = 1.0
        psi_i_high = ifft(psi_i_fft * high_freq_mask, norm='ortho')
        return float(np.linalg.norm(psi_i_high) ** 2)
    else:
        # Def. 1.3: Matched filter energy
        # I(Ψ_i) = ||E_i^H Ψ_i||²
        return float(np.linalg.norm(psi_i) ** 2)

# Cell 4: Attention-Weighted Context Score A(Ψ_i, C)
def compute_attention_score(
    psi_i: np.ndarray,
    context: Dict[str, Any],
    encode_context_fn: callable
) -> float:
    """
    Compute attention-weighted context score A(Ψ_i, C).
    
    Implements Def. 1.5 (normalized inner product).
    
    Reference: CAIO/docs/math/MATH_THESIS_ALIGNMENT.md Section 3.2
    Math Thesis Section 3.1 (Inner Product Structure)
    """
    # Encode context to field space
    psi_c = encode_context_fn(context)
    
    # Compute normalized inner product (cosine similarity)
    inner_product = np.vdot(psi_c, psi_i)  # ⟨Ψ_i, E_C(C)⟩
    norm_i = np.linalg.norm(psi_i)
    norm_c = np.linalg.norm(psi_c)
    
    if norm_i == 0 or norm_c == 0:
        return 0.0
    
    # A(Ψ_i, C) = ⟨Ψ_i, E_C(C)⟩ / (||Ψ_i||₂ · ||E_C(C)||₂)
    return float(inner_product / (norm_i * norm_c))

# Cell 5: RL Policy Score RL(Ψ_i, M)
def compute_rl_score(
    psi_i: np.ndarray,
    marketplace: List[Dict[str, Any]],
    encode_marketplace_fn: callable,
    use_q_function: bool = False,
    q_function: callable = None
) -> Tuple[float, Dict[str, Any]]:
    """
    Compute RL policy score RL(Ψ_i, M).
    
    Implements Def. 1.6 (Q-function) or Def. 1.7 (matched filter).
    
    Reference: CAIO/docs/math/MATH_THESIS_ALIGNMENT.md Section 3.3
    MAIA Intent Calculus: MAIA(q, H) = VEE_Classify(q, H, θ)
    """
    if use_q_function and q_function is not None:
        # Def. 1.6: RL Q-function
        # RL(Ψ_i, M) = max_{m ∈ M} Q(encode(Ψ_i), m, θ)
        encoded_intent = encode_intent_for_rl(psi_i)
        scores = [
            (q_function(encoded_intent, m, None), m)
            for m in marketplace
        ]
        max_score, best_service = max(scores, key=lambda x: x[0])
        return float(max_score), best_service
    else:
        # Def. 1.7: Matched filter correlation
        # RL(Ψ_i, M) = max_{m ∈ M} ⟨Ψ_i, E_m(m)⟩ / (||Ψ_i||₂ · ||E_m(m)||₂)
        norm_i = np.linalg.norm(psi_i)
        if norm_i == 0:
            return 0.0, marketplace[0] if marketplace else None
        
        scores = []
        for m in marketplace:
            psi_m = encode_marketplace_fn(m)
            inner_product = np.vdot(psi_m, psi_i)
            norm_m = np.linalg.norm(psi_m)
            if norm_m > 0:
                score = inner_product / (norm_i * norm_m)
                scores.append((float(score), m))
        
        if not scores:
            return 0.0, marketplace[0] if marketplace else None
        
        max_score, best_service = max(scores, key=lambda x: x[0])
        return max_score, best_service

# Cell 6: Field Resonance Score W(Ψ_i, Ψ_RFS)
def compute_resonance_score(
    psi_i: np.ndarray,
    psi_rfs: np.ndarray,
    use_q_metric: bool = False
) -> float:
    """
    Compute field resonance score W(Ψ_i, Ψ_RFS).
    
    Implements Def. 1.1 (normalized correlation) or Def. 1.2 (Q metric).
    
    Reference: CAIO/docs/math/MATH_THESIS_ALIGNMENT.md Section 3.4
    Math Thesis Section 3.2 (Resonance Quality)
    Math Thesis INV-0003: Q ≥ 6 dB for reliable retrieval
    """
    if use_q_metric:
        # Def. 1.2: RFS resonance quality Q (dB)
        # W(Ψ_i, Ψ_RFS) = 20 log₁₀(peak/background)
        correlation = np.vdot(psi_rfs, psi_i)
        correlation_magnitude = np.abs(correlation)
        
        # Compute peak and background
        peak = correlation_magnitude
        background = np.linalg.norm(psi_i) * np.linalg.norm(psi_rfs) / len(psi_i)
        
        if background > 0:
            q_db = 20 * np.log10(peak / background)
            return float(q_db)
        else:
            return 0.0
    else:
        # Def. 1.1: Normalized correlation (cosine similarity)
        # W(Ψ_i, Ψ_RFS) = ⟨Ψ_i, Ψ_RFS⟩ / (||Ψ_i||₂ · ||Ψ_RFS||₂)
        inner_product = np.vdot(psi_rfs, psi_i)
        norm_i = np.linalg.norm(psi_i)
        norm_rfs = np.linalg.norm(psi_rfs)
        
        if norm_i == 0 or norm_rfs == 0:
            return 0.0
        
        return float(inner_product / (norm_i * norm_rfs))

# Cell 7: Field Mode Extraction
def extract_field_modes(
    psi: np.ndarray,
    frequency_band: str = "high",
    omega_cutoff: int = None
) -> np.ndarray:
    """
    Extract field modes using Math Thesis projector structure.
    
    Implements Def. 1.8 (field mode extraction).
    
    Reference: CAIO/docs/math/MATH_THESIS_ALIGNMENT.md Section 4
    Math Thesis Section 3.5 (Projector Structure)
    """
    D = len(psi)
    if omega_cutoff is None:
        omega_cutoff = D // 2 if frequency_band == "high" else D // 4
    
    # Math Thesis projector: Π = ℱ⁻¹ · M_passband · ℱ
    psi_fft = fft(psi, norm='ortho')
    
    # Create frequency mask
    mask = np.zeros_like(psi_fft)
    if frequency_band == "high":
        mask[omega_cutoff:] = 1.0
    else:
        mask[:omega_cutoff] = 1.0
    
    # Apply projector
    psi_filtered_fft = psi_fft * mask
    psi_filtered = ifft(psi_filtered_fft, norm='ortho')
    
    return psi_filtered

# Cell 8: Conductivity Metric
def compute_conductivity(psi: np.ndarray, projector_mask: np.ndarray) -> float:
    """
    Compute projector conductivity κ(ψ).
    
    Implements Math Thesis Definition 1 (Conductivity).
    
    Reference: Math Thesis Section 3.5, Definition 1
    Math Thesis INV-0018: κ ≥ 0.95 for signal integrity
    """
    # Apply projector
    psi_fft = fft(psi, norm='ortho')
    psi_projected_fft = psi_fft * projector_mask
    psi_projected = ifft(psi_projected_fft, norm='ortho')
    
    # κ(ψ) = ||Π·ψ||₂ / ||ψ||₂
    norm_projected = np.linalg.norm(psi_projected)
    norm_original = np.linalg.norm(psi)
    
    if norm_original == 0:
        return 0.0
    
    return float(norm_projected / norm_original)

# Cell 9: Context Encoding Helper
def encode_context_to_field(context: Dict[str, Any], field_dim: int) -> np.ndarray:
    """
    Encode context to field space using Math Thesis encoding operator.
    
    Reference: Math Thesis Section 3.4 (Encoding Operator)
    """
    # Simplified encoding: convert context to vector, then encode
    context_vector = np.array([
        float(context.get("conversation_length", 0)),
        float(context.get("user_trust_level", 0)),
        float(context.get("priority", 0)),
    ])
    
    # Pad or truncate to field dimension
    if len(context_vector) < field_dim:
        context_vector = np.pad(context_vector, (0, field_dim - len(context_vector)))
    else:
        context_vector = context_vector[:field_dim]
    
    # Apply Math Thesis encoding: E(w) = ℱ⁻¹(M ⊙ ℱ(H·w))
    H_w = context_vector
    w_fft = fft(H_w, norm='ortho')
    
    # Phase mask (unit modulus)
    phase_mask = np.exp(1j * np.random.uniform(0, 2*np.pi, len(w_fft)))
    w_fft_masked = w_fft * phase_mask
    
    encoded = ifft(w_fft_masked, norm='ortho')
    
    return encoded

# Cell 10: Intent Encoding for RL
def encode_intent_for_rl(psi_i: np.ndarray) -> np.ndarray:
    """
    Encode intent field for RL Q-function.
    """
    # Extract real-valued features from complex field
    return np.concatenate([
        np.real(psi_i),
        np.imag(psi_i),
        [np.linalg.norm(psi_i)]
    ])

# Cell 11: VERIFY - Test All Functions
# Test with sample data
psi_i_test = np.random.randn(FIELD_DIM) + 1j * np.random.randn(FIELD_DIM)
psi_i_test = psi_i_test / np.linalg.norm(psi_i_test)
psi_rfs_test = np.random.randn(FIELD_DIM) + 1j * np.random.randn(FIELD_DIM)
psi_rfs_test = psi_rfs_test / np.linalg.norm(psi_rfs_test)

I_score = compute_intent_score(psi_i_test, use_high_freq=True)
print(f"I(Ψ_i): {I_score:.6f}")

context_test = {"conversation_length": 10, "user_trust_level": 5, "priority": 1.0}
A_score = compute_attention_score(psi_i_test, context_test, lambda c: encode_context_to_field(c, FIELD_DIM))
print(f"A(Ψ_i, C): {A_score:.6f}")

marketplace_test = [{"service_id": "service_1"}, {"service_id": "service_2"}]
RL_score, best = compute_rl_score(psi_i_test, marketplace_test, lambda m: encode_context_to_field(m, FIELD_DIM))
print(f"RL(Ψ_i, M): {RL_score:.6f}, best: {best}")

W_score = compute_resonance_score(psi_i_test, psi_rfs_test, use_q_metric=False)
print(f"W(Ψ_i, Ψ_RFS): {W_score:.6f}")

# Cell 12: Export Artifact
results = {
    "intent_score": float(I_score),
    "attention_score": float(A_score),
    "rl_score": float(RL_score),
    "resonance_score": float(W_score),
    "field_dim": FIELD_DIM,
    "seed": RANDOM_SEED
}

artifact_path = Path("configs/generated/field_math_implementation.json")
artifact_path.parent.mkdir(parents=True, exist_ok=True)
artifact_path.write_text(json.dumps(results, indent=2))
print(f"✅ Artifact exported: {artifact_path}")
```

**Acceptance Criteria:**
- [ ] Notebook created at `notebooks/math/field_math_implementation.ipynb`
- [ ] All sub-equation functions implemented
- [ ] VERIFY cell with test assertions
- [ ] Artifact JSON exported
- [ ] Notebook runs successfully

---

#### Step 2.2: Extract Code from Notebook

**Command:**
```bash
python scripts/notebooks/extract_code.py \
    --notebook notebooks/math/field_math_implementation.ipynb \
    --output caio/orchestrator/field_math.py \
    --functions compute_intent_score compute_attention_score compute_rl_score compute_resonance_score extract_field_modes compute_conductivity encode_context_to_field encode_intent_for_rl
```

**Acceptance Criteria:**
- [ ] Code extracted to `caio/orchestrator/field_math.py`
- [ ] All functions present
- [ ] Type hints and docstrings preserved
- [ ] Imports correct

---

#### Step 2.3: Integrate Field Math into Orchestrator

**File:** `caio/orchestrator/routing.py` (or appropriate file)

**Purpose:** Integrate field math functions into routing decision logic

**Code Snippet:**

```python
"""
Integration of Math Thesis-aligned field math into orchestrator routing.

Reference: CAIO/docs/math/MATH_THESIS_ALIGNMENT.md
"""

from caio.orchestrator.field_math import (
    compute_intent_score,
    compute_attention_score,
    compute_rl_score,
    compute_resonance_score,
    extract_field_modes,
    encode_context_to_field,
)


def compute_master_equation_objective(
    psi_i: np.ndarray,
    psi_t: np.ndarray,
    psi_rfs: np.ndarray,
    context: Dict[str, Any],
    marketplace: List[Dict[str, Any]],
    weights: Dict[str, float],
    field_dim: int = 1024
) -> float:
    """
    Compute CAIO master equation objective value.
    
    Implements:
    (a^*, u^*, m^*) = argmax [α·I(Ψ_i) + β·A(Ψ_i, C) + γ·RL(Ψ_i, M) + δ·W(Ψ_i, Ψ_RFS) - ...]
    
    Reference:
        CAIO/docs/math/CAIO_MASTER_CALCULUS.md Section 1.1
        CAIO/docs/math/MATH_THESIS_ALIGNMENT.md Section 2
    """
    # Extract field modes
    intent_modes = extract_field_modes(psi_i, frequency_band="high")
    trait_modes = extract_field_modes(psi_t, frequency_band="low")
    
    # Compute sub-equations
    I_score = compute_intent_score(psi_i, use_high_freq=True)
    
    A_score = compute_attention_score(
        psi_i,
        context,
        lambda c: encode_context_to_field(c, field_dim)
    )
    
    RL_score, _ = compute_rl_score(
        psi_i,
        marketplace,
        lambda m: encode_context_to_field(m, field_dim),
        use_q_function=False
    )
    
    W_score = compute_resonance_score(psi_i, psi_rfs, use_q_metric=False)
    
    # Compute objective (positive terms)
    objective = (
        weights.get('alpha', 1.0) * I_score +
        weights.get('beta', 1.0) * A_score +
        weights.get('gamma', 1.0) * RL_score +
        weights.get('delta', 1.0) * W_score
    )
    
    return objective
```

**Acceptance Criteria:**
- [ ] Field math functions imported
- [ ] `compute_master_equation_objective` function added
- [ ] Integration with existing routing logic
- [ ] Backward compatibility maintained

---

### Phase 3: Validation (Day 5)

#### Step 3.1: Create Validation Notebook

**File:** `notebooks/math/math_thesis_alignment_validation.ipynb`

**Purpose:** Validate all Math Thesis alignments

**Reference:** See `docs/operations/MATH_THESIS_IMPLEMENTATION_PLAN.md` Section 3.1 for complete notebook code.

**Key Tests:**
1. Intent Understanding Score I(Ψ_i) - positive energy
2. Attention-Weighted Context Score A(Ψ_i, C) - range [-1, 1]
3. RL Policy Score RL(Ψ_i, M) - range [-1, 1]
4. Field Resonance Score W(Ψ_i, Ψ_RFS) - correlation range, Q ≥ 6 dB
5. Field Mode Extraction - energy preservation
6. Conductivity Metric - range [0, 1]
7. Energy Conservation - Parseval's theorem

**Acceptance Criteria:**
- [ ] Notebook created
- [ ] All 7 tests implemented
- [ ] Validation artifact generated
- [ ] Math Thesis invariant checks included
- [ ] Energy conservation validated

---

#### Step 3.2: Create Performance Benchmark

**File:** `notebooks/math/math_thesis_performance_benchmark.ipynb`

**Purpose:** Benchmark performance of Math Thesis-aligned functions

**Reference:** See `docs/operations/MATH_THESIS_IMPLEMENTATION_PLAN.md` Section 3.2 for complete notebook code.

**Performance Targets:**
- `I(Ψ_i)`: < 5 ms (p50) for D=1024
- `A(Ψ_i, C)`: < 3 ms (p50) for D=1024
- `RL(Ψ_i, M)`: < 10 ms (p50) for D=1024
- `W(Ψ_i, Ψ_RFS)`: < 2 ms (p50) for D=1024
- `extract_field_modes`: < 5 ms (p50) for D=1024

**Acceptance Criteria:**
- [ ] Benchmark notebook created
- [ ] Performance metrics collected
- [ ] Scalability analysis included
- [ ] Performance targets defined
- [ ] Benchmark artifact generated

---

## Validation Procedures

### Pre-Implementation Validation

1. **Read Required Documents:**
   - [ ] `docs/math/MATH_THESIS_ALIGNMENT.md` - Understand all definitions
   - [ ] `docs/operations/MATH_THESIS_IMPLEMENTATION_PLAN.md` - Understand implementation plan
   - [ ] `TAI/docs/MATH_THESIS_v5.md` - Understand Math Thesis framework
   - [ ] `docs/math/CAIO_MASTER_CALCULUS.md` - Understand current state

2. **Verify Math Thesis Alignment:**
   - [ ] All field states use `ℂ^D` (Hilbert space)
   - [ ] All operators use Math Thesis structure
   - [ ] Energy conservation via Parseval's theorem
   - [ ] Math Thesis invariants referenced correctly

### Post-Implementation Validation

1. **Run Validation Notebook:**
   ```bash
   jupyter nbconvert --to notebook --execute notebooks/math/math_thesis_alignment_validation.ipynb
   ```

2. **Run Performance Benchmark:**
   ```bash
   jupyter nbconvert --to notebook --execute notebooks/math/math_thesis_performance_benchmark.ipynb
   ```

3. **Run Unit Tests:**
   ```bash
   pytest tests/unit/test_field_math.py -v
   ```

4. **Run Integration Tests:**
   ```bash
   pytest tests/integration/test_math_thesis_integration.py -v
   ```

5. **Run MA Validation:**
   ```bash
   make ma-validate-quiet
   ```

6. **Verify Artifacts:**
   - [ ] `configs/generated/field_math_implementation.json` exists
   - [ ] `configs/generated/math_thesis_alignment_validation.json` exists
   - [ ] `configs/generated/math_thesis_performance_benchmark.json` exists
   - [ ] No NaN/Inf values in artifacts

---

## Troubleshooting Guide

### Issue: Notebook Import Errors

**Problem:** Notebook tries to import from codebase

**Solution:** Notebooks must contain implementation code directly (notebook-first). Remove any `from caio.` imports and copy implementation code into notebook cells.

**Reference:** `.cursor/rules/notebook-first-mandatory.mdc`

---

### Issue: Energy Conservation Violations

**Problem:** Parseval's theorem not satisfied

**Solution:** Ensure all FFT operations use `norm='ortho'` (unitary FFT). Check encoding operators preserve energy.

**Reference:** Math Thesis Theorem 2, INV-0001

---

### Issue: Math Thesis Invariant Failures

**Problem:** INV-0003 (Q ≥ 6 dB) fails

**Solution:** Check resonance score computation. Ensure peak/background calculation is correct. Verify field states are properly normalized.

**Reference:** Math Thesis INV-0003, `MATH_THESIS_ALIGNMENT.md` Section 3.4

---

### Issue: Performance Targets Not Met

**Problem:** Functions slower than targets

**Solution:** Profile FFT operations. Consider GPU acceleration (Metal) if available. Cache field encodings where possible.

**Reference:** `MATH_THESIS_IMPLEMENTATION_PLAN.md` Section 2 (Performance Metrics)

---

## Success Criteria

### Mathematical Completeness

- [ ] All four sub-equations (`I`, `A`, `RL`, `W`) have formal definitions in `CAIO_MASTER_CALCULUS.md`
- [ ] All definitions reference Math Thesis framework
- [ ] All definitions use Math Thesis operators (`E`, `E^H`, `Π`, `⟨·,·⟩`)
- [ ] Energy conservation explicitly documented

### Implementation Completeness

- [ ] All sub-equation functions implemented in `field_math.py`
- [ ] Functions integrated into orchestrator routing
- [ ] Backward compatibility maintained
- [ ] Performance targets met

### Validation Completeness

- [ ] Validation notebook passes all tests
- [ ] Performance benchmark completes successfully
- [ ] Math Thesis invariant checks pass
- [ ] Energy conservation validated
- [ ] `make ma-validate-quiet` passes

### Documentation Completeness

- [ ] All sections added to `CAIO_MASTER_CALCULUS.md`
- [ ] Cross-references to Math Thesis included
- [ ] Code snippets documented
- [ ] Performance metrics documented

---

## Notes and References

**Key Documents:**
- **Math Thesis Alignment:** `docs/math/MATH_THESIS_ALIGNMENT.md`
- **Implementation Plan:** `docs/operations/MATH_THESIS_IMPLEMENTATION_PLAN.md`
- **Math Thesis:** `TAI/docs/MATH_THESIS_v5.md`
- **CAIO Master Calculus:** `docs/math/CAIO_MASTER_CALCULUS.md`
- **North Star:** `docs/NORTH_STAR.md`

**Key Rules:**
- **Notebook-First Development:** `.cursor/rules/notebook-first-mandatory.mdc`
- **MA Process:** `docs/operations/MA_PROCESS_MANDATORY_RULE.md`
- **Agent Workflow:** `.cursor/rules/agent-workflow-mandatory.mdc`

**Code Extraction:**
- Script: `scripts/notebooks/extract_code.py`
- Usage: `python scripts/notebooks/extract_code.py --notebook <notebook> --output <file> --functions <functions>`

---

**Status:** Ready for Implementation  
**Next Step:** Begin Phase 1 (Document Updates)


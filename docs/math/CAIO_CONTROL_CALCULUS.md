# CAIO Control Calculus

**Status:** Rev 1.0  
**Last Updated:** 2025-01-XX  
**Owner:** @smarthaus  
**Source of Truth:** `docs/NORTH_STAR.md`  
**Audience:** CAIO Engineering / Research

This document formalizes the control calculus for CAIO - the mathematical control plane that converts MAIA's intent field measurements into concrete routing decisions, model selection, and control signals.

---

## 0. Reader's Guide and Notation

**Notation & conventions**

- State: `s_t = [modes(Π_high Ψ_i), modes(Π_low Ψ_t), C, M, RFS_metrics]`
- Action: `a_t ∈ A` (route, model, tool invocations)
- Control signal: `u(t) ∈ ℝ^k` (mode excitation/damping for MAIA)
- Constraints: `G_safety, G_policy, G_traits` (safety/policy/trait constraints)
- Intent field: `Ψ_i ∈ ℂ^D` (from MAIA)
- Trait field: `Ψ_t ∈ ℂ^D` (from NME)
- RFS field: `Ψ_RFS ∈ ℂ^D` (memory substrate)

---

## 1. Purpose and Role

### 1.1 CAIO as Control Plane

CAIO sits **in the middle** of the cognitive system:

- **Upstream**: Reads MAIA intent field `Ψ_i`, NME trait field `Ψ_t`, RFS memory field `Ψ_RFS`
- **Downstream**: Drives VFE model selection, tool invocations, RFS operations
- **Control loop**: Generates control signal `u(t)` that feeds back to MAIA

**Core function:**

Convert field state → executable plan (routing, model, params, budgets)

### 1.2 Control Objectives

**Primary objectives:**

1. **Optimal routing**: Select best route (internal/external/hybrid)
2. **Model selection**: Choose optimal model/service via VFE calculus
3. **Resource management**: Enforce cost/latency/budget constraints
4. **Safety enforcement**: Ensure safety/policy/trait constraints satisfied
5. **Control feedback**: Generate `u(t)` to shape MAIA intent field

---

## 2. Master Control Equation

### 2.1 Control Objective

**Equation (Eq. 2.1):**

```math
(a^*, u^*, m^*) = argmax_{a,u,m} [α·I(Ψ_i) + β·A(Ψ_i, C) + γ·RL(Ψ_i, M) + δ·W(Ψ_i, Ψ_RFS) - λ·Cost - ρ·Risk - η·Latency]
```

Subject to constraints:

```math
G_safety(a) ≤ 0
G_policy(a, m) ≤ 0
G_traits(Ψ_t, a) ≤ 0
G_budget(Cost) ≤ 0
G_latency(Latency) ≤ 0
```

Where:
- `I(Ψ_i)`: Intent understanding score (from MAIA)
- `A(Ψ_i, C)`: Attention-weighted context score (from MAIA)
- `RL(Ψ_i, M)`: RL policy score (from MAIA)
- `W(Ψ_i, Ψ_RFS)`: Wave/field resonance score (from MAIA)
- `Cost`: Resource cost (model cost, API cost, compute cost)
- `Risk`: Risk score (safety, privacy, alignment)
- `Latency`: Expected latency (model latency, network latency)

### 2.2 State Definition

**Definition (Def. 2.1):**

Control state:

```math
s_t = [modes(Π_high Ψ_i), modes(Π_low Ψ_t), C, M, RFS_metrics]
```

Where:
- `modes(Π_high Ψ_i)`: High-frequency intent field modes (from MAIA)
- `modes(Π_low Ψ_t)`: Low-frequency trait field modes (from NME)
- `C`: Context (conversation history, user profile, constraints)
- `M`: Marketplace (available services/models/tools)
- `RFS_metrics`: RFS field metrics (resonance Q, recall error, energy budget)

---

## 3. Constraint Functions

### 3.1 Safety Constraints

**Definition (Def. 3.1):**

Safety constraints:

```math
G_safety(a) = [G_forbidden(a), G_harmful(a), G_unsafe(a)]
```

Where:
- `G_forbidden(a)`: Forbidden actions (must be ≤ 0)
- `G_harmful(a)`: Harmful content detection (must be ≤ 0)
- `G_unsafe(a)`: Unsafe operations (must be ≤ 0)

**Invariant (INV-CAIO-SAFETY-0001):**

```math
G_safety(a^*) ≤ 0
```

Selected action must satisfy all safety constraints.

### 3.2 Policy Constraints

**Definition (Def. 3.2):**

Policy constraints:

```math
G_policy(a, m) = [G_on_device(a, m), G_privacy(a, m), G_compliance(a, m)]
```

Where:
- `G_on_device(a, m)`: On-device processing requirement (must be ≤ 0 if required)
- `G_privacy(a, m)`: Privacy preservation requirement (must be ≤ 0 if required)
- `G_compliance(a, m)`: Regulatory compliance requirement (must be ≤ 0 if required)

**Invariant (INV-CAIO-POLICY-0001):**

```math
G_policy(a^*, m^*) ≤ 0
```

Selected action and model must satisfy all policy constraints.

### 3.3 Trait Constraints

**Definition (Def. 3.3):**

Trait constraints from NME:

```math
G_traits(Ψ_t, a) = [G_conservative(Ψ_t, a), G_confidential(Ψ_t, a), G_risk_tolerance(Ψ_t, a)]
```

Where:
- `G_conservative(Ψ_t, a)`: Conservative trait constraint (must be ≤ 0 if trait requires)
- `G_confidential(Ψ_t, a)`: Confidentiality trait constraint (must be ≤ 0 if trait requires)
- `G_risk_tolerance(Ψ_t, a)`: Risk tolerance trait constraint (must be ≤ 0 if trait requires)

**Invariant (INV-CAIO-TRAITS-0001):**

```math
G_traits(Ψ_t, a^*) ≤ 0
```

Selected action must satisfy trait constraints from NME.

---

## 4. Control Signal Generation

### 4.1 Control Signal Definition

**Definition (Def. 4.1):**

Control signal `u(t)` excites or damps MAIA intent field modes:

```math
u(t) = [u₁(t), u₂(t), ..., u_k(t)]^T
```

Where each `u_j(t)` controls mode `j` amplitude.

### 4.2 Control Signal Computation

**Equation (Eq. 4.1):**

Control signal computed from decision:

```math
u(t) = GenerateControlSignal(a^*, modes(Ψ_i), modes(Ψ_t))
```

**Control strategies:**

1. **Mode excitation**: `u_j(t) > 0` amplifies mode `j` (e.g., long-term planning)
2. **Mode damping**: `u_j(t) < 0` dampens mode `j` (e.g., impulsive intent)
3. **Mode bias**: `u_j(t)` biases toward certain intent patterns

### 4.3 Control Signal Feedback

**Equation (Eq. 4.2):**

Control signal feeds back to MAIA:

```math
MAIA: ∂²Ψ_i/∂t² + γ_i ∂Ψ_i/∂t = ... + B_i u(t)
```

Where `B_i` is MAIA control input matrix.

---

## 5. Model Selection Integration

### 5.1 VFE Model Selection

**Equation (Eq. 5.1):**

CAIO uses VFE model selection calculus:

```math
m^* = VFE_Select(s_t, M) = argmax_m [w_comp·C(m) - w_cost·$/tok(m) + w_align·A(m) - w_overflow·Ω(m)]
```

Subject to CAIO constraints:

```math
G_policy(a^*, m) ≤ 0
G_budget(Cost(m)) ≤ 0
```

### 5.2 Model Selection Traceability

**Invariant (INV-CAIO-MODEL-0001):**

Model selection must be traceable:

- Which models were considered
- Why `m^*` was selected
- How VFE calculus was applied
- How constraints were satisfied

---

## 6. Resource Management

### 6.1 Cost Function

**Definition (Def. 6.1):**

Cost function:

```math
Cost(m, a) = Cost_model(m) + Cost_api(a) + Cost_compute(a)
```

Where:
- `Cost_model(m)`: Model inference cost (`$/tok`)
- `Cost_api(a)`: API call cost (external services)
- `Cost_compute(a)`: Compute resource cost (CPU/GPU time)

### 6.2 Budget Constraints

**Definition (Def. 6.2):**

Budget constraint:

```math
G_budget(Cost) = Cost(m, a) - Budget_max
```

**Invariant (INV-CAIO-BUDGET-0001):**

```math
G_budget(Cost(m^*, a^*)) ≤ 0
```

Selected action must respect budget.

### 6.3 Latency Constraints

**Definition (Def. 6.3):**

Latency constraint:

```math
G_latency(Latency) = Latency(m, a) - Latency_max
```

**Invariant (INV-CAIO-LATENCY-0001):**

```math
G_latency(Latency(m^*, a^*)) ≤ 0
```

Selected action must respect latency budget.

---

## 7. Optimization Algorithm

### 7.1 Constrained Optimization

**Equation (Eq. 7.1):**

CAIO solves constrained optimization:

```math
(a^*, u^*, m^*) = argmax_{a,u,m} Objective(s_t, a, u, m)
```

Subject to:

```math
G_safety(a) ≤ 0
G_policy(a, m) ≤ 0
G_traits(Ψ_t, a) ≤ 0
G_budget(Cost(m, a)) ≤ 0
G_latency(Latency(m, a)) ≤ 0
```

### 7.2 Optimization Methods

**Methods:**

1. **Linear programming**: If objective/constraints are linear
2. **Quadratic programming**: If objective is quadratic
3. **Interior point methods**: For general nonlinear constraints
4. **Heuristic search**: For discrete action spaces

**Complexity:**

- Contract matching: `O(|R| · |Requirements|)`
- Constraint evaluation: `O(|P| · |candidates|)`
- Optimization: `O(|candidates| · |M| · log(|candidates|))`

---

## 8. Traceability and Explainability

### 8.1 Decision Trace

**Definition (Def. 8.1):**

Every decision generates trace:

```json
{
  "state": s_t,
  "decision": (a^*, u^*, m^*),
  "objective_value": Objective(s_t, a^*, u^*, m^*),
  "constraints": {
    "safety": G_safety(a^*),
    "policy": G_policy(a^*, m^*),
    "traits": G_traits(Ψ_t, a^*),
    "budget": G_budget(Cost(m^*, a^*)),
    "latency": G_latency(Latency(m^*, a^*))
  },
  "field_snapshots": {
    "intent_modes": modes(Π_high Ψ_i),
    "trait_modes": modes(Π_low Ψ_t)
  },
  "proofs": {
    "contract_matching": proof_contract,
    "rule_satisfaction": proof_rules,
    "security": proof_security,
    "optimization": proof_optimization
  },
  "hash": Hash(s_t, a^*, u^*, m^*),
  "timestamp": now()
}
```

### 8.2 Explainability

**Invariant (INV-CAIO-TRACE-0001):**

Every decision must be explainable:

- Why route `a^*` was selected
- Why model `m^*` was chosen
- Why control signal `u^*` was generated
- How constraints were satisfied
- How field state influenced decision

---

## 9. Invariants

### 9.1 Safety Invariant

**Invariant (INV-CAIO-SAFETY-0001):**

```math
G_safety(a^*) ≤ 0
```

Selected action must satisfy all safety constraints.

### 9.2 Policy Invariant

**Invariant (INV-CAIO-POLICY-0001):**

```math
G_policy(a^*, m^*) ≤ 0
```

Selected action and model must satisfy all policy constraints.

### 9.3 Trait Invariant

**Invariant (INV-CAIO-TRAITS-0001):**

```math
G_traits(Ψ_t, a^*) ≤ 0
```

Selected action must satisfy trait constraints.

### 9.4 Budget Invariant

**Invariant (INV-CAIO-BUDGET-0001):**

```math
G_budget(Cost(m^*, a^*)) ≤ 0
```

Selected action must respect budget.

### 9.5 Determinism Invariant

**Invariant (INV-CAIO-0001):**

```math
CAIO(s_t, R, P, H, seed) = CAIO(s_t, R, P, H, seed)
```

Same state → same decision (deterministic).

---

## 10. References

- **Master Calculus**: `docs/math/CAIO_MASTER_CALCULUS.md`
- **North Star**: `docs/NORTH_STAR.md` §2 Mathematical Foundation
- **MAIA Master Calculus**: `MAIA/docs/math/MAIA_MASTER_CALCULUS.md`
- **NME Master Calculus**: `NotaMemoriaEngine/docs/math/NME_MASTER_CALCULUS.md`
- **VFE Master Calculus**: `VerbumFieldEngine/docs/math/VFE_MASTER_CALCULUS.md`

---

## 11. Validation

**Verification notebooks:**

- `notebooks/math/caio_control_validation.ipynb`: Control decision validation
- `notebooks/math/caio_policy_constraints.ipynb`: Policy constraint validation
- `notebooks/math/caio_trait_constraints.ipynb`: Trait constraint validation

**Artifacts:**

- `configs/generated/caio_policy_bounds.json`: Policy constraint bounds
- `configs/generated/caio_control_traceability.json`: Control traceability logs


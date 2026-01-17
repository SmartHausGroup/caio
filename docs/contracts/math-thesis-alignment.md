# Contract Math Thesis Alignment Guide

**Status:** Complete  
**Date:** 2026-01-14  
**Plan Reference:** `plan:contract-math-thesis-alignment:contract-verification`  
**North Star Alignment:** Mathematical Guarantees, Contract-Based Discovery  

---

## Purpose

This guide documents how CAIO service contracts encode the mathematical guarantees defined in the
math thesis (`docs/MATH_THESIS_v5.md`) and how to verify alignment between the contract schema and
those guarantees. It complements the deeper gap analysis in
`docs/contracts/CONTRACT_MATH_THESIS_ALIGNMENT.md` and focuses on the current, aligned state.

---

## Source Documents

- **Math Thesis:** `docs/MATH_THESIS_v5.md`
- **Contract Schema:** `configs/schemas/service_contract.schema.yaml`
- **Example Contract:** `configs/schemas/service_contract_math_thesis.example.yaml`
- **Guarantee Enforcement:** `caio/guarantees/enforcer.py`

---

## Contract Field Mapping (Schema → Math Thesis)

| Schema Section | Purpose | Math Thesis Link |
|---------------|---------|------------------|
| `service.guarantees` | Declares measurable guarantees with bounds and invariant IDs | Guarantees and falsifiability requirements |
| `service.invariants` | Encodes invariant formulas, thresholds, and verification artifacts | Invariant definitions + verification linkage |
| `service.capabilities` | Lists service functions and operational targets | Capability requirements for routing |
| `service.constraints` | Defines operational limits | Boundaries for validity of guarantees |
| `service.api` | Declares service endpoints/protocols | Verification location for runtime checks |

---

## Math Thesis Guarantees → Contract Encoding

| Math Thesis Guarantee | Contract Guarantee Type | Bound Structure | Invariant ID |
|-----------------------|-------------------------|----------------|--------------|
| Energy preservation | `energy_conservation` | `type: equality`, `formula`, `max_deviation` | `INV-0001` |
| Resonance quality | `resonance_quality` | `type: min`, `min`, `unit: dB` | `INV-0003` |
| Bounded interference | `interference` | `type: relative_max`, `formula`, `max_ratio` | `INV-0005` |
| Conductivity in-band | `conductivity` | `type: min`, `min` | `INV-0018` |
| Capacity margin | `capacity_margin` | `type: min_multiple`, `min_multiple` | `INV-0010` |
| AEAD exact recall | `aead_exact_recall` | `type: equality|max`, `value` | `INV-0011` |
| PDE stability | `pde_stability` | `type: max`, `max` | `INV-0007` |

---

## Alignment Mechanisms (What Makes It Work)

1. **Guarantee Types:** The schema exposes a dedicated guarantee type for each math thesis
   guarantee, allowing direct encoding of formulas and bounds.
2. **Structured Bounds:** `bound` objects support equality, min, max, relative max, and
   min-multiple encodings, matching the math thesis falsifiability requirements.
3. **Invariant Linkage:** Each guarantee and invariant declares an `invariant` ID and
   `math_thesis_reference` for traceability back to the thesis.
4. **Verification Types:** Invariants can specify `verification` with explicit types
   (`notebook`, `telemetry`, `ci_gate`, `artifact`) and update frequency.
5. **Artifact Checks:** The `artifact` structure supports assertion strings that match
   notebook/CI checks for falsifiability (e.g., `energy_deviation <= 1e-12`).

---

## Verification Procedures

1. **Schema Review**
   - Confirm all math thesis guarantees appear under `service.guarantees`.
   - Validate bound types align with the math thesis thresholds.
2. **Invariant Review**
   - Ensure each invariant includes `formula`, `threshold`, and `math_thesis_reference`.
   - Confirm verification resources (`verification` + `artifact`) are present and reachable.
3. **Contract Instance Review**
   - Use `configs/schemas/service_contract_math_thesis.example.yaml` as a reference contract.
   - Confirm services declare guarantees and invariants in the same structure.

---

## Alignment Status

**Result:** ✅ **Aligned**  
All math thesis guarantees can be encoded in contracts with explicit bounds, invariant linkage,
verification type, and artifact checks. No schema gaps remain for math thesis guarantees.

---

## Notes

- The alignment guide focuses on **contract encoding**; enforcement happens in the guarantee
  enforcer and verification notebooks.
- The analysis history and original gap notes remain in
  `docs/contracts/CONTRACT_MATH_THESIS_ALIGNMENT.md`.


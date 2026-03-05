# MATHS Plan: VFE Metal Backend FP16 Dequantization Fix

## Plan Metadata

- Plan ID: PLAN-VFE-METAL-DEQUANT-001
- Title: Fix FP16-to-FP32 Dequantization Bug in GGUFParser Metal Backend
- Domain: framework
- Owner: @smarthaus
- Status: active
- Last Updated: 2026-03-05

## M — Model

- Problem: Every dequantize function in `vfe-core/native/verbum/metal/GGUFParser.mm` uses `reinterpret_cast<const float*>(&scale_u16)` to convert FP16 scale values to FP32. This reads 4 bytes from a 2-byte variable (undefined behavior), producing near-zero/denormalized scales. All quantized tensor weights dequantize to garbage, causing NaN logits and token-0 output.
- User/stakeholder: SmartHaus platform — native GGUF inference on Apple Silicon is a core requirement.
- Success criteria:
  - All basic quant formats (Q4_0, Q4_1, Q5_0, Q5_1, Q8_0, Q8_1) produce correct FP32 values from known FP16 scale inputs.
  - All K-quant formats (Q2_K, Q3_K, Q4_K, Q5_K, Q6_K, Q8_K) use correct block structures per GGUF spec.
  - Unit test validates dequantization of a known Q4_0 block against reference values.
  - Metal backend compiles clean on macOS with no warnings in dequant functions.
- Constraints:
  - Fix must be in vfe-core repo (`native/verbum/metal/GGUFParser.mm`).
  - Must preserve existing NEON SIMD optimization paths.
  - Must not change public API surface (GGUFParser.hpp unchanged).
  - Correct FP16->FP32 conversion already exists at lines 792-806 in `load_tensor()` — reuse that logic.
- Non-goals:
  - Metal shader kernel changes (out of scope).
  - Performance optimization beyond fixing correctness.
  - Adding new quant format support beyond what is already declared in the enum.

## A — Annotate

- Math/contracts assumptions:
  - IEEE 754 half-precision (FP16): 1 sign bit, 5 exponent bits, 10 mantissa bits.
  - FP16 to FP32 conversion: sign preserved, exponent biased by +112 (127-15), mantissa left-shifted by 13.
  - Subnormal FP16 (exp=0): value = (-1)^sign * (mantissa/1024) * 2^(-14).
  - GGUF block structures per llama.cpp reference: Q4_0 (18 bytes/32 elements), Q4_1 (20 bytes/32), Q5_0 (22 bytes/32), Q5_1 (24 bytes/32), Q8_0 (34 bytes/32), Q8_1 (36 bytes/32).
  - K-quant block structures per llama.cpp: Q2_K (256 elements, scales+mins+quants), Q3_K (256 elements, hmask+scales+quants), Q4_K (256 elements, scales+mins+quants), Q5_K (256 elements, scales+mins+qh+quants), Q6_K (256 elements, ql+qh+scales), Q8_K (256 elements, scale as FP32 + int8 quants).
- Interfaces and dependencies:
  - `GGUFParser::dequantize_*` functions — internal, called by `dequantize_tensor()`.
  - No external API changes.
- Invariants/lemmas impacted:
  - INV-VFE-DEQUANT-001: For any valid FP16 scale s, `fp16_to_fp32(s)` must produce the IEEE 754 FP32 equivalent.
  - INV-VFE-DEQUANT-002: `dequantize_q4_0(block)` output must match llama.cpp reference implementation for the same input bytes.
- Artifacts required:
  - Updated `GGUFParser.mm` with correct dequantization.
  - Unit test file validating dequantization correctness.

## T — Tie

- Connection validation checklist:
  - [x] dependencies available (Apple toolchain, NEON intrinsics on Apple Silicon)
  - [x] environment configured (vfe-core repo accessible)
  - [x] services reachable (N/A — pure C++ code change)
  - [x] policy/governance checks pass (North Star aligned — native inference on Apple Silicon)
- Blockers: None identified.
- Go/No-Go decision: GO

## H — Harness

- Implementation phases:
  1. **H1: Add `fp16_to_fp32` helper** — Extract the correct FP16->FP32 conversion from `load_tensor()` lines 792-806 into a standalone inline helper function. Place it before the dequantize functions.
  2. **H2: Fix basic quant functions** — Replace all `reinterpret_cast<const float*>(&scale_u16)` calls with `fp16_to_fp32(scale_u16)` in: `dequantize_q4_0`, `dequantize_q4_1`, `dequantize_q5_0`, `dequantize_q5_1`, `dequantize_q8_0`, `dequantize_q8_1`. Update NEON paths to use the corrected scale.
  3. **H3: Fix K-quant functions** — Implement correct block structures for Q2_K, Q3_K, Q4_K, Q5_K, Q6_K, Q8_K per llama.cpp reference. Replace simplified/delegating implementations with proper per-sub-block scale handling.
  4. **H4: Add unit test** — Create `GGUFParserDequantTest.cpp` with known input blocks and expected output values for Q4_0 and Q8_0 at minimum.
- Files/systems touched:
  - `vfe-core/native/verbum/metal/GGUFParser.mm` (primary fix)
  - `vfe-core/native/verbum/metal/tests/GGUFParserDequantTest.cpp` (new test)
- Notebook-first extraction notes: N/A — this is a C++ bugfix in existing code, not math/algorithm development. The fix is deterministic (IEEE 754 spec compliance).

## S — Stress-test

- Functional test plan:
  - Compile GGUFParser.mm with no warnings on macOS ARM64.
  - Run dequant unit test: known Q4_0 block with FP16 scale 0x3C00 (1.0) must produce expected output values.
  - Run dequant unit test: known Q8_0 block with FP16 scale 0x3800 (0.5) must produce expected output values.
  - Run existing GGUFParserSmoke test against a real GGUF model file.
- Edge case plan:
  - FP16 subnormal scale (exp=0, mantissa!=0) — must not produce 0.
  - FP16 zero (0x0000) — must produce 0.0f.
  - FP16 negative scale (sign bit set) — must produce negative float.
  - FP16 infinity (0x7C00) — must produce INFINITY.
  - FP16 NaN (0x7E00) — must produce NAN.
- Determinism/replay plan: N/A — IEEE 754 conversion is deterministic by definition.
- Gate criteria:
  - All dequant unit tests pass.
  - Clean compilation with -Wall -Wextra.
  - No reinterpret_cast<const float*>(&scale_u16) patterns remain in dequant functions.

## Decision Log

- Date: 2026-03-05
- Decision: Proceed with fix. Root cause confirmed via code analysis: UB in FP16->FP32 cast.
- Rationale: Correct FP16 conversion already exists in the same file (load_tensor lines 792-806), confirming the author's intent. The dequant functions simply used a broken shortcut.

## Exit Criteria

- [x] Required outputs produced (plan document)
- [x] Required artifacts generated (fixed GGUFParser.mm, unit test)
- [x] Required gates pass (compilation: 1 pre-existing warning only; unit tests: 55/55 pass)
- [x] Risks documented (see below)

## Risks

- K-quant formats (Q2_K through Q8_K) have complex super-block structures. If the llama.cpp reference has changed since this code was written, block sizes may need updating. Mitigation: cross-reference against current llama.cpp `ggml-quants.h`.
- NEON SIMD paths in Q4_0 and Q8_0 use the scale value in vector lanes. The `fp16_to_fp32` conversion must happen before vectorization (it already does — scale is computed once per block, then broadcast).

## Crosswalk (Legacy Naming)

- Model = Architect
- Annotate = Trace
- Tie = Link
- Harness = Assemble
- Stress-test = Stress-test

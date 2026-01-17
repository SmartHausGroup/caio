# ADR Gate Scope

## When ADR is Required

ADR is required when guardrail files change:

- `configs/constants/` — Control constants and thresholds
- `invariants/INV-CAIO-CONTROL*` — Control-related invariants
- `caio/control/` — Control module (if applicable)

## When ADR is NOT Required

ADR is **not** required for:

- Documentation-only changes (`docs/**/*.md`, `README.md`)
- Packaging changes (`pyproject.toml`, `requirements.txt` unless adding new dependencies)
- Example/test files (`*_example.py`, `*_test.py`)
- Configuration changes unrelated to guardrails
- Code changes unrelated to control/guardrail logic

## Examples

**Requires ADR:**

- Changing `configs/constants/routing_thresholds.yaml`
- Adding a control invariant `invariants/INV-CAIO-CONTROL-0002.yaml`
- Modifying control logic in `caio/control/`

**Does NOT Require ADR:**

- Updating `docs/NORTH_STAR.md`
- Adding `pydantic-settings` to `requirements.txt`
- Creating `docs/integration/TAI_INTEGRATION.md`
- Fixing `pyproject.toml` package discovery

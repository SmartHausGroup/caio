# ADR-0001: Unified Inference Architecture - CAIO Orchestration Role

## Status

Accepted

## Context

CAIO initially implemented Tier 1 adapters (OpenAI, Anthropic, Groq, Mistral AI, Cohere) for external API inference. This created architectural confusion about service boundaries:

1. **Service Boundary Confusion**: Unclear whether CAIO or VFE handles external API inference
2. **Inconsistent Patterns**: Local inference in VFE, external API inference in CAIO
3. **Routing Complexity**: CAIO routing to both VFE (local) and external APIs (direct)

The user clarified the architectural vision:
- **VFE**: Unified inference engine for ALL inference (local models + external APIs)
- **CAIO**: Universal AI controller that orchestrates VFE (for inference), NME/MAIA/RFS/VEE (for services), and marketplace agents (Salesforce, Zoom, etc.)

## Decision

**CAIO focuses on orchestration, not inference execution. VFE handles all inference.**

### Changes

1. **Adapter Migration**
   - **Before**: Tier 1 adapters (OpenAI, Anthropic, Groq, Mistral AI, Cohere) in CAIO
   - **After**: Adapters moved to VFE as external API backends

2. **CAIO Role Clarification**
   - **Before**: Routes to external AI services (OpenAI, Anthropic, Groq)
   - **After**: Orchestrates VFE (for inference), NME/MAIA/RFS/VEE (for services), marketplace agents (Salesforce, Zoom, etc.)

3. **Service Architecture**
   - **CAIO**: Universal AI Controller (orchestrates all services)
   - **VFE**: Unified Inference Engine (executes all inference)
   - **Marketplace Agents**: Register in CAIO, executed via mathematical contracts

## Consequences

### Positive

- **Clear Service Boundaries**: CAIO orchestrates, VFE executes inference
- **Unified Inference**: All inference goes through VFE's selection calculus
- **Marketplace Focus**: CAIO focuses on marketplace agent orchestration
- **Mathematical Guarantees**: Contract-based discovery applies to all services

### Challenges

- **Adapter Migration**: Requires moving adapters from CAIO to VFE
- **Gateway Updates**: Gateway executor needs updates to route to VFE for inference
- **Testing**: Need to test orchestration routing to VFE
- **Documentation**: Update North Star and architecture docs

### Risks

- **Breaking Changes**: Existing CAIO functionality may depend on adapters
- **Gateway Updates**: Gateway executor may need refactoring
- **Migration Complexity**: Adapters need to be adapted to VFE's interface

## Alternatives Considered

1. **Keep Adapters in CAIO**: Rejected - violates "VFE is unified inference engine" principle
2. **Both CAIO and VFE Have Adapters**: Rejected - creates duplication and confusion
3. **CAIO Routes Directly to External APIs**: Rejected - user explicitly stated "all inference through VFE"

## North Star Alignment

- **CAIO North Star**: Updated to clarify orchestration role (Section 1.3)
- **VFE North Star**: Updated to include external API inference
- **TAI North Star**: Updated with enterprise vision

## References

- **CAIO North Star**: `docs/NORTH_STAR.md` (Section 1.3)
- **VFE North Star**: `VerbumFieldEngine/docs/NORTH_STAR.md`
- **TAI North Star**: `TAI/docs/NORTH_STAR_V3.md`
- **API Key Management**: `TAI/docs/operations/API_KEY_MANAGEMENT.md`

---

**Date:** 2026-01-13
**Deciders:** @smarthaus
**Status:** Accepted

# AI Project Instructions

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-05
**Related Documents:** [Project Roadmap](../01_Project/Project_Roadmap.md), [AI Development
Specification](../03_Development/AI_Development_Specification.md)

## Purpose

Project-specific rules for any AI assistant (or human contributor) working on this codebase, in
addition to the general engineering standards in the AI Development Specification. This document
governs how the roadmap is used; it does not redefine the roadmap itself — see
[Project_Roadmap.md](../01_Project/Project_Roadmap.md) for the authoritative phase order.

## Scope

Applies to all planning, implementation, and reporting work performed on this project.

---

## Roadmap Compliance

The [Project Roadmap](../01_Project/Project_Roadmap.md) is the **authoritative implementation
order**. It is final and was fixed by the project owner across 16 phases, from Project Foundation
through Deployment & Final Polish.

The AI must:

- **Never change the roadmap.** The order, numbering, and phase names in
  `Project_Roadmap.md` are not to be edited, reordered, renamed, or reinterpreted as part of
  implementation work.
- **Never recommend a different implementation order.** Suggestions must work within the
  existing 16-phase sequence, not propose alternative sequencing.
- **Never implement functionality from a future phase.** If a request would require work
  belonging to a later phase than the one currently in progress, the AI must decline to
  implement it and say which phase it belongs to instead.
- **Defer any out-of-scope work to its assigned phase.** If asked to build something that
  belongs to a later phase, respond by naming the correct phase and, if useful, note that the
  request is noted for that phase — without doing the work now.
- **Ensure the "Next Recommended Phase" in every Engineering Report always matches the
  official roadmap.** This is not a suggestion the AI forms from context each time — it is
  always "the next incomplete phase, in order," taken directly from
  `Project_Roadmap.md`.

### Applying this rule

- Before recommending next steps or writing an Engineering Report's "Next Recommended Phase"
  section, check `Project_Roadmap.md`'s Phase Status table rather than inferring an order from
  the current conversation.
- If a person asks for work from a future phase, the AI should explain that it belongs to that
  phase per the roadmap, and offer to either proceed anyway (if explicitly instructed) or wait
  until that phase is reached — but should not silently reorder the roadmap to accommodate the
  request.
- Documentation-only corrections (fixing a stale phase reference, typo, or broken link) are not
  "implementation work" and are not blocked by this rule — they may happen at any time, as in
  this review.

## References

- [Project Roadmap](../01_Project/Project_Roadmap.md)
- [AI Development Specification](../03_Development/AI_Development_Specification.md)

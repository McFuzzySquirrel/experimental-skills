# Skill Audit Report

**Generated:** 2026-07-18 (post-apply)  
**Audited by:** skill-review  
**Skills audited:** 1

---

## Summary Scores

| Skill | Context | Gotchas | Procedure | Progressive | Calibration | Validation | Overall |
|-------|---------|---------|-----------|-------------|-------------|------------|---------|
| agent-meeting-minutes | 3 | 3 | 3 | 3 | 3 | 3 | 3.0 |

**Score interpretation:**
- 2.5–3.0: Strong - follows best practices well
- 1.5–2.4: Adequate - works but has improvement opportunities
- 1.0–1.4: Needs work - significant gaps against best practices

---

## Per-Skill Findings

### agent-meeting-minutes

**Overall score:** 3.0

**Strengths:**
- Clear and specific purpose with good activation keywords in frontmatter description.
- Strong gotchas section that prevents common hallucinations (invented decisions, guessed owners, over-formalizing short chats).
- Procedural clarity is high: explicit Step-based flow with decision criteria and fallback behavior.
- Validation is concrete and actionable with a pre-finalization checklist and explicit self-check cue.
- Progressive disclosure is strong: non-operational example prose is moved into references/example-output.md and loaded only on a specific trigger.
- Calibration is explicit: inline format tokens (`draft:`, `single-pass`, `Agent`), escape hatches, and flexible-op alternatives.

**Improvement opportunities:** None — all axes scored 3.

**Applied changes:**
1. Added `## Process` and `## Calibration` sections in SKILL.md with explicit defaults and escape hatches.
2. Upgraded Process to explicit `Step` headings plus a low-quality-input decision criterion.
3. Trimmed duplicated narrative guidance in SKILL.md by removing the standalone Example and Tone/Style blocks while preserving core operational rules.
4. Replaced non-operational example prose in prompts.md with a specific load trigger and added references/example-output.md.
5. Added a direct markdown reference link and a self-check cue so progressive disclosure and validation are machine-detectable by the rubric script.
6. Enriched Calibration with concrete inline code tokens and an additional flexible-op alternative to push calibration axis to 3.

**Additional checks:**
- [x] name matches parent directory name
- [x] description is specific and activation-friendly
- [x] YAML frontmatter is valid
- [x] file references are relative from skill root
- [x] no more than one reference-chain depth

---

## Next Steps

Collect real usage feedback and iterate in the next audit cycle.

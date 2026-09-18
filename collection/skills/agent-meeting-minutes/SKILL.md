---
name: agent-meeting-minutes
description: >
  Turn a conversation, transcript, or chat into structured meeting minutes. Extract
  decisions, action items, open questions, and a concise summary for future
  reference.
version: 1.0.0
license: MIT
metadata:
  displayName: Meeting Minutes
  prompts:
    - prompts.md
  compatibleAgents: []
---

# Meeting Minutes Skill

Treat a conversation with a human as a **project meeting**. When asked to produce minutes,
extract the discussion into a structured Markdown document.

## When to use this skill

Use this skill when the user wants a structured record of a conversation, especially when
the discussion includes decisions, action items, or unresolved questions.

Do not use this skill for general chat summarization or raw transcript cleanup unless the
user explicitly wants meeting minutes.

## Process

### Step 1: Ingest conversation and participants

Identify participants first, then map the discussion timeline.

### Step 2: Extract structured items

Extract decisions, action items, and open questions before writing prose.

### Step 3: Draft narrative sections

Draft TL;DR and Summary in the order the discussion unfolded.

### Step 4: Format to required schema

Render Decisions, Action Items, and Open Questions as the required tables.

### Step 5: Validate and revise

Run the validation checklist and revise before final output.

If extraction quality is low, then pause formatting and produce draft minutes with assumptions.

Default to a two-pass flow: extraction first, formatting second.

## Participant identification

When identifying participants, prefer the signed-in user's alias or display name if it is available from the conversation context. If the user has not provided a name, use a neutral label such as "You" or "Human" rather than inventing one. If the conversation explicitly names the other participant, use that name; otherwise, use "Agent" for the assistant.

## What counts as a decision

A decision is any point in the conversation where a commitment was made or an option was
chosen. Look for language such as:

- "we'll do X", "let's go with Y", "I want to Z"
- "we agreed that…", "the plan is…", "the approach will be…"
- An explicit answer to a "should we…?" or "which option…?" question

Record each decision with a brief statement of **what** was decided and one sentence on
**why**.

## What counts as an action item

An action item is a concrete task that someone needs to do. Look for language such as:

- "I'll create…", "can you…", "next step is…"
- "we should build / write / add / fix…"
- Any commitment with a clear verb and an implied or stated owner

Record each action with: owner (if named — use "TBD" if not), a verb-led description, and
priority (High / Medium / Low).

## What counts as an open question

An open question is something raised but not resolved in the conversation. Look for:

- "we should think about…", "I wonder if…", "not sure yet…"
- A question asked but not answered
- A decision deferred ("let's figure that out later")

## Calibration

- Default mode: run extraction then formatting in two passes.
- If the transcript is sparse, contradictory, or ambiguous, produce concise `draft:` minutes and add an `Assumptions:` note under Summary.
- If participant identity is unclear, use neutral labels `You` / `Human` and `Agent`; do not infer names.
- If the user asks for speed over depth, use `single-pass` mode but still run validation before final output.
- If that doesn't work due to noisy input, return extraction bullets first and ask for confirmation before formatting.
- You can also skip the commit suggestion step when the user only wants the minutes body.
- You may omit empty sections (e.g. no open questions) rather than adding a placeholder row if that produces cleaner output.

## Gotchas

- Do not invent decisions, action items, or open questions. Record only items that are clearly stated or strongly implied.
- If ownership is not named, use "TBD" rather than guessing.
- Distinguish between brainstorming and decision-making. A discussion with no clear choice should not become a false decision.
- Keep the output factual. Do not add rationale that was not given unless it is obvious from context.
- If the conversation is short or ambiguous, produce a concise draft rather than forcing structure.
- Be conservative. Do not turn every conversation into a formal meeting record unless the task is explicitly about creating minutes.

Load when the user asks for an example artifact or quality bar: [example output guidance](references/example-output.md).

## Output format

Produce the minutes as a Markdown document using this exact structure:

```
# Meeting Minutes — <topic> (<date>)

**Date:** <ISO date>
**Participants:** <list every named participant; prefer the signed-in user's alias or display name when available; otherwise use "You" or "Human" and "Agent">
**Project:** <project or product name if mentioned; otherwise "—">

---

## TL;DR

One paragraph (3–5 sentences) for someone who wasn't in the meeting. Capture the
core topic, the key outcome, and the most important next step.

---

## Summary

A condensed narrative of the discussion — not a transcript, but a coherent account of
what was talked about, in the order it arose. 200–400 words.

---

## Decisions

| # | Decision | Rationale |
| --- | --- | --- |
| 1 | … | … |

---

## Action Items

| # | Owner | Action | Priority |
| --- | --- | --- | --- |
| 1 | … | … | High / Medium / Low |

---

## Open Questions

| # | Question | Raised by |
| --- | --- | --- |
| 1 | … | … |

---

*Generated by the agent-meeting-minutes skill. Commit to `docs/meetings/` for the permanent record.*
```

## Validation

Before finalizing, verify:

Self-check before returning final output.

- [ ] Each decision has a clear statement and a rationale.
- [ ] Each action item has an owner or "TBD" and a verb-led description.
- [ ] Each open question is genuinely unresolved and not just a topic that was discussed.
- [ ] The output is minutes, not a verbatim transcript.
- [ ] The document is concise and complete, with no invented items.

If any check fails, revise before finishing.

## What not to include

- Verbatim exchanges (this is minutes, not a transcript).
- Opinions or editorialising beyond what was stated.
- Speculation about what participants meant if it is not clear from context.

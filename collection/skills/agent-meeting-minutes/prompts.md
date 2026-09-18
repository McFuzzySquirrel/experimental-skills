# Meeting Minutes Prompts

These prompts are used by an agent equipped with the `agent-meeting-minutes` skill. Each block
reinforces the extraction-first workflow and the required output structure.

## Extraction prompt

Extract only:

- Participants
- Decisions and rationale
- Action items with owner and priority
- Open questions and who raised them
- A concise topic summary

Do not invent missing details. Use `TBD` for an unnamed owner and preserve uncertainty.

## Formatting prompt

Render the extracted material as the exact meeting-minutes Markdown structure from `SKILL.md`.
Keep the Summary chronological and distinguish decisions from brainstorming.

## Validation prompt

Before returning the minutes, check that every decision has rationale, every action has an owner or `TBD`, and every open question is unresolved. Remove invented facts and transcript-like detail.

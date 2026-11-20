---
name: again
description: Rewrite the last answer (or the part named after /again) simply, step by step, as a cheat sheet. Use only when the user types /again.
---

The developer did not understand your last answer. Rewrite it in the language of the conversation: simple, clear, step by step, cheat-sheet style (short bullets, numbered steps, a small table only if it really helps). No padding, no repeated preamble, no new topics.

Scope: the text the user typed after `/again` in the same message.

- If there is none, rewrite the whole last answer.
- Otherwise the scope tells you what to rewrite. It can be a point number (for example `2.`), a word or several words, a sentence or several sentences, a quotation, or any other pointer to a part of the last answer. Find that part and rewrite only it, with the surrounding context it needs to be understood. If it could mean more than one part, rewrite the most likely one and say which one you chose.

Explain the idea in plain words first, jargon second. Use a concrete example where it helps. Do not run tools or change files unless the rewrite cannot be done without reading something.

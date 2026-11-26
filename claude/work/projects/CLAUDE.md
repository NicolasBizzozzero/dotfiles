# AGENTS.md

**The fixed set of engineering rules AI agents and human contributors follow in this repository. Generic by design — identical in every project that uses it.**

---

## ⚠️ Read This First — Directive for AI Agents

**If you are an AI coding agent: read this entire file, carefully, from top to bottom, before you read or change any other file in this repository.** Do not skim. Do not jump to the section that looks relevant and skip the rest.

You do not carry memory between sessions. This file does. It is the closest thing this project has to a handover document from every engineer who ever worked on it, human or AI. Treat it that way, not as an optional style guide.

A few rules about the rules:

- **This file is immutable.** It is dropped into this project exactly as written and is never edited, extended, or reworded here — not by an agent, not casually by a human. It reads identically in every project that uses it.
- **Project overview, setup instructions, and structure belong in `README.md`, not here.** If something project-specific needs to be recorded or corrected, do it there. See [Section 2](#2-where-project-details-live).
- If something a human asks you to do in the current conversation genuinely conflicts with this file, **say so and ask which one wins.** Don't silently pick one.
- If a rule here seems to genuinely not fit this project, that's a conversation to have with a human — not a reason to edit or quietly ignore this file.
- Re-read this file if your session has been long, if context was compacted or summarized, or if you're resuming after a gap. Don't rely on having read it "earlier."

This document practices what it preaches: it's written in the plain-language, low-clutter style required in Section 5. Read it once as a rulebook, and once as a worked example.

---

## Contents

1. [Quick Reference](#1-quick-reference)
2. [Where Project Details Live](#2-where-project-details-live)
3. [How to Use This File](#3-how-to-use-this-file)
4. [Guiding Philosophy](#4-guiding-philosophy)
5. [Communication and Accessibility Standards](#5-communication-and-accessibility-standards)
6. [Architecture](#6-architecture)
7. [Coding Practices](#7-coding-practices)
8. [Comments: Type and Style](#8-comments-type-and-style)
9. [Documentation Beyond Comments](#9-documentation-beyond-comments)
10. [Testing](#10-testing)
11. [Long-Term Maintenance](#11-long-term-maintenance)
12. [Security Basics](#12-security-basics)
13. [Commits, PRs, and Agent Attribution](#13-commits-prs-and-agent-attribution)
14. [Guardrails: What Agents Must Never Do](#14-guardrails-what-agents-must-never-do)
15. [Definition of Done](#15-definition-of-done)
16. [Why This File Stays Fixed](#16-why-this-file-stays-fixed)
17. [Sources and Further Reading](#17-sources-and-further-reading)

---

## 1. Quick Reference

If you read nothing else, read this.

- [ ] Read this whole file before touching code. Re-read after a long gap.
- [ ] Plan before you code. For anything non-trivial, write down your approach and open questions first.
- [ ] Verify before claiming done: run the tests, the linter, and the build. Don't say something works because it looks right.
- [ ] Fix the root cause. Never suppress an error, delete a test, or fabricate fallback data to make something "pass."
- [ ] Keep changes small and focused — one concern per commit and per pull request.
- [ ] Explain *why*, not just *what*, in comments, commit messages, and PR descriptions.
- [ ] Write in plain language: short sentences, one idea at a time, everyday words. See [Section 5](#5-communication-and-accessibility-standards).
- [ ] Update docs and comments in the same change as the code they describe.
- [ ] Tag every commit you author with the exact model name and version. See [Section 13](#13-commits-prs-and-agent-attribution).
- [ ] Ask before anything hard to undo: force-push, deleting files or tests, changing a public API, adding a dependency, touching a migration.
- [ ] Don't guess. If you're unsure an API, library, or fact is real, check it before using it.
- [ ] Flag conflicts and ambiguity instead of silently resolving them your own way.

---

## 2. Where Project Details Live

This file is generic by design and never contains project-specific facts. All of the following lives in `README.md` instead — add it there if it's missing, fix it there if it's wrong, and never add it here:

- Project name, purpose, and who it's for
- Language(s), runtime(s), and framework(s)
- Setup, run, test, and lint commands
- Directory map: what each top-level path is for and why
- Architecture style, and a diagram if one exists

---

## 3. How to Use This File

- **Precedence:** explicit instructions from a human in the current task outrank this file, but only after a real conflict has been flagged, not by default. This file outranks an agent's own defaults and habits.
- **This file does not change.** It's the same in every project that uses it. Anything project-specific — overview, setup, structure, conventions unique to this codebase — belongs in `README.md` or a doc it links to. See [Section 2](#2-where-project-details-live).
- **This file encodes defaults and guardrails, not a decision tree for every situation.** Where it doesn't cover a case, fall back to [Section 4](#4-guiding-philosophy) and state what you assumed.

---

## 4. Guiding Philosophy

Every rule below serves one goal: **a competent programmer who has never seen this codebase should be able to understand it, trust it, and safely change it — on their first day, or five years from now, with no one left to ask.**

- **Optimize for the reader, not the writer.** Code is read far more often than it is written or changed. A few extra minutes now can save hours for whoever reads this next — including you, later, after you've forgotten why you wrote it.
- **Simple and boring beats clever and novel.** A dependency, pattern, or trick that only its author can maintain is a liability, however elegant. Prefer the well-understood approach over the impressive one.
- **Make decisions visible.** Assumptions, trade-offs, and the reasoning behind them belong in the repository — in an ADR, a comment, or a commit message — not only in a chat transcript or someone's memory.
- **Prefer small, reversible steps over big, irreversible ones.** A change you can undo in five minutes beats one you can't undo at all.
- **Consistency beats local optimization.** A merely-good pattern applied everywhere is easier to live with than a slightly-better pattern applied inconsistently.

---

## 5. Communication and Accessibility Standards

*(This section governs every piece of prose produced in this project: commit messages, PR descriptions, code comments, docstrings, READMEs, error messages, log lines, and CLI text.)*

Clear technical writing and accessible writing turn out to be the same skill: reduce the reader's cognitive load so they can find what they need, understand it, and use it — whether that reader is a tired on-call engineer at 2 a.m., a non-native English speaker, someone with dyslexia or ADHD, or a future maintainer with zero context. The rules below adapt four public standards for clear communication to a software setting:

- **ISO 24495-1:2023** (*Plain language — Governing principles and guidelines*) — the international plain-language standard. Its test for good writing isn't a readability formula; it's whether the intended reader can locate what's relevant to them, make sense of it, and act on it.
- **US Plain Writing Act of 2010** and the Federal Plain Language Guidelines — the requirement that writing be understandable on a first read: everyday words, active voice, direct address to the reader, short sentences, lists instead of dense prose, no unexplained jargon.
- **W3C WAI cognitive accessibility guidance** ("Making Content Usable," produced by the Cognitive and Learning Disabilities Accessibility Task Force, COGA) — guidance for people with cognitive and learning disabilities that generalizes well to anyone working under pressure: make patterns consistent and self-explanatory, make things easy to find, write clearly, design errors to explain the problem and the fix, minimize distraction, avoid requiring the reader to remember earlier steps, and put help where it's needed.
- **US Job Accommodation Network (JAN) guidance on ADHD-related accommodations** — workplace guidance built around a recurring pattern: put instructions in writing instead of relying on a one-time verbal explanation, break work into checklists and clearly separated tasks, cut clutter and distraction, and keep structure predictable enough to lean on.

None of these were written for source code, but the translation is direct:

1. **One idea per sentence.** Aim under ~20 words. If a sentence needs "and," "which," or a semicolon to hold two ideas, split it.
2. **Everyday words over jargon.** If a technical term is genuinely necessary, define it the first time it appears, then use that exact term every time after — don't rename a concept partway through.
3. **Active voice, and name the actor.** "The validator rejects malformed input," not "malformed input is rejected."
4. **Put the point first.** Lead a comment, commit body, or doc section with its most important sentence, then support it. Don't make the reader dig for the conclusion.
5. **Short paragraphs, short files, short functions.** Break long content into clearly headed sections instead of one dense block. If a section can't be summarized in its heading, it's probably two sections.
6. **Lists over prose for anything sequential or enumerable.** Steps, options, and parameters belong in a list, not a paragraph.
7. **Be consistent and predictable.** Use the same commit format, the same PR template, and the same section order in every README or ADR. Predictability lets a reader skim with confidence instead of re-reading everything.
8. **Don't make the reader hold things in memory.** Repeat essential context locally — a comment restating a non-obvious precondition, a doc restating a key constraint — rather than requiring recall of an earlier file, an earlier meeting, or an earlier conversation turn.
9. **Error and log messages state the problem, the likely cause, and the next step.** "Config file not found at `[path]` — copy `config.example.yml` to `config.yml` and fill in the values" beats "something went wrong."
10. **No double negatives, idioms, sarcasm, or culture-specific metaphors.** They cost a fluent native reader nothing and everyone else a great deal.
11. **Descriptive headings and link text.** "See the database migration guide," never "click here."
12. **One concern at a time.** Scope each comment, commit, and PR narrowly enough to be understood on its own.
13. **Show, not just tell.** Pair an abstract rule with one concrete example wherever practical — it's how most of this file is written.
14. **Keep visual noise low.** No decorative badges, emoji walls, or animation in generated docs. Headings and whitespace exist to help navigation, not to decorate.

---

## 6. Architecture

- **Write down the shape of the system in `README.md`** — layered, hexagonal/ports-and-adapters, modular monolith, microservices, or whatever it actually is — and link a diagram if one exists. A newcomer should be able to read one page and know where a given piece of logic belongs.
- **Separate concerns explicitly.** Each module should have one reason to change and a narrow, clearly defined public interface; keep its internals hidden from callers.
- **Point dependencies inward, toward stable abstractions.** Business logic shouldn't depend on a specific database, framework, or transport; those should depend on the business logic's interfaces, not the reverse.
- **Prefer composition over inheritance**, unless there's a genuine is-a relationship that will hold up over time.
- **Avoid hidden state and action at a distance.** A reader shouldn't have to trace global mutable state across the codebase to understand what a function does. Prefer explicit inputs and outputs.
- **Record architectural decisions.** For any choice a future maintainer might reasonably question ("why isn't this just a REST call?"), add a short Architecture Decision Record — context, decision, consequences — under `docs/adr/`. A comment or README can say *what*; an ADR is where *why* lives permanently.
- **Keep the directory map in `README.md` current** (see [Section 2](#2-where-project-details-live)). It's the map new contributors, human or agent, reach for first.
- **Minimize dependencies, and justify new ones.** Every dependency is code you didn't write but are now responsible for maintaining and securing. Note why it was chosen over the standard library or an existing dependency in the PR that introduces it.
- **Design for deletion, not just for addition.** A component that's easy to remove or replace cleanly is healthier long-term than one that's merely easy to extend.

---

## 7. Coding Practices

- **Naming:** descriptive, unabbreviated, and consistent. Use exactly one name for one concept throughout the codebase — don't call the same thing `user` in one file and `customer` in another.
- **Functions and modules:** small, single-purpose, written at one level of abstraction. Prefer several well-named functions over one long one broken up with section comments.
- **Control flow:** prefer guard clauses and early returns over deep nesting. If a reader needs to hold four levels of indentation in their head, restructure it.
- **DRY, but don't over-abstract early.** Duplication is cheaper than the wrong abstraction. A common rule of thumb: wait for the third repetition before extracting a shared abstraction.
- **Handle errors explicitly and loudly.** No empty `catch` blocks, no silently swallowed exceptions, no falling back to fake or default data to avoid surfacing a real failure. The same problem/cause/next-step structure from [Section 5](#5-communication-and-accessibility-standards) applies to exceptions and log messages, not just user-facing text.
- **Let tools own formatting.** Adopt a linter and formatter and run them automatically; don't debate tabs versus spaces in review. Machine-enforced consistency frees attention, human or agent, for things that matter more.
- **Use the strongest typing the language reasonably supports.** Type hints and static types are documentation that can't silently go stale — the type-checker notices when it does.
- **Tests are specification.** Name tests after the behavior they verify, and test through the public interface, not internal details that are free to change.
- **Keep commits and PRs small and single-purpose.** A change that does one thing is reviewable in minutes; a change that does five things is reviewable in nobody's lifetime.

---

## 8. Comments: Type and Style

**The core rule: comments explain *why*; code and good naming already explain *what*.** If a comment only restates the line below it, delete the comment or rename the thing it describes.

*(One narrow exception: in a long, unavoidably procedural function — teardown, multi-step setup — a short label before each block can help a reader skim, even though each line is individually obvious. Use this sparingly, and only where breaking the function into smaller named functions per [Section 7](#7-coding-practices) genuinely wouldn't read better. A label that adds nothing beyond what the code already visually groups is a trivial comment — cut it.)*

**Types of comments to write:**

- **Doc comments** on every public function, class, and module: purpose, parameters, return value, errors or exceptions raised, side effects, and a usage example for anything non-obvious. Use the language's standard doc-comment format (docstrings, JSDoc, Javadoc, rustdoc, godoc, …) so tooling and IDEs can surface it.
- **Design comments** near the top of a file, giving the overall approach: what algorithm or technique is used, and why, especially when the chosen design looks simpler than a reader might expect. This differs from an ADR — it lives with the code it describes and covers that file's internal approach, not a cross-cutting project decision.
- **Rationale comments** for a specific decision a reasonable reader would question: why this approach and not the obvious one, why a workaround exists, what business rule this encodes. Link to a ticket or ADR if one exists.
- **Teacher comments** when the code depends on background the reader may not have — a piece of math, a protocol quirk, how a data structure's invariants work. Explain the *concept*, not the code; it's often the difference between the code being readable by a few specialists and by anyone on the team.
- **Warning comments** for footguns: ordering dependencies, concurrency hazards, "don't change this without also changing X."
- **Tracked TODOs**, formatted as `TODO(name, YYYY-MM-DD): what and why`, linked to a ticket where possible. A `TODO` with no owner and no date is debt nobody will ever pick up — see [Section 11](#11-long-term-maintenance).

**What not to do:**

- Don't leave commented-out code. Delete it — version control already remembers it.
- Don't write a changelog inside comments; that's what commit history and `CHANGELOG.md` are for.
- Don't vent, apologize, or joke in comments left in the codebase.
- Don't write a comment that will predictably go stale: a hard-coded line number, a duplicated value that will drift from its source.
- Don't let a comment survive a change to the code it describes. Update or delete it in the same commit — a wrong comment actively misleads the next reader, which is worse than no comment.

**Style:** the plain-language rules in [Section 5](#5-communication-and-accessibility-standards) apply here too — one idea per comment, everyday words, no unexplained jargon, active voice.

---

## 9. Documentation Beyond Comments

- **A README per package or service:** purpose, how to run it, how to test it, how to extend it.
- **`CHANGELOG.md`** for anything released or versioned, newest entries first, written for a reader deciding whether to upgrade.
- **`docs/adr/`** for architecture decisions (see [Section 6](#6-architecture)).
- **A glossary** for domain-specific terms, so "one term, one meaning" (rule 2 in Section 5) is enforceable rather than aspirational.
- **`CONTRIBUTING.md`** as the onboarding path for new humans and new agent sessions alike. Test it against a simple bar: could someone with zero prior context be productive within an hour using only what's in the repository?

---

## 10. Testing

- Favor a large base of fast, isolated unit tests, a smaller layer of integration tests, and a thin layer of end-to-end tests — not the reverse.
- Tests must be deterministic: no sleep-based waits, no order-dependent tests, no reliance on external services that aren't mocked or containerized.
- Every bug fix ships with a regression test that fails before the fix and passes after.
- Treat coverage as a signal, not a target. 100% coverage with weak assertions is worse than 80% coverage that genuinely exercises edge cases.
- **For agents specifically: never delete, skip, or weaken a test — or fabricate mock or fallback data — to make a suite pass.** If a test fails, either the code or the test is wrong; find out which, fix that, and say what you found. Silencing the signal is not the same as fixing the problem.

---

## 11. Long-Term Maintenance

- **Dependencies:** keep them patched. If one is pinned to an older version, say why in a comment next to the pin, and note when to revisit it.
- **Deprecate, don't just delete.** Mark deprecated code explicitly, with a removal plan and a target date, rather than leaving it to rot indefinitely or deleting it without warning to callers.
- **Track technical debt where it's visible**, not just in memory — an issue label, a `docs/DEBT.md`, whatever the team actually looks at — noting what the shortcut was, why it was taken, and what fixing it would take. Periodically grep the codebase for `TODO` / `FIXME` / `HACK` markers as part of that review; one nobody ever revisits isn't being tracked, it's just noise.
- **Document breaking changes and migrations.** Anyone upgrading should be able to follow written steps, not reverse-engineer the diff.
- **Make observability worth a future maintainer's time.** Structured, meaningful logs and metrics mean a two-year-old incident is diagnosable without reconstructing context from memory.
- **Improve opportunistically, but in small, reviewable steps.** Leaving code a little better than you found it is good; a sweeping, unrequested rewrite bundled into an unrelated task is not — it hides the change you were actually asked to make.
- **The test that matters:** assume the next person to touch this code remembers nothing about how or why it was written — not this conversation, not the reasoning that felt obvious at the time. If that knowledge exists only in a chat log, it doesn't really exist. Put it in the repository.

---

## 12. Security Basics

- Never commit secrets or credentials. Use environment variables or a secrets manager, and add secret-scanning to pre-commit or CI.
- Validate all external input; default to least privilege.
- **Agents specifically** should not add a new network call, telemetry, dependency with broad permissions, or credential-handling code without calling it out explicitly first. These are exactly the changes a reviewer needs to see coming, not discover in a diff.

---

## 13. Commits, PRs, and Agent Attribution

**Commit messages:** a short imperative subject line (aim for ≤ 50 characters, hard cap around 72), a blank line, then a body in plain language explaining what changed and *why*, not just what. Reference a ticket if one exists.

### Required: tag every agent commit with model name and version

Any commit written or substantially modified by an AI coding agent **must** carry a trailer naming the exact model and version that produced it — including small or "obvious" changes.

Add this as the last line(s) of the commit message, after a blank line:

```
Assisted-by: <model display name> (<exact model identifier>)
```

Examples:
```
Assisted-by: Claude Sonnet 5 (claude-sonnet-5)
Assisted-by: GPT-5.2 Codex (gpt-5.2-codex)
Assisted-by: Gemini 3 Pro (gemini-3-pro)
```

Full example:
```
Fix null pointer in session cache eviction

The eviction loop dereferenced `entry` after a concurrent cleanup
pass had already removed it. Lock the cache during eviction
instead of after, closing the race.

Assisted-by: Claude Sonnet 5 (claude-sonnet-5)
Signed-off-by: [Human reviewer name] <[email]>
```

Rules:

- Name the exact model and version, not just the provider or family. "Assisted-by: Claude" doesn't tell anyone which model; "Assisted-by: Claude Sonnet 5 (claude-sonnet-5)" does.
- If an exact machine-readable version string isn't available, use the most precise human-readable name available rather than skipping the trailer.
- Pair it with a human `Signed-off-by:`. A person stays accountable for every change that ships, whatever wrote the diff.
- If a coding tool already adds its own attribution trailer, that's fine, but if it omits the specific model version, add this line as well — a generic trailer is not a substitute.
- Preserve the trailer through squashes and rebases. If commits from different models get squashed together, list each one.
- Never omit, falsify, or strip this trailer, and never attribute agent-written work to a human author.
- Consider enforcing this with a pre-commit hook or CI check that greps for the trailer on commits from agent sessions or branches.

**PR descriptions:** a one- or two-sentence summary of what changed and why, first, then details. List any assumptions made to resolve ambiguity explicitly, rather than leaving the reviewer to discover them later.

---

## 14. Guardrails: What Agents Must Never Do

*(Some of this repeats the Quick Reference on purpose — these are exactly the rules that shouldn't depend on memory. See rule 8 in Section 5.)*

- Never weaken, skip, delete, or comment out a failing test or assertion to make a build pass. Fix the cause, or stop and flag it.
- Never fabricate an API, library, config option, or fact that hasn't been verified. Check the actual source, docs, or tests — or say plainly that you're not sure.
- Never reformat or refactor unrelated code inside a task-focused change. It buries the real diff and makes review harder.
- Never delete a comment, test, or ADR you don't understand. Ask first, or leave it and flag it.
- Never expand scope beyond what was asked without saying so out loud.
- Never claim a change works without having run it — tests, build, and linter — first.
- Never proceed past one of these actions without explicit confirmation: force-pushing or rewriting shared history; deleting files, tests, or data; altering a database migration; changing a public API's shape; adding a new dependency; disabling or weakening a check.

---

## 15. Definition of Done

- [ ] Tests written and passing, including a regression test for any bug fixed
- [ ] Linter, formatter, and type-checker clean
- [ ] Comments and docs updated in the same change as the code
- [ ] No secrets, credentials, or debug output left in the diff
- [ ] Commit(s) carry the `Assisted-by:` trailer with exact model and version
- [ ] PR description explains what and why, and lists any assumptions made
- [ ] Nothing unrelated to the task was touched

---

## 16. Why This File Stays Fixed

This file is designed to be dropped into any project unchanged, and to mean the same thing everywhere it's used. That's only true if it stays generic and untouched.

- **Don't edit this file per project.** Not to add project details, not to "improve" a rule for a specific case, not even to fix a typo. A locally patched copy stops being the same golden standard as every other project using this file.
- **Project-specific and evolving information belongs in `README.md`** (see [Section 2](#2-where-project-details-live)) — name, purpose, stack, commands, directory map, architecture notes. Those change constantly and correctly; this file doesn't.
- **If a rule here seems to genuinely not fit this project**, raise it with a human. That's a decision for whoever owns this template, not something to resolve by quietly editing or ignoring the file.

---

## 17. Sources and Further Reading

This file draws on the open `AGENTS.md` convention, Anthropic's public guidance on agentic coding, established software-engineering literature, and four public standards for clear communication.

- [agents.md](https://agents.md/) — the open standard this file follows
- [Anthropic — Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Anthropic — Claude Code: Best Practices for Agentic Coding](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Salvatore Sanfilippo (antirez) — Writing System Software: Code Comments](https://antirez.com/news/124)
- [ISO 24495-1:2023, Plain language — Governing principles and guidelines](https://www.iso.org/standard/78907.html)
- [W3C WAI — Making Content Usable for People with Cognitive and Learning Disabilities](https://www.w3.org/TR/coga-usable/)
- [US Plain Writing Act of 2010 and Federal Plain Language Guidelines — plainlanguage.gov](https://www.plainlanguage.gov/)
- [Job Accommodation Network — ADHD accommodation guidance](https://askjan.org/disabilities/Attention-Deficit-Hyperactivity-Disorder-AD-HD.cfm)

Also drawn on, more generally: *Clean Code* and *Clean Architecture* (Robert C. Martin), *The Pragmatic Programmer* (Hunt & Thomas), *A Philosophy of Software Design* (John Ousterhout), *Refactoring* (Martin Fowler), *Working Effectively with Legacy Code* (Michael Feathers), Michael Nygard's Architecture Decision Records, and Google's published engineering practices for code review and style.

---

*This file is generic by design and does not change per project. Project-specific details live in `README.md` — see [Section 2](#2-where-project-details-live).*
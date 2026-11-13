# Global agent instructions

Copy this file to `~/.claude/CLAUDE.md` (Claude Code) and `~/.codex/AGENTS.md` (Codex), then edit it to fit the machine. It holds behavioral rules only. `how-i-work.md` next to it explains the process behind them.

## Context file hygiene

This file and `MEMORY.md` load into every conversation. Keep them small; bloat degrades instruction adherence.

- **This file:** rules only (what the agent must DO). No reference info, project descriptions or knowledge.
- **MEMORY.md:** a concise index of memory files, one line per entry, under 150 characters.
- **memory/*.md:** knowledge and reference info, loaded on demand.
- **A repo's `AGENTS.md`:** what any agent needs to work in that repo (build and test commands, invariants, gotchas). Commit it with a `CLAUDE.md` that holds only `@AGENTS.md`. Codex can't read Claude memory, so a repo fact kept only in memory never reaches a delegated job.

Before adding a line here, ask: "Is this a rule, or is this knowledge?" Knowledge goes in a memory file.

## Language and tech stack

Don't default to Python. Before starting a new project, tool or significant component, pick the best language for the job and state it with a one-line rationale.

- CLI tools, dev tooling, MCP servers: Go (single binary, fast startup), or Rust when performance or memory safety is critical.
- High-concurrency services and APIs: Go or Rust; TypeScript if iteration speed matters more.
- CRUD web backends: TypeScript (Node/Bun) or Go. Python only for a thin service that leans on Python-only libraries.
- Web frontends and browser extensions: TypeScript.
- Data pipelines, ETL, data science, ML training and inference: Python.
- Quick automation: Python or Bash; move to Go if it grows or needs distributing.
- Systems and embedded: Rust or C. Mobile: Swift, Kotlin, or React Native / Flutter for cross-platform.

Python is right only when the value comes from Python-only libraries, the script is a throwaway, or the codebase is already Python.

## Engineering principles

These bind every agent doing coding work: the main session, subagents, Codex jobs and reviewers. Put them in every brief.

- **Repro first; no fix from a guess.** A repro is a test that fails on the base branch, or the raw rows that show the failure. Walk the exact path that ran. When logs exist, pull the raw rows before calling a span or call missing; don't answer from memory. Keep what you know apart from what you guess, and what the code says apart from what one log shows. A fix that covers the symptom is not the root cause. Write findings in plain English, one idea per beat.
- **Fix root causes, not with guards.** When review rounds keep finding new edge cases in the same subsystem, the approach is wrong. Stop layering conditional guards and flags. Find the structural model that turns the check into one comparison (a generation, session or sequence token) and rework the change around it.
- **Keep PRs scoped.** When a bug fix grows into hardening an adjacent subsystem, split it: ship the small real fix now and give the hardening its own ticket and PR, designed from scratch. No drive-by cleanup, CI changes or unrelated fixes.
- **Judge a PR by its diff,** not by how cleanly its review threads were cleared. Fewer lines and no new state, flags, config, subsystems or migrations is the win.
- **Subtract first.** Reuse or delete before adding. Mirror the existing path; a deviation needs a stated reason.
- **Comments only for a non-obvious why.** None that restate the code or repeat another comment. Trim agent-written comment walls down to that.

## Push back on overcomplication

Don't wait to be caught. Default to the simplest fix that matches how the user thinks about the problem. Red flags, in your own work too:

- a big diff guarding a rare race
- new machinery, state or subsystems for a simple task
- a defensive nudge that doesn't fix the cause
- an agent that never reproduced the bug

## Changing existing code

- Match the surrounding code's formatting, method contracts, persistence, transaction and error-handling patterns. Keep payment and data fixes narrow. Explain any necessary deviation with concrete evidence before implementing it.
- Reviews and debugging stay inside the task's scope. Act on regressions the change introduces, defects in its new code, and what the task asks for. A gap the base branch already has goes in one short "noted, out of scope" list, with no fix and no extra digging unless asked. Label every finding **regression** or **pre-existing**.
- New features and logic need thorough tests. A test counts only if it fails without the change. When the same agent wrote the code and its tests, check that before trusting a green run. Mechanical changes (type widening, version bumps) get tests only where the compiler can't catch a regression.
- Fix the hard fails the plan requires. Polish, nits and optional tests go to the backlog, not new rounds of fixes. The backlog is the repo's GitHub issues, filed with the `file-issue` skill.
- Before treating code as someone else's, check its git log and CODEOWNERS. When you find a bug in code you don't own, report it to its owners; don't patch it in place.

## Evidence and status

- If a source is reachable, read it before drafting. Don't ship "I haven't checked X" as a caveat.
- Never report a background job's state from memory. Check it.
- Before arguing from a template, reference or baseline, check that the baseline is still live and used.
- Don't mark a task or ticket done until the deploy after merge finishes green, health check included.
- For a substantial investigation, write a reading guide with a claim ledger: stable IDs (`F1`, `F2`), each claim labelled **Proven**, **Derived**, **Hypothesis** or **Unknown**, with its evidence, what it doesn't prove, and what would disprove it. Keep "the defect exists" apart from "the defect caused this." Use the `engineering-investigation` skill.

## Planning and delegation

- When an approved spec exists, don't re-explore the code it mapped or re-debate its decisions. Go straight to the task breakdown, and keep each task a concrete action rather than a research prompt.
- Hand implementation tasks from an approved plan to background Codex jobs, one task per job. The plan file is the handoff. Each task in it has: goal, context and decisions, files, acceptance criteria (the behavior the tests must prove), out of scope, test command. Before delegating, write any decision made in chat since the plan was written into the plan file, and point the job at the plan by absolute path and task number.
- Run each job in its own git worktree, never the checkout I'm editing.
- A job ends by reporting files changed, commands run with results, deviations from the plan and why, and open questions. Fold the deviations back into the plan before the next task.
- When a job finishes, judge the diff's size and new surface before its test results, then run the task's tests. If it ballooned a simple task, cut it back before showing me.
- When review rounds keep turning up edge cases, rewrite the plan task around the structural fix and start a fresh job rather than sending more special cases.
- Agents never push or open PRs from a delegated job. I do that after review.
- Before I leave long agent work unattended, ask every decision and permission question up front so nothing stalls.

## Models and effort

- Set the effort on every delegate and subagent you start. Defaults differ by model, and GPT Sol's is `low`.
- Codex implementation jobs start at `medium`: GPT Terra for mechanical tasks (renames, type widening, version bumps, code that follows an existing pattern), GPT Sol for anything with real logic. When a job's tests fail or review finds a blocker, re-run that task on Sol at `high`. Don't raise effort before something has failed.
- Delegates for status checks, research and general questions run at `medium`.
- In Claude Code, send read-only searches (finding code, reading logs, sweeping a directory) to the `Explore` subagent with `model: haiku`. A subagent that has to judge code gets Sonnet at `medium`.

## Multi-model review

- Use a council review (the `council` skill) only for significant changes: new subsystems, security-sensitive or cross-service code. Routine changes rely on tests, lint and self-review.
- When a phase of a multi-phase plan finishes, review that phase's code before presenting it, and record the findings in a durable backlog doc in the repo, not in chat.
- Don't call council while generating a plan. Review the finished plan once. One call per decision; skip it when the spec already settled the architecture.
- Verify council claims against the code or docs before acting on them. Confident agreement between models is not proof.

## Git and PRs

- PR descriptions carry `file-pr`'s `Created with <model> in <harness>` attribution (as the closing line, or as the summary of the collapsed details block) and no other: no harness "Generated with" footer. Commits keep the harness's `Co-Authored-By` trailer.
- Ticket IDs go only in PR titles, commit subjects and branch names. Never in code, comments, tests, changelogs or PR descriptions.
- Every PR mention gets its full URL, every time. A bare `#123` isn't clickable outside the forge.
- Don't commit specs, plans or design docs. Keep them in the repo's `notes/` folder, excluded with a `/notes/` line in `.git/info/exclude`.
- Git worktrees go under `<repo>/.claude/worktrees/` or `~/dev/.worktrees/`. Remove a worktree once its branch is merged.
- Review comments read like a senior teammate wrote them: a few verified points that change what ships. No nit lists, no AI formatting.

## Writing for humans

- Every draft that goes out under my name or that other people read (messages, email, PR descriptions and comments, tickets, docs) runs through `/as-alex` before I see it.
- Replies to me in chat are not drafts. Keep them plain: strip the List A tells in `voice-rewrite/references/ai-tells.md`, but don't use my voice.
- Never invent a number to make a claim specific. Flag the gap as `[NEEDS NUMBER]`.
- Always show me a draft of anything external-facing before it's sent. Never send until I approve.
- No personal data in messages unless there's a real debugging reason.
- Don't write "on master" or "main would..." in replies. Name the behavior instead: in prod, the current code, without this check.

## Files and workspace

- `~/dev` holds git repos and a few fixed folders. Never create loose files there.
- Notes, plans, investigations and drafts for a project go in that project's `notes/` folder (git-excluded). Name them `<topic>-<what>-<YYYY-MM-DD>.md` and file them right away.
- Knowledge that outlives one project (a lesson, a decision and its reason, a how-to) goes in `~/dev/kb`, one markdown file per topic, listed in its README. Read the README there before researching something I may have already worked out.
- Throwaway output goes in the session scratchpad. Prune clones, builds and large outputs as each task finishes.
- Credentials go in `~/.secrets/` (dir 700, files 600), never in a repo.

## Replies and command output

- Keep routine replies brief: the result, the relevant validation, and any blocker. Expand when asked or when the task needs it.
- For verbose noninteractive build and test commands, save the full output to a file. On success, report the status and meaningful counts, skipped tests included. On failure, read the complete log and surface the relevant diagnostics. Keep the original exit status, and read more output whenever correctness depends on it.

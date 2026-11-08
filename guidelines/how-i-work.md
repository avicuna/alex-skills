# How I work

This is the process behind the rules in `AGENTS.md` and which skill I use at each step. The rules say what an agent has to do and this file says why so I can tell when a rule doesn't fit.

## The loop for a change

1. **Work out the design** with `brainstorming` when the what or the how is unclear. Skip it when I already have a clear spec. The design doc goes in the repo's `notes/` folder so it never ends up in git.
2. **Write the plan** with `writing-plans`. Each task is a self-contained handoff: goal, context and decisions, files, acceptance criteria, out of scope, test command. If something gets decided in chat after the plan is written, it goes into the plan file before the next task starts.
3. **Execute one task at a time.** Each task goes to a subagent or a background Codex job in its own worktree. The job reports back what it changed, what it ran, where it deviated and why, and what's still open.
4. **Review the diff before the test results.** A simple task that came back as a big diff with new state or flags gets cut back first, even if the tests pass.
5. **Get a second opinion** with `sol-loop` for most changes, or `council` for significant ones: new subsystems, security-sensitive or cross-service code. Check what the reviewers claim against the code before acting on it. Several models agreeing doesn't make them right.
6. **File the PR** with `file-pr`. It leads with the problem, not an inventory of changes.
7. **Watch it through** with `babysit-pr`. Fix the real findings and push back on the wrong ones.
8. **Merge and watch the deploy.** `full-send` runs steps 5 through 8 on its own, and `full-stop` stops when the PR is ready for me to merge. A task isn't done until the deploy after merge is green.

## Debugging

- **Reproduce it first.** A failing test on the base branch, or the raw log rows that show the failure. No fix from a guess.
- **Walk the path that actually ran,** not the one the code suggests. Pull raw rows before saying a call or span is missing.
- **Keep what I know apart from what I guess.** "No timeout" doesn't explain a call that never came back. Name the clue that does.
- **When reviews keep finding new edge cases, the approach is wrong.** Layering guards and flags is the symptom. Find the structural fix, often a single token like a generation or sequence number that turns the check into one comparison, and rework the change around it.

## Scope

- A bug fix stays a bug fix. If it grows into hardening the subsystem next to it, the small fix ships now and the hardening gets its own ticket and PR, designed from scratch.
- A review or debugging session labels each finding as a **regression** the change introduced or something **pre-existing**. Pre-existing gaps go in one short "noted, out of scope" list. Otherwise every review turns into a refactor.
- Polish and nits go to a backlog. Only the hard fails the plan requires get fixed in the current round.

## Investigations

For anything bigger than routine debugging I use `engineering-investigation`. The core idea is that every material statement is a bounded claim, and four questions stay separate:

1. Does the condition exist?
2. Did it cause this incident?
3. What population did it affect?
4. What consequence followed?

Evidence for one of these doesn't prove the others. Each claim gets an ID and a label (Proven, Derived, Hypothesis, Unknown), along with its evidence, what it doesn't prove, and what would disprove it. An Unknown isn't a dead end. It names the missing evidence, who owns it, the exact question, and what decision it blocks. When an investigation runs over several sessions, the checkpoint in `references/investigation-loop.md` keeps it resumable.

## Reviewing other people's code

- A few verified points that change what ships. No nit lists, no AI formatting. Comments should read like a senior teammate wrote them.
- Before treating code as someone else's, check its git log and CODEOWNERS.
- When I find a bug in code I don't own, I report it to the owners rather than patching it.

## Writing

- Anything that goes out under my name runs through `/as-alex` (the `voice-rewrite` skill with my voice turned on). Replies from an agent to me stay plain since getting a reply in my own voice is uncanny.
- No invented numbers. A vague claim gets flagged as `[NEEDS NUMBER]`, and the hook in `hooks/` blocks a send that still has one.
- I see a draft of anything external before it's sent.

## Working with agents

- **Rules vs knowledge.** The global instructions file only holds rules. Knowledge goes in memory files that load on demand. A bloated instructions file gets followed less.
- **Subtract first.** Every plan task and agent brief starts by asking what can be reused or deleted. New machinery needs a reason.
- **Ask everything up front** before leaving work unattended, so a run doesn't stall overnight on one permission prompt.
- **Check, don't remember.** A background job's status comes from checking it, not from what I think I started.
- **Hand off cleanly.** When I switch tools or sessions mid-task, `handoff` writes a capsule with the goal, the state, what was tried and why it failed, and the next action.

## Where things go

| What | Where |
|---|---|
| Repos | `~/dev/<project>/` |
| Specs, plans, investigations, drafts | `<project>/notes/`, excluded with `/notes/` in `.git/info/exclude` |
| Worktrees | `<repo>/.claude/worktrees/` or `~/dev/.worktrees/`, removed after merge |
| Throwaway output | the session scratchpad |
| Credentials | `~/.secrets/` (dir 700, files 600) |

---
name: fan-out
description: Split a plan or a list of fixes across independent subagents inside one session, each in its own worktree with a self-contained brief, so they run in parallel without cluttering the sidebar with extra threads. Use when the user says "fan out", or asks to run tasks in parallel, spin up subagents for a plan, or "fix 1, 2 and 4 in parallel", even if they don't name this skill. Also use when they pair it with "full send" or "full stop", so this session takes each task's PR to merged or ready. Not for one task (use a single subagent or `handoff`), and not when the user explicitly asks for separate top-level T3 Code threads.
---

# Fan out

Turn a set of tasks into parallel subagents managed from this session. Everything stays in one
sidebar thread: you split the work, launch the subagents in isolated worktrees, review their diffs
when they return, and coordinate the next steps from here.

A subagent starts with no memory of this conversation and a fresh checkout. Everything below follows
from that. Whatever a subagent needs has to be in its brief or in a file the brief points at, and
whatever two subagents might both touch has to be settled before they start.

Never use `t3_thread_launch` or `create_threads` for a fan-out. Those open top-level sessions that
clutter the sidebar.

If the user pairs the fan-out with "full send" or "full stop", read "Full send and full stop"
(after step 4) before you start. It changes how you ask questions up front, what each subagent does,
and what this session does after they return.

## 1. Check you can do this

- You need at least two tasks. For one task, do it here, start a single subagent, or use `handoff`
  if the user wants a fresh top-level thread.
- Pick the subagent mechanism for your harness:
  - **T3 Code (default when available):** use `delegate_task` with `isolation: "worktree"` and
    `mode: "async"`. Call `orchestrator_capabilities` once before the first `delegate_task` (load
    deferred T3 tools with ToolSearch before deciding they are missing). Never create a child's
    worktree in the shell when using `delegate_task`; `isolation: "worktree"` handles the checkout.
  - **Outside T3 Code (native subagents):**
    - In Claude Code, use the `Agent` tool with `isolation: "worktree"`, launching all subagents in
      one turn.
    - In Codex or other harnesses whose subagent tool has no worktree isolation flag, create one
      worktree per subagent first under `<repo>/.claude/worktrees/` or `~/dev/.worktrees/`
      (`git worktree add <path> -b <branch> <base>`) and pass that path in each brief.
- If no subagent tool is available, say so and stop. Do not silently substitute `t3_thread_launch`
  or `create_threads`.

## 2. Make the work durable

Subagents can't read this chat, so the work has to live somewhere they can.

- **A plan file exists** (the `writing-plans` format: goal, context and decisions, files,
  acceptance criteria, out of scope, test command per task). Use it as the handoff. First fold in
  anything decided in chat since it was written. Briefs point at it by absolute path and task
  number.
- **A short list of independent fixes** (review findings, audit items). No plan file needed. Each
  brief carries its whole task: what is wrong, the evidence, what to do, what to leave alone, how
  to test.
- **Anything bigger with no plan.** Write the plan first with `writing-plans`. A brief that tries
  to hold a multi-task design gets long and the subagents drift apart.

Then check the base the subagents will start from. Run `git fetch` and look at what is merged, what
is open in PRs, and whether the work depends on anything unpushed or uncommitted. A worktree created
with `isolation: "worktree"` starts from this session's current `HEAD` commit and does not include
uncommitted edits. Give every subagent the exact base ref or commit SHA (`origin/<default branch>`,
or a local commit SHA when it needs unpushed commits) and the exact branch name(s) to create inside
its worktree (`git checkout -b <branch> <base>`). That way every subagent starts from the right base
even if this checkout is on another branch.

Check that nobody has started this work already. Look for each task's planned branch and title in
local branches (`git branch --list <branch>`), remote branches
(`git ls-remote --heads origin <branch>`), active worktrees (`git worktree list`), and open PRs
(`gh pr list`).

- **An open PR or active branch already owns the task:** don't duplicate it. Include it in your
  report to the user.
- **The branch exists from merged or abandoned work:** pick a new branch name. Don't delete the old
  branch.

Check the untracked inputs too. A plan in a git-excluded `notes/` folder, generated assets and
local data files are not in a fresh worktree either. Point briefs at them by absolute path, and
say whether to read them in place or copy them in.

## 3. Group tasks into subagents

Independence is about files, not topics. Two tasks that edit the same file will conflict even if
they are unrelated; two related tasks in different files won't.

List each task with the files it creates, edits or deletes, and what it needs from other tasks.
Then:

1. **Same files, or one needs the other's output: same subagent.** The subagent does them in order
   on stacked branches (one branch per task). An order the plan states is not a dependency on its
   own; group on it only when the later task builds on what the earlier one produces.
2. **Everything else: its own subagent.** Keep a single-task subagent when the task spans areas that
   no group owns.
3. **A file several subagents must touch lightly** (a settings module, an env example, a shared
   test helper): give it to one subagent if you can. If you can't, name the file in each brief and
   ask for minimal, separate-line edits so the merges stay trivial.
4. **One subagent needs something another is still building.** Fix the contract now: the exact
   names both sides will use (entry point, setting, path, route). Put it in both briefs. The
   consumer writes to the contract and reports the checks it could not run yet.

Hold back, and tell the user why:

- Steps that use the user's accounts, spend real money, move real data, or change DNS or
  production. Those become a runbook the user runs. A subagent may write the runbook down.
- Tasks that only make sense after other work is merged and has run for a while.

When a task mixes code with one of those steps, split it instead of holding the whole task. The
subagent does the code and stops before the step, and its brief says which case applies: a step that
can run after the user says go, or a step an agent cannot run at all because it has no credential
for it, which stays with the user.

If you end up with more than about six subagents, show the grouping and confirm before launching.
That many usually means some tasks are too small to deserve a subagent.

## 4. Write the briefs

One brief per subagent, written to be read cold. Use this skeleton and drop a section only when it
has nothing to say. Keep each section short; the plan file carries the detail.

```markdown
You own **<Task N and Task M>** of an approved plan for this repo (<one line on what the project
is>). The plan is the handoff. Read it first, in full:

`<absolute path to the plan>`

Do <N, then M> exactly as written there. Its decisions are settled; do not re-debate them or
re-check what it already verified.

## Your tasks in one line each
- **Task N:** <what it produces>
- **Task M:** <what it produces, and what it depends on>

## Other subagents are working in parallel. Stay out of their files.
- Subagent B owns <files> (<tasks>).
- Subagent C owns <files> (<tasks>).
<Contracts: the exact names this subagent must provide or may rely on.>
<Shared files: which ones, and "keep edits minimal and on their own lines".>

Do not edit the plan file: several subagents share it. Put deviations and anything it asks you to
record in your final message.

## Engineering rules (binding)
<The Engineering principles from ~/Dev/alex-skills/guidelines/AGENTS.md, in five or six lines: repro
first, root cause not guards, scoped PRs, subtract first, a test counts only if it fails without
the change, comments only for a non-obvious why. Name the specific out-of-scope items this subagent
is most likely to be tempted by.>

## Environment and git
Create your task branch from `<base ref or SHA>`: `git checkout -b <branch> <base>`.
<For stacked tasks: branch Task M from Task N's branch and give each branch name.>
<Outside T3 Code when the parent created the worktree: state the worktree path and branch.>
<What the fresh worktree lacks (deps, env files) and how to set up its own. The test command.
Anything destructive about running it. Which checkouts or services are live and must not be
touched. Hooks that will block commands.>
<Its own copy of every local resource the subagents would otherwise share: a test database, a port,
a cache directory. Name it for the subagent, such as `myapp_test_b`.>

## Hard limits
No pushes, no PRs, no merges, no PR watches, no starting your own subagents. No deploys, no
external resources, no secrets set or printed. Anything that spends money or is outward-facing:
do the rest first, then stop and report what is blocked.

## Finish
Commit your work on the task branch(es) above. Do not push or open PRs; the parent session reviews
your diff and handles PRs. End with: worktree path, branch name(s) and head SHA(s), files changed,
commands run with results, proof the new tests fail without the change, deviations and why, what is
still owed, open questions.
```

For a list of independent fixes with no plan file, replace the first two sections with the task
itself: **The bug** (what and where, with file paths), **Evidence** (what was reproduced and what
was only read), **What to do**, **Out of scope**.

Before launching, read each brief as the subagent would. If it would have to guess a path, a name, a
command or who owns a file, add it. Tell every subagent the same story about ownership: brief A's
"Subagent B owns X" has to match brief B's task list.

Subagents run the same commands at the same moment on one machine. Look at what the test suite and
dev setup write to. A suite that recreates its database, or a server on a fixed port, will make
parallel subagents fail in ways none of them can explain, so give each subagent its own.

Never put credentials, tokens or connection strings in a brief.

## Full send and full stop

When the user pairs the fan-out with "full send" ("fan out the plan, full send"), this session takes
every task all the way to a merged PR with nobody watching: subagents implement and prove their
tasks in parallel worktrees, and this session reviews the diffs, runs `sol-loop` (or `council` when
Sol is unavailable), files the PRs (`file-pr`), watches and babysits them (`babysit-pr`), and merges
them once `full-send`'s merge gate passes. With "full stop", this session does the same work but
stops with every PR ready to merge and never merges.

Read the phrase as narrowly as `full-send` and `full-stop` do. If it only stresses a rule ("never
touch prod, full stop"), it is not a request. If you can't tell, ask.

Subagents never watch PRs, never merge, and never spawn nested review loops. Keeping review, PR
filing, PR watching (`watch_pull_request` or `pr-wait`), rebases, and merges in this session keeps
everything in one sidebar thread and lets you unblock contract consumers automatically once a
producer PR merges.

What changes:

- **Ask everything before launch.** Nobody will be watching this session once it starts. Put every
  question you can foresee (go-aheads for steps that need them, unclear scope) in one question-tool
  call (`AskUserQuestion`, `request_user_input`, or your harness's question tool), and write each
  answer into the briefs it affects. For full send, also show the grouping and confirm it whatever
  the subagent count: no one reviews these PRs before they merge, so a bad grouping lands on the
  default branch.
- **Held-back work stays held back.** The grant covers the PRs and the tests they need. It doesn't
  cover the steps step 3 holds back.
- **Pass testing permission to each subagent.** Add a short line in each brief granting
  `full-send`'s testing permission (direct proof without asking first: running the app, dev server,
  browser or simulator checks, screenshots) and telling the subagent to pick sensible defaults on
  minor ambiguities and report every decision made instead of stalling.
- **Stay active after subagents return.** Do not stop after launching or while checks or review bots
  are pending. As each subagent finishes:
  1. Review its diff (size, new surface, scope) and confirm its proof covers every change. Fix
     small issues yourself; for bigger rework, start a fresh subagent (raising effort per
     `AGENTS.md`).
  2. Run `sol-loop` (or `council` if Sol can't run) on each task branch. You can run independent
     `sol-loop` reviews in parallel.
  3. Rebase onto the latest default branch (or the previous branch in a stack) and file one PR per
     task with `file-pr`, including the proof line.
  4. Link and watch all open PRs from this session (`watch_pull_request` in T3 Code; `pr-wait`
     elsewhere). Fix real CI failures and bot findings directly for small fixes, or via a fresh
     subagent for bigger ones.
  5. **Stacked PRs:** under full send, merge bottom first; after a PR merges, retarget the next PR
     to `<default branch>`, rebase, wait for green, and re-check the merge gate. Under full stop,
     leave the stack ready and give the bottom-first merge order.
  6. **Shared files and base drift:** as PRs merge into `<default branch>`, rebase remaining PRs
     when they fall behind or touch shared files. Keep both sides' lines on minimal shared-file
     conflicts; ask with the question tool on real logic conflicts.
  7. **Contract consumers:** hold a consumer PR until its producer PR merges. Under full send, once
     the producer merges, rebase the consumer onto `<default branch>`, run the remaining
     cross-contract checks (directly or via a subagent), push, and finish the merge gate. Under
     full stop, list the checks that wait on the producer PR.
  8. **Finish or ask:** under full send, merge each PR when `full-send`'s merge gate passes (using
     the repo's merge method, never `--admin`). Under full stop, call `unwatch_pull_request` on
     every watched PR before handing back. If blocked on any PR and needing the user, unwatch first
     and use the harness's question tool.

## 5. Launch

Send every subagent call in one message so they start together.

### In T3 Code (`delegate_task`)

Call `orchestrator_capabilities` once first if you have not called it yet in this thread. Then call
`delegate_task` once per subagent with:

- `title`: `<Project or effort> <letter>: <what it does> (Tasks N, M)`. The letter is how the
  briefs refer to each other.
- `task`: the brief.
- `role`: `"implementation"` (or `"test"` / `"research"` if a subagent is only doing that).
- `isolation`: `"worktree"`.
- `mode`: `"async"`.
- `clientRequestId`: a stable slug such as `cloud-plan-b-backend`, so a retry doesn't start a
  second subagent.
- `target`: pick the model and effort from `~/Dev/alex-skills/guidelines/AGENTS.md` ("Models and
  effort") or from whatever the user explicitly requested, using the exact provider, instance,
  model and option IDs from `orchestrator_capabilities` (for example `reasoningEffort` or `effort`).
  Pick the newest version of a named model ("Opus" means the latest Opus listed) unless the user
  gave a version. Never write a model ID from memory: IDs go stale and quietly pin subagents to an
  old model. Omit `target` only when the user did not name a model and inheriting your current
  model and effort is right. Say which model and effort you picked. If a named model is ambiguous,
  ask; if it isn't available, say so and do not silently substitute.
- Leave `runtimeMode` unset unless the user asked for supervised subagents.

Record each returned `taskId` with its letter, tasks, and branch. Post a short launch summary
(subagent table, grouping rule, held-back items) and end your turn to wait for completion
notifications. Follow `delegate_task`'s `next` instructions. Never poll (`task_status`, `sleep`,
watchers).

### Outside T3 Code (native subagents)

- **Claude Code:** call `Agent` with `isolation: "worktree"` for each subagent in one message. Set
  `model` per `AGENTS.md` or the user's request.
- **Codex or other harnesses without worktree isolation:** create each worktree first with
  `git worktree add`, then start all subagents in parallel pointing each at its worktree path.

## 6. Collect, review, and report

As subagents finish, manage everything from this session:

1. **Inspect each diff before trusting the summary.** Check `git diff <base>..<branch> --stat` and
   read the diff. Judge diff size and new surface before test results (`AGENTS.md`): if a simple
   task ballooned, cut it back before showing the user or filing a PR.
2. **Handle failures and rework cleanly.**
   - Small fixes or missed scope items: fix them yourself in the branch's worktree rather than
     spawning another subagent.
   - Failed tests, wrong structure, or a stalled subagent: stop any active run with `task_cancel`
     (never `t3_thread_interrupt`), rewrite the task around the structural fix, and launch a fresh
     `delegate_task` with a new `clientRequestId` (raising effort per `AGENTS.md`, such as Sol at
     `high`). Never use `t3_thread_send` to retry a review or rework loop.
3. **Fold deviations into the plan file.** Subagents were told not to edit the plan. Fold their
   reported deviations and measurements into it once they finish.
4. **Run combined checks.** Run any checks that needed more than one subagent's work once the
   branches are ready or merged.
5. **Clean up worktrees after merge.** Remove each worktree once its branch is merged (or
   abandoned). Keep unmerged worktrees intact if the user still needs to inspect or push them.

### Final report (default fan-out)

Once all subagents are done and reviewed, reply with:

- A table: subagent letter, tasks, branch name (and worktree path), status, diff size, and test or
  proof result.
- How the subagents stayed independent: the grouping rule, contracts, and shared files.
- Diff review notes: anything you trimmed, fixed, or flagged.
- Deviations folded into the plan, combined checks still owed, open questions, and PR merge order.
- What you did not launch, and why.

Do not push or open PRs unless the user asked for PRs (or asked for `full-send` / `full-stop`).

### Final report (full send and full stop)

Open with two or three plain sentences on what changed and why across the effort. Then include:

- A table: task, full PR URL, final state (merged with merge commit, ready to merge, waiting for
  approval, or blocked), proof, and `sol-loop` or `council` outcome.
- Decisions you made for the user, deviations folded into the plan, combined checks run or still
  owed (including deploy checks after merge), and anything held back.

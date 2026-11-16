---
name: fan-out
description: Split a plan or a list of fixes across independent T3 Code threads, each in its own worktree with a self-contained brief, so they can all run at once without stepping on each other. Use when the user says "fan out", or asks to hand tasks to their own threads, spin up threads for a plan, run tasks in parallel threads, or "fix 1, 2 and 4 in their own threads", even if they don't name this skill. Also use when they pair it with "full send" or "full stop", so each thread takes its own PRs to merged or ready. Not for one task (use `handoff`), and not for subagents or delegates that report back to this thread.
---

# Fan out

Turn a set of tasks into top-level T3 Code threads that work at the same time. The user steers
each thread directly afterwards, so this is not delegation: you launch, report the links, and stop.

A new thread starts with no memory of this conversation and a fresh checkout of the base branch.
Everything below follows from that. Whatever a thread needs has to be in its brief or in a file the
brief points at, and whatever two threads might both touch has to be settled before they start.

If the user pairs the fan-out with "full send" or "full stop", read "Full send and full stop"
(after step 4) before you start. It changes steps 3, 4 and 6.

## 1. Check you can do this

- `t3_thread_launch` is usually deferred. Load it with ToolSearch
  (`select:mcp__t3-code__t3_thread_launch`) before deciding it's missing. If it isn't there, say so
  and stop. Don't substitute subagents or background jobs; the user asked for threads.
- You need at least two tasks. For one, use `handoff`.
- Use `t3_thread_launch`, not `create_threads`. `create_threads` puts every thread in this
  checkout, and parallel threads in one checkout overwrite each other.

## 2. Make the work durable

Threads can't read this chat, so the work has to live somewhere they can.

- **A plan file exists** (the `writing-plans` format: goal, context and decisions, files,
  acceptance criteria, out of scope, test command per task). Use it as the handoff. First fold in
  anything decided in chat since it was written. Briefs point at it by absolute path and task
  number.
- **A short list of independent fixes** (review findings, audit items). No plan file needed. Each
  brief carries its whole task: what is wrong, the evidence, what to do, what to leave alone, how
  to test.
- **Anything bigger with no plan.** Write the plan first with `writing-plans`. A brief that tries
  to hold a multi-task design gets long and the threads drift apart.

Then check the base the threads will start from. Run `git fetch` and look at what is merged, what
is open in PRs, and whether the work depends on anything unpushed or uncommitted. A new worktree
does not get uncommitted edits. If a thread needs an unpushed commit, give it the SHA to
cherry-pick (worktrees share the object store) or base it on the local branch.

Check that nobody has started this work already. Another thread may have launched the same tasks
(a planning thread, or an earlier fan-out the user has lost track of). Look for each task in two
places: live threads (`t3_thread_search` with the task's title and its planned branch), and the
planned branch itself (`git branch --list <branch>` and `git ls-remote --heads origin <branch>`).
T3 Code creates the branch when it sets up the worktree. If the branch already exists, the thread
fails before it starts.

- **A live thread owns the task:** don't launch it again. Put that thread's link in the report.
- **The branch exists but no live thread owns it** (merged or abandoned): use a new branch name.
  Don't delete the old branch.

Check the untracked inputs too. A plan in a git-excluded `notes/` folder, generated assets and
local data files are not in a fresh worktree either. Point briefs at them by absolute path, and
say whether to read them in place or copy them in.

## 3. Group tasks into threads

Independence is about files, not topics. Two tasks that edit the same file will conflict even if
they are unrelated; two related tasks in different files won't.

List each task with the files it creates, edits or deletes, and what it needs from other tasks.
Then:

1. **Same files, or one needs the other's output: same thread.** The thread does them in order
   and stacks the PRs. An order the plan states is not a dependency on its own; group on it only
   when the later task builds on what the earlier one produces.
2. **Everything else: its own thread.** Keep a single-task thread when the task spans areas that
   no group owns.
3. **A file several threads must touch lightly** (a settings module, an env example, a shared
   test helper): give it to one thread if you can. If you can't, name the file in each brief and
   ask for minimal, separate-line edits so the merges stay trivial.
4. **One thread needs something another is still building.** Fix the contract now: the exact
   names both sides will use (entry point, setting, path, route). Put it in both briefs. The
   consumer writes to the contract and reports the checks it could not run yet.

Hold back, and tell the user why:

- Steps that use the user's accounts, spend real money, move real data, or change DNS or
  production. Those become a runbook the user runs. A thread may write the runbook down.
- Tasks that only make sense after other work is merged and has run for a while.

When a task mixes code with one of those steps, split it instead of holding the whole task. The
thread does the code and stops before the step, and its brief says which case applies: a step it
can run after the user says go, or a step it cannot run at all because it has no credential for
it, which stays with the user.

If you end up with more than about six threads, show the grouping and confirm before launching.
That many usually means some tasks are too small to deserve a thread.

## 4. Write the briefs

One brief per thread, written to be read cold. Use this skeleton and drop a section only when it
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

## Other threads are working in parallel. Stay out of their files.
- Thread B owns <files> (<tasks>).
- Thread C owns <files> (<tasks>).
<Contracts: the exact names this thread must provide or may rely on.>
<Shared files: which ones, and "keep edits minimal and on their own lines".>

Do not edit the plan file: several threads share it. Put deviations and anything it asks you to
record in your final message.

## Engineering rules (binding)
<The Engineering principles from ~/Dev/alex-skills/guidelines/AGENTS.md, in five or six lines: repro
first, root cause not guards, scoped PRs, subtract first, a test counts only if it fails without
the change, comments only for a non-obvious why. Name the specific out-of-scope items this thread
is most likely to be tempted by.>

## Environment
<What the fresh worktree lacks (deps, env files) and how to set up its own. The test command.
Anything destructive about running it. Which checkouts or services are live and must not be
touched. Hooks that will block commands.>
<Its own copy of every local resource the threads would otherwise share: a test database, a port,
a cache directory. Name it for the thread, such as `myapp_test_b`.>

## Hard limits
<No deploys, no external resources, no secrets set or printed, no merges. Anything that spends
money or is outward-facing: do the rest first, then stop and ask.>

## Finish
One PR per task. <Branch name for each task. For tasks that build on each other, each PR targets
the previous task's branch; give the merge order, bottom first.> You are a top-level thread, not a
delegated job, so you open the PRs yourself, following the repo's AGENTS.md and my global rules
for branches and PR descriptions. Do not merge. End with: files changed, commands run with
results, proof the new tests fail without the change, deviations and why, what is still owed,
open questions.
```

For a list of independent fixes with no plan file, replace the first two sections with the task
itself: **The bug** (what and where, with file paths), **Evidence** (what was reproduced and what
was only read), **What to do**, **Out of scope**.

Before launching, read each brief as the thread would. If it would have to guess a path, a name, a
command or who owns a file, add it. Tell every thread the same story about ownership: brief A's
"Thread B owns X" has to match brief B's task list.

Threads run the same commands at the same moment on one machine. Look at what the test suite and
dev setup write to. A suite that recreates its database, or a server on a fixed port, will make
parallel threads fail in ways none of them can explain, so give each thread its own.

Never put credentials, tokens or connection strings in a brief.

## Full send and full stop

When the user pairs the fan-out with "full send" ("fan out the plan, full send"), each thread runs
the `full-send` skill on its own PRs: proof, `sol-loop` review, `file-pr`, `babysit-pr`, merge.
With "full stop", each thread runs `full-stop` and leaves its PRs ready to merge. Read the phrase
as narrowly as those skills do. If it only stresses a rule ("never touch prod, full stop"), it is
not a request. If you can't tell, ask.

The request is for the threads, not for this one. This thread still launches, reports and stops.
It doesn't run full-send on anything itself, and the grant reaches a thread only through its brief.

What changes:

- **Ask everything before launch.** Nobody will be watching the threads, and a thread that stalls
  on a question waits until the user looks. Put every question you can foresee (go-aheads for the
  steps a thread can run after the user says go, unclear scope) in one
  `AskUserQuestion` call, and write each answer into the briefs it affects. For full send, also
  show the grouping and confirm it whatever the thread
  count: no one reviews these PRs before they merge, so a bad grouping lands on the default branch.
- **Held-back work stays held back.** The grant covers each thread's own PRs and the tests they
  need. It doesn't cover the steps step 3 holds back, and it doesn't cover a thread touching
  another thread's PR.
- **Hard limits.** Replace "no merges" with "Merge only your own PRs, and only when full-send's
  merge gate passes." For full stop: "Never merge."
- **Finish.** Replace the skeleton's Finish section with the one below.
- **Last line.** End the brief with `Full send.` or `Full stop.` on its own line. Both skills only
  grant their permissions on an explicit request, and to the thread the brief is the user's
  message.

```markdown
## Finish
Take each PR through the `<full-send | full-stop>` skill. I am not watching this thread; when that
skill says to ask, use the question tool. One PR per task. <Branch name for each task.> Follow the
repo's AGENTS.md and my global rules for branches and PR descriptions.

<Stacked tasks:> Each PR targets the previous task's branch. <Full send: Merge bottom first. After a
PR merges, retarget the next one to `<default branch>`, rebase, wait for green, and take it through
the merge gate again. | Full stop: Leave the stack ready and give the merge order, bottom first.>

Other threads merge into `<default branch>` while you work. Their merges are the base commits the
merge gate tells you to rebase over. When a rebase conflicts in <shared file>, keep both sides'
lines. When it conflicts in logic, ask.

<Contract consumer:> You rely on <contract> from Thread <X>, branch `<branch>`. <Full send: Don't
merge until that PR has merged. Don't watch it; Thread <X> owns it. When yours is otherwise ready,
unwatch it and ask with the question tool to be told when Thread <X>'s PR has merged. Then check
its live state with `gh`, rebase onto `<default branch>`, run the checks you couldn't run before,
and finish the merge gate. | Full stop: List the checks you couldn't run, and say they wait on
Thread <X>'s PR.>

End with the skill's report, plus: deviations from the plan and why, what is still owed, open
questions.
```

In step 6, drop the merge order from what needs the user (the threads merge themselves under full
send) and say where results will show up: a merged PR, a ready PR, or a question waiting in the
thread. The checks that need more than one thread's work, and the deploy after the last merge, are
still owed.

## 5. Launch

Send every `t3_thread_launch` call in one message so the threads start together.

- `title`: `<Project or effort> <letter>: <what it does> (Tasks N, M)`. The letter is how the
  briefs refer to each other.
- `message`: the brief.
- `clientRequestId`: a stable slug such as `cloud-plan-b-backend`, so a retry doesn't start a
  second thread.
- `workspaceStrategy`: `{type: "worktree", baseRef: "origin/<default branch>",
  startFromOrigin: true, branch: "<type>/<short-description>"}`. Use a branch that step 2 found
  free, both locally and on origin. This is the branch for the thread's first task; the brief names the branches for the rest. Use the local base with `startFromOrigin: false` only when the thread needs commits
  that aren't pushed.
- `modelSelection`: omit it so the thread inherits yours. Pass it only when the user names a
  model or effort, as `{provider, instanceId, model, options: [{id: "effort", value: "high"}]}`.
  Call `orchestrator_capabilities` and take the provider, instance, model and option ids from what
  it lists. Pick the newest version of the model the user named ("Opus" means the latest Opus
  listed) unless they gave a version. Don't write a model id from memory: ids go stale, and a
  remembered one quietly pins the threads to an old model. Say which model you picked. If the
  name could mean more than one family, ask; if it isn't available, say so.
- Leave `projectId` and the mode fields unset so they inherit.

## 6. Report and stop

Reply with:

- A table: each thread's `link` exactly as returned, its tasks, and what it owns.
- How the threads stay independent: the grouping rule you applied, the contracts, any shared
  files.
- What will need the user: go-aheads for paid or outward steps, setup a thread is likely to stall
  on, PR merge order, combined checks owed after merging.
- What you did not launch, and why.

A launch result of `preparing` means the thread exists, not that work has happened. Say that.
Don't wait on the threads, poll them, or describe their progress.

## Later, when the user comes back

- Read a thread with `t3_thread_read` before saying anything about its state. After a full send,
  check each PR's live state with `gh` too; don't take a thread's report as the merge.
- Fold each thread's reported deviations and measurements into the plan file, since the threads
  were told not to edit it.
- Run the checks that needed more than one thread's work, once those PRs are merged.
- Remove each worktree after its branch is merged.

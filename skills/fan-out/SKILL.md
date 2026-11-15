---
name: fan-out
description: Split a plan or a list of fixes across independent T3 Code threads, each in its own worktree with a self-contained brief, so they can all run at once without stepping on each other. Use when the user says "fan out", or asks to hand tasks to their own threads, spin up threads for a plan, run tasks in parallel threads, or "fix 1, 2 and 4 in their own threads", even if they don't name this skill. Not for one task (use `handoff`), and not for subagents or delegates that report back to this thread.
---

# Fan out

Turn a set of tasks into top-level T3 Code threads that work at the same time. The user steers
each thread directly afterwards, so this is not delegation: you launch, report the links, and stop.

A new thread starts with no memory of this conversation and a fresh checkout of the base branch.
Everything below follows from that. Whatever a thread needs has to be in its brief or in a file the
brief points at, and whatever two threads might both touch has to be settled before they start.

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
<The Engineering principles from ~/Dev/tstack/guidelines/AGENTS.md, in five or six lines: repro
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

## 5. Launch

Send every `t3_thread_launch` call in one message so the threads start together.

- `title`: `<Project or effort> <letter>: <what it does> (Tasks N, M)`. The letter is how the
  briefs refer to each other.
- `message`: the brief.
- `clientRequestId`: a stable slug such as `cloud-plan-b-backend`, so a retry doesn't start a
  second thread.
- `workspaceStrategy`: `{type: "worktree", baseRef: "origin/<default branch>",
  startFromOrigin: true, branch: "<type>/<short-description>"}`. This is the branch for the
  thread's first task; the brief names the branches for the rest. Use the local base with `startFromOrigin: false` only when the thread needs commits
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

- Read a thread with `t3_thread_read` before saying anything about its state.
- Fold each thread's reported deviations and measurements into the plan file, since the threads
  were told not to edit it.
- Run the checks that needed more than one thread's work, once those PRs are merged.
- Remove each worktree after its branch is merged.

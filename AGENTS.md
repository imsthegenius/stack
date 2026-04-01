# Linear Agent Control Plane — Codex Rules

Linear is our task management system. All actionable work flows through Linear tickets. Team key: `TWO` (Twohundred workspace).

## When to Create Linear Tickets

Create a Linear ticket whenever:
- A bug, issue, or improvement is identified during discussion
- The user describes a feature or change they want
- A code review reveals issues that need fixing
- A refactor, cleanup, or optimization is discussed
- Any actionable work item emerges from conversation

Do NOT create tickets for questions, research, or one-off queries.

## Ticket Structure (mandatory)

Every ticket must have enough detail for any developer or agent to implement without asking for context:

```
Title: Clear, specific action (e.g., "Replace inline HTML-strip regex with stripHtml utility")

What: 1-2 sentences explaining what needs to change and why.

Files:
- src/path/to/file.ts (lines 23, 133, 540)
- src/path/to/other-file.ts (lines 58, 65)

Changes:
1. Step-by-step implementation instructions
2. Import X from Y
3. Replace pattern A with pattern B

Acceptance criteria:
- [ ] All instances replaced across listed files
- [ ] Build passes
- [ ] No regressions
- [ ] Tests pass (if applicable)

Verify: <build command> passes
```

## Parent Issues

Use parent issues when work needs 3+ tasks. Parent holds context/spec/scope, children are individual implementation tasks.

- Parent: overall feature description, spec link, scope
- Children: reference parent via parentId, each completable in one session/PR

## Dependencies (mandatory)

Always set dependencies when creating tickets:
- If ticket B cannot start until ticket A is done, set `blockedBy` on B
- If ticket A must finish before B and C, set `blocks` on A
- Create all tickets first, then update with dependency relationships
- Never start a blocked ticket
- Update dependencies immediately if new ones are discovered during work

## Implementation Workflow

ALL ticket work happens in a worktree. Never implement directly on main.

1. Read the Linear ticket and any parent issue for full context
2. Read spec files if referenced in the description
3. Update ticket status to "In Progress"
4. Determine branch prefix from labels: feature/ (default), fix/ (bug), cleanup/ (cleanup/tech-debt), test/ (test)
5. Create a worktree using `EnterWorktree(name: "two-<number>-<slug>")` (Claude) or `git worktree add .claude/worktrees/two-<number>-<slug> -b <prefix>/two-<number>-<slug>` (Codex)
6. Work in the worktree directory
7. Implement the change as described
8. Run build/verify — do not commit code that doesn't build
9. Commit with Linear ID: `<summary> (TWO-<number>)`
10. Self-review the diff: unused imports, empty catch blocks, over-engineering
11. Push the branch
12. Create a PR with: summary, verification section, link to Linear issue
13. Update ticket status to "In Review" — do NOT mark as done

13. Update ticket status to "In Review" — do NOT mark as done. Tag @codex in a comment for review.

## Codex Review Gate (you are the reviewer)

When you are tagged via @codex on a Linear ticket that is "In Review", you are the independent review gate. Claude implements, you verify. Run this checklist from inside the worktree or against the PR:

### Merge Safety Checklist

1. **Build** — run the project's build command. Must pass with zero errors.
2. **Tests** — run tests if they exist. Must pass.
3. **Lint** — run linter if configured. Zero warnings on changed files.
4. **Diff review** (git diff main..HEAD):
   - Every changed file is relevant to the ticket — no unrelated changes
   - No debug code (console.log, print, TODO/FIXME added)
   - No hardcoded secrets or credentials
   - No commented-out code or dead code
   - No unused imports
   - No empty catch blocks or swallowed errors
5. **Acceptance criteria** — re-read the Linear ticket, verify EACH criterion with evidence (not just "looks right")
6. **Verify command** — if the ticket says "Verify: <command>", run it and confirm output
7. **Regression check** — do existing features still work? Breaking changes to shared APIs?
8. **Convention compliance** — changes follow CLAUDE.md / AGENTS.md project rules

### Your response:
- **All checks pass** → comment "APPROVED" with evidence for each check, mark ticket "Done", approve PR
- **Any check fails** → comment listing exactly what failed with file/line references, set ticket back to "In Progress", do NOT approve

You are the last line of defence. Do not rubber-stamp. If something looks wrong, reject it.

14. Worktree cleanup happens only after you approve and PR is merged. Use `ExitWorktree(action: "remove")` (Claude) or `git worktree remove <path>` (Codex).

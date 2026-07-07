---
name: cogrex-codebase-init
description: Use when the user asks Cogrex to initialize, create, generate, inspect, or maintain a codebase-directory .cogrex.md notes file.
compatibility: opencode
metadata:
  workflow: cogrex-codebase-notes
---

# Cogrex Codebase Init

Use this skill when the user asks to create, initialize, generate, inspect, or maintain `.cogrex.md` for the current codebase directory.

## Purpose

`.cogrex.md` is an optional, codebase-local authority file for Cogrex. It records the development environment, commands, reference locations, and concise project notes Cogrex should trust when working in that codebase.

Do not create `.cogrex.md` in every codebase. Create it only when the user asks for it.

## Core Rules

- The file is named `.cogrex.md` exactly.
- The codebase directory is the user's explicit path or tool workdir; otherwise use the current working directory. Never treat `/` as the codebase directory unless the user explicitly names `/`; ask one focused clarification question if the resolved directory is `/` or unclear.
- The file lives only in the codebase directory. Do not walk parent or child directories looking for alternatives.
- If codebase-directory `.cogrex.md` already exists, read it before editing or relying on it.
- Treat existing `.cogrex.md` content as authoritative project context unless higher-priority instructions or the user's current request conflict with it.
- If `.cogrex.md` conflicts with discovered project files or seems stale, ask one focused clarification question before changing or overriding it.
- Use `N/A` for fields that do not apply to a project.
- Do not add `Update Policy`, `Architecture Map`, or `Verification` sections by default.
- Keep the file short and operational. Avoid broad documentation, marketing description, or speculative architecture notes.

## Blank Template

```markdown
# Cogrex Codebase Notes

## Project Notes
- Purpose: N/A
- Main stack: N/A
- Important entrypoints: N/A
- Constraints and gotchas: N/A

## User Requirement
- N/A

## Reference
- Reference dirs:
  - N/A
- External docs: N/A
- Related repos: N/A

## Dev Environment
- Build env: N/A
- Run env: N/A
- Test env: N/A
- Required services: N/A
- Environment files: N/A

## Dev Commands
- Install: N/A
- Build: N/A
- Run: N/A
- Test: N/A
- Lint: N/A
- Format: N/A
- Other: N/A
```

## Init Workflow

1. Resolve the codebase directory from the user's explicit path or tool workdir; otherwise use the current working directory.
2. If the resolved directory is `/` or unclear, ask one focused clarification question before creating or editing `.cogrex.md`.
3. Check whether `.cogrex.md` exists in that directory.
4. If it exists, read it and preserve existing user-written content.
5. If it does not exist and the user asked to initialize it, create the blank template above.
6. Do not scan the repository to prefill commands during initialization unless the user explicitly asks for discovery.
7. Report the file path and whether the file was created or updated.

## Maintenance Workflow

- When the user asks to maintain or update `.cogrex.md`, update only the relevant entries.
- When `.cogrex.md` already exists and a completed task changes a recorded dev environment, command, reference dir, or project note, update the affected entry unless the user opts out.
- Prefer facts from the user or the authoritative `.cogrex.md` over inference from package files.
- Do not silently replace an authoritative command with a discovered command. Ask if the difference matters.
- Keep section names stable so future agents can skim the file quickly.

## Reporting

- If created, say `.cogrex.md` was initialized with the blank template.
- If updated, summarize only the changed entries.
- If no change was needed, say `No changes needed`.

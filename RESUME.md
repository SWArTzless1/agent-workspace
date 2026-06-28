# Workspace Build — Resume Notes

Last updated: 2026-06-27

---

## What this workspace is

A multi-agent development workspace. Every user prompt goes through a Triage → planning → execution pipeline. Agents are cold LLM sessions given behaviour by skill files (`agents/<name>/skill.md`). The main conversation (Claude Code) is the persistent orchestrator — it spawns all collaborative agents and manages phase checkpoints.

The authoritative spec is `CLAUDE.md`. Read it before doing anything.

---

## What's been built

### Infrastructure (complete)

| File | Status | Notes |
|---|---|---|
| `CLAUDE.md` | Done | Full orchestration protocol: Phase Checkpoints, sub-agent vs collaborative agent distinction, MVP/completion pass model, Feasibility Report flow, parallel planning agents |
| `plans/README.md` | Done | Plan file structure with Feasibility Report section, Executor Dependency Map, Game Design Notes in Godot section, MVP/completion pass Tech Lead Notes templates |
| `shared/agent-roles.md` | Done | All roles updated: executor handoffs corrected, Design/Game Design two-mode descriptions, Triage no longer spawns downstream |
| `shared/conventions.md` | Pre-existing | No changes needed yet |
| `shared/glossary.md` | Pre-existing | No changes needed yet |

### Skill files (complete)

| Agent | File | Notes |
|---|---|---|
| Triage | `agents/triage/skill.md` | Reviewed and approved. No downstream spawning language. |
| Triage Reviewer | `agents/triage-reviewer/skill.md` | Reviewed and approved. Absorbs former Plan Review Agent (Steps 3b/3c). |
| Tech Lead | `agents/tech-lead/skill.md` | Three modes: planning, feasibility, alignment-review. Executor Dependency Map. MVP/completion pass model. |
| Tech Lead Reviewer | `agents/tech-lead-reviewer/skill.md` | Two spawn modes: initial and revision. Independent assessment first. Handoff references updated to "main conversation". |
| Design | `agents/design/skill.md` | Two modes: planning (independent, tech-stack agnostic) and design-notes-only (post-feasibility). Does NOT read Tech Lead solution in planning mode. |

### Skill files (not yet written)

Write them in this order — each builds on what came before:

1. `agents/design-reviewer/skill.md` — reviews Design Agent planning-mode output only; two spawn modes (initial/revision); read-only on plan file
2. `agents/game-design/skill.md` — two modes: planning (independent GDD) and notes-only (writes Game Design Executor Notes + Game Design Notes to Executor-Godot post-feasibility)
3. `agents/game-design-reviewer/skill.md` — reviews Game Design planning-mode output; same structure as Design Reviewer
4. `agents/executor-react/skill.md` — two modes: mvp (mock API) and completion (wires real API); creates task branch; spawns Review Agent
5. `agents/executor-dotnet/skill.md` — two modes: mvp (in-memory store) and completion (real DB); creates task branch; spawns Review Agent
6. `agents/executor-database/skill.md` — typically full task in MVP pass (root dependency); creates task branch; spawns Review Agent
7. `agents/executor-godot/skill.md` — two modes: mvp (stub data) and completion; creates task branch; spawns Review Agent
8. `agents/executor-python/skill.md` — two modes: mvp (mock services/in-memory) and completion (real DB); FastAPI default; folder created, roster entries added
9. `agents/review/skill.md` — code quality review of executor output; read-only; produces PASS/FAIL/CONDITIONAL report

---

## Design artifact output format — deferred decision

Both the Design Agent and Game Design Agent now produce standalone artifact files alongside the plan file:
- Design Agent: `projects/<project-name>/docs/design-spec.md`
- Game Design Agent: `projects/<project-name>/docs/game-design.md`

Format is currently plain markdown. Revisit when tooling matures — an MCP server could produce richer artifacts (Figma-compatible specs, Miro boards, structured JSON for design systems). The artifact production step is in `agents/design/skill.md` Phase 4 and `agents/game-design/skill.md` Phase 4. Changing the format only requires updating those two sections and the Output Formats templates in each file.

---

## Key architectural decisions (locked in)

These are stable. Don't re-litigate them without a good reason.

**Orchestration:**
- Main conversation is the persistent orchestrator — spawns all collaborative agents (Tech Lead, Design, Game Design, all Executors)
- Each agent spawns only its own reviewer (1 sub-agent max per session)
- Triage and its reviewer handle planning only — no downstream spawning

**Planning phase:**
- Tech Lead, Design Agent, and Game Design Agent (if routed) run in parallel — each does an independent first pass, then spawns its reviewer
- Design Agent reads ONLY the user problem and Triage context in planning mode — NOT the Tech Lead solution. This independence is the whole point.
- All three must be reviewed and approved before feasibility fires

**Feasibility phase:**
- Tech Lead (feasibility mode) fires AFTER all planning agents are approved
- Writes only `### Tech Lead Feasibility Assessment` — not Design or Game Design sections
- User reviews feasibility assessment directly (no reviewer spawned)
- After user approves: Design Agent (design-notes-only) + Game Design Agent (notes-only) spawn in parallel to write executor notes

**Execution phase:**
- All executor MVP passes start simultaneously — each uses mocks/stubs/in-memory for any unresolved dependencies
- Completion passes triggered by Executor Dependency Map (written by Tech Lead in the plan file)
- Each executor spawns Review Agent (sub-agent) after implementation; main conversation spawns Tech Lead (alignment-review mode) separately

---

## Process for writing remaining skill files

1. Write the draft
2. Send to a general-purpose subagent (fresh agent, not fork) for independent review
3. Critically evaluate the gaps — not all feedback is valid; push back where appropriate
4. Apply agreed changes
5. Check in with the user before moving on

Reference bar for quality: `agents/triage/skill.md` and `agents/tech-lead-reviewer/skill.md`

---

## Executor agent pattern (apply to all executor skill files)

All executor skill files follow this pattern — established in Executor-React:

**Branch:** Create `task/<short-description>` before writing any code. This is the working branch throughout. The PR is not opened until the agent is confident the work is complete.

**Live verification:** Start the runtime environment before implementing anything. Keep it running throughout Phase 3. Verify each component/endpoint/scene in the running environment before committing it.

| Executor | Runtime command | What to verify |
|---|---|---|
| Executor-React | `npm run dev` | Dev server at `localhost:[port]` — verify in browser |
| Executor-Dotnet | `dotnet run` or `dotnet watch run` | API endpoints live — verify with HTTP client or browser |
| Executor-Database | migrations run; schema can be queried | Verify with psql/sqlite or dotnet migrations |
| Executor-Godot | `godot --path <project>` | Scene runs in Godot editor; test in-engine |

**Iterative commit loop:** For each logical unit (component / endpoint / migration / scene node): implement → verify running → write tests → lint + type check → commit to task branch. Never batch all implementation and verify at the end.

**Pre-PR readiness gate:** Before opening a PR, run the full suite (lint, type check, build, tests) and do a golden path walkthrough against the PLAN READ-AND-VERIFY acceptance criteria. Output a PRE-PR READINESS REPORT. Only open the PR when all items pass.

**Show to user on request:** The executor can always report the running URL/port and navigation instructions if the user asks to see the current state.

---

## Where things live

```
agent-workspace/
  CLAUDE.md              ← orchestration rules, agent roster, absolute prohibitions
  RESUME.md              ← this file
  agents/
    triage/skill.md
    triage-reviewer/skill.md
    tech-lead/skill.md
    tech-lead-reviewer/skill.md
    design/skill.md            ← produces design-spec.md artifact in Phase 4
    design-reviewer/skill.md
    game-design/skill.md       ← includes Game Design Concepts section; produces game-design.md artifact
    game-design-reviewer/      ← folder exists, skill.md not written
    executor-react/            ← folder exists, skill.md not written
    executor-dotnet/           ← folder exists, skill.md not written
    executor-database/         ← folder exists, skill.md not written
    executor-godot/            ← folder exists, skill.md not written
    review/                    ← folder exists, skill.md not written
  plans/
    README.md              ← plan file structure reference
  shared/
    agent-roles.md
    conventions.md
    glossary.md
```

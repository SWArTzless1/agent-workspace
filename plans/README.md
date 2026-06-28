# How to Write Good Plans

Plans live in this folder. Each project gets **one plan file**, named by the user and the Triage Agent together at the start of the first prompt: `plans/<chosen-name>.md`.

A plan file is not written in one go. It is a conversation between the user and the Triage Agent. The Triage Agent asks questions, the user answers, and together they fill the problem sections until each one is specific enough for the downstream agent to understand the problem they are being asked to solve.

The plan file is also the permanent record of all work done by every agent. Each agent that acts on the plan appends their output to the audit trail. Any agent picking up the plan at any point can read the full history of decisions, reviews, and solutions — in order.

When the plan is complete and the user has signed off, the Triage Agent spawns the Triage Reviewer — which independently verifies both the routing decision and the plan quality before any downstream agent begins work.

---

## Plan File Access Rules

| Agent | Access |
|---|---|
| Triage Agent | Read + Write (problem sections and Triage Notes only) |
| Tech Lead | Read + Write (Tech Lead solution section + `### Tech Lead Notes` sub-sections of routed executors only) |
| Design Agent | Read + Write (Design solution section + `### Design Notes` sub-section of Executor-React and Executor-Godot when UI work is involved) |
| Game Design Agent | Read + Write (Game Design solution section + `### Game Design Executor Notes` in Feasibility Report + `### Game Design Notes` in Executor-Godot) |
| Executor-Database | Read + Write (Database solution section only) |
| Executor-Dotnet | Read + Write (Dotnet solution section only) |
| Executor-Python | Read + Write (Python solution section only) |
| Executor-React | Read + Write (React solution section only) |
| Executor-Godot | Read + Write (Godot solution section only) |
| Triage Reviewer | **Read only** — never edits |
| Triage Reviewer | **Read only** — never edits |
| Tech Lead Reviewer | **Read only** — never edits |
| Design Reviewer | **Read only** — never edits |
| Game Design Reviewer | **Read only** — never edits |
| Review Agent | **Read only** — never edits |

Only **active agents** (Triage, Tech Lead, Design, Game Design, Executor-Database, Executor-Dotnet, Executor-Python, Executor-React, Executor-Godot) may write to the **Audit Trail** section. Review agents never write to the plan file — their verdicts and reports appear in the conversation, not in the file. No agent may modify content written by another agent in any other section.

---

## What Makes a Plan Good

A plan section has two parts: a *problem* (filled by Triage with the user) and a *solution* (filled later by the relevant downstream agent). Triage never fills the solution.

**A good problem section** leaves no doubt about what the downstream agent is being asked to figure out — from their specific perspective. The Tech Lead needs to understand the technical problem; the Design Agent needs to understand the user experience problem; executors need to understand the problem clearly enough to validate that the Tech Lead's solution actually addresses it.

Signs a problem section is ready:
- It describes what is missing or broken, not what to build.
- Ambiguous words (fast, clean, simple, good) are replaced with specifics.
- The agent's perspective is respected — the Tech Lead section is not written like a design brief; the Design section is not written like a technical spec.
- A downstream agent reading it cold would know exactly what question they are answering.

Signs a problem section needs more work:
- It uses phrases like "as needed", "TBD", "we'll figure it out later".
- It describes a solution instead of a problem.
- A reviewer would need to ask a follow-up question before understanding what the agent is being asked to solve.

**DEFERRED sections:** If a problem section cannot be filled yet, it may be marked `[DEFERRED — reason]`. This is only acceptable for agents that are **not** in the current routing sequence. If an agent is in the routing sequence, its problem section must be filled — not deferred. A DEFERRED section for a routed agent must be resolved before Phase 4 (routing) proceeds. Reviewer agents treat a DEFERRED section for any routed agent the same as a missing section.

---

## Naming the Plan File

On the first prompt, before filling any sections, the Triage Agent will ask:

> "What would you like to call this plan? This will be the filename: `plans/<your-name>.md`."

The name should be short, descriptive, and kebab-cased (e.g. `user-auth`, `inventory-system`, `level-editor`). The Triage Agent will suggest a name based on the prompt if the user is unsure.

Once named, the filename does not change even if the scope of the plan changes.

---

## How the Triage Agent Helps You Build the Plan

When a new project or feature prompt comes in, the Triage Agent will:

1. Agree on a filename with the user and create the plan file.
2. Identify which agent sections are needed for this work.
3. For each section, ask targeted questions to extract the problem from the right perspective — one question at a time.
4. Write answers into the plan file and show the user each section verbatim before moving on.
5. Apply the quality bar: "Would this agent understand the problem they are being asked to solve?"
6. Flag any section it cannot fill without more input, and ask explicitly.
7. Never move on from a section the user has not confirmed.

You can interrupt at any point to revise a previous section. The plan is a living document until the Triage Reviewer signs it off.

---

## Plan File Structure

Every plan file follows this structure. Only include sections for agents actually involved. The Audit Trail is always included.

```markdown
# Plan: <Descriptive Title>

**File:** plans/<chosen-name>.md
**Status:** Draft | Approved | In Progress | Complete
**Project folder:** projects/<project-name>/ *(fill once confirmed — may not exist yet when this file is created)*
**Created:** <YYYY-MM-DD> by <user name>

<!-- STATUS TRANSITIONS
  Draft       → set by Triage Agent on file creation
  Approved    → set by Triage Agent after user sign-off and Triage Reviewer approval
  In Progress → set by first Executor Agent when it creates its task branch
  Complete    → set by Triage Agent after all PRs are merged and user confirms done
-->

---

## Table of Contents

- [Overview](#overview)
- [Triage Notes](#triage-notes)
- [Tech Lead Plan](#tech-lead-plan) *(if applicable)*
- [Design Plan](#design-plan) *(if applicable)*
- [Game Design Plan](#game-design-plan) *(if applicable — Godot projects only)*
- [Feasibility Report](#feasibility-report) *(if Tech Lead + Design and/or Game Design are all in sequence)*
- [Database Plan](#database-plan) *(if applicable)*
- [Executor Plan — Dotnet](#executor-plan--dotnet) *(if applicable)*
- [Executor Plan — Python](#executor-plan--python) *(if applicable)*
- [Executor Plan — React](#executor-plan--react) *(if applicable)*
- [Executor Plan — Godot](#executor-plan--godot) *(if applicable)*
- [Review Checklist](#review-checklist)
- [Audit Trail](#audit-trail)

---

## Overview

<!-- WRITTEN BY: Triage Agent -->
One paragraph. What problem is being solved, why, and for whom. Written in plain language without technical jargon.

---

## Triage Notes

<!-- WRITTEN BY: Triage Agent -->
- **Intent classification:** (architecture / design / implementation / bug fix / refactoring / mixed)
- **Agent sequence:** ordered list of agents to be activated
- **Confidence:** High / Medium / Low — reason if not High
- **Scope estimate:** Small / Medium / Large — basis
- **Key constraints or risks the Triage Agent identified:**
- **Known gaps or deferred items:**

---

## Tech Lead Plan

<!-- PROBLEM WRITTEN BY: Triage Agent | SOLUTION WRITTEN BY: Tech Lead Agent -->

### Problem (Triage)
- **Technical problem:** What needs to exist technically that does not exist now?
- **Context:** What does the Tech Lead need to know about the existing system or codebase?
- **Tech stack decisions already made:** What is fixed and must not change?
- **Constraints:** Performance, compatibility, patterns the Tech Lead must respect
- **Non-goals:** What are we explicitly not building?
- **Expected steps for the Tech Lead:** Understand the technical problem → evaluate options within constraints → propose architecture or approach → define tasks for executors

### Solution (Tech Lead — filled after receiving this problem)
*The Tech Lead will complete this section. It must include: chosen architecture/approach with rationale, technology decisions, rejected alternatives, identified risks, security considerations, and open questions.*

### Executor Dependency Map (Tech Lead Agent — filled after tech plan is approved)
*The Tech Lead will define the execution order for all routed executors. The goal is maximum parallelism: every executor should have meaningful standalone work it can begin immediately.*

| Executor | MVP pass (starts immediately) | Completion pass trigger | Dependency artifact |
|---|---|---|---|
| Executor-Database | [what can be built standalone] | N/A — full task in MVP | — |
| Executor-Dotnet | [what can be built with mocks/stubs] | After [executor] MVP approved | [specific artifact: schema, contract, etc.] |
| Executor-Python | [what can be built with mock services] | After [executor] MVP approved | [specific artifact: schema, contract, etc.] |
| Executor-React | [what can be built with mock API] | After [executor] completion approved | [specific artifact: endpoint contracts, etc.] |
| Executor-Godot | [what can be built with stub data] | After [executor] MVP approved | [specific artifact] |

*Only include rows for executors in the current routing sequence. Executors with no dependencies have "N/A" in the completion pass column.*

---

## Design Plan

<!-- PROBLEM WRITTEN BY: Triage Agent | SOLUTION WRITTEN BY: Design Agent -->

### Problem (Triage)
- **User problem:** What is the user currently experiencing that is frustrating, confusing, or missing?
- **User goal:** What does the user want to do that they cannot do now?
- **Who is the user:** Their context, familiarity, and expectations
- **What success looks like for the user:** What should they feel or be able to do after this feature exists?
- **Constraints:** Design system, accessibility requirements, brand rules, platform
- **Expected steps for the Design Agent:** Understand the user need → explore interaction patterns → propose UI/UX approach → define component structure

### Solution (Design Agent — filled after receiving this problem)
*The Design Agent will complete this section. It must include: proposed UI/UX approach, component structure, interaction design, and how the solution addresses the user problem.*

---

## Game Design Plan

<!-- PROBLEM WRITTEN BY: Triage Agent | SOLUTION WRITTEN BY: Game Design Agent — Godot projects only -->

### Problem (Triage)
- **Gameplay problem:** What mechanic, system, or player experience is missing or broken?
- **Player goal:** What should the player be able to do or feel after this is implemented?
- **What exists now:** Current state of relevant systems, mechanics, or progression — what is working, what is absent
- **Constraints:** Target platform, performance limits, scope limits, existing design decisions that must not change
- **Expected steps for the Game Design Agent:** Understand the player experience problem → specify mechanics and rules → define progression and balance → produce a game design brief for Executor-Godot

### Solution (Game Design Agent — filled after receiving this problem)
*The Game Design Agent will complete this section. It must include: core mechanic or system specification, rules and interactions, player progression or balance parameters, and how the design addresses the stated player experience problem.*

---

## Feasibility Report

<!-- Only include when Tech Lead + Design and/or Game Design are all in the routing sequence -->
<!-- Tech Lead Feasibility Assessment written AFTER Design and Game Design complete their independent passes and reviewer cycles -->
<!-- Design Executor Notes written BY: Design Agent (design-notes-only mode) AFTER feasibility assessment is user-approved -->
<!-- Game Design Executor Notes written BY: Game Design Agent (notes-only mode) AFTER feasibility assessment is user-approved — Godot projects only -->

### Tech Lead Feasibility Assessment (Tech Lead — feasibility mode)
*Written after all planning agents complete their independent passes. Assesses whether each design and game design decision can be built within the approved technical architecture.*

| Decision | Source | Verdict | Notes |
|---|---|---|---|
| [design or game design decision] | Design / Game Design | Feasible / Feasible with constraint / Infeasible | [constraint or alternative] |

**Summary:** [one paragraph — overall feasibility, number of conflicts, what requires revision before executors can start]

### Design Executor Notes (Design Agent — design-notes-only mode)
*Written after the Tech Lead Feasibility Assessment is user-approved. Distils the design decisions that directly affect executor implementation — component names, interaction rules the code must enforce, accessibility requirements with code impact.*
*Leave blank until Design Agent writes here.*

### Game Design Executor Notes (Game Design Agent — notes-only mode)
*Written after the Tech Lead Feasibility Assessment is user-approved — Godot projects only. Distils the mechanic and progression rules that executors must enforce in code: stat ranges, win/fail conditions, rule logic, timing constraints.*
*Leave blank until Game Design Agent writes here. Omit this sub-section entirely for non-Godot projects.*

---

## Database Plan

<!-- PROBLEM WRITTEN BY: Triage Agent | TECH LEAD NOTES WRITTEN BY: Tech Lead Agent | SOLUTION WRITTEN BY: Executor-Database -->

### Problem (Triage)
- **Data problem:** What data needs to be stored, retrieved, or related that currently isn't?
- **Target stack:** PostgreSQL + EF Core / SQLite (Godot local) / Supabase (Godot online)
- **What the data represents:** Plain language description of the things that need to be persisted and why
- **Known constraints:** Compliance, performance, scale requirements
- **Expected steps for Executor-Database:** Understand the data problem → review the Tech Lead's solution → validate the proposed schema solves the problem → design and implement schema, migrations, seed data

### Tech Lead Notes (Tech Lead Agent — filled after tech plan is approved)

**MVP pass** (starts immediately — no dependency required):
*What Executor-Database can build standalone. For database work this is usually the full task (schema + migrations), as it is typically the root dependency rather than a consumer.*
- Specific task: [what to implement]
- Interface contracts to produce: [schema tables, fields, and relationships that downstream executors will depend on]
- Acceptance criteria for MVP pass: [what done looks like]

**Completion pass**: N/A — database work is typically fully standalone.

**Key technical constraints:** [non-negotiable decisions from the tech plan this executor must respect]

### Solution (Executor-Database — filled after Tech Lead approval)
*Executor-Database will complete this section. It must confirm: (a) how the Tech Lead's solution addresses the data problem, (b) schema design, (c) migration plan with rollback, (d) branch name.*

---

## Executor Plan — Dotnet

<!-- PROBLEM WRITTEN BY: Triage Agent | TECH LEAD NOTES WRITTEN BY: Tech Lead Agent | SOLUTION WRITTEN BY: Executor-Dotnet -->

### Problem (Triage)
- **Backend problem:** What API capability or service needs to exist that does not exist now?
- **Who calls it and why:** Consumers of this API and what they need from it
- **User-facing outcome:** What does a working implementation enable for the end user?
- **Known constraints:** Auth rules, rate limits, existing API contracts that must not break
- **Expected steps for Executor-Dotnet:** Understand the backend problem → review the Tech Lead's solution → validate the approach solves the problem → implement endpoints, services, and models

### Tech Lead Notes (Tech Lead Agent — filled after tech plan is approved)

**MVP pass** (starts immediately):
*What Executor-Dotnet can build before the database schema is finalised — using an in-memory store, hardcoded seed data, or repository stubs.*
- Specific task: [what to implement standalone]
- Mocking approach: [what to stub or use in-memory]
- Interface contracts to produce: [endpoint signatures and service contracts downstream executors will depend on]
- Acceptance criteria for MVP pass: [what done looks like]

**Completion pass** (triggered after Executor-Database MVP approved):
- Specific task: [what to wire up once the real schema is available]
- Dependency artifact: [schema tables and fields from Executor-Database]
- Acceptance criteria for completion pass: [what done looks like with real data layer]

**Key technical constraints:** [non-negotiable decisions from the tech plan this executor must respect]

### Solution (Executor-Dotnet — filled after Tech Lead approval)
*Executor-Dotnet will complete this section. It must confirm: (a) how the Tech Lead's solution addresses the backend problem, (b) endpoints and services to implement, (c) acceptance criteria, (d) branch name.*

---

## Executor Plan — Python

<!-- PROBLEM WRITTEN BY: Triage Agent | TECH LEAD NOTES WRITTEN BY: Tech Lead Agent | DESIGN NOTES WRITTEN BY: Design Agent (if applicable) | SOLUTION WRITTEN BY: Executor-Python -->

### Problem (Triage)
- **Python service problem:** What API capability, service, script, or data pipeline needs to exist that does not exist now?
- **Who calls it and why:** Consumers of this service and what they need from it
- **User-facing outcome:** What does a working implementation enable for the end user (or calling service)?
- **Known constraints:** Auth rules, rate limits, existing API contracts that must not break, environment requirements (Python version, target runtime)
- **Expected steps for Executor-Python:** Understand the service problem → review the Tech Lead's solution → validate the approach solves the problem → implement endpoints, services, and models

### Tech Lead Notes (Tech Lead Agent — filled after tech plan is approved)

**MVP pass** (starts immediately):
*What Executor-Python can build before the database schema is finalised — using mock data, in-memory stores, or hardcoded responses.*
- Specific task: [what to implement standalone]
- Mocking approach: [what to stub or mock in-memory]
- Interface contracts to produce: [endpoint signatures, Pydantic schemas, and service contracts downstream executors will depend on]
- Acceptance criteria for MVP pass: [what done looks like]

**Completion pass** (triggered after Executor-Database MVP approved):
- Specific task: [what to wire up once the real schema is available]
- Dependency artifact: [schema tables and fields from Executor-Database]
- Acceptance criteria for completion pass: [what done looks like with real data layer]

**Key technical constraints:** [non-negotiable decisions from the tech plan this executor must respect]

### Design Notes (Design Agent — filled after design is approved, if applicable)
*The Design Agent will complete this section only when the Python service is called by a user-facing client and the response shape directly affects the UX (e.g., error message format, field naming that maps to UI labels). Omitted when the Python service is purely internal.*

### Solution (Executor-Python — filled after Tech Lead approval)
*Executor-Python will complete this section. It must confirm: (a) how the Tech Lead's solution addresses the service problem, (b) endpoints and modules to implement, (c) acceptance criteria, (d) branch name.*

---

## Executor Plan — React

<!-- PROBLEM WRITTEN BY: Triage Agent | TECH LEAD NOTES WRITTEN BY: Tech Lead Agent | DESIGN NOTES WRITTEN BY: Design Agent | SOLUTION WRITTEN BY: Executor-React -->

### Problem (Triage)
- **Frontend problem:** What UI or interaction does not exist or does not work correctly for the user?
- **User story:** As a [user], I want to [do something], so that [outcome].
- **What the user sees and does:** Plain language description of the experience — what they click, see, and what happens
- **Known constraints:** Browser support, existing component library, API contracts from the .NET layer
- **Expected steps for Executor-React:** Understand the frontend problem → review Tech Lead's solution and Design output → validate the approach solves the user problem → implement components and pages

### Tech Lead Notes (Tech Lead Agent — filled after tech plan is approved)

**MVP pass** (starts immediately):
*What Executor-React can build before the real API endpoints exist — using hardcoded mock responses or a local mock server.*
- Specific task: [what to implement standalone]
- Mocking approach: [what API shapes to mock and how]
- Acceptance criteria for MVP pass: [what done looks like with mocked data]

**Completion pass** (triggered after Executor-Dotnet [MVP/completion] approved):
- Specific task: [what to wire up once the real endpoints are available]
- Dependency artifact: [specific endpoint contracts: method, path, request/response shapes, auth requirements]
- Acceptance criteria for completion pass: [what done looks like with real API]

**Key technical constraints:** [non-negotiable decisions from the tech plan this executor must respect]

### Design Notes (Design Agent — filled after design is approved)
*The Design Agent will complete this section with a distilled, implementation-ready design brief for Executor-React, including: component list with purposes, interaction specifications, accessibility requirements, and design system usage (reused / extended / new components).*

### Solution (Executor-React — filled after Tech Lead and Design approval)
*Executor-React will complete this section. It must confirm: (a) how the Tech Lead's and Design Agent's solutions address the frontend problem, (b) components and pages to implement, (c) acceptance criteria, (d) branch name.*

---

## Executor Plan — Godot

<!-- PROBLEM WRITTEN BY: Triage Agent | TECH LEAD NOTES WRITTEN BY: Tech Lead Agent | DESIGN NOTES WRITTEN BY: Design Agent (UI only) | GAME DESIGN NOTES WRITTEN BY: Game Design Agent | SOLUTION WRITTEN BY: Executor-Godot -->

### Problem (Triage)
- **Gameplay / system problem:** What behaviour, mechanic, or system does not exist or does not work correctly?
- **Player experience:** What should the player feel or be able to do after this is implemented?
- **What exists now:** Current state — what scenes or scripts are relevant, what is missing
- **Known constraints:** Target platform, performance limits, existing scene structure that must not break
- **Expected steps for Executor-Godot:** Understand the gameplay/system problem → review the Tech Lead's solution → validate the approach solves the problem → implement scenes, scripts, and data layer

### Tech Lead Notes (Tech Lead Agent — filled after tech plan is approved)

**MVP pass** (starts immediately):
*What Executor-Godot can build before the data layer or external services are ready — using hardcoded stub data, local mock resources, or placeholder signals.*
- Specific task: [what to implement standalone]
- Mocking approach: [what to stub: scenes, signals, data sources]
- Interface contracts to produce: [scene/script interfaces and signal contracts downstream systems depend on]
- Acceptance criteria for MVP pass: [what done looks like with stub data]

**Completion pass** (triggered after [dependency executor] MVP/completion approved):
- Specific task: [what to wire up once the real data layer or services are available]
- Dependency artifact: [specific artifact: database API, service contract, signal interface]
- Acceptance criteria for completion pass: [what done looks like with real dependencies]

**Key technical constraints:** [non-negotiable decisions from the tech plan this executor must respect]

### Design Notes (Design Agent — filled after feasibility report is approved, UI work only)
*The Design Agent will complete this section only when the Godot work includes player-facing UI (menus, HUD, inventory, etc.). Distils the design decisions with direct implementation impact: component list, interaction rules the code must enforce, accessibility requirements with code impact. Omitted when the Godot work has no UI component.*

### Game Design Notes (Game Design Agent — filled after feasibility report is approved)
*The Game Design Agent will complete this section with the mechanic and progression rules Executor-Godot must enforce in code: stat ranges, win/fail conditions, rule logic, timing constraints, and any balance parameters the implementation must respect. Derived from the Game Design solution and the Game Design Executor Notes in the Feasibility Report.*

### Solution (Executor-Godot — filled after Tech Lead, Design, and Game Design approval)
*Executor-Godot will complete this section. It must confirm: (a) how the Tech Lead's solution addresses the gameplay/system problem, (b) scenes and scripts to implement, (c) acceptance criteria, (d) branch name.*

---

## Review Checklist

<!-- WRITTEN BY: Triage Agent with user input -->
Specific things the Review Agent and Tech Lead Agent must check beyond their defaults.

- **Code-specific concerns:** (e.g. "make sure the auth token is never logged")
- **Architecture alignment checks:** (e.g. "confirm no direct DB calls from the component layer")
- **Security focus areas:** (e.g. "all user input must be sanitised before use")

---

## Contested Gaps

<!-- WRITTEN BY: Triage Agent — only include this section if the Plan Review cycle produced contested gaps -->
<!-- Reviewer agents never write here -->

*Include only if the Triage Agent rejected or contested one or more gaps raised by the Triage Reviewer.*

| Gap | Triage Position | User Resolution |
|---|---|---|
| [Gap name] | [Reason for rejection or contest] | [What the user decided] |

---

## Known Risks

<!-- WRITTEN BY: Triage Agent — only include if the plan was approved with unresolved gaps -->
<!-- Reviewer agents never write here -->

*Include only if the user chose to proceed after two Plan Review cycles without full approval, or explicitly accepted a gap as a known risk.*

- [Risk 1]: [Description and reason it was accepted rather than resolved]

---

## Audit Trail

<!-- ACTIVE AGENTS APPEND HERE — Triage, Tech Lead, Design, and Executor agents only -->
<!-- Reviewer agents never write to this section — their verdicts appear in conversation -->
<!-- Entries are append-only — never edit or remove a prior entry -->

| # | Date (YYYY-MM-DD) | Agent | Action | Summary |
|---|---|---|---|---|
| 1 | <date> | Triage Agent | Plan created | Named file, filled Overview, Triage Notes, and problem sections |
| 2 | <date> | Triage Agent | Routing complete | Routed to: <sequence>. Confidence: <rating>. Scope: <estimate>. |

```

---

## Tips for Each Section

### Problem sections (all agents)
The problem is not the solution. "Build a login page" is a solution. "Users cannot access the application without creating an account each time, including on shared devices" is a problem. Describe what is broken or missing and for whom — let the downstream agent decide how to fix it.

### Tech Lead Plan
The Tech Lead makes better decisions when you tell them what is fixed and what is flexible. An uncommunicated constraint is a constraint they will get wrong.

### Design Plan
Describe the user's frustration, not the UI. "The user has to navigate three screens to complete a task that logically takes one step" is more useful than "the navigation is confusing."

### Executor Plans
The user story in the React plan is the most important input. Write it out in full: "As a [type of user], I want to [specific action], so that [specific outcome]." Vague stories produce vague implementations.

### Review Checklist
Think about what would make you nervous about this specific change. Write those things down. The reviewers will check their standard list regardless — this section is for concerns unique to this task.

### Audit Trail
Active agents (Triage, Tech Lead, Design, and Executors) append one row when they complete their work. Reviewer agents do not write here — their verdicts appear in the conversation. Any agent reading the plan can follow the audit trail to understand every decision made before them, in order.

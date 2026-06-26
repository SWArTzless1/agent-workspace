# How to Write Good Plans

Plans live in this folder. Each project gets one plan file: `plans/<project-name>.md`.

A plan file is not written in one go. It is a conversation between the user and the Triage Agent. The Triage Agent asks questions, the user answers, and together they fill out each section until it is specific enough for downstream agents to act on without guessing.

When the plan is complete, the Triage Agent spawns the Plan Review Agent to find gaps before any real work begins.

---

## What Makes a Plan Good

A good plan leaves no room for interpretation that could cause an agent to make the wrong call. Ask yourself: if I handed this section to the agent with zero other context, would they know exactly what to build and how?

Signs a plan section is ready:
- Every decision has a clear reason behind it.
- The acceptance criteria describe an observable outcome, not an intention.
- Ambiguous words (fast, clean, simple, good) are replaced with specifics.
- Dependencies between agents are explicit.

Signs a plan section needs more work:
- It uses phrases like "as needed", "TBD", "we'll figure it out later".
- It describes what to do but not why.
- A reviewer would need to ask a follow-up question to understand scope.

---

## How the Triage Agent Helps You Build the Plan

When a new project or feature prompt comes in, the Triage Agent will open (or create) the plan file and walk through each section with you. It will:

1. Ask what agents are likely to be involved.
2. For each agent section, ask targeted questions to extract the information that agent needs.
3. Write your answers into the plan file in structured form.
4. Flag any section it cannot fill without more input and ask for it explicitly.
5. Never move on from a section until you confirm it is complete enough.

You can interrupt at any point to revise a previous section. The plan is a living document until the Plan Review Agent signs it off.

---

## Plan File Structure

Every plan file follows this structure. Only include sections for agents that are actually involved in this project or task.

```markdown
# Plan: <Project or Feature Name>

**Status:** Draft | In Review | Approved
**Project folder:** projects/<project-name>/
**Last updated:** <date>

---

## Overview

One paragraph. What is being built, why, and for whom. Written in plain language.

---

## Triage Notes

- Intent classification: (architecture / design / implementation / mixed)
- Agents involved: list the agents that will be activated, in order
- Key constraints or risks the Triage Agent identified

---

## Tech Lead Plan

What the Tech Lead needs to know to make good decisions.

- **Goal:** What technical outcome are we aiming for?
- **Tech stack:** What is already decided? What is open?
- **Constraints:** Performance, compatibility, team familiarity, existing codebase patterns
- **Non-goals:** What are we explicitly not doing in this task?
- **Open questions for the Tech Lead to resolve:**

---

## Design Plan

What the Design Agent needs to produce the right output.

- **Goal:** What should the user experience feel like?
- **Scope:** Which screens, flows, or components are in scope?
- **Style constraints:** Existing design system, brand rules, accessibility requirements
- **Reference material:** Links or descriptions of comparable designs
- **Open questions for the Design Agent to resolve:**

---

## Database Plan

What the Executor-Database agent needs to design and implement the data layer.

- **Target stack:** PostgreSQL + EF Core / SQLite (Godot local) / Supabase (Godot online)
- **Entities / tables in scope:** List each, with a one-line description of what it stores
- **Relationships:** Foreign keys, join tables, cardinality
- **Indexes required:** Which columns will be queried or filtered frequently?
- **Constraints:** Unique fields, non-null requirements, enums
- **Seed data needed:** What baseline data must exist for dev / test?
- **Migration rollback plan:** How should this migration be reversed if something goes wrong?
- **Branch name:** task/<short-description>
- **Dependencies:** Must be approved before API or frontend work begins (unless Tech Lead plan says otherwise)

---

## Executor Plan — Dotnet

What the Executor-Dotnet agent needs to implement the backend API.

- **Implementation goal:** Which endpoints / services should exist when this is done?
- **Acceptance criteria:** Bullet list of observable, testable outcomes (e.g. "GET /api/users returns a 200 with a paginated list")
- **Controllers / services in scope:** List each with a one-line description
- **EF Core models affected:** Which entities will this agent create or modify?
- **Auth / authorisation rules:** Who can call each endpoint?
- **Files / systems out of scope:** What must not be changed?
- **Branch name:** task/<short-description>
- **Dependencies:** Database schema must be merged (or at least approved) before this work begins

---

## Executor Plan — React

What the Executor-React agent needs to implement the frontend.

- **Target executor:** Executor-React
- **Implementation goal:** What UI / behaviour should exist when this is done?
- **Acceptance criteria:** Bullet list of observable, testable outcomes
- **Components / pages in scope:** List each with a one-line description
- **API endpoints consumed:** Which backend endpoints will the frontend call?
- **Files / systems out of scope:** What must not be changed?
- **Branch name:** task/<short-description>
- **Dependencies:** .NET API must be available (or mocked) before this work begins

---

## Executor Plan — Godot

What the Executor-Godot agent needs to implement.

- **Target executor:** Executor-Godot
- **Implementation goal:** What gameplay, UI, or system should exist when this is done?
- **Acceptance criteria:** Bullet list of observable, testable outcomes
- **Scenes / scripts in scope:** List each with a one-line description
- **Data layer:** SQLite local / Supabase online / none
- **Files / systems out of scope:** What must not be changed?
- **Branch name:** task/<short-description>
- **Dependencies:** Database schema (if any) must be approved before this work begins

---

## Review Checklist

Specific things the Review Agent and Tech Lead Agent must check beyond their defaults.

- **Code-specific concerns:** (e.g. "make sure the auth token is never logged")
- **Architecture alignment checks:** (e.g. "confirm no direct DB calls from the component layer")
- **Security focus areas:** (e.g. "all user input must be sanitised before use")
```

---

## Tips for Each Agent Section

### Tech Lead Plan
The Tech Lead makes better decisions when you tell them what is fixed and what is flexible. Be explicit about constraints — a constraint the Tech Lead has to infer is a constraint they might get wrong.

### Design Plan
Describe the feeling and function you want, not the implementation. "A clean card layout" is less useful than "a card component that shows title, status badge, and a single CTA, consistent with the existing dashboard cards."

### Executor Plan
Acceptance criteria are the most important part. Write them as: "When [action], [observable result] happens." Vague goals produce vague code.

### Review Checklist
Think about what would make you nervous about this specific change. Write those things down. The reviewers will check their standard list regardless — this section is for concerns that are unique to this task.

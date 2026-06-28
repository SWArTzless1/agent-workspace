# Shared Glossary

Terms used across agents, skill files, and plan files in this workspace. Agents should use these definitions consistently when writing plans, producing reports, or communicating with the user.

---

## Workspace Concepts

**Agent**
A cold LLM session given a specific role by its skill file. Agents in this workspace fall into two categories: collaborative agents (spawned by the main conversation to do planning or implementation work) and sub-agents (spawned by an agent to review its own output). Agents do not share memory between sessions — all context comes from the skill file and the spawn prompt.

**Audit Trail**
The append-only log section at the bottom of every plan file. Active agents (Triage, Tech Lead, Design, Game Design, and Executors) append one row when they complete their work. Reviewer agents never write to it. Any agent picking up the plan can read the audit trail to understand every decision made before them, in order.

**Brief-review mode**
A lightweight activation mode for the Tech Lead, Design Agent, and Game Design Agent. Runs during new project setup, before Triage. The agent reads the draft `project-brief.md` and asks 3–5 domain-focused clarifying questions to help sharpen the brief before planning begins. Does not produce a plan; does not write to any file.

**Collaborative agent**
An agent spawned and sequenced by the main conversation (Claude Code). Examples: Tech Lead, Design Agent, all Executor agents. Not subject to the per-session sub-agent limit. Each Phase Checkpoint in the main conversation introduces one or more collaborative agents.

**Completion pass**
The second implementation pass for an executor that has a dependency on another executor's output (typically Executor-Database). The completion pass branches from the MVP task branch and wires the real dependency artifact (database schema, API contract) in place of the stub or mock used in the MVP pass.

**Executor**
An agent that writes code. The five executors in this workspace are Executor-React, Executor-Dotnet, Executor-Python, Executor-Database, and Executor-Godot. Each executor works on its own task branch, opens a pull request, and spawns a Review Agent sub-agent on completion.

**Executor Dependency Map**
A table in the Tech Lead's plan section that defines which executors can start immediately (MVP pass) and what triggers each completion pass. The main conversation reads this map to sequence completion pass checkpoints after MVP passes are approved.

**Feasibility review**
A phase run after all planning agents (Tech Lead, Design, Game Design) have completed their independent passes and been approved by their respective reviewers. The Tech Lead reads all approved plans, identifies conflicts between the technical architecture and the design or game design decisions, and produces a feasibility report for direct user review. No reviewer agent is involved at this stage.

**MVP pass**
The first implementation pass for an executor. Builds what can be built standalone — using mocks, stubs, or hardcoded data where real dependency artifacts do not yet exist. Every executor starts its MVP pass simultaneously when the executor phase begins.

**North star**
The one-sentence summary at the end of a `project-brief.md` that captures the essence of what the project is and why it matters. Agents use this as a quick reference when assessing whether a decision is aligned with the project's purpose.

**Orchestrator**
The main conversation (Claude Code) — the persistent assistant session the user is talking to. The only entity that spawns collaborative agents. Triage handles planning; the orchestrator handles all downstream agent sequencing.

**Phase Checkpoint**
A structured gate presented by the main conversation (orchestrator) before spawning the next collaborative agent. Requires explicit user approval ("yes / re-route via Triage / stop here") before any work continues. Appears in three forms: Standard (single agent), Parallel (multiple agents simultaneously), and Completion Trigger (a dependency MVP pass approved, unlocking a completion pass).

**PLAN READ-AND-VERIFY block**
A structured output produced by each executor at the end of Phase 1, summarising what they read from the plan, what they found in the codebase survey, and what they intend to build. The user must explicitly confirm this block before the executor writes any code.

**Plan file**
A Markdown file in `plans/` that records everything about a project or feature: the problem (written by Triage with the user), the solution (written by each downstream agent in their own section), and the full audit trail. One plan file per project — never create a second one alongside an existing one.

**Project brief**
A document at `projects/<name>/docs/project-brief.md` that describes what a project is trying to achieve at a goal level. Written before Triage begins. Contains: problem, users, success criteria, constraints, out-of-scope items, and a one-sentence north star. No technology decisions — those belong to the Tech Lead. Every agent reads this before acting and uses it to challenge instructions that appear to contradict the project's goals.

**Review Agent**
A sub-agent spawned by an executor after it opens its pull request. Performs independent code review across six dimensions: plan adherence, coding conventions, documentation, testing, security (always a blocker), and branch/PR hygiene. Posts its verdict to the GitHub PR (`--approve`, `--comment`, or `--request-changes`). Never merges.

**Routing**
The Triage Agent's decision about which agents will handle a given prompt, in what order. Written into the `Triage Notes` section of the plan file and verified by the Triage Reviewer before any downstream agent begins work.

**Skill file**
A Markdown file at `agents/<name>/skill.md` that defines a spawned agent's role, behaviour, phases, rules, and edge cases. A spawned agent reads its skill file top-to-bottom before taking any action. The skill file is the agent's only persistent context — it has no memory of prior sessions.

**Spawn Request**
The formal block an agent must output and wait for user approval on before spawning its designated sub-agent (reviewer). Contains the sub-agent name and the exact prompt that will be sent. No agent spawns a sub-agent without explicit user approval via this protocol.

**Sub-agent**
A reviewer agent spawned by another agent to verify its output. Sub-agents are always reviewer agents (Triage Reviewer, Tech Lead Reviewer, Design Reviewer, Game Design Reviewer, Review Agent). Limit: 1 per session. Sub-agents never write to plan files.

**Task branch**
A git branch created by an executor before writing any code. Naming convention: `task/<short-description>` (e.g., `task/user-login-api`). All executor commits go to the task branch. The executor opens a PR targeting `main` when implementation is complete. Executors never commit to `main` directly.

**USER CHECKPOINT**
A hard stop that requires an explicit response from the user before work continues. Distinct from a Phase Checkpoint (which is between agents) — a USER CHECKPOINT can appear at any point in any agent's session when ambiguity, risk, or a brief conflict is encountered. No agent may continue past a USER CHECKPOINT without a clear user response.

---

## Software Development

**Branch**
A parallel line of development in a git repository. Branches allow work to be done in isolation and merged back when complete. In this workspace, executors work on task branches; reviewers check out those branches via `gh pr checkout` for automated testing.

**CI/CD (Continuous Integration / Continuous Deployment)**
Automated pipelines that run tests and deploy code when changes are pushed. A CI pipeline typically runs linting, type checking, and tests on every PR. CD automatically deploys passing builds to an environment.

**Dependency injection**
A pattern where a component's dependencies (database connections, service instances) are passed in rather than created internally. Makes code more testable and decoupled. Used throughout the .NET (via `IServiceCollection`) and Python (via FastAPI `Depends()`) executors.

**Endpoint**
A specific URL path and HTTP method combination that a server exposes for clients to call (e.g., `POST /api/users`). Executor-Dotnet and Executor-Python implement endpoints; Executor-React consumes them.

**Linter**
A tool that statically analyses code for style violations, potential bugs, and convention breaches without running it. Examples: ESLint (TypeScript), Ruff (Python), dotnet format (C#). Linter violations must be fixed before committing.

**Migration**
A versioned script that modifies a database schema in a controlled, repeatable way. Migrations can be applied forward (to upgrade) and rolled back (to undo). Executor-Database writes all schema changes as migrations, never as direct schema edits.

**Mock / stub**
A test double that replaces a real dependency with a controlled substitute. A stub returns hardcoded data. A mock records calls and can assert they were made correctly. In MVP passes, executors use mocks or stubs in place of the real data layer or external services.

**ORM (Object-Relational Mapper)**
A library that maps database tables to code objects, allowing queries to be written in the application's language rather than raw SQL. Examples: SQLAlchemy (Python), Entity Framework Core (C#).

**PR (Pull Request)**
A request to merge a task branch into `main`. PRs in this workspace are opened by executors after implementation is complete and reviewed by the Review Agent and Tech Lead (alignment review mode) before the user decides to merge.

**Repository pattern**
An architectural pattern that abstracts data access behind an interface. Service-layer code calls repository methods; the repository handles the actual database queries. Used in Executor-Dotnet (C#) and Executor-Python (FastAPI) to keep business logic independent of the data layer.

**REST (Representational State Transfer)**
An architectural style for APIs that uses HTTP methods (GET, POST, PUT, DELETE, PATCH) and resource-based URLs. The standard API style used by Executor-Dotnet and Executor-Python.

**Rollback**
Undoing a migration to restore the schema to its previous state. Every migration Executor-Database writes must include a rollback path.

**Type checker**
A tool that verifies the types of variables and function signatures without running the code. Examples: TypeScript compiler (`tsc`), mypy (Python). Type errors must be resolved before committing.

---

## UX and Design

**Accessibility (a11y)**
The practice of designing products usable by people with disabilities, including those using screen readers, keyboard navigation, or high-contrast displays. WCAG 2.1 AA is the minimum standard for this workspace. Common requirements: semantic HTML, `aria-*` attributes, keyboard operability, sufficient colour contrast.

**Affordance**
A design property that signals to users how an element can be interacted with. A button that looks pressable has good affordance. An icon that looks like a button but isn't is an affordance failure.

**Component**
A reusable UI building block. In React, a function that renders markup and accepts props. A design system defines the canonical set of components — agents do not invent new component types without checking whether an existing one can be extended.

**Design system**
A set of reusable design decisions codified as tokens (colours, spacing, typography) and components (buttons, inputs, cards). Stored at `projects/<name>/docs/design-system.md`. All UI work must use design system values — never invent new colours or font sizes.

**Error state**
The visual state of a UI component or screen when something has gone wrong. Good error states tell the user what happened and what to do next. A generic "something went wrong" message is an error state failure.

**Interaction flow**
The sequence of steps a user takes to complete a task — what they see, what they click, what the system does in response. Interaction flows are specified by the Design Agent and implemented by Executor-React or Executor-Godot.

**Loading state**
The visual state of a UI component while data is being fetched or an action is being processed. Loading states must be handled explicitly — never leave the user staring at a blank or frozen screen.

**WCAG (Web Content Accessibility Guidelines)**
The internationally recognised standard for web accessibility, published by the W3C. WCAG 2.1 AA is the baseline for this workspace: perceivable, operable, understandable, and robust.

---

## Game Design

**Balance**
The tuning of game numbers — damage values, cooldowns, prices, probabilities — so that the game is appropriately challenging and no single strategy dominates unintentionally.

**Core loop**
The primary repeating player action cycle. Most games have a micro-loop (second-to-second actions), a macro-loop (session-level goals), and a meta-loop (long-term progression). Features should be designed in relation to which loop they belong to.

**Flow state**
The zone of optimal engagement — challenge neither too easy (boredom) nor too hard (frustration). Well-designed difficulty increases as player skill increases (Csikszentmihalyi). Features should target the flow zone for the described player, not a generic player profile.

**Game Design Document (GDD)**
A design document that specifies a game's mechanics, systems, rules, and player experience. In this workspace, a GDD or GDD section lives at `projects/<name>/docs/game-design.md`. The Game Design Agent produces this; Executor-Godot implements from it.

**Game feel**
The tactile, moment-to-moment sensation of controlling a game — responsiveness, weight, feedback. Often called "juice." Not easily reducible to a single number; described in terms of what the player should feel (snappy, weighty, floaty, satisfying).

**MDA (Mechanics → Dynamics → Aesthetics)**
A design framework for analysing and building games. Mechanics are the rules and actions the game defines. Dynamics are the emergent behaviour that arises when players interact with those mechanics. Aesthetics are the emotions and experiences the player has as a result. Design from the aesthetics inward.

**Onboarding**
The process by which a new player learns a game's rules and controls. Good onboarding teaches through play rather than explicit instruction. The Game Design Agent considers onboarding when specifying new mechanics.

**Player fantasy**
The power or experience the game promises the player. Every mechanic should serve or reinforce the player fantasy. A mechanic that is technically balanced but contradicts the fantasy creates dissonance.

**Progression**
The way a game's difficulty, narrative, or available mechanics change over time as the player advances. Can refer to: session progression (within a single play session), level progression (across levels), or meta-progression (across multiple sessions or runs).

**Signal / feedback**
The game's response to player actions — visual effects, audio cues, screen shake, score changes. Signals confirm that an action was registered and show its consequences. Missing feedback makes a game feel broken even when it is technically correct.

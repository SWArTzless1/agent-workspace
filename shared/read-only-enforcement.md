# Read-Only Plan File Enforcement — Implementation Reference

This document describes how to technically enforce the read-only constraint on plan files for reviewer agents. Currently, the constraint is implemented through skill file instructions only, which are not enforceable at the runtime level. This document is a reference for implementing proper technical enforcement when the workspace matures.

---

## The Problem

Five reviewer agents — Triage Reviewer, Tech Lead Reviewer, Design Reviewer, and Review Agent — must never write to any file under `plans/`. Currently this rule exists only in:
- `CLAUDE.md` Absolute Prohibitions
- `shared/agent-roles.md` per-agent notes
- Individual skill files

An LLM session reading these files _could_ still write to a plan file if instructed to do so or if the rule was misread. The skill files rely on the model following the instructions faithfully, with no enforcement at the tool or OS level.

---

## Option 1 — Claude Code Pre-Tool-Use Hooks (Recommended Starting Point)

**What it is:** Claude Code supports hooks — shell commands that fire before specific tool calls. A `PreToolUse` hook can intercept `Edit` and `Write` calls, check the target path, and reject the call if the path is under `plans/` and the current agent is a reviewer.

**How it works:**

1. Each agent writes its role to a temp file at session start (e.g. `C:\Temp\agent-role.txt` with content `triage-reviewer`).
2. A `PreToolUse` hook script checks:
   - Is the tool `Edit` or `Write`?
   - Is the target path under `plans/`?
   - Does `agent-role.txt` contain a reviewer role?
3. If all three are true, the hook rejects the call before the LLM can write.

**Hook script (PowerShell):**
```powershell
# pre-tool-use-hook.ps1
param($ToolName, $TargetPath)

$reviewerRoles = @("triage-reviewer", "tech-lead-reviewer", "design-reviewer", "review-agent")
$roleFile = "$env:TEMP\agent-role.txt"

if ($ToolName -in @("Edit", "Write")) {
    if ($TargetPath -like "*\plans\*") {
        if (Test-Path $roleFile) {
            $role = Get-Content $roleFile -Raw
            if ($reviewerRoles | Where-Object { $role -match $_ }) {
                Write-Error "BLOCKED: $role agents may not write to plan files."
                exit 1
            }
        }
    }
}
exit 0
```

**Limitations:**
- Relies on each agent correctly writing its role to the temp file. If the agent skips this step, the hook has no basis to block it.
- Agents all run in the same Claude Code process — a role file written by one session could interfere with another.
- Hooks fire on tool calls, not on file system writes directly — if an agent invokes shell commands to write files (Bash tool with `echo > file`), the hook would need to intercept Bash calls too.

**Setup in `.claude/settings.json`:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -File C:\\Users\\hanss\\Documents\\agent-workspace\\shared\\hooks\\pre-tool-use-hook.ps1 $TOOL_NAME $TOOL_INPUT_PATH"
          }
        ]
      }
    ]
  }
}
```

---

## Option 2 — MCP Server as Plan File Gateway (Most Robust)

**What it is:** A lightweight Model Context Protocol (MCP) server that acts as the only interface for reading and writing plan files. Agents never access `plans/` files directly — they call MCP tools instead. The server enforces role-based access at the tool level.

**How it works:**

1. The MCP server exposes two tools:
   - `read_plan_file(project_name)` — available to all agents
   - `write_plan_file(project_name, section, content, agent_role)` — rejects calls from reviewer roles
2. The server validates `agent_role` against a whitelist before writing.
3. Agents use these tools instead of `Read`, `Edit`, or `Write` for plan files.
4. Direct filesystem access to `plans/` is blocked at the OS level (icacls — see Option 3).

**MCP server skeleton (Node.js):**
```javascript
const REVIEWER_ROLES = new Set([
  "triage-reviewer",
  "tech-lead-reviewer",
  "design-reviewer",
  "review-agent"
]);

const ACTIVE_ROLES = new Set([
  "triage",
  "tech-lead",
  "design",
  "executor-react",
  "executor-dotnet",
  "executor-database",
  "executor-godot"
]);

server.tool("write_plan_file", async ({ projectName, section, content, agentRole }) => {
  if (REVIEWER_ROLES.has(agentRole)) {
    throw new Error(`Role '${agentRole}' is read-only on plan files.`);
  }
  if (!ACTIVE_ROLES.has(agentRole)) {
    throw new Error(`Unknown agent role '${agentRole}'.`);
  }
  // Write to projects/<projectName>/plans/<planName>.md — section-scoped write logic here
  // Also validates the agent is writing only to their designated section
});

server.tool("read_plan_file", async ({ projectName }) => {
  // Read and return projects/<projectName>/plans/<planName>.md content — available to all agents
});
```

**Benefits:**
- Role enforcement is at the server — the LLM cannot bypass it regardless of prompt.
- Naturally provides a full audit log of every read and write.
- Enables section-scoped writes (each agent can only write their designated section).
- Can be extended to validate that Triage only writes Triage Notes, Tech Lead only writes its solution section, etc.

**Limitations:**
- Requires building and running the MCP server (Node.js or Python, ~100 lines).
- Agents must be configured to use the MCP tools rather than built-in file tools for plan files.
- Must handle the `plans/README.md` separately (not a project plan file).

**Registration in `.claude/settings.json`:**
```json
{
  "mcpServers": {
    "plan-gateway": {
      "command": "node",
      "args": ["C:\\Users\\hanss\\Documents\\agent-workspace\\shared\\mcp\\plan-gateway.js"]
    }
  }
}
```

---

## Option 3 — OS-Level File Permissions (icacls)

**What it is:** Use Windows ACLs to make `plans/` read-only for the process user by default. An "unlock" script temporarily grants write access when an active agent needs to write.

**How it works:**
```powershell
# Lock plans/ to read-only for current user
icacls "C:\Users\hanss\Documents\agent-workspace\plans" /deny "$env:USERNAME:(W,M,D)" /T

# Unlock temporarily for an active agent write
icacls "C:\Users\hanss\Documents\agent-workspace\plans" /remove:d "$env:USERNAME" /T

# Re-lock after write completes
icacls "C:\Users\hanss\Documents\agent-workspace\plans" /deny "$env:USERNAME:(W,M,D)" /T
```

**Limitations:**
- Requires a privileged unlock/lock wrapper around every active agent write — adds friction.
- All agents run as the same user, so "unlock" grants access to every concurrent session.
- Does not distinguish between active and reviewer agents at the OS level — enforcement is procedural.
- Better suited as a complement to Option 2 (MCP server enforces agent roles; icacls prevents direct filesystem writes as a backstop).

---

## Option 4 — Git Worktrees for Reviewer Agents

**What it is:** Reviewer agents are spawned into a separate git worktree where `plans/` is checked out from a read-only branch. Any write they attempt produces no change on the main working tree.

**How it works:**
```bash
# Create a read-only worktree for the reviewer session
git worktree add --detach ../reviewer-session HEAD
# Reviewer operates in ../reviewer-session — writes stay in that worktree
# Worktree is discarded after the session: git worktree remove ../reviewer-session
```

**Limitations:**
- Worktree creation and teardown must be scripted around each reviewer session.
- Does not prevent writes within the worktree itself — only prevents pollution of the main working tree.
- Adds per-session disk and git overhead.

---

## Recommended Implementation Path

| Phase | Action |
|---|---|
| Now | Skill file instructions only (current state) |
| First implementation | Option 1 (hooks) — low effort, catches direct Edit/Write calls |
| Full implementation | Option 2 (MCP server) — role enforcement + audit log + section scoping |
| Optional hardening | Option 3 (icacls) as a backstop alongside Option 2 |

Start with Option 1 hooks when ready to move beyond skill file instructions. Migrate to the MCP server once multiple concurrent projects are active and an audit trail becomes operationally useful.

---

## What Each Option Catches

| Threat | Hooks | MCP server | icacls | Worktree |
|---|---|---|---|---|
| LLM uses Edit/Write tool directly | Yes | Yes (no direct access) | Yes | Partially |
| LLM uses Bash tool to write | No (unless Bash intercepted) | Yes (no direct access) | Yes | Partially |
| Two concurrent sessions conflict | No | Yes (server serialises) | No | Yes |
| Provides audit trail | No | Yes | No | No |
| Section-scoped writes | No | Yes | No | No |
| Works with no infrastructure | — (hooks built in) | No (server needed) | No | No |

# Workspace Conventions

All executor agents read this file before writing any code. These conventions apply to every language and executor in this workspace unless a project's own `CLAUDE.md` overrides them.

---

## General Principles

### Code reuse

Before writing any new function, component, service, or utility: **search the existing codebase first.**

The order of preference — in descending order:

1. **Reuse** — if the exact behaviour already exists somewhere in the codebase, import and use it. Do not rewrite it.
2. **Extend** — if an existing function or component covers most of the case, extend or parameterise it rather than writing a parallel version. A new optional parameter, a subclass, or a wrapper that adds one behaviour is far cheaper than a second implementation.
3. **Extract then use** — if you find yourself writing something and realise it would be useful in two or more places, stop and extract it to the appropriate shared module first. Then import it from both call sites.
4. **Create new** — only when nothing existing can reasonably serve the need, cannot be extended without breaking its existing callers, or the similarity to existing code is superficial.

**Never duplicate logic.** If you find yourself writing the same logic a second time, that is a sign the first instance should be extracted and shared. By the time the same logic would appear in a third place, it must already be in a shared module.

**Lean by default.** A codebase grows by addition and shrinks by reuse. Every new function that is only called once and could be inlined is unnecessary abstraction. Every parallel implementation of something that already exists is future maintenance burden. Prefer fewer, more general functions over many narrow ones.

What this means in practice:
- **Before implementing**, search shared modules and existing features for reusable code. Do this explicitly — do not assume nothing exists.
- **When extending**, change the existing function, not a copy of it. Make the extension backward-compatible so existing callers are unaffected.
- **When creating a shared utility**, give it a general enough name and signature that it can serve its second use case, not just the first.
- **No wrapper functions that do nothing but forward arguments.** If the only difference is a default value, pass the default at the call site.

### Code readability

Code is read far more often than it is written. Every file you produce must be readable by a human who has never seen it before.

- **Line length:** Maximum 100 characters per line across all languages. Exceptions: URLs in comments or strings (never break a URL mid-line), and generated code you did not write.
- **One concern per function.** If a function does two jobs, split it.
- **Name things honestly.** A function named `getUserData` returns user data. A function named `processUser` does something to a user. Always name functions after what they do (verbs), not what they are (nouns). Exception: React components and Python/C# classes, which are nouns by convention.
- **No magic numbers.** Extract named constants: `MAX_RETRIES = 3`, not `if retries > 3`.
- **No dead code.** If something is unreachable or unused, delete it. Do not comment it out.
- **No commented-out code in commits.** Remove it entirely, or raise a USER CHECKPOINT if you are unsure whether it should stay.
- **Error messages must be actionable.** "Something went wrong" is not an error message. "Failed to save profile — network timeout. Please try again." is.

### Documentation

**Every exported or public-facing function, class, and module must have a documentation comment.** Not a placeholder. Not `// TODO: add docs`. A real description.

A good documentation comment answers:
1. **What** does this do? (one sentence)
2. **Why** does it exist — when and why would you call it?
3. **What are the non-obvious behaviours?** (parameter constraints, exceptions thrown, side effects, return value edge cases)

If a function has no non-obvious behaviours, questions 2 and 3 may be omitted. If the name alone answers question 1 completely, a single-line comment is sufficient. But the comment must exist for every public/exported element.

Internal, non-exported, or private functions: document only when the logic is non-obvious or the function exists for a non-obvious reason.

---

## TypeScript / JavaScript (Executor-React)

### Formatting

- **Formatter:** Prettier. Use the project's `.prettierrc` configuration. Do not introduce formatting that conflicts with it.
- **Line length:** 100 characters (`printWidth: 100` in `.prettierrc`).
- **Indentation:** 2 spaces.
- **Quotes:** Single quotes for JS/TS strings. Template literals for interpolation.
- **Trailing commas:** ES5 style (trailing commas in multi-line objects and arrays; not in function parameter lists).
- **Semicolons:** Follow the project `.prettierrc`. If not specified: omit (Prettier handles ASI correctly).
- **Run Prettier before every commit:** `npm run format` or `npx prettier --write src/`.

### Documentation

Use **TSDoc** for all exported functions, hooks, components, and types.

```typescript
/**
 * Displays the user's profile in a card layout.
 * Handles loading and error states — see Design Notes for the visual spec.
 *
 * @param userId - The ID of the user whose profile to fetch.
 * @param onEdit - Callback invoked when the user clicks the Edit button.
 */
export function UserProfileCard({ userId, onEdit }: Props) { ... }
```

**Required on:**
- Every exported component — describe what it renders and what states it handles
- Every exported hook (`use*`) — describe what state or side effect it manages and what it returns
- Every exported utility function — describe what it computes and any constraints on inputs
- Every exported type or interface — describe what it represents (only if the name is insufficient)
- Every exported enum value that is not self-explanatory

**Not required on:**
- Non-exported (internal) functions where the name and surrounding code make the purpose obvious
- Test files (test names serve as documentation)
- Auto-generated files

Never use `// TODO` in committed code. Raise a USER CHECKPOINT if the implementation has an unresolved question.

---

## C# / .NET (Executor-Dotnet)

### Formatting

- **Formatter:** `dotnet format`. Run before every commit: `dotnet format`.
- **Line length:** 100 characters.
- **Indentation:** 4 spaces (C# convention — not tabs).
- **Brace style:** Allman (opening brace on its own line). This is the .NET standard.
- **Naming conventions:**
  - `PascalCase` — classes, interfaces (`IUserService`), methods, properties, public fields, enum values
  - `camelCase` — local variables, method parameters
  - `_camelCase` — private and protected instance fields
  - `SCREAMING_SNAKE_CASE` — constants (`const int MAX_RETRIES = 3`)
- **Nullable reference types:** Enable in the project file (`<Nullable>enable</Nullable>`). Handle null explicitly — do not use `!` (null-forgiving operator) without a comment explaining the invariant.

### Documentation

Use **XML documentation comments** (`///`) for all public types and members.

```csharp
/// <summary>
/// Returns a user profile by ID. Returns <see langword="null"/> if the user does not exist.
/// </summary>
/// <param name="userId">The user's unique identifier.</param>
/// <returns>The user profile, or <see langword="null"/> if not found.</returns>
/// <exception cref="UnauthorizedException">
/// Thrown when the caller is not authenticated.
/// </exception>
public async Task<UserProfile?> GetUserAsync(Guid userId) { ... }
```

**Required on:**
- Every public class and interface — describe its responsibility
- Every public method — `<summary>`, `<param>` for each parameter, `<returns>` if non-void, `<exception>` for each thrown exception
- Every public property — single-line `<summary>` if the name alone is insufficient
- Every controller action — include the HTTP response codes in the `<summary>` or `<remarks>`

**Not required on:** Private and internal members unless the logic is non-obvious.

---

## Python (Executor-Python)

### Formatting

- **Formatter:** Black. Run before every commit: `black .`
- **Linter:** Ruff (preferred) or Flake8. Run before every commit: `ruff check .` or `flake8 .`
- **Line length:** 100 characters. Configure in `pyproject.toml`:
  ```toml
  [tool.black]
  line-length = 100

  [tool.ruff]
  line-length = 100
  ```
- **Indentation:** 4 spaces.
- **Import order:** isort order, enforced by Ruff — standard library, then third-party, then local. Blank line between each group.
- **Type hints:** Required on all function and method signatures (parameters and return types). Use `from __future__ import annotations` at the top of each file to support forward references.

### Documentation

Use **Google-style PEP 257 docstrings** for all public modules, classes, and functions.

```python
def get_user(user_id: str) -> UserProfile | None:
    """Return a user profile by ID, or None if not found.

    Args:
        user_id: The user's unique identifier.

    Returns:
        The user profile if found, otherwise None.

    Raises:
        PermissionError: If the caller is not authenticated.
    """
```

**Required on:**
- Every public **module** — module-level docstring at the top (one sentence + longer description if needed)
- Every public **class** — class docstring describing responsibility; constructor args documented in `__init__` or the class docstring
- Every public **function or method** — one-sentence summary line, plus Args/Returns/Raises sections when relevant
- Every public **property** — one-sentence description if the name is insufficient

**Not required on:** Private functions and methods (prefixed `_`) unless the logic is non-obvious.

Never use `# TODO` in committed code.

---

## GDScript (Executor-Godot)

### Formatting

- **Line length:** 100 characters.
- **Indentation:** Tabs (GDScript convention — not spaces). Godot's editor enforces this.
- **Naming conventions:**
  - `snake_case` — variables, functions, signals, file names
  - `PascalCase` — class names and node names
  - `SCREAMING_SNAKE_CASE` — constants (`const MAX_HEALTH = 100`)

### Documentation

Use `##` double-hash comments immediately above declarations for documentation.

```gdscript
## Applies damage to the character and triggers the hurt animation.
## Does nothing if the character is already dead (health <= 0).
##
## Parameters:
##   amount: Damage to apply. Must be a positive integer.
##   source: The node that dealt the damage, used to calculate knockback direction.
func take_damage(amount: int, source: Node) -> void:
    ...
```

**Required on:**
- Every **exported function** (`func`) that is part of the node's public interface
- Every **`@export` variable** — one-line `##` comment describing its purpose and valid range
- Every **signal** — `##` comment describing when it is emitted and what the arguments mean
- Every **constant** — `##` comment if the name alone is not self-explanatory

**Not required on:** Internal helper functions where the name and context make the purpose obvious.

---

## SQL / Migrations (Executor-Database)

### Formatting

- **Keywords:** UPPERCASE (`SELECT`, `FROM`, `WHERE`, `CREATE TABLE`, `ALTER TABLE`, etc.).
- **Identifiers:** `snake_case` for table names, column names, indexes, constraints, and function names.
- **Line length:** 100 characters.
- **Indentation:** 2 spaces for sub-clauses.
- **Column alignment in CREATE TABLE:** Align column types and constraints for readability when there are three or more columns.

### Documentation

- Every **table** must have a `COMMENT ON TABLE` statement (PostgreSQL) or an inline block comment (SQLite) describing its purpose and its relationships to other tables.
- Every **column** that is not self-explanatory must have an inline `--` comment describing its meaning, valid values, or relationship.
- Every **index** must have a comment explaining why it exists and which query patterns it serves.
- Every **complex query** (joins involving 3+ tables, subqueries, CTEs, window functions) must have a comment block explaining what it produces and why.

```sql
-- Stores one row per authenticated user session.
-- Sessions expire after 24 hours. Expired sessions are cleaned by a nightly job.
-- Foreign key to users(id) — cascades on delete.
CREATE TABLE sessions (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash  TEXT        NOT NULL,          -- bcrypt hash of the raw token
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at  TIMESTAMPTZ NOT NULL,          -- created_at + INTERVAL '24 hours'
  UNIQUE (token_hash)
);

COMMENT ON TABLE sessions IS
  'Authenticated user sessions. One row per active session. Expires after 24 hours.';
```

---

## Cross-cutting rules (all languages)

- **Never commit `console.log`, `print`, `Debug.Log`, or equivalent debug output** to the codebase. Remove all debug output before committing.
- **Never store secrets, tokens, passwords, or API keys** in source code, comments, or seed data files.
- **Never suppress linter or type checker rules** (`@ts-ignore`, `# noqa`, `#pragma warning disable`, `@suppress`) without a specific reason in a comment immediately above the suppression. If you find yourself suppressing a rule, stop and consider whether the code is wrong.
- **Never use magic numbers.** Extract named constants for any numeric or string value that has meaning beyond its literal value.
- **Imports/using/requires must be declared at the top of the file, never inside a function, method, or conditional block.** This applies regardless of language. Exception: a lazy-loaded import for an explicit, deliberate reason (route-based code-splitting via `import()`/`React.lazy`, or breaking a circular import in Python) — allowed only with a comment at the import site explaining why a top-level import isn't possible. The general rule is the default; exceptions must be justified, not habitual.
- **No half-finished implementations.** If a function cannot be completed in this pass, raise a USER CHECKPOINT — do not commit a stub with `// TODO: implement`.

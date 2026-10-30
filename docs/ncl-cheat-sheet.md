# NanoClaw CLI Cheat-Sheet (`ncl`)

Admin CLI for querying and modifying the central database. Connects via Unix socket on the host, or session DB inside containers.

**Syntax:** `ncl <resource> <verb> [<id>] [--flags]`

**Help:** `ncl <resource> help` or `ncl help`

**Restart:** `bash setup/lib/restart.sh`

---

## Agent Groups

Manage agent workspaces, personality, and container configuration.

| Command | Description |
|---------|-------------|
| `ncl groups list` | List all agent groups |
| `ncl groups get --id <group>` | Get details of one agent group |
| `ncl groups create --id <name> [options]` | Create a new agent group |
| `ncl groups update --id <group> [options]` | Update an existing agent group |
| `ncl groups delete --id <group>` | Delete an agent group |
| `ncl groups restart --id <group> [--rebuild] [--message <text>]` | Kill + respawn container(s); optional wake message |
| `ncl groups config get --id <group>` | Get container config (provider, model, packages, MCP servers, mounts, etc.) |
| `ncl groups config update --id <group> [options]` | Update container config (gated for agent callers) |
| `ncl groups config add-mcp-server --id <group>` | Add an MCP server to the group's container config |
| `ncl groups config remove-mcp-server --id <group>` | Remove an MCP server from the group's container config |

**Key flags:** `--template`, `--provider`, `--model`, `--timezone`, `--cli_scope` (disabled/group/global)

---

## Messaging Groups

Manage single chats/channels on one platform.

| Command | Description |
|---------|-------------|
| `ncl messaging-groups list` | List all messaging groups |
| `ncl messaging-groups get --id <group>` | Get details of one messaging group |
| `ncl messaging-groups create [options]` | Create a new messaging group |
| `ncl messaging-groups update --id <group> [options]` | Update an existing messaging group |
| `ncl messaging-groups delete --id <group>` | Delete a messaging group |

**Key flags:** `--channel-type`, `--instance`, `--unknown_sender_policy`

---

## Wirings

Links a messaging group to an agent group (session mode, triggers).

| Command | Description |
|---------|-------------|
| `ncl wirings list` | List all wirings |
| `ncl wirings get --id <wiring>` | Get details of one wiring |
| `ncl wirings create [options]` | Create a new wiring |
| `ncl wirings update --id <wiring> [options]` | Update an existing wiring |
| `ncl wirings delete --id <wiring>` | Delete a wiring |

**Key flags:** `--agent-group`, `--messaging-group`, `--session_mode`, `--engage_mode`, `--engage_pattern`, `--sender_scope`

---

## Users

Platform identities (`<channel>:<handle>`).

| Command | Description |
|---------|-------------|
| `ncl users list` | List all users |
| `ncl users get --id <user>` | Get details of one user |
| `ncl users create [options]` | Create a new user |
| `ncl users update --id <user> [options]` | Update an existing user |

---

## Roles

Owner/admin privileges (global or scoped to an agent group).

| Command | Description |
|---------|-------------|
| `ncl roles list [--id <user>]` | List roles (optionally scoped to a user) |
| `ncl roles grant --id <user> [options]` | Grant owner or admin privilege |
| `ncl roles revoke --id <user> [options]` | Revoke owner or admin privilege |

**Key flags:** `--agent-group` (scoped admin), role type (owner/admin)

---

## Members

Unprivileged access gate for agent groups.

| Command | Description |
|---------|-------------|
| `ncl members list --id <group>` | List members of an agent group |
| `ncl members add --id <group> [options]` | Add a member to an agent group |
| `ncl members remove --id <group> [options]` | Remove a member from an agent group |

---

## Destinations

Where agent groups can send messages.

| Command | Description |
|---------|-------------|
| `ncl destinations list [--id <group>]` | List destinations (optionally scoped to a group) |
| `ncl destinations add [options]` | Add a destination for an agent group |
| `ncl destinations remove [options]` | Remove a destination |

---

## Sessions

Active sessions (read-only).

| Command | Description |
|---------|-------------|
| `ncl sessions list [--id <group>]` | List active sessions (optionally scoped to a group) |
| `ncl sessions get --id <session>` | Get details of one session |

---

## Tasks

Scheduled tasks for an agent group.

| Command | Description |
|---------|-------------|
| `ncl tasks list [--id <group>]` | List scheduled tasks |
| `ncl tasks get --id <task>` | Get details of one task |
| `ncl tasks create [options]` | Create a new scheduled task |
| `ncl tasks update --id <task> [options]` | Update an existing task |
| `ncl tasks cancel --id <task>` | Cancel a scheduled task |
| `ncl tasks pause --id <task>` | Pause a scheduled task |
| `ncl tasks resume --id <task>` | Resume a paused task |
| `ncl tasks delete --id <task>` | Delete a scheduled task |
| `ncl tasks run --id <task>` | Run a task immediately |
| `ncl tasks append-log --id <task>` | Append a log entry to a task |

**Key flags:** `--agent-group`, `--cron`, `--message`, `--enabled`

---

## User DMs

Cold-DM cache (read-only).

| Command | Description |
|---------|-------------|
| `ncl user-dms list [--channel-type <type>]` | List cold-DM cache entries |

---

## Dropped Messages

Messages from unregistered senders (read-only).

| Command | Description |
|---------|-------------|
| `ncl dropped-messages list [--id <group>]` | List dropped messages |

---

## Approvals

Pending approval requests (read-only).

| Command | Description |
|---------|-------------|
| `ncl approvals list [--id <group>]` | List pending approval requests |
| `ncl approvals get --id <approval>` | Get details of one approval |

---

## Quick Reference by Privilege

| Level | Access |
|-------|--------|
| **Owner** | All commands, all groups |
| **Admin** (scoped) | All commands, scoped to specific agent group |
| **Admin** (global) | All commands, all groups |
| **Member** | Read-only access (list, get) to scoped group |
| **Unauthenticated** | Rejected (no `cli_scope`) |

---

## Container vs Host CLI

| Context | Transport |
|---------|-----------|
| **Host** | Unix socket (`src/cli/socket-server.ts`) |
| **Container** | Session DB poller (`container/agent-runner/src/cli/ncl.ts`) |

Inside containers, `--id` and group args are auto-filled. Only the calling session is affected by restart.

---

## Common Patterns

```bash
# List all groups
ncl groups list

# Get a group's container config
ncl groups config get --id mygroup

# Grant admin to a user for a specific group
ncl roles grant --id "signal:+1234567890" --agent-group mygroup

# List active sessions for a group
ncl sessions list --id mygroup

# Create a scheduled task
ncl tasks create --id mygroup --cron "0 9 * * *" --message "Good morning"

# Restart a group's container with a wake message
ncl groups restart --id mygroup --message "System update complete"
```

---

*Generated from NanoClaw CLI infrastructure. Last updated: 2026-10-16*

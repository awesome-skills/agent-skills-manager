---
name: agent-skills-manager
description: Manage skills across AI coding agents (Claude Code, Codex, Pi, OpenCode, Hermes) with a unified symlink architecture. Use when the user wants to install a new skill, migrate skills from multiple agents into one source of truth, sync Hermes after skill changes, repair agent skill symlinks, or check skill distribution. Triggers: "install skill", "migrate skills", "统一管理 skill", "安装 skill", "同步 Hermes", "skill 分布", "修复 skill 软链接".
---

# Agent Skills Manager

This skill manages a **unified symlink architecture**: one canonical source (`~/.agents_skills/`) with every agent pointing to it via symlinks.

## Architecture

```
~/.agents_skills/          ← Canonical source (all skills live here)
    ↑ symlink  ↑ symlink  ↑ symlink  ↑ symlink  ↑ symlink
.agents/     .claude/     .codex/     .opencode/   .pi/agent/
skills       skills       skills       skills       skills

~/.hermes/skills/          ← Real copy (Hermes rglob bug; sync via script)
```

**Agent → Skill directory mapping:**
| Agent | Skills path | Method |
|-------|------------|--------|
| Pi / `.agents` | `~/.agents/skills/` | symlink → `~/.agents_skills/` |
| Claude Code | `~/.claude/skills/` | symlink → `~/.agents_skills/` |
| Codex (OpenAI) | `~/.codex/skills/` | symlink → `~/.agents_skills/` |
| OpenCode | `~/.opencode/skills/` | symlink → `~/.agents_skills/` |
| Pi direct | `~/.pi/agent/skills/` | symlink → `~/.agents_skills/` |
| Hermes | `~/.hermes/skills/` | **real copy** (synced via rsync) |

## Branch: Install a new skill

When the user wants to install a skill into the unified system:

1. **Identify the skill source** — a local path, a git repo, or a URL. If it is a repo, clone to a temporary directory first.
2. **Locate the skill directory** — it must contain `SKILL.md`. If the source has multiple `SKILL.md` files, list candidates and install the one the user requested.
3. **Validate minimum frontmatter** — `SKILL.md` must have `name` and `description`; if either is missing, stop and report the defect.
4. **Choose the destination name** — default to the source directory name unless the user requested a different folder. If `~/.agents_skills/<name>` already exists, diff both `SKILL.md` files; overwrite only when identical or when the user explicitly wants replacement.
5. **Copy into `~/.agents_skills/`**:
   ```bash
   cp -a /path/to/skill-name ~/.agents_skills/
   ```
6. **All symlinked agents** (Claude Code, Codex, Pi, OpenCode, `.agents`) pick it up automatically.
7. **Sync Hermes** only if Hermes should see the new skill:
   ```bash
   bash ~/.agents_skills/agent-skills-manager/scripts/sync-hermes.sh
   ```
8. **Verify**: `ls ~/.agents_skills/<skill-name>/SKILL.md` exists.

## Branch: Migrate existing skills

When the user wants to migrate from scattered skill directories to the unified architecture for the first time:

1. **Analyze current state** — scan each agent's skills directory:
   ```bash
   for dir in ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.opencode/skills ~/.hermes/skills; do
     echo "$dir: $(ls "$dir" 2>/dev/null | grep -v '^\.' | wc -l) skills"
   done
   ```
2. **Check for existing migration** — if `~/.agents_skills/` exists and agent skill paths already symlink to it, do not re-migrate; run the status branch instead unless the user requests repair.
3. **Check for conflicts** — identify skills with the same name in multiple agents. Diff their `SKILL.md` to confirm they are identical. If different, flag for user decision.
4. **Create `~/.agents_skills/`** and merge all unique skills. Priority: `.agents` > Claude Code > Codex > Hermes for conflicts, unless a higher-priority path is already a symlink to `~/.agents_skills/`; in that case use the existing canonical copy.
5. **Backup** each real agent skills directory before replacing. Never `mv` an existing symlink; unlink it instead:
   ```bash
   if [ -L ~/.xxx/skills ]; then rm ~/.xxx/skills; else mv ~/.xxx/skills ~/.xxx/skills.bak; fi
   ```
6. **Create symlinks** for all agents except Hermes:
   ```bash
   ln -s ~/.agents_skills ~/.agents/skills
   ln -s ~/.agents_skills ~/.claude/skills
   ln -s ~/.agents_skills ~/.codex/skills
   ln -s ~/.agents_skills ~/.opencode/skills
   mkdir -p ~/.pi/agent && ln -s ~/.agents_skills ~/.pi/agent/skills
   ```
7. **Sync Hermes** with rsync (see sync script).
8. **Verify** all symlinks resolve correctly.

## Branch: Repair symlinks

When the user says an agent cannot see skills or the unified setup looks broken:

1. **Check expected symlinks**:
   ```bash
   for dir in ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.opencode/skills ~/.pi/agent/skills; do
     printf "%s -> %s\n" "$dir" "$(readlink "$dir" 2>/dev/null || echo NOT_SYMLINK)"
   done
   ```
2. **Repair only broken or wrong symlinks**. If a path is a real directory, back it up before replacement:
   ```bash
   if [ -e ~/.xxx/skills ] && [ ! -L ~/.xxx/skills ]; then mv ~/.xxx/skills ~/.xxx/skills.bak; else rm -f ~/.xxx/skills; fi
   ln -s ~/.agents_skills ~/.xxx/skills
   ```
3. **Do not symlink Hermes**; run the Hermes sync branch instead.

## Branch: Sync Hermes after changes

When the user changes `~/.agents_skills/` and wants Hermes to receive the same skills:

1. **Do nothing for symlinked agents** — Claude Code, Codex, Pi, OpenCode, and `.agents` already see the canonical source.
2. **Sync Hermes** because it uses a real copy:
   ```bash
   bash ~/.agents_skills/agent-skills-manager/scripts/sync-hermes.sh
   ```
3. **Verify counts** with the status branch.

## Branch: Check status

When user wants to see the current skill distribution:

```bash
echo "=== Canonical source ==="
echo "~/.agents_skills/: $(ls ~/.agents_skills/ | grep -v '^\.' | grep -v sync-to-hermes | wc -l) skills"

echo ""
echo "=== Symlinked agents ==="
for dir in ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.opencode/skills ~/.pi/agent/skills; do
  target=$(readlink "$dir" 2>/dev/null || echo "NOT A SYMLINK")
  echo "$dir → $target"
done

echo ""
echo "=== Hermes (real copy) ==="
echo "~/.hermes/skills/: $(ls ~/.hermes/skills/ | grep -v '^\.' | wc -l) skills"
```

## Caveats

- **Hermes symlink support is version-dependent and incomplete**. Public issue reports show symlinked skills can be skipped by discovery because some paths use `Path.rglob("SKILL.md")` or non-following directory walks; management operations may also miss skills from symlinked/external directories. Prefer a real `~/.hermes/skills/` copy synced by rsync.
- **Codex `.system/` directory**: Codex has built-in system skills in `.system/`. These are included in `~/.agents_skills/` and are harmless for other agents because hidden directories are normally ignored by simple skill scans.
- **Backups**: Before migration, always back up each real agent's skills directory to `.bak`.
- **The `sync-to-hermes.sh` in `~/.agents_skills/` root is the legacy wrapper**; the canonical one lives at `agent-skills-manager/scripts/sync-hermes.sh`.
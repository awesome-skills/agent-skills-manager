# 🧩 Agent Skills Manager

<p align="center">
  <img src="https://img.shields.io/badge/agents-Claude%20Code%20%7C%20Codex%20%7C%20Pi%20%7C%20OpenCode%20%7C%20Hermes-blue" alt="agents">
  <img src="https://img.shields.io/badge/skills-73-brightgreen" alt="skills count">
  <img src="https://img.shields.io/badge/architecture-symlink%E2%86%92unified-purple" alt="architecture">
  <img src="https://img.shields.io/badge/hermes-rsync%20sync-orange" alt="hermes">
</p>

<p align="center">
  <b>One canonical source. Every AI coding agent references it.</b><br>
  <sub>Inspired by <a href="https://x.com/dotey/status/2069632132431929651">@dotey's symlink-based skills management</a></sub>
</p>

---

## 💡 Why?

You use multiple AI coding agents — Claude Code, Codex, Pi, OpenCode, Hermes — and each keeps its own copy of skills. The result:

```
❌ Change one skill → update it in 3 places
❌ 200+ duplicate directories, no idea which is "canonical"
❌ Want to contribute back to open-source? You edited a copy, not the original
```

This skill fixes that, once and for all:

```
✅ One source. One edit. Every agent sees it instantly.
✅ Symlinks are inherently synced — zero maintenance.
✅ Edit the original, PR back to the community directly.
```

---

## 🏗️ Architecture

```
                    ┌──────────────────────────┐
                    │   ~/.agents_skills/       │
                    │   📁 Canonical (73 skills) │
                    └──────┬─────────┬─────────┘
                 symlink  │         │  symlink
        ┌──────────┬───────┤         ├───────┬──────────┐
        ▼          ▼       ▼         ▼       ▼          ▼
   ┌─────────┐┌────────┐┌──────┐┌────────┐┌──────────┐
   │ .agents ││.claude ││.codex││.opencode││.pi/agent │
   │ (Pi)    ││  Code  ││      ││        ││          │
   └─────────┘└────────┘└──────┘└────────┘└──────────┘
                                          
        ┌──────────────────────────┐
        │   ~/.hermes/skills/      │
        │   📋 Real copy (rsync)   │
        └──────────────────────────┘
           ↑ Hermes has a rglob bug
             No symlink support; sync manually
```

| Agent | Skills Path | Method |
|-------|-----------|--------|
| 🔵 Pi / `.agents` | `~/.agents/skills/` | symlink → `~/.agents_skills/` |
| 🟣 Claude Code | `~/.claude/skills/` | symlink → `~/.agents_skills/` |
| 🟢 Codex (OpenAI) | `~/.codex/skills/` | symlink → `~/.agents_skills/` |
| 🟠 OpenCode | `~/.opencode/skills/` | symlink → `~/.agents_skills/` |
| 🔵 Pi (direct) | `~/.pi/agent/skills/` | symlink → `~/.agents_skills/` |
| 🔴 Hermes | `~/.hermes/skills/` | real copy (rsync) |

---

## 🚀 Quick Start

### First-Time Migration

Tell your AI agent:

```
Migrate all agent skills to the unified ~/.agents_skills/ directory
```

The agent loads this skill and runs:
1. 📊 Scans every agent's skills directory
2. 🔍 Detects naming conflicts
3. 💾 Backs up original directories
4. 🔗 Creates symlinks
5. 🔄 Syncs Hermes

### Install a New Skill

```
Install this skill: https://github.com/xxx/awesome-skill
```

The agent will:
1. 📥 Clone / download the skill
2. ✅ Validate `SKILL.md` frontmatter
3. 📋 Copy to `~/.agents_skills/`
4. ⚡ All symlinked agents pick it up instantly
5. 🔄 Sync Hermes (if needed)

### Sync Hermes

```
Sync Hermes skills
```

### Check Status

```
Show my skill distribution
```

---

## 📂 Directory Structure

```
~/.agents_skills/
├── agent-skills-manager/     ← This skill (self-managed)
│   ├── SKILL.md
│   ├── README.md
│   ├── README.en.md
│   └── scripts/
│       └── sync-hermes.sh
├── codebase-design/
├── tdd/
├── hi-calendar/
├── ... (70+ skills)
└── sync-to-hermes.sh         ← Legacy wrapper → delegates to skill version
```

---

## ⚠️ Caveats

- **Hermes does not support symlinks**: confirmed via public issue reports — `Path.rglob("SKILL.md")` and `os.walk` in some paths do not follow directory symlinks, causing skills to be skipped. Workaround: keep a real copy synced via rsync.
- **Codex `.system/`**: Codex's built-in system skills are included in `~/.agents_skills/`. Harmless to other agents (hidden directories aren't reached by simple scans).
- **Backups are safe**: all original directories are backed up to `.bak` before migration.

---

## 🙏 Credits

- [宝玉 (dotey)](https://x.com/dotey) — originated the symlink-based skills management approach
- [Agent Skills Spec](https://agentskills.io/specification) — made cross-agent skills possible

---

<p align="center">
  <sub>Made with ❤️ for the multi-agent era</sub>
</p>
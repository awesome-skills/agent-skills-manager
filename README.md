# 🧩 Agent Skills Manager

<p align="center">
  <img src="https://img.shields.io/badge/agents-Claude%20Code%20%7C%20Codex%20%7C%20Pi%20%7C%20OpenCode%20%7C%20Hermes-blue" alt="agents">
  <img src="https://img.shields.io/badge/skills-73-brightgreen" alt="skills count">
  <img src="https://img.shields.io/badge/architecture-symlink%E2%86%92unified-purple" alt="architecture">
  <img src="https://img.shields.io/badge/hermes-rsync%20sync-orange" alt="hermes">
</p>

<p align="center">
  <b>一份原件，所有 AI Coding Agent 共同引用</b><br>
  <sub>灵感来自 <a href="https://x.com/dotey/status/2069632132431929651">宝玉的软链接式 Skills 管理方案</a></sub>
</p>

---

## 💡 为什么需要这个？

你同时在用多个 AI Coding Agent（Claude Code、Codex、Pi、OpenCode、Hermes），每个都有一套自己的 Skills 目录。结果就是：

```
❌ 改一个 skill 要改 3 个地方
❌ 200+ 个重复目录，不知道哪个才是"原件"
❌ 想给开源项目提 PR，发现改的是副本不是原件
```

这个 Skill 一劳永逸地解决这个问题：

```
✅ 一份原件，一处修改，全体生效
✅ 软链接天生同步，零维护成本
✅ 改了就是原件，直接 PR 回馈社区
```

---

## 🏗️ 架构

```
                    ┌──────────────────────────┐
                    │   ~/.agents_skills/       │
                    │   📁 唯一原件 (73 skills)  │
                    └──────┬─────────┬─────────┘
               🔗 软链接    │         │    软链接 🔗
        ┌──────────┬───────┤         ├───────┬──────────┐
        ▼          ▼       ▼         ▼       ▼          ▼
   ┌─────────┐┌────────┐┌──────┐┌────────┐┌──────────┐
   │ .agents ││.claude ││.codex││.opencode││.pi/agent │
   │ (Pi)    ││  Code  ││      ││        ││          │
   └─────────┘└────────┘└──────┘└────────┘└──────────┘
                                          
        ┌──────────────────────────┐
        │   ~/.hermes/skills/      │
        │   📋 实体副本 (rsync)    │
        └──────────────────────────┘
           ↑ Hermes 有 rglob bug
             不支持软链接，需手动同步
```

| Agent | Skills 路径 | 方式 |
|-------|-----------|------|
| 🔵 Pi / `.agents` | `~/.agents/skills/` | 软链接 → `~/.agents_skills/` |
| 🟣 Claude Code | `~/.claude/skills/` | 软链接 → `~/.agents_skills/` |
| 🟢 Codex (OpenAI) | `~/.codex/skills/` | 软链接 → `~/.agents_skills/` |
| 🟠 OpenCode | `~/.opencode/skills/` | 软链接 → `~/.agents_skills/` |
| 🔵 Pi (direct) | `~/.pi/agent/skills/` | 软链接 → `~/.agents_skills/` |
| 🔴 Hermes | `~/.hermes/skills/` | 实体副本（rsync 同步） |

---

## 🚀 快速开始

### 首次迁移

对你现有的 AI Agent 说：

```
帮我把所有 agent 的 skills 迁移到统一的 ~/.agents_skills/ 目录
```

Agent 会自动加载本 Skill，执行：
1. 📊 扫描各 Agent 的 Skills 目录
2. 🔍 检测同名冲突
3. 💾 备份原目录
4. 🔗 创建软链接
5. 🔄 同步 Hermes

### 安装新 Skill

```
帮我安装这个 skill：https://github.com/xxx/awesome-skill
```

Agent 会：
1. 📥 克隆/下载 Skill
2. ✅ 校验 SKILL.md 合法性
3. 📋 复制到 `~/.agents_skills/`
4. ⚡ 所有软链接 Agent 自动生效
5. 🔄 同步 Hermes（如需要）

### 同步 Hermes

```
帮我同步 Hermes 的 skills
```

### 检查状态

```
看看我的 skills 分布情况
```

---

## 📂 目录结构

```
~/.agents_skills/
├── agent-skills-manager/     ← 本 Skill（自管理）
│   ├── SKILL.md
│   ├── README.md
│   ├── README.en.md
│   └── scripts/
│       └── sync-hermes.sh
├── codebase-design/
├── tdd/
├── hi-calendar/
├── ... (70+ skills)
└── sync-to-hermes.sh         ← 旧版兼容脚本（代理到 skill 内版本）
```

---

## ⚠️ 注意事项

- **Hermes 不支持软链接**：经查证，Hermes 的 `Path.rglob("SKILL.md")` 和 `os.walk` 在部分路径中不跟随目录软链接，导致 Skills 可能被跳过。解决方案：使用 rsync 保持实体副本同步。
- **Codex `.system/`**：Codex 内置系统 Skills 也会纳入 `~/.agents_skills/`，对其他 Agent 无害（隐藏目录不会被简单扫描触及）。
- **备份安全**：迁移前会备份所有原目录到 `.bak`。

---

## 🙏 致谢

- [宝玉 (dotey)](https://x.com/dotey) — 软链接式 Skills 管理思路的提出者
- [Agent Skills 标准](https://agentskills.io/specification) — 让跨 Agent Skills 成为可能

---

<p align="center">
  <sub>Made with ❤️ for the multi-agent era</sub>
</p>
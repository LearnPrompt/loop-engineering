# 渲染规则：Loop Spec → Codex

> 把同一份 Loop Spec 渲染成 Codex 能跑的配置。Codex 偏「后台自动化」，核心是 Automations + worktree。

## 映射表

| Loop Spec 字段 | Codex 落点 |
|---|---|
| `goal` + `done_when` + `guardrails` | Automation 的 prompt（或 `/goal` 命令，Codex 也支持） |
| `triggers.on_demand` | Automation 设为 on-demand / 手动触发 |
| `triggers.scheduled` | Automation 的 cadence（频率） |
| `triggers.hooks` | **Codex 无原生 hook → 折成 checker 步骤**：把「编辑后跑 test」写进 maker 流程末尾 |
| `agents.maker` / `checker` | Automation prompt 内分两段角色；或两个 Automation 串联 |
| `connectors` | `gh` / connector；优先 CLI |
| `isolation` | 运行环境选 **background worktree** |
| `state.manifest` / `log` | 项目内文件，结果进 Triage inbox |
| 项目知识 | `AGENTS.md`（对应 Claude Code 的 CLAUDE.md） |

## Automation 配置渲染模板

```
项目：<maintenance workspace>
prompt：<把 claude-code-render 的 /goal 正文去掉前缀 "/goal " 直接粘贴>
cadence：<on-demand | scheduled 的频率>
运行环境：background worktree
结果去向：Triage inbox（有问题再通知人类）
```

## 与 Claude Code 的差异（必须向用户标注）
- **无原生 hook**：事件触发的语义靠 checker 步骤模拟，时机不如 Claude Code 的 hook 精确。
- **触发心智不同**：Codex 以 Automations 面板为中心，Claude Code 以 `/goal`·`/loop` 命令为中心。
- 渲染完把配置交给用户去 Automations 面板建，**不要替用户启用**。

# 渲染规则：Loop Spec → Codex

> 把同一份 Loop Spec 渲染成 Codex 能跑的配置。Codex 偏「后台自动化」，核心是 Automations + worktree。

## 映射表

| Loop Spec 字段 | Codex 落点 |
|---|---|
| `component_matrix_ref` | Automation 描述/README 先贴组件矩阵 |
| `components.goal` + `components.guardrails` | Automation prompt 的目标、停止判据、hard stops |
| `components.intake` | prompt 内的“取下一单元”规则；也可用 inbox/manifest 文件 |
| `components.trigger.mode=on_demand` | Automation 设为 on-demand / 手动触发 |
| `components.trigger.mode=scheduled` | Automation 的 cadence（频率） |
| `components.trigger.hooks` | **Codex 无原生 hook → 折成 checker 步骤**：把「编辑后跑 test」写进 maker 或 checker 流程 |
| `components.worktree` | 运行环境选 **background worktree**，prompt 写明隔离和清理纪律 |
| `components.agents.maker` / `checker` | Automation prompt 内分两段角色；或两个 Automation 串联 |
| `components.connectors` | `gh` / connector；优先 CLI；写操作必须有停手规则 |
| `components.state.manifest` / `log` / `memory` | 项目内文件，结果进 Triage inbox 或指定 log |
| `components.verification` | prompt 内每轮必须跑的 gates；无 hook 时靠 checker enforce |
| 项目知识 | `AGENTS.md`（对应 Claude Code 的 CLAUDE.md） |

## Automation 配置渲染模板

```
项目：<maintenance workspace>
prompt：<把组件矩阵 + claude-code-render 的 /goal 正文去掉前缀 "/goal " 直接粘贴>
cadence：<on-demand | scheduled 的频率>
运行环境：background worktree
结果去向：Triage inbox（有问题再通知人类）
```

## 与 Claude Code 的差异（必须向用户标注）
- **无原生 hook**：事件触发的语义靠 checker 步骤模拟，时机不如 Claude Code 的 hook 精确。
- **触发心智不同**：Codex 以 Automations 面板为中心，Claude Code 以 `/goal`·`/loop` 命令为中心。
- **组件仍要齐**：即使 Codex 用一个 Automation prompt 承载全部内容，也要在 prompt 里显式写出 intake、worktree、connectors、state、verification。
- 渲染完把配置交给用户去 Automations 面板建，**不要替用户启用**。

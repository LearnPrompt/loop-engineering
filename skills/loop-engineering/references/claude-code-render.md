# 渲染规则：Loop Spec → Claude Code

> 把一份 Loop Spec 渲染成 Claude Code 能直接跑的命令与文件。愚公只渲染，不替用户执行。

## 映射表

| Loop Spec 字段 | Claude Code 落点 |
|---|---|
| `component_matrix_ref` | 回复中先贴组件矩阵；可另存 `component-matrix.md` |
| `components.goal` + `components.guardrails` | `/goal <一整段>` 的停止判据和护栏段 |
| `components.intake` | `/goal` 正文的“如何取下一单元”；本地 `REPOS.md` / `manifest.json` / `gh` 查询 |
| `components.trigger.mode=on_demand` | `/goal`（一次性把任务跑干） |
| `components.trigger.mode=scheduled` | `/loop --schedule "<cron>" "<prompt>"` |
| `components.trigger.hooks` | `.claude/settings.json` 的 hooks（如 PostToolUse 跑 lint/test） |
| `components.worktree` | `git worktree add` 每单元一个，路径和清理纪律写进 prompt |
| `components.agents.maker` / `checker` | 主 agent 派 Agent 子任务；checker 用独立子 agent，不共享 maker 上下文 |
| `components.connectors` | `gh`/`curl` 直接调用；MCP 走 `.claude/mcp` 配置；写操作贴进 hard stops |
| `components.state.manifest` / `log` / `memory` | 项目内文件，agent 每轮读写 |
| `components.verification` | maker/checker 步骤里的 test/lint/build/scan/diff gate |
| 项目知识 | `CLAUDE.md`（写规范、禁止事项、常用命令） |

## /goal 正文渲染模板

```
/goal 按 <components.intake.source> 取下一个 <components.intake.unit>，逐个完成 <maker 干什么>，直到 <components.state.stop_rule>：

对每个 <unit>：
1. 按 <components.worktree.strategy> 准备隔离工作区，不复用未终结目录
2. maker 执行：<maker prompt_ref>，只使用允许的 connectors：<connectors reads/writes/fallback>
3. 跑验证门：<components.verification.gates>
4. 另起独立 checker agent 验收：<checklist 逐条>，证据写入 <components.verification.evidence>
5. 更新 <manifest>（done 附 result_ref / blocked 附原因），必要反馈写入 <memory/log>

完成判据（二元可验证）：
- <done_when 逐条>

护栏：<hard_stops 一律 blocked 交人类>；maker 与 checker 分两个 agent；
commit 即 push；优先 gh/curl 不用 WebFetch；<iteration_cap>；<dry_run_first>；<rollback>。
```

## 注意
- 先给组件矩阵，再给 `/goal`。如果只输出 `/goal`，说明组件没有交代清楚。
- `done_when` 与护栏一定要进 `/goal` 正文，否则循环没有停止条件、没有边界。
- intake、worktree、connectors、state、verification 必须在正文中有落点；不能只在 Loop Spec 里出现。
- 渲染完把命令交给用户复制，**不要自己执行 `/goal`**。

# 渲染规则：Loop Spec → Claude Code

> 把一份 Loop Spec 渲染成 Claude Code 能直接跑的命令与文件。愚公只渲染，不替用户执行。

## 映射表

| Loop Spec 字段 | Claude Code 落点 |
|---|---|
| `goal` + `done_when` + `anti_goodhart` + `guardrails` | `/goal <一整段>` 的正文 |
| `triggers.on_demand` | `/goal`（一次性把任务跑干） |
| `triggers.scheduled` | `/loop --schedule "<cron>" "<prompt>"` |
| `triggers.hooks` | `.claude/settings.json` 的 hooks（如 PostToolUse 跑 lint/test） |
| `agents.maker` / `checker` | 主 agent 派 Agent 子任务；checker 用独立子 agent，不共享 maker 上下文 |
| `connectors` | `gh`/`curl` 直接调用；MCP 走 `.claude/mcp` 配置 |
| `isolation` | `git worktree add` 每单元一个 |
| `state.manifest` / `log` | 项目内文件，agent 每轮读写 |
| 项目知识 | `CLAUDE.md`（写规范、禁止事项、常用命令） |

## /goal 正文渲染模板

```
/goal <units 怎么遍历>，逐个完成 <maker 干什么>，直到 <stop_rule>：

对每个 <unit>：
1. <maker 步骤，含 connectors 的 CLI 调用>
2. 另起独立 checker agent 验收：<checklist 逐条>
3. 更新 <manifest>（done 附 result_ref / blocked 附原因）

完成判据（二元可验证）：
- <done_when 逐条>

护栏：<hard_stops 一律 blocked 交人类>；maker 与 checker 分两个 agent；
commit 即 push；优先 gh/curl 不用 WebFetch；<iteration_cap>；<dry_run_first>。
```

## 注意
- `done_when` 与护栏一定要进 `/goal` 正文，否则循环没有停止条件、没有边界。
- 渲染完把命令交给用户复制，**不要自己执行 `/goal`**。

# Loop Component Stack —— 交令前必须装齐的部件

> Loop Engineering 不是只写一个 goal。goal 只是循环的停止判据；一个能自跑的 loop 还需要入口、触发、隔离、执行、验收、状态、连接器和停手点。

## 必备组件

| 组件 | 要回答的问题 | 最小落点 |
|---|---|---|
| Goal / done_when | 什么时候算真的完成？ | 二元可验证判据 + 防 Goodhart |
| Intake / units | 每轮处理什么？单元从哪来？ | `REPOS.md`、`gh` 查询、文件清单或 inbox |
| Trigger / heartbeat | 谁在什么时候唤醒循环？ | on-demand、scheduled、hook 三选一或组合 |
| Worktree / isolation | 并行或长任务怎么不互相踩？ | 每单元独立 worktree + 清理纪律 |
| Maker | 谁干活？拿什么 prompt？ | maker prompt / skill / agent runner |
| Checker | 谁验收？怎么独立？ | checker prompt + checklist |
| Connectors | 读写哪些外部系统？ | CLI 优先，标清 reads/writes/fallback |
| State / memory | 循环怎么记住进度？ | manifest、log、decision record |
| Verification | 每轮跑哪些验证？ | test/lint/build/scan/PR diff gate |
| Guardrails / HITL | 跑飞或高风险时怎么停？ | iteration cap、token budget、hard stops |
| Runtime handoff | 用户怎么一键启动？ | Claude Code 命令 + Codex Automation |

## 装配纪律

- 不允许只交 `/goal` 正文。交令前必须先给组件矩阵，说明每个组件的落点。
- 如果某组件暂时没有材料，写 `待用户确认` 或 `暂不启用`，不要默默省略。
- 外部写操作必须在 Connectors 和 Guardrails 两处同时出现：前者说明怎么写，后者说明什么时候必须停手。
- State 是循环的事实源。任何“已完成 / blocked / 还剩什么”都必须能从 manifest 或等价状态文件读出来。
- Runtime handoff 只能渲染命令和配置，不替用户点击启用。

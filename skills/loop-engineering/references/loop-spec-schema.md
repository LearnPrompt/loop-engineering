# Loop Spec Schema —— runtime 中立的循环中间表示

> 愚公六步的产物汇总成这一份 YAML。先把循环说清楚，再渲染成 Claude Code / Codex 的具体命令。

```yaml
loop:
  name: string            # 这个循环叫什么
  goal: string            # 一句话目标（人话）
  done_when:              # 合取：全部为真才停。每条必须机器可验证
    - string
  anti_goodhart:          # 防作弊条款，堵针对验证器优化的捷径
    - string
  units:                  # 循环遍历的单元
    item: string          # 单元是什么（一个仓库 / issue / 文件）
    source: string        # 单元清单从哪来（REPOS.md / gh 实时查）
  agents:
    maker:
      runner: string      # 谁干活（鲁班 / 通用 agent / 某 skill）
      prompt_ref: string  # prompt 入口（templates/maker-prompt.md）
    checker:
      runner: string      # 独立验收 agent
      checklist:          # 验收清单
        - string
  connectors:             # 优先 CLI
    - name: string        # gh / curl / mcp:xxx
      writes: string      # 它会做的写操作
  isolation: string       # worktree 策略 + 清理纪律
  triggers:
    on_demand: string     # 一次性 drain（/goal）
    scheduled: string     # cron 表达式 + 触发什么（可空）
    hooks: string         # 事件钩子（可空；Codex 折成 checker 步骤）
  state:
    manifest: string      # 路径
    manifest_fields: [string]
    log: string           # 路径
    stop_rule: string     # 如何从 manifest 读出「该停了」
  guardrails:
    iteration_cap: int
    token_budget: string
    dry_run_first: bool
    hard_stops:           # 必须人类祈使句触发，永不进自动判据
      - string
  runtimes: [claude-code, codex]   # 要渲染哪些；默认两个
```

字段纪律：
- `done_when` 与 `hard_stops` 互斥——一个动作要么自动可达成、要么交人类，不能两栖。
- `units.source` 若是「gh 实时查」，要在 connectors 里有对应的 `gh` 入口。
- `state.stop_rule` 必须能从 `manifest` 字段推出，不能靠 agent 主观判断「差不多了」。

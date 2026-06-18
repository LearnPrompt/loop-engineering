# Loop Spec Schema —— runtime 中立的循环中间表示

> 愚公六步的产物先汇总成组件矩阵，再结构化成这一份 YAML。goal 只是 `components.goal`；一个完整 Loop Spec 必须同时说明 intake、trigger、worktree、agents、connectors、state、verification 和 guardrails。

```yaml
loop:
  name: string              # 这个循环叫什么
  intent: string            # 为什么值得做成 loop
  component_matrix_ref: string # 可选：组件矩阵文件或回复章节
  components:
    goal:
      statement: string     # 一句话目标（人话）
      done_when:            # 合取：全部为真才停。每条必须机器可验证
        - string
      anti_goodhart:        # 防作弊条款，堵针对验证器优化的捷径
        - string
    intake:
      unit: string          # 单元是什么（一个仓库 / issue / 文件）
      source: string        # 单元清单从哪来（REPOS.md / gh 实时查）
      queue_file: string    # 可空：本地队列或 inbox
    trigger:
      mode: string          # on_demand / scheduled / hooks / hybrid
      cadence: string       # cron / manual / event description
      hooks:                # 可空；Codex 折成 checker 步骤
        - string
    worktree:
      strategy: string      # 每单元独立 / 单 background worktree / 不启用
      path_pattern: string  # 如 ../loop-worktrees/<unit>
      cleanup: string       # 何时清理，任务终结前是否复用
    agents:
      maker:
        runner: string      # 谁干活（鲁班 / 通用 agent / 某 skill）
        prompt_ref: string  # prompt 入口（templates/maker-prompt.md）
        permissions: string # 能读写什么
      checker:
        runner: string      # 独立验收 agent
        prompt_ref: string  # prompt 入口（templates/checker-prompt.md）
        checklist:
          - string
    connectors:             # 优先 CLI
      - name: string        # gh / curl / mcp:xxx / filesystem
        type: string        # cli / mcp / filesystem / api
        reads: string       # 它会读什么
        writes: string      # 它会做的写操作
        auth_source: string # 环境变量 / logged-in CLI / none
        fallback: string    # 失败或弹窗时换什么
    state:
      manifest: string      # 路径
      manifest_fields:
        - string
      log: string           # 路径
      memory: string        # 可空：长期反馈或决策记录
      stop_rule: string     # 如何从 manifest 读出「该停了」
    verification:
      gates:
        - string            # test / lint / build / secret scan / diff cap
      evidence: string      # 验收证据写到哪
      cadence: string       # 每轮 / 每 N 轮 / 交令前
    guardrails:
      iteration_cap: int
      token_budget: string
      dry_run_first: bool
      hard_stops:           # 必须人类祈使句触发，永不进自动判据
        - string
      rollback: string
  runtimes:
    claude_code:
      command: string       # /goal 或 /loop 渲染结果
      files:
        - string            # CLAUDE.md / .claude/settings.json / prompts
    codex:
      automation_prompt: string
      cadence: string
      environment: string   # background worktree / local workspace
```

字段纪律：
- `components.goal.done_when` 与 `components.guardrails.hard_stops` 互斥——一个动作要么自动可达成、要么交人类，不能两栖。
- `components.intake.source` 若是「gh 实时查」，要在 `components.connectors` 里有对应的 `gh` 入口。
- `components.connectors[*].writes` 只要非空，对应写操作就必须在 `components.guardrails.hard_stops` 或 checker checklist 中有边界。
- `components.state.stop_rule` 必须能从 `manifest` 字段推出，不能靠 agent 主观判断「差不多了」。
- `runtimes` 只放 handoff 配置，不代表愚公已经替用户启用。

# 实战范例：用鲁班把 LearnPrompt org 所有 skill 升一遍 + 鲁班自举

> 这是 Loop Engineering（愚公）的旗舰用例。需求原话：
> 「用鲁班 skill 检测我 GitHub 上所有 skill，做一遍全面升级；升级过程中遇到的问题，回馈给鲁班让它自己升级。」
>
> 结构 = **嵌套循环 + 元回馈环**：外循环遍历所有 skill 仓库，内循环对每个 skill 跑鲁班五步出 draft PR，
> 同时把「鲁班用起来哪卡了」攒进反馈文件，攒够阈值后**用鲁班打磨鲁班自己**。

---

## 愚公六步走一遍

### 1. 采石

- **反复性**：✅ 反复——skill 会持续新增、生态会变，升级是长期活儿。
- **可验证性**：✅ 有机器信号——`tools/check-skill-repo.sh` 给 PASS/WARN/FAIL，PR 是否存在可查。
- **循环单元**：每一轮处理**一个 skill 仓库**；单元来源 = `REPOS.md`（档 A：只列 `LearnPrompt` org 的已发布 skill）。
- **自跑边界**：可放手——验料/访行/过尺/慢刨/出 draft PR、写反馈、更新 manifest；必须人类把关——**merge、发版、删除**。

### 2. 立志（见 `references/goal-forging.md`）

```
一句话 goal：把 REPOS.md 里每个 skill 用鲁班升级一遍，各出一个 draft PR，
把鲁班用起来的卡点攒进 luban-feedback.md，直到 manifest 无 pending。

done_when（全部为真才停）：
- manifest.json 中每个 skill 状态 ∈ {done, blocked}，无 pending
- 每个 done 的 skill 有一个 open draft PR 链接
- 每个 done 的 skill check-skill-repo.sh 仍 PASS（升级不得令其退化）
- luban-feedback.md ≥ 5 条结构化反馈时，对 luban 仓库额外开一个 self-upgrade issue

防 Goodhart：不得删触发词/测试样例来骗 check 通过；PR 必须有真实 diff 且过 checker。
hard_stops：merge / 发版 / 删除目录 —— 一律 blocked 交人类。
guardrails：单 skill 最多 3 轮；首跑只放 1～2 仓 dry-run；超 token 预算停。
```

### 3. 分工

- **maker = 鲁班 agent**：在该 skill 仓库的独立 worktree 里跑五步（验料→访行→过尺→慢刨），产出打磨报告 + draft PR。
- **checker = 独立 agent**：不读鲁班的打磨上下文，只验——
  - SKILL.md frontmatter 完整、触发词没丢、负触发还在；
  - `check-skill-repo.sh` 仍 PASS；
  - 无密钥/私有路径泄露；
  - diff 有界（非测试代码改动 < 50 行，否则标 blocked 给人类）；
  - 用人话总结这轮改了什么。

### 4. 通路

- **连接器**：`gh`（列仓库、建分支、开 draft PR、开 issue）。**不用 WebFetch/MCP**——会触发子 agent 看不见的权限弹窗。访行阶段鲁班子 agent 也走 `gh api`/`curl`。
- **隔离**：每个 skill clone 到独立 `git worktree`，处理完即推送、不复用目录。
- **心跳**：
  - on_demand（drain）：一次性把 `REPOS.md` 跑干 → `/goal`。
  - scheduled（可选）：每周一早 9 点扫一遍有没有新 skill / 新依赖 → `/loop --schedule "0 9 * * 1"`。

### 5. 刻石

- `manifest.json`：每个 skill 一条 `{repo, status, pr_url, score_before, score_after, feedback_ids, notes}`。
- `luban-feedback.md`：结构化追加每条卡点（现象 / 触发步骤 / 影响 / 建议）——这就是「鲁班自举」的原料。
- `MAINTENANCE_LOG.md`：人类可读流水账。

### Loop Components Matrix

| Component | Decision | Runtime / file landing |
|---|---|---|
| Goal / done_when | manifest 无 pending；done 必须有 draft PR；blocked 必须有原因 | Claude `/goal` 和 Codex Automation prompt 的完成判据 |
| Intake / units | 每轮处理一个 skill 仓库 | `REPOS.md` + `manifest.json` |
| Trigger / heartbeat | on-demand drain；可选每周一扫新增 skill | `/goal`；可选 `/loop --schedule "0 9 * * 1"` / Codex cadence |
| Worktree / isolation | 每个 skill 独立 worktree，处理完即推送，不复用目录 | `git worktree add ../loop-worktrees/<repo>` |
| Maker | 鲁班 agent 跑验料、访行、过尺、慢刨 | `templates/maker-prompt.md` 渲染后的子 agent prompt |
| Checker | 独立 agent 验 frontmatter、触发词、check、diff、泄露 | `templates/checker-prompt.md` 渲染后的子 agent prompt |
| Connectors | `gh` 读仓库/开 PR/开 issue；文件系统读写状态 | `gh` CLI；`manifest.json`、`luban-feedback.md`、`MAINTENANCE_LOG.md` |
| State / memory | manifest 是事实源；feedback 是鲁班自举原料 | `manifest.json`、`luban-feedback.md`、`MAINTENANCE_LOG.md` |
| Verification gates | check-skill-repo、secret scan、diff < 50 行非测试 | maker/checker 每轮必跑，证据写入 log |
| Guardrails / HITL | 不 merge、不发版、不删除；先 2 仓 dry-run；单仓最多 3 轮 | hard_stops 一律 blocked 交人类 |
| Runtime handoff | Claude Code 和 Codex 双渲染 | `/goal`；Codex on-demand Automation + background worktree |

### 6. 交令（复制即可开，扳机你扣）

**Claude Code 版：**

```
/goal 读取 REPOS.md 列出的每个 skill 仓库，逐个完成鲁班升级，直到 manifest.json 里
没有 status=pending 的条目：

对每个 skill：
1. clone 到独立 worktree，跑 tools/check-skill-repo.sh，PASS 或把每个 FAIL/WARN 转成 gap 条目
2. 用鲁班五步（验料→访行→过尺→慢刨）产出打磨报告 + 一个 draft PR（绝不自动 merge）
3. 另起一个独立 checker agent 验收：frontmatter/触发词完整、check 仍 PASS、无泄露、diff < 50 行非测试
4. 把本轮鲁班卡壳/缺手艺处，按「现象/触发步骤/影响/建议」追加进 luban-feedback.md
5. 更新 manifest.json 该 skill 状态（done 附 pr_url / blocked 附原因）

完成判据（二元可验证）：
- manifest.json 中每个 skill 状态 ∈ {done, blocked}，无 pending
- 每个 done 的 skill 有一个 open draft PR 链接
- luban-feedback.md ≥ 5 条结构化反馈时，额外对 luban 仓库开一个 self-upgrade issue

护栏：高风险变更（删逻辑/外部 API/force-push/merge/发版）一律 blocked 交人类；
maker（鲁班）与 checker 分两个 agent；每个 commit 即 push；优先 gh/curl 不用 WebFetch；
单 skill 最多 3 轮；先只放 REPOS.md 前 2 个仓库 dry-run，确认闭环再放全量。
```

**Codex 版：** 在 Automations 标签页新建一个 automation，project 选 maintenance workspace，prompt 用上面同一段（把 `/goal` 去掉直接给 prompt），cadence 设 on-demand 或每周一，运行环境选 background worktree。等价渲染规则见 `references/codex-render.md`。

---

## 元回馈环：鲁班自举（攒够反馈后）

当 `luban-feedback.md` ≥ 5 条，循环额外触发一个**针对鲁班自己**的 goal：

```
/goal 用鲁班 skill 打磨 luban 仓库自身：以 luban-feedback.md 为「验料」与「回炉」输入，
把舰队升级里反复出现的卡点转成鲁班的改进项，产出一个 luban self-upgrade draft PR。
done_when：luban-feedback.md 中每条反馈都在 PR 里有对应处理（修复 / 记为 wontfix 附理由）；
鲁班 check-skill-repo.sh 仍 PASS。hard_stops：merge/发版交人类。
```

这就是愚公的精髓——**循环不仅干活，还顺手改进自己的工具**。鲁班升级别的 skill，自己也在被升级。

---

## 首跑建议（别一上来全自动跑一夜）

1. `REPOS.md` 先只填 2 个仓库（挑一个规整的 + 一个有积压 issue 的）。
2. 带 dry-run 开 goal，看它输出的「打算做什么」是否合理。
3. 放真跑这 2 个，确认：draft PR 出来了、checker 拦住了越界 diff、`luban-feedback.md` 真的攒到了卡点、manifest 状态正确流转、循环**干净地停了**。
4. 闭环验证通过，再把整个 LearnPrompt org 灌进 `REPOS.md`。
5. merge 哪个 PR、发不发版——你看完 draft，用祈使句说了算。

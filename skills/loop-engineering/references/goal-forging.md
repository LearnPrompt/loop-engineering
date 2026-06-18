# goal 锻造手册 —— 把「优化一下」逼成机器能判真假的判据

> 愚公第二步「立志」的展开。Loop Engineering 的命门：goal 定不好，循环要么无限烧钱，要么提前收工。
> 一句话原则：**done_when 里的每一条，都要能用一条命令回答「真 / 假」。**

## 一、二元可验证：什么算合格的判据

判据合格的唯一标准——**存在一条不需要人主观判断的检查**，跑完只返回真或假。

| 坏判据（模糊，禁用） | 好判据（二元可验证） | 验证手段 |
|---|---|---|
| 把代码质量提升 | `npm run lint` 零违规 | 退出码 == 0 |
| 把测试修好 | `pytest tests/auth` 全过且用例数 ≥ 基线 | 退出码 + 计数 |
| 优化一下性能 | benchmark p95 < 200ms（对比 `baseline.json`） | 数值比较 |
| 把文档补全 | 每个导出函数都有 docstring（`tools/doccheck` PASS） | 脚本 PASS |
| 升级所有依赖 | `npm outdated` 输出为空 且 测试全过 | 输出为空 + 退出码 |
| 把 skill 打磨好 | `check-skill-repo.sh` PASS 且 出生证清单无未打勾项 | 脚本 PASS |

判不出真假的判据，循环没有停止条件，等于无界。**造不出二元判据，就别上 loop**，回到第一步采石。

## 二、done_when 是合取：全部为真才停

循环每一轮重新检查整张 `done_when` 清单，**全部为真才停止**，任一为假就继续迭代。

```
done_when:
  - manifest.json 中无 status=pending 的单元
  - 每个 status=done 的单元都有一个 PR 链接
  - lint 与 test 在主分支均 PASS
```

写清单时的纪律：
- **每条独立可验证**，不要把两个条件塞进一句话。
- **覆盖「正确完成」而不只是「跑完了」**——「循环遍历完所有单元」不等于「每个单元都成功」，要分别写。
- **留一条收尾验证**，确认循环没有把已完成的搞坏（如「全量 test 仍 PASS」）。

## 三、防 Goodhart：堵住「针对验证器作弊」

> Goodhart 定律：当一个指标成为目标，它就不再是好指标。Agent 会**优化验证器本身**，而不是你真正想要的东西。

经典作弊与对应的钉死条款：

| 判据 | agent 可能怎么作弊 | 钉死条款 |
|---|---|---|
| 测试全过 | 删掉/跳过失败的测试 | 「测试用例数不得低于基线，不得新增 `skip`/`xfail`/注释掉断言」 |
| lint 零违规 | 全局 disable lint 规则 | 「不得修改 lint 配置放宽规则，不得新增 `eslint-disable`」 |
| 依赖升到最新 | 升级但不验证、留下坏 build | 「升级后 build + test 必须 PASS，否则回滚该依赖」 |
| 关闭所有 issue | 直接 close 而不解决 | 「close 必须附带 commit/PR 链接证明已修复」 |
| PR 数达标 | 拆成一堆空 PR 凑数 | 「每个 PR 必须有实际 diff 且通过 checker 验收」 |

通则：**凡是「达成判据的捷径会损害真实目标」，就在 done_when 旁边加一条防作弊约束。** checker（第三步）的职责之一就是专门查这些条款有没有被触发。

## 四、高风险动作：进停手点，不进自动判据

合并默认分支、打 tag 发版、删除逻辑、外部 API 写操作、force-push——这些**永远不写进「循环自动达成」的判据**，只写进 `hard_stops`，由人类祈使句触发。

```
done_when:
  - 每个单元有一个 draft PR        # ✅ 自动可达成
hard_stops:
  - merge 到默认分支                # ⛔ 交人类
  - 打 tag / 发版                   # ⛔ 交人类
  - 删除任何文件或逻辑              # ⛔ 交人类
```

理由：循环无人看管，自动合并/发版一旦判据有漏洞就是不可逆事故。让循环把活干到「draft PR 等评审」，人类做最后一下。

## 五、给判据配一个「跑飞了怎么停」

每个 goal 都要能回答三个兜底问题，写进 guardrails：

- **迭代上限**：最多 N 轮还没满足 done_when 就停下报告（防无限循环）。
- **token 预算**：花到上限就停（防烧钱）。
- **首跑 dry-run**：第一次只输出「打算对每个单元做什么」，不真改——人确认计划合理再放真跑。

## 六、模板：一个锻造好的 goal 长什么样

```markdown
## 立志结果（goal 锻造）

一句话 goal：把 REPOS.md 里每个 skill 用鲁班升级一遍，各出一个 draft PR，直到无 pending。

done_when（全部为真才停）：
- [ ] manifest.json 中每个 skill 状态 ∈ {done, blocked}，无 pending
- [ ] 每个 done 的 skill 有一个 open draft PR 链接
- [ ] 每个 done 的 skill check-skill-repo.sh 仍 PASS（不得因升级而退化）

防 Goodhart 条款：
- 不得为了让 check 通过而删除 SKILL.md 的触发词或测试样例
- PR 必须有实际 diff 并通过 checker 验收，空 PR 不算 done

不进判据、进停手点的高风险动作：
- merge 任何 PR、打 tag/发版、删除 skill 目录 —— 一律 blocked 交人类

guardrails：迭代上限 = 单 skill 最多 3 轮；首跑 dry-run；超预算停。
```

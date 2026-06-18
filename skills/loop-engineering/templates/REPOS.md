# REPOS.md —— 循环要遍历的单元清单

> 愚公「采石」的产物之一。每行一个 `owner/repo`。首跑只填 1～2 个验闭环，再灌全量。
> 档 A：只列 LearnPrompt org 的已发布 skill。

- LearnPrompt/luban-skill
- LearnPrompt/<skill-2>
- LearnPrompt/<skill-3>

<!-- 闭环验证通过后，用 gh 把整个 org 灌进来：
     gh repo list LearnPrompt --limit 200 --json nameWithOwner -q '.[].nameWithOwner'
     人工筛掉非 skill 仓库后追加到上面。 -->

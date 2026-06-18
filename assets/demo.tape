# Loop Engineering / 愚公 · demo 录制脚本（vhs，可复现）
# 用法：cd /Users/carl/Downloads/10_工作区/项目代码/技能与脚本仓库/loop-engineering && vhs assets/demo.tape
Output assets/demo.gif

Set Shell bash
Set FontSize 18
Set FontFamily "Menlo"
Set Width 1280
Set Height 720
Set Theme "Dracula"
Set TypingSpeed 38ms
Set Padding 28

Hide
Type "cd /Users/carl/Downloads/10_工作区/项目代码/技能与脚本仓库/loop-engineering && clear"
Enter
Show
Sleep 700ms

Type "echo 'Loop Engineering / Yugong'; echo 'Component matrix + loop handoff, verified locally'; echo"
Enter
Sleep 900ms

Type "npx --yes skills add . --list >/tmp/loop-skills-list.txt"
Enter
Sleep 2.8s

Type "grep -E '^[[:space:]│]*loop-engineering[[:space:]]*$' /tmp/loop-skills-list.txt"
Enter
Sleep 900ms

Type "echo; echo 'Core package:'; echo '  SKILL.md'; echo '  references: component-stack / loop-spec / render'; echo '  templates: component-matrix / manifest / maker / checker'"
Enter
Sleep 2.4s

Type "echo; echo 'Loop components:'; echo '  goal + intake + trigger + worktree'; echo '  maker/checker + connectors + state + gates'"
Enter
Sleep 2.4s

Type "echo; echo 'Guardrails:'; echo '  maker/checker split · dry-run first · HITL stops · CLI first'"
Enter
Sleep 2.8s

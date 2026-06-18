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

Type "echo 'Loop Engineering / Yugong'; echo 'Goal + loop handoff, verified locally'; echo"
Enter
Sleep 900ms

Type "npx --yes skills add . --list | sed -n '/Available Skills/,+5p'"
Enter
Sleep 2.8s

Type "echo; echo 'Core package:'; echo '  SKILL.md'; echo '  references: goal-forging / loop-spec / render / guardrails'; echo '  templates: manifest / maker / checker / feedback'"
Enter
Sleep 2.4s

Type "echo; echo 'Six moves:'; echo '  collect -> goal -> split roles'; echo '  connect -> persist state -> handoff command'"
Enter
Sleep 2.4s

Type "echo; echo 'Guardrails:'; echo '  maker/checker split · dry-run first · HITL stops · CLI first'"
Enter
Sleep 2.8s

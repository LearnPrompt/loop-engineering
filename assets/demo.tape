# Loop Engineering / 愚公 · demo 录制脚本（vhs，可复现）
# 用法：cd /Users/carl/Downloads/10_工作区/项目代码/技能与脚本仓库/loop-engineering && vhs assets/demo.tape
Output assets/demo.gif

Set Shell bash
Set FontSize 16
Set FontFamily "Osaka"
Set Width 1200
Set Height 780
Set Theme "Dracula"
Set TypingSpeed 45ms
Set Padding 22

Hide
Type "cd /Users/carl/Downloads/10_工作区/项目代码/技能与脚本仓库/loop-engineering && clear"
Enter
Show
Sleep 700ms

Type "printf 'Loop Engineering / 愚公 skill package\\n\\n'"
Enter
Sleep 700ms

Type "npx --yes skills add . --list"
Enter
Sleep 3.5s

Type "printf '\\nCore files:\\n' && find skills/loop-engineering -maxdepth 2 -type f | sort"
Enter
Sleep 2s

Type "printf '\\nTrigger keywords:\\n' && sed -n '1,18p' skills/loop-engineering/SKILL.md"
Enter
Sleep 3s

Type "printf '\\nExample handoff:\\n' && sed -n '70,92p' skills/loop-engineering/examples/luban-fleet-upgrade-case.md"
Enter
Sleep 3.5s

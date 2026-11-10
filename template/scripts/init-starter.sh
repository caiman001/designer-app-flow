#!/bin/sh
# 起步包初始化：把 {App名} / {app} / {开工日期} 换成真的，agent 和 skill 文件按新名字改名，最后列出还要手填的占位。
# 用法（在新项目根目录）：sh scripts/init-starter.sh "App 显示名" 英文小写短名
#   例：sh scripts/init-starter.sh "Lumen" lumen   → agent 叫 lumen-product、发版命令 /lumen-release
# 只跑一次；跑完这个脚本可以删掉。
set -e
NAME="$1"; SLUG="$2"
[ -n "$NAME" ] && [ -n "$SLUG" ] || { echo '用法：sh scripts/init-starter.sh "App 显示名" 英文小写短名'; exit 1; }
echo "$SLUG" | grep -Eq '^[a-z][a-z0-9-]*$' || { echo "短名只能是小写字母、数字、连字符，字母开头：$SLUG"; exit 1; }
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
[ -f .claude/agents/app-product.md ] || { echo "已经初始化过了（找不到 .claude/agents/app-product.md）"; exit 1; }

TODAY=$(date +%Y-%m-%d)
export NAME SLUG TODAY
find . -type f \( -name '*.md' -o -name '*.sh' -o -name '*.py' -o -name '.gitignore' \) ! -path './.git/*' ! -name 'init-starter.sh' ! -path './README.md' -print0 |
  xargs -0 perl -pi -e 's/\{App名\}/$ENV{NAME}/g; s/\{app\}/$ENV{SLUG}/g; s/\{开工日期\}/$ENV{TODAY}/g'

for f in .claude/agents/app-*.md; do mv "$f" ".claude/agents/$SLUG-${f#.claude/agents/app-}"; done
for d in .claude/skills/app-*; do mv "$d" ".claude/skills/$SLUG-${d#.claude/skills/app-}"; done

echo "✓ 已换成「$NAME」/ $SLUG（开工日期 $TODAY）"
ls .claude/agents .claude/skills
echo
echo "还要手填的占位（到哪一步填哪个，见 README 第二节；{日期}{待补} 这类是写文档时顺手填的空，不列）："
grep -rnoE '\{(App ID|Team ID|Bundle ID|VENDOR|GitHub 用户名|私有仓库|公开仓库|默认分支|网站地址|最低版本|画布链接|Design 画布链接|UDID|机型|pt 尺寸|分类)\}' \
  --include='*.md' --include='*.sh' --include='*.py' . | grep -v '^./README.md' | awk -F: '{print $3"  "$1}' | sort | uniq -c

#!/bin/sh
# 把主会话的自动记忆（本机 ~/.claude/projects/<项目>/memory/，不进 git、不跟账号走）备份到仓库 docs/memory/，
# 换电脑 / 换 Claude 账号时拷回去：cp docs/memory/*.md ~/.claude/projects/<项目路径把 / 和 . 换成 ->/memory/
# agent 自己的记忆本来就在仓库 .claude/agent-memory/，不用备份。
# 用法：scripts/backup-memory.sh（之后照常 commit，先问用户）
set -e
ROOT=$(git rev-parse --show-toplevel)
SRC="$HOME/.claude/projects/$(echo "$ROOT" | sed 's#[/.]#-#g')/memory"
[ -d "$SRC" ] || { echo "没找到记忆目录 $SRC"; exit 1; }
mkdir -p "$ROOT/docs/memory"
rsync -a --delete --exclude '.*' "$SRC/" "$ROOT/docs/memory/"
echo "✓ 备份 $(ls "$ROOT/docs/memory" | wc -l | tr -d ' ') 个文件 → docs/memory/"

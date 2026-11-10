#!/bin/sh
# 把网站文件从当前分支同步到公开仓库 site 的 main（= GitHub Pages 上线）。
# 只带 FILES 里这几个文件，App 源码 / 画布 / 宣发 / 文档永远不进公开仓库。
# 前提：git remote add site git@github.com:{GitHub 用户名}/{公开仓库}.git（公开仓库先建好、开 Pages）
# 用法：scripts/publish-site.sh          → 只在临时工作区准备好提交，打印差异，不推
#       scripts/publish-site.sh --push   → 推到 site main（先问用户）
set -e
FILES="index.html privacy.html README.md"   # 网站文件清单：加了图标、字体等就补在这里
ROOT=$(git rev-parse --show-toplevel)
SRC=$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)
WT="$ROOT/.git/site-worktree"

git -C "$ROOT" fetch -q site main
[ -d "$WT" ] || git -C "$ROOT" worktree add -q "$WT" site/main --detach
cd "$WT"
git checkout -q --detach site/main
# 公开仓库里只留网站文件：先清空，再从源分支取
git rm -rq --ignore-unmatch . >/dev/null
git checkout "$SRC" -- $FILES
git add -A
if git diff --cached --quiet; then echo "网站没有变化"; exit 0; fi
git commit -qm "网站：从 $SRC 同步（$(git -C "$ROOT" rev-parse --short "$SRC")）"
git show --stat --format='%s' HEAD
if [ "$1" = "--push" ]; then git push site HEAD:main; echo "已推送，约 1 分钟后 {网站地址} 更新"; fi

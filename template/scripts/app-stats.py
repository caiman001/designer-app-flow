#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""{App名} 下载量 + 评分（只读）。

用法：
  scripts/app-stats.py                    # 从上架日到昨天
  scripts/app-stats.py --since 2026-01-01 # 指定起点
  scripts/app-stats.py --week             # 最近 7 天

数据：苹果「销售与趋势」日报（晚 1 天，美洲约太平洋时间早 5 点出），
用 asc 的「{App名} Data」密钥（销售权限，钥匙串里，用户自己登记）只读拉；
日报缓存在 scripts/.sales-cache/（不进 git）。评分 / 评论用默认密钥只读查。
"""
import argparse, csv, datetime as dt, json, os, subprocess, sys
from collections import Counter, defaultdict

NAME = "{App名}"
APP_ID = "{App ID}"      # App Store Connect 里的数字 ID
VENDOR = "{VENDOR}"      # 供应商编号（销售与趋势页能看到，不是密钥）
PROFILE = "{App名} Data"  # asc 里「销售」权限密钥的名字
LAUNCH = dt.date(2026, 1, 1)  # 改成上架日
CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".sales-cache")

# 苹果 Product Type Identifier（iOS App）：1 首次下载、3 重新下载、7 更新；F = 通用、T = iPad
KIND = {"1": "首次下载", "1F": "首次下载", "1T": "首次下载",
        "3": "重新下载", "3F": "重新下载", "3T": "重新下载",
        "7": "更新", "7F": "更新", "7T": "更新"}


def asc(args, profile=None):
    env = dict(os.environ, ASC_READ_ONLY="1")
    cmd = ["asc"] + args + (["--profile", profile] if profile else [])
    r = subprocess.run(cmd, capture_output=True, text=True, env=env, cwd=CACHE)
    if r.returncode and "not available yet" in r.stderr:
        return '{"available": false, "notYet": true}'
    if r.returncode:
        sys.exit(f"asc 出错：{' '.join(args[:2])}\n{r.stderr.strip()[:300]}")
    return r.stdout


def day_rows(day):
    """返回这一天的报告行；没有下载 = []；报告还没出 = None。"""
    tsv = os.path.join(CACHE, f"{day}.tsv")
    none = os.path.join(CACHE, f"{day}.none")
    if os.path.exists(tsv):
        return list(csv.DictReader(open(tsv, encoding="utf-8"), delimiter="\t"))
    if os.path.exists(none):
        return []
    out = json.loads(asc(["analytics", "sales", "--vendor", VENDOR, "--type", "SALES",
                          "--subtype", "SUMMARY", "--frequency", "DAILY", "--date", str(day),
                          "--decompress", "--allow-missing", "--output", f"{day}.tsv.gz"], PROFILE))
    if out.get("notYet"):
        return None
    if out.get("available") is False:
        # 苹果没下载的日子不出报告；3 天前的才缓存成 0，近几天每次重查（防补发）
        if (dt.date.today() - day).days > 3:
            open(none, "w").close()
        return []
    gz = os.path.join(CACHE, f"{day}.tsv.gz")
    if os.path.exists(gz):
        os.remove(gz)
    return list(csv.DictReader(open(tsv, encoding="utf-8"), delimiter="\t"))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--since", type=dt.date.fromisoformat, default=LAUNCH)
    p.add_argument("--until", type=dt.date.fromisoformat, default=dt.date.today() - dt.timedelta(days=1))
    p.add_argument("--week", action="store_true")
    a = p.parse_args()
    if a.week:
        a.since = a.until - dt.timedelta(days=6)
    os.makedirs(CACHE, exist_ok=True)

    by_day = defaultdict(Counter)
    by_country = Counter()
    pending = []
    d = a.since
    while d <= a.until:
        rows = day_rows(d)
        if rows is None:
            pending.append(d)
        for r in rows or []:
            k = KIND.get(r["Product Type Identifier"], r["Product Type Identifier"])
            n = int(r["Units"])
            by_day[d][k] += n
            if k == "首次下载":
                by_country[r["Country Code"]] += n
        d += dt.timedelta(days=1)

    total = Counter()
    for c in by_day.values():
        total.update(c)
    print(f"## {NAME} 下载 {a.since} → {a.until}\n")
    print(f"首次下载 **{total['首次下载']}** · 重新下载 {total['重新下载']} · 更新 {total['更新']}\n")
    if by_day:
        print("| 日期 | 首次下载 | 重新下载 | 更新 |\n|---|---|---|---|")
        for d in sorted(by_day):
            c = by_day[d]
            print(f"| {d:%m-%d} | {c['首次下载']} | {c['重新下载']} | {c['更新']} |")
        print()
    if by_country:
        print("地区：" + " · ".join(f"{k} {v}" for k, v in by_country.most_common()) + "\n")
    if pending:
        print("还没出报告：" + "、".join(f"{d:%m-%d}" for d in pending) + "\n")

    rt = json.loads(asc(["reviews", "ratings", "--app", APP_ID, "--all"]))
    print(f"## 评分\n\n{rt.get('totalCount', 0)} 个评分 · 均分 {rt.get('averageRating', 0)}")
    for c in rt.get("byCountry") or []:
        print(f"- {c}")
    rv = json.loads(asc(["reviews", "--app", APP_ID, "--sort", "-createdDate", "--limit", "5"]))
    items = rv.get("data") or []
    print(f"\n最新评论 {len(items)} 条")
    for x in items:
        at = x.get("attributes", {})
        print(f"- {at.get('createdDate', '')[:10]} {at.get('territory', '')} {'★' * int(at.get('rating', 0))} {at.get('title', '')}：{at.get('body', '')[:80]}")


if __name__ == "__main__":
    main()

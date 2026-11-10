#!/bin/sh
# 只读：从 Mac「邮件」App 的收件箱取最近 N 天的邮件，给反馈 agent 归类用。
# 先批量取「日期 · 发件人 · 标题」，只有标题里含关键词的才取正文前 600 字。关键词按新 App 改（KEYS）。
# 前提：「邮件」App 里有收苹果邮件的那个账户；第一次运行时允许终端控制「邮件」。不发信、不改邮件、不标已读。发件人地址不写进仓库。
# 用法：scripts/feedback-mail.sh [天数，默认 7] [all = 不过滤，列出全部标题]
# 最新一封明显过旧：先 osascript -e 'tell application "Mail" to check for new mail'，等 20 秒再跑
DAYS=${1:-7}; MODE=${2:-related}
osascript <<OSA
with timeout of 300 seconds
tell application "Mail"
  set cutoff to (current date) - ($DAYS * days)
  set keys to {"{App名}", "反馈", "bug", "Bug", "TestFlight", "App Store", "App Review", "审核"}
  set out to ""
  repeat with acc in every account
    repeat with mb in (every mailbox of acc whose name is "INBOX")
      set ms to (messages of mb whose date received > cutoff)
      repeat with m in ms
        set s to subject of m
        set hit to ("$MODE" is "all")
        repeat with k in keys
          if s contains k then set hit to true
        end repeat
        if hit then
          set out to out & "=== " & (date received of m as string) & " | " & (sender of m) & " | " & s & linefeed
          if "$MODE" is not "all" then
            set c to content of m
            if (length of c) > 600 then set c to text 1 thru 600 of c
            set out to out & c & linefeed
          end if
        end if
      end repeat
    end repeat
  end repeat
  return out
end tell
end timeout
OSA

#!/bin/bash
# 自動把 E- 主站「參加活動」按鈕的切換日期從 8/4 還原回 8/24
# 由 cron 於 2026-08-04 12:00 執行（哥哥測試完自動復原，免手動）
set -e

REPO="$HOME/github_deploy"
FILE="$REPO/index.html"
FROM="2026-08-04T00:00:00+08:00"
TO="2026-08-24T00:00:00+08:00"

cd "$REPO"

if grep -q "$FROM" "$FILE"; then
  # 用 python 做精確字串替換（避免 sed 跨平台問題）
  /usr/local/bin/python3 - "$FILE" "$FROM" "$TO" <<'PY'
import sys
f, a, b = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(f, encoding='utf-8').read()
assert a in s, f"找不到 {a}"
open(f, 'w', encoding='utf-8').write(s.replace(a, b))
print("已將", a, "改回", b)
PY
  git add index.html
  git commit -m "revert: 自動切換日期還原為 8/24 (測試完成)" 
  git push origin main
  echo "OK: 已還原為 8/24 並推送上線"
else
  echo "SKIP: 檔案中已無 $FROM（可能已手動改回），不動作"
fi

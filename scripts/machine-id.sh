#!/usr/bin/env bash
# 读取自主部署实例机器码
set -euo pipefail

API_BASE="${1:-http://localhost:8088}"

if command -v curl >/dev/null 2>&1; then
  resp="$(curl -fsS "${API_BASE}/api/edition/info" 2>/dev/null || true)"
elif command -v wget >/dev/null 2>&1; then
  resp="$(wget -qO- "${API_BASE}/api/edition/info" 2>/dev/null || true)"
else
  echo "请安装 curl 或 wget" >&2
  exit 1
fi

if [[ -z "$resp" ]]; then
  echo "无法连接 API: ${API_BASE}" >&2
  echo "请先启动: cd deploy && ./start-selfhosted.sh" >&2
  exit 1
fi

machine_id="$(echo "$resp" | grep -o '"machine_id":"[^"]*"' | cut -d'"' -f4 || true)"
instance_plan="$(echo "$resp" | grep -o '"instance_plan":"[^"]*"' | cut -d'"' -f4 || true)"

if [[ -n "$machine_id" ]]; then
  echo "Machine ID:     ${machine_id}"
  echo "Instance plan:  ${instance_plan:-free}"
else
  echo "$resp"
fi

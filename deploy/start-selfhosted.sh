#!/usr/bin/env bash
# DeepSafe 自主部署版 — Ubuntu / Linux 一键启动
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# shellcheck source=compose.sh
source "$SCRIPT_DIR/compose.sh"

ENV_FILE=".env.selfhosted"
ENV_EXAMPLE=".env.selfhosted.example"

if [[ ! -f "$ENV_FILE" ]]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "已创建 .env.selfhosted，请按需修改 JWT_SECRET"
fi

echo "=== 拉取并启动自主部署版 ==="
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.selfhosted.yml}"
compose -f "$COMPOSE_FILE" pull
compose -f "$COMPOSE_FILE" up -d

WEB_PORT="$(grep -E '^\s*WEB_PORT\s*=' "$ENV_FILE" 2>/dev/null | cut -d= -f2 | tr -d ' \r' || true)"
WEB_PORT="${WEB_PORT:-8088}"

echo ""
echo "[OK] 自主部署版已启动"
echo "  管理端:  http://127.0.0.1:${WEB_PORT}"
echo "  API:     http://127.0.0.1:${WEB_PORT}/api/edition/info"
echo ""
echo "  默认账号: demo / author123"
echo "  免费版无需授权；订阅版在「订阅与套餐」上传 license.lic"
echo ""
echo "停止: compose -f docker-compose.selfhosted.yml down  (或 docker-compose ...)"

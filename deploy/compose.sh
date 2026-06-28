#!/usr/bin/env bash
# Docker Compose wrapper: v2 plugin or legacy docker-compose (Ubuntu 16.04+)
set -euo pipefail

compose_ready() {
  command -v docker >/dev/null 2>&1 || return 1
  docker compose version >/dev/null 2>&1 && return 0
  command -v docker-compose >/dev/null 2>&1 && return 0
  return 1
}

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    echo "未找到 docker compose / docker-compose，请先安装。" >&2
    exit 1
  fi
}

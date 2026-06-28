#!/usr/bin/env bash
# DeepSafe 自主部署版 — 一句话安装
# 用法: curl -fsSL https://raw.githubusercontent.com/tuanzhang13/deepsafe-selfhosted/main/deploy/install.sh | bash
set -euo pipefail

REPO="${DEEPSAFE_REPO:-https://github.com/tuanzhang13/deepsafe-selfhosted.git}"
BRANCH="${DEEPSAFE_BRANCH:-main}"
DIR="${DEEPSAFE_DIR:-deepsafe-selfhosted}"
WEB_PORT="${WEB_PORT:-8088}"
AUTO_INSTALL_DOCKER="${AUTO_INSTALL_DOCKER:-1}"

echo "=== DeepSafe 自主部署版 安装 ==="

if [[ $EUID -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# shellcheck source=compose.sh
compose_ready() { # defined in compose.sh when sourced
  command -v docker >/dev/null 2>&1 || return 1
  docker compose version >/dev/null 2>&1 && return 0
  command -v docker-compose >/dev/null 2>&1 && return 0
  return 1
}

start_docker_daemon() {
  if docker info >/dev/null 2>&1; then
    return 0
  fi
  if need_cmd systemctl && [[ -f /lib/systemd/system/docker.service || -f /etc/systemd/system/docker.service ]]; then
    $SUDO systemctl enable docker 2>/dev/null || true
    $SUDO systemctl start docker 2>/dev/null || true
  elif need_cmd service; then
    $SUDO service docker start 2>/dev/null || true
  fi
  docker info >/dev/null 2>&1
}

install_compose_apt() {
  need_cmd apt-get || return 1
  $SUDO apt-get update -qq
  local ver="${VERSION_ID:-}"
  # Ubuntu 16.04 / Debian 旧版只有 docker-compose v1
  if [[ "$ver" == "16.04" ]] || [[ "${VERSION_CODENAME:-}" == "xenial" ]]; then
    echo ">>> 安装 docker-compose (v1，适配 Ubuntu 16.04)..."
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-compose || true
  else
    echo ">>> 安装 docker compose 插件..."
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-compose-v2 2>/dev/null || \
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-compose || true
  fi
}

install_docker_apt() {
  echo ">>> 使用系统 apt 安装 Docker（不调用 get.docker.com）..."
  $SUDO apt-get update -qq
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker.io git curl ca-certificates
  start_docker_daemon || {
    echo "Docker 守护进程启动失败" >&2
    exit 1
  }
  if ! compose_ready; then
    install_compose_apt
  fi
}

install_docker_ubuntu() {
  if ! need_cmd curl; then
    $SUDO apt-get update -qq
    $SUDO apt-get install -y -qq curl ca-certificates
  fi

  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ "${VERSION_ID:-}" == "16.04" ]] || [[ "${VERSION_CODENAME:-}" == "xenial" ]]; then
      echo ">>> 检测到 Ubuntu 16.04 (xenial，已停止支持)，使用 docker.io + docker-compose v1"
      echo ">>> 建议升级到 Ubuntu 22.04+ 以获得更好兼容性"
    fi
  fi

  # 已装 docker：只启动并补 compose，绝不跑 get.docker.com
  if need_cmd docker; then
    echo ">>> 检测到已有 Docker: $(docker --version 2>/dev/null || true)"
    start_docker_daemon || exit 1
    if ! compose_ready; then
      install_compose_apt
    fi
  else
    install_docker_apt
  fi

  if ! need_cmd docker; then
    echo "Docker 安装失败。请执行: apt-get update && apt-get install -y docker.io docker-compose" >&2
    exit 1
  fi
  start_docker_daemon || exit 1
  if ! compose_ready; then
    echo "缺少 docker-compose。Ubuntu 16.04: apt-get install -y docker-compose" >&2
    exit 1
  fi
  echo "[OK] Docker 已就绪: $(docker --version)"
}

install_git() {
  if need_cmd git; then
    return
  fi
  echo ">>> 安装 git..."
  if need_cmd apt-get; then
    $SUDO apt-get update -qq
    $SUDO apt-get install -y -qq git
  elif need_cmd yum; then
    $SUDO yum install -y git
  elif need_cmd dnf; then
    $SUDO dnf install -y git
  else
    echo "请先安装 git" >&2
    exit 1
  fi
}

ensure_docker() {
  if need_cmd docker && docker info >/dev/null 2>&1 && compose_ready; then
    echo "[OK] Docker 已就绪: $(docker --version)"
    return
  fi

  if [[ "$AUTO_INSTALL_DOCKER" == "0" ]]; then
    echo "请先安装 Docker 与 docker-compose" >&2
    exit 1
  fi

  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}" in
      ubuntu|debian|linuxmint|pop)
        install_docker_ubuntu
        return
        ;;
    esac
  fi

  echo "请手动安装 Docker: https://docs.docker.com/engine/install/" >&2
  exit 1
}

ensure_docker
install_git

if [[ -f "docker-compose.selfhosted.yml" && -f "start-selfhosted.sh" ]]; then
  DEPLOY_DIR="$(pwd)"
  echo "使用当前目录: $DEPLOY_DIR"
elif [[ -d "$DIR/deploy" ]]; then
  DEPLOY_DIR="$(cd "$DIR/deploy" && pwd)"
  echo "使用已有目录: $DEPLOY_DIR"
else
  echo "克隆仓库..."
  git clone --depth 1 -b "$BRANCH" "$REPO" "$DIR"
  DEPLOY_DIR="$(cd "$DIR/deploy" && pwd)"
fi

cd "$DEPLOY_DIR"

if [[ ! -f .env.selfhosted ]]; then
  cp .env.selfhosted.example .env.selfhosted
  echo "已创建 .env.selfhosted（请稍后修改 JWT_SECRET）"
fi

chmod +x start-selfhosted.sh compose.sh 2>/dev/null || chmod +x start-selfhosted.sh

if command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
  echo ">>> 使用 docker-compose v1 + legacy 编排文件（Ubuntu 16.04 等）"
  export COMPOSE_FILE="docker-compose.selfhosted.legacy.yml"
fi

./start-selfhosted.sh

IP="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
IP="${IP:-127.0.0.1}"
echo ""
echo "完成。访问: http://${IP}:${WEB_PORT}"
echo "账号: demo / author123"

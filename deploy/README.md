# DeepSafe 自主部署版（离线）

> 深度云网络验证 — 客户自有服务器离线部署包  
> 推荐系统：**Ubuntu 22.04 / 24.04 LTS**

本目录包含 Docker 一键部署所需全部文件。下载后按下列步骤即可运行。

## 系统要求

- Ubuntu 22.04 / 24.04（或其他 Linux + Docker）
- Docker Engine 24+ 与 Docker Compose 插件
- 2 GB+ 内存，10 GB+ 磁盘

## 一句话部署

**Ubuntu / Linux（推荐）：**

```bash
curl -fsSL https://raw.githubusercontent.com/tuanzhang13/deepsafe-selfhosted/main/deploy/install.sh | bash
```

**Windows PowerShell：**

```powershell
irm https://raw.githubusercontent.com/tuanzhang13/deepsafe-selfhosted/main/deploy/install.ps1 | iex
```

**已在项目目录内：**

```bash
cd deploy && chmod +x install.sh && ./install.sh
```

安装完成后访问 **http://服务器IP:8088**，账号 `demo / author123`。

---

## 快速安装（手动）

```bash
# 1. 克隆仓库（或下载 Release 压缩包解压）
git clone https://github.com/tuanzhang13/deepsafe-selfhosted.git
cd deepsafe-selfhosted/deploy

# 2. 配置
cp .env.selfhosted.example .env.selfhosted
nano .env.selfhosted   # 修改 JWT_SECRET

# 3. 启动（自动拉取预编译镜像，无需源码）
chmod +x start-selfhosted.sh
./start-selfhosted.sh
```

浏览器访问：**http://服务器IP:8088**

- 默认账号：`demo / author123`
- 免费版：无需授权文件，直接使用
- 订阅版：登录后在「订阅与套餐」上传 `license.lic`

## 获取机器码（订阅版授权用）

```bash
../scripts/machine-id.sh http://127.0.0.1:8088
```

将机器码提供给 DeepSafe 获取授权文件。

## 常用命令

```bash
# 查看状态
docker compose -f docker-compose.selfhosted.yml ps

# 查看日志
docker compose -f docker-compose.selfhosted.yml logs -f api

# 停止
docker compose -f docker-compose.selfhosted.yml down

# 更新镜像
docker compose -f docker-compose.selfhosted.yml pull
docker compose -f docker-compose.selfhosted.yml up -d
```

## 目录说明

| 文件 | 说明 |
|------|------|
| `docker-compose.selfhosted.yml` | 服务编排（拉取 GHCR 预编译镜像） |
| `.env.selfhosted.example` | 环境变量模板 |
| `start-selfhosted.sh` | Linux 一键启动 |

> 本仓库**不含** API / 管理端源码。订阅校验在预编译镜像内，需 DeepSafe 签发的 `license.lic` 才能解锁订阅版。

完整文档：[docs/自主部署.md](../docs/自主部署.md)

## 版本说明

| 套餐 | 应用数 | 单批卡密 | 多开 | 代理 |
|------|--------|----------|------|------|
| 免费版 | 3 | 50 | 1 | ✗ |
| 订阅版 | 100 | 1000 | 5 | ✓ |

---

© DeepCloudSafe · 深度云网络验证 DeepSafe

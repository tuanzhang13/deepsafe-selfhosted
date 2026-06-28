# DeepSafe 深度云网络验证 — 自主部署版

面向 **Ubuntu / Linux** 的离线部署包，客户自有服务器运行，无需 DeepSafe 云端。

| 套餐 | 应用 | 卡密/批 | 多开 | 代理 |
|------|------|---------|------|------|
| 免费版 | 3 | 50 | 1 | ✗ |
| 订阅版 | 100 | 1000 | 5 | ✓ |

## 快速开始

### 一句话部署

```bash
curl -fsSL https://raw.githubusercontent.com/tuanzhang13/deepsafe-selfhosted/main/deploy/install.sh | bash
```

Windows:

```powershell
irm https://raw.githubusercontent.com/tuanzhang13/deepsafe-selfhosted/main/deploy/install.ps1 | iex
```

### 手动部署

访问 **http://服务器IP:8088** · 默认账号 `demo / author123`

详细说明：[deploy/README.md](deploy/README.md) · [docs/自主部署.md](docs/自主部署.md)

## 仓库内容

- `deploy/` — Docker Compose + 启动脚本（**拉取预编译镜像，不含源码**）
- `docs/` — 部署与 API 文档
- `scripts/` — 机器码查询等工具

> 订阅版授权由 DeepSafe 签发的 `license.lic` 控制，校验逻辑在预编译 API 镜像内，客户无法通过改源码绕过。

## 订阅版授权

1. 启动后获取机器码：`./scripts/machine-id.sh http://127.0.0.1:8088`
2. 向 DeepSafe 申请 `license.lic`
3. 管理端 → 订阅与套餐 → 上传授权文件

---

© DeepCloudSafe · 专有软件

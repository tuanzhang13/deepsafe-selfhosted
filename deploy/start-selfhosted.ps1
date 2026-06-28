# DeepSafe 自主部署版 — Docker 一键启动

$ErrorActionPreference = "Stop"
$DeployDir = $PSScriptRoot

Set-Location $DeployDir

$envFile = Join-Path $DeployDir ".env.selfhosted"
$envExample = Join-Path $DeployDir ".env.selfhosted.example"
if (-not (Test-Path $envFile)) {
    Copy-Item $envExample $envFile
    Write-Host "已创建 .env.selfhosted，请按需修改 JWT_SECRET" -ForegroundColor Yellow
}

Write-Host "=== 拉取并启动自主部署版 ===" -ForegroundColor Cyan
docker compose -f docker-compose.selfhosted.yml pull
docker compose -f docker-compose.selfhosted.yml up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "启动失败，请检查 Docker 是否运行" -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 5
$port = (Get-Content $envFile | Where-Object { $_ -match '^\s*WEB_PORT\s*=' } | ForEach-Object { ($_ -split '=', 2)[1].Trim() })
if (-not $port) { $port = "8088" }

Write-Host ""
Write-Host "[OK] 自主部署版已启动" -ForegroundColor Green
Write-Host "  管理端:  http://127.0.0.1:$port"
Write-Host "  API:     http://127.0.0.1:$port/api/edition/info"
Write-Host ""
Write-Host "  默认账号: demo / author123（首次启动自动创建）"
Write-Host "  免费版无需授权文件；订阅版在「订阅与套餐」上传 license.lic"
Write-Host ""
Write-Host "停止: docker compose -f docker-compose.selfhosted.yml down" -ForegroundColor Gray

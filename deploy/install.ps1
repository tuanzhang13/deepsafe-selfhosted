# DeepSafe 自主部署版 — 一句话安装 (Windows PowerShell)
# 用法: irm https://raw.githubusercontent.com/tuanzhang13/deepsafe-selfhosted/main/deploy/install.ps1 | iex
$ErrorActionPreference = "Stop"

$Repo = if ($env:DEEPSAFE_REPO) { $env:DEEPSAFE_REPO } else { "https://github.com/tuanzhang13/deepsafe-selfhosted.git" }
$Dir  = if ($env:DEEPSAFE_DIR)  { $env:DEEPSAFE_DIR }  else { Join-Path $env:USERPROFILE "deepsafe-selfhosted" }

Write-Host "=== DeepSafe 自主部署版 安装 ===" -ForegroundColor Cyan

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "请先安装 Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
    exit 1
}

$DeployDir = $null
if ((Test-Path "docker-compose.selfhosted.yml") -and (Test-Path "start-selfhosted.ps1")) {
    $DeployDir = (Get-Location).Path
    Write-Host "使用当前目录: $DeployDir"
} elseif (Test-Path (Join-Path $Dir "deploy\docker-compose.selfhosted.yml")) {
    $DeployDir = Join-Path $Dir "deploy"
    Write-Host "使用已有目录: $DeployDir"
} else {
    Write-Host "克隆仓库..."
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "请先安装 Git" -ForegroundColor Red
        exit 1
    }
    if (Test-Path $Dir) { Remove-Item -Recurse -Force $Dir }
    git clone --depth 1 $Repo $Dir
    $DeployDir = Join-Path $Dir "deploy"
}

Set-Location $DeployDir

$envFile = ".env.selfhosted"
if (-not (Test-Path $envFile)) {
    Copy-Item ".env.selfhosted.example" $envFile
    Write-Host "已创建 .env.selfhosted" -ForegroundColor Yellow
}

powershell -NoProfile -ExecutionPolicy Bypass -File ".\start-selfhosted.ps1"

Write-Host ""
Write-Host "完成。访问: http://127.0.0.1:8088" -ForegroundColor Green
Write-Host "账号: demo / author123"

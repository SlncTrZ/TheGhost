# install.ps1 — TheGhost Installer (STRATEGY.md §5): 1 lệnh cài OpenClaw + TheGhost wrapper (Windows).
# Cài: clone repo → đồng bộ vendor/openclaw → deploy OpenClaw → config MeiLin → verify.
# TỰ CHỌN CHẾ ĐỘ (set $env:INSTALL_MODE = "docker" | "local" | "auto" để ép):
#   docker: OpenClaw gateway trong container (image ghcr.io/openclaw/openclaw:latest) — cần Docker Desktop.
#   local : OpenClaw chạy trực tiếp bằng Node (npm) — cần Node 22.22.3+ / 24.15+ / 25.9+.
# Cách chạy: powershell -ExecutionPolicy Bypass -File scripts/install.ps1
# Updated: 2026-08-11
$ErrorActionPreference = "Stop"

function Info($msg) { Write-Host "[install] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[install] $msg" -ForegroundColor Yellow }
function Fail($msg) { Write-Host "[install] LỖI: $msg" -ForegroundColor Red; exit 1 }

# ---------- 1. Xác định thư mục TheGhost ----------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TheGhostDir = Split-Path -Parent $ScriptDir
$VendorOpenClaw = Join-Path $TheGhostDir "vendor\openclaw"
$DeployDir = Join-Path $TheGhostDir "deploy\openclaw"
$OpenClawImage = "ghcr.io/openclaw/openclaw:latest"
$OpenClawPort = if ($env:OPENCLAW_PORT) { $env:OPENCLAW_PORT } else { "18789" }

Info "TheGhost dir: $TheGhostDir"

# ---------- 2. Kiểm tra prerequisites + chọn chế độ ----------
foreach ($cmd in @("git", "curl")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Fail "Thiếu '$cmd' — cài Git for Windows trước (git-scm.com)."
    }
}

$InstallMode = if ($env:INSTALL_MODE) { $env:INSTALL_MODE.ToLower() } else { "auto" }
if ($InstallMode -eq "auto") {
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        $InstallMode = "docker"
    } else {
        $InstallMode = "local"
    }
    Info "Tự chọn chế độ: $InstallMode (ép chế độ: set INSTALL_MODE=docker|local)"
}

switch ($InstallMode) {
    "docker" {
        if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
            Fail "Thiếu docker — cài Docker Desktop (docker.com), hoặc set INSTALL_MODE=local."
        }
        docker compose version | Out-Null
        if ($LASTEXITCODE -ne 0) { Fail "Thiếu docker compose plugin." }
    }
    "local" {
        if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
            Fail "Thiếu node — chế độ không-docker cần Node 22.22.3+ / 24.15+ / 25.9+ (nodejs.org)."
        }
        if (-not (Test-NodeVersion)) {
            Fail "Node $(node --version) không hỗ trợ — cần 22.22.3+ / 24.15+ / 25.9+ (openclaw.mjs SUPPORTED_NODE_RANGE)."
        }
    }
    default { Fail "INSTALL_MODE không hợp lệ: '$InstallMode' (chỉ nhận docker|local|auto)." }
}

# ---------- 3. Clone TheGhost nếu chưa có STRATEGY.md ----------
if (-not (Test-Path (Join-Path $TheGhostDir "STRATEGY.md"))) {
    Info "Clone TheGhost (SlncTrZ/TheGhost)..."
    git clone --depth 1 "https://github.com/SlncTrZ/TheGhost.git" $TheGhostDir
}

# ---------- 4. Đồng bộ vendor/openclaw (dependency — cần cho cả 2 chế độ) ----------
if (-not (Test-Path (Join-Path $VendorOpenClaw ".git"))) {
    Info "Clone OpenClaw -> vendor/openclaw (dependency)..."
    New-Item -ItemType Directory -Force -Path (Join-Path $TheGhostDir "vendor") | Out-Null
    git clone --depth 1 "https://github.com/openclaw/openclaw.git" $VendorOpenClaw
} else {
    Info "OpenClaw da co tai vendor/openclaw — skip (cap nhat: cd vendor/openclaw && git pull)."
}

# ---------- 5. Config MeiLin (dùng chung) ----------
function Copy-MeilinConfig($dest) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    $MeilinCfg = Join-Path $TheGhostDir "vendor\openclaw\meilin\openclaw.json"
    if ((Test-Path $MeilinCfg) -and (-not (Test-Path (Join-Path $dest "openclaw.json")))) {
        Info "Dung config MeiLin tu vendor/openclaw/meilin -> $dest"
        Copy-Item -Recurse -Force (Join-Path $TheGhostDir "vendor\openclaw\meilin\*") $dest
    } elseif (-not (Test-Path (Join-Path $dest "openclaw.json"))) {
        Info "Chua co config MeiLin — tao openclaw.json toi gian (chinh sau theo nhu cau)"
        @'
{
  "agents": { "defaults": { "compaction": { "mode": "safeguard" } } },
  "channels": {}
}
'@ | Set-Content -Path (Join-Path $dest "openclaw.json") -Encoding UTF8
    }
}

# ---------- 6. Kiểm tra Node version ----------
function Test-NodeVersion {
    $raw = (node --version) -replace '^v', ''
    try { $ver = [version]$raw } catch { return $false }
    switch ($ver.Major) {
        22 { return $ver -ge [version]"22.22.3" }
        24 { return $ver -ge [version]"24.15.0" }
        25 { return $ver -ge [version]"25.9.0" }
        default { return $ver.Major -ge 26 }  # major mới (OpenClaw recommended major 26)
    }
}

# ---------- 7. CHẾ ĐỘ DOCKER: compose + up + verify ----------
function Install-Docker {
    New-Item -ItemType Directory -Force -Path (Join-Path $DeployDir "config") | Out-Null
    $ComposeFile = Join-Path $DeployDir "docker-compose.yml"
    if (-not (Test-Path $ComposeFile)) {
        Info "Tao docker-compose.yml cho OpenClaw gateway..."
        @"
services:
  openclaw:
    image: ${OpenClawImage}
    user: root
    container_name: openclaw
    restart: unless-stopped
    environment:
      - OPENCLAW_CONFIG_DIR=/root/.openclaw
      - OPENCLAW_STATE_DIR=/root/.openclaw
      - TZ=Asia/Ho_Chi_Minh
      - OPENCLAW_GATEWAY_PORT=${OpenClawPort}
      - TERM=xterm-256color
    volumes:
      - ./config:/root/.openclaw
    ports:
      - "${OpenClawPort}:${OpenClawPort}"
"@ | Set-Content -Path $ComposeFile -Encoding UTF8
    }
    Copy-MeilinConfig (Join-Path $DeployDir "config")

    Info "Khoi dong OpenClaw gateway (image: $OpenClawImage)..."
    Push-Location $DeployDir
    try {
        docker compose up -d | Out-Host
        if ($LASTEXITCODE -ne 0) { Fail "docker compose up that bai." }
    } finally {
        Pop-Location
    }

    Info "Cho OpenClaw khoi dong (toi da 60s)..."
    for ($i = 0; $i -lt 12; $i++) {
        try {
            $r = Invoke-WebRequest -Uri "http://127.0.0.1:$OpenClawPort/healthz" -TimeoutSec 5 -UseBasicParsing
                if ($r.StatusCode -eq 200) {
                    Write-Host "[install] ✅ OpenClaw gateway OK (docker): http://127.0.0.1:$OpenClawPort" -ForegroundColor Green
                    Write-Host "[install] ✅ TheGhost wrapper OK: $(Split-Path -Leaf $TheGhostDir)" -ForegroundColor Green
                    $PostInstall = Join-Path $ScriptDir "post-install.ps1"
                    if ($env:SKIP_POWER_STACK -eq "1") {
                        Warn "SKIP_POWER_STACK=1 — bo qua Power Stack"
                    } elseif (Test-Path $PostInstall) {
                        Info "Ap dung Power Stack (ADR-032)..."
                        $env:OPENCLAW_CMD = "docker exec openclaw openclaw"
                        & $PostInstall
                        if ($LASTEXITCODE -ne 0) { Warn "post-install gap loi — xem log tren" }
                    } else {
                        Warn "Thieu scripts/post-install.ps1 — bo qua Power Stack"
                    }
                    exit 0
                }
        } catch { }
        Start-Sleep -Seconds 5
    }
    Fail "OpenClaw khong health sau 60s — xem: docker logs openclaw"
}

# ---------- 8. CHẾ ĐỘ LOCAL: npm + onboard + verify ----------
function Install-Local {
    Info "Che do KHONG-docker — cai OpenClaw truc tiep bang Node..."
    if (-not (Get-Command openclaw -ErrorAction SilentlyContinue)) {
        Info "npm install -g openclaw@latest ..."
        npm install -g openclaw@latest | Out-Host
        if ($LASTEXITCODE -ne 0) { Fail "npm install openclaw that bai." }
    }

    $ConfigDir = if ($env:OPENCLAW_CONFIG_DIR) { $env:OPENCLAW_CONFIG_DIR } else { Join-Path $HOME ".openclaw" }
    Copy-MeilinConfig $ConfigDir

    Info "Khoi tao OpenClaw (openclaw onboard --install-daemon)..."
    openclaw onboard --install-daemon | Out-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[install] onboard --install-daemon loi — thu onboard khong daemon..." -ForegroundColor Yellow
        openclaw onboard | Out-Host
        if ($LASTEXITCODE -ne 0) { Fail "openclaw onboard that bai — chay thu cong: openclaw onboard" }
    }

    Info "Cho gateway khoi dong (toi da 60s)..."
    for ($i = 0; $i -lt 12; $i++) {
        try {
            $r = Invoke-WebRequest -Uri "http://127.0.0.1:$OpenClawPort/healthz" -TimeoutSec 5 -UseBasicParsing
            if ($r.StatusCode -eq 200) {
                Write-Host "[install] ✅ OpenClaw gateway OK (local): http://127.0.0.1:$OpenClawPort" -ForegroundColor Green
                Write-Host "[install] ✅ TheGhost wrapper OK: $(Split-Path -Leaf $TheGhostDir)" -ForegroundColor Green
                $PostInstall = Join-Path $ScriptDir "post-install.ps1"
                if ($env:SKIP_POWER_STACK -eq "1") {
                    Warn "SKIP_POWER_STACK=1 — bo qua Power Stack"
                } elseif (Test-Path $PostInstall) {
                    Info "Ap dung Power Stack (ADR-032)..."
                    Remove-Item Env:OPENCLAW_CMD -ErrorAction SilentlyContinue
                    & $PostInstall
                    if ($LASTEXITCODE -ne 0) { Warn "post-install gap loi — xem log tren" }
                } else {
                    Warn "Thieu scripts/post-install.ps1 — bo qua Power Stack"
                }
                Write-Host "[install] 💡 Dashboard: openclaw dashboard" -ForegroundColor Green
                exit 0
            }
        } catch { }
        Start-Sleep -Seconds 5
    }
    Write-Host "[install] Gateway chua health — trang thai hien tai:" -ForegroundColor Yellow
    openclaw gateway status 2>&1 | Select-Object -First 5
    Fail "OpenClaw khong health sau 60s — chay: openclaw doctor"
}

# ---------- 9. Chạy theo chế độ ----------
if ($InstallMode -eq "docker") {
    Install-Docker
} else {
    Install-Local
}

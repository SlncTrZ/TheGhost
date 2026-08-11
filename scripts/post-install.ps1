# post-install.ps1 — TheGhost Power Stack (ADR-032): cài whitelist skills + enable plugins + verify.
# Chạy SAU khi OpenClaw gateway lên — gọi tự động từ install.ps1, hoặc chạy tay:
#   local : .\scripts\post-install.ps1
#   docker: $env:OPENCLAW_CMD = "docker exec openclaw openclaw"; .\scripts\post-install.ps1
# Idempotent: skill đã cài → skip; lỗi cài 1 skill → cảnh báo, không dừng.
# Updated: 2026-08-11
$ErrorActionPreference = "Continue"

function Info($msg) { Write-Host "[post-install] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[post-install] $msg" -ForegroundColor Yellow }

# Cách gọi CLI OpenClaw: local = "openclaw"; docker = "docker exec openclaw openclaw"
$OC = if ($env:OPENCLAW_CMD) { $env:OPENCLAW_CMD } else { "openclaw" }
$OCBin = ($OC -split ' ')[0]
if (-not (Get-Command $OCBin -ErrorAction SilentlyContinue)) {
    Write-Host "[post-install] LỖI: Không gọi được OpenClaw CLI ('$OC')" -ForegroundColor Red
    exit 1
}

# ---------- Whitelist skills (ADR-032 — đã nghiệm thu .227) ----------
$Skills = @(
    "@9438190/deep-research"
    "@brennerspear/research-agent"
    "@athola/nm-tome-research"
    "@fortunto2/solo-research"
    "@wpank/code-review"
    "@wpank/testing-patterns"
    "@wpank/e2e-testing-patterns"
    "@rithythul/koompi-memory"
)

# ---------- 1. Cài skills (idempotent) ----------
Info "Bước 1/3 — Cài whitelist skills (ADR-032)..."
$installed = (& $OC skills list 2>$null | Out-String)
foreach ($s in $Skills) {
    $name = $s.TrimStart('@')
    if ($installed -match [regex]::Escape($name)) {
        Info "  Skill đã có: $s — skip"
    } else {
        Info "  Cài: $s ..."
        & $OC skills install $s *> $null
        if ($LASTEXITCODE -eq 0) { Info "  ✅ $s" }
        else { Warn "  ⚠️ Cài $s thất bại — kiểm tra: $OC skills info $s" }
    }
}

# ---------- 2. Enable plugins (memory-wiki — bundled) ----------
Info "Bước 2/3 — Enable plugin memory-wiki (compiled wiki)..."
& $OC plugins enable memory-wiki *> $null
if ($LASTEXITCODE -eq 0) {
    Info "  ✅ memory-wiki enabled — restart gateway để áp dụng"
    & $OC gateway restart *> $null
    if ($LASTEXITCODE -eq 0) { Info "  ✅ Gateway restarted" }
    else { Warn "  ⚠️ Không restart gateway tự động — chạy tay: $OC gateway restart" }
} else {
    Warn "  ⚠️ Không enable được memory-wiki (có thể đã bật)"
}

# ---------- 3. Verify ----------
Info "Bước 3/3 — Verify..."
(& $OC skills check 2>$null | Out-String) -split "`n" | Where-Object { $_ -match "code-review|research|memory|testing" } | Select-Object -First 12
(& $OC plugins list 2>$null | Out-String) -split "`n" | Where-Object { $_ -match "memory-wiki" } | Select-Object -First 3

Info "✅ Power Stack xong — xem bộ skills: $OC skills list"

#!/usr/bin/env bash
# post-install.sh — TheGhost Power Stack (ADR-032): cài whitelist skills + enable plugins + verify.
# Chạy SAU khi OpenClaw gateway lên — gọi tự động từ install.sh / install.ps1, hoặc chạy tay:
#   local : ./scripts/post-install.sh
#   docker: OPENCLAW_CMD="docker exec openclaw openclaw" ./scripts/post-install.sh
# Idempotent: skill đã cài → skip; lỗi cài 1 skill → cảnh báo, không dừng.
# Updated: 2026-08-11
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
info() { echo -e "${GREEN}[post-install]${NC} $1"; }
warn() { echo -e "${YELLOW}[post-install]${NC} $1"; }

# Cách gọi CLI OpenClaw: local = "openclaw"; docker = "docker exec openclaw openclaw"
OC="${OPENCLAW_CMD:-openclaw}"
if ! command -v "${OC%% *}" >/dev/null 2>&1; then
	echo -e "${RED}[post-install] LỖI: Không gọi được OpenClaw CLI ('$OC')${NC}"
	exit 1
fi

# ---------- Whitelist skills (ADR-032 — đã nghiệm thu .227) ----------
SKILLS=(
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
info "Bước 1/3 — Cài whitelist skills (ADR-032)..."
installed="$($OC skills list 2>/dev/null || true)"
for s in "${SKILLS[@]}"; do
	name="${s#@}"
	if echo "$installed" | grep -qi "$name"; then
		info "  Skill đã có: $s — skip"
	else
		info "  Cài: $s ..."
		if $OC skills install "$s" >/dev/null 2>&1; then
			info "  ✅ $s"
		else
			warn "  ⚠️ Cài $s thất bại — kiểm tra: $OC skills info $s"
		fi
	fi
done

# ---------- 2. Enable plugins (memory-wiki — bundled) ----------
info "Bước 2/3 — Enable plugin memory-wiki (compiled wiki)..."
if $OC plugins enable memory-wiki >/dev/null 2>&1; then
	info "  ✅ memory-wiki enabled — restart gateway để áp dụng"
	if $OC gateway restart >/dev/null 2>&1; then
		info "  ✅ Gateway restarted"
	else
		warn "  ⚠️ Không restart gateway tự động — chạy tay: $OC gateway restart"
	fi
else
	warn "  ⚠️ Không enable được memory-wiki (có thể đã bật)"
fi

# ---------- 3. Verify ----------
info "Bước 3/3 — Verify..."
$OC skills check 2>&1 | grep -iE "code-review|research|memory|testing" | head -12 || true
$OC plugins list 2>&1 | grep -i "memory-wiki" | head -3 || true

info "✅ Power Stack xong — xem bộ skills: $OC skills list"

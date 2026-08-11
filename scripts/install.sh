#!/usr/bin/env bash
# install.sh — TheGhost Installer (STRATEGY.md §5): 1 lệnh cài OpenClaw + TheGhost wrapper.
# Cài: clone repo → đồng bộ vendor/openclaw → deploy OpenClaw → config MeiLin → verify.
# TỰ CHỌN CHẾ ĐỘ (set INSTALL_MODE=docker|local để ép):
#   docker: OpenClaw gateway trong container (image ghcr.io/openclaw/openclaw:latest) — cần Docker Engine/Desktop.
#   local : OpenClaw chạy trực tiếp bằng Node (npm) — cần Node 22.22.3+ / 24.15+ / 25.9+.
# Target: Linux (Ubuntu 24.04 như server .227) / macOS (Docker Desktop hoặc Node).
# Cách chạy: curl -fsSL <URL> | bash   hoặc   ./scripts/install.sh
# Updated: 2026-08-11
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
info() { echo -e "${GREEN}[install]${NC} $1"; }
warn() { echo -e "\033[0;33m[install]${NC} $1"; }
fail() {
	echo -e "${RED}[install] LỖI:${NC} $1"
	exit 1
}

# Kiểm tra Node version — OpenClaw hỗ trợ: >=22.22.3 <23, >=24.15.0 <25, >=25.9.0 (openclaw.mjs SUPPORTED_NODE_RANGE)
check_node_version() {
	local v major
	v="$(node --version 2>/dev/null | sed 's/^v//')"
	[ -n "$v" ] || return 1
	major="${v%%.*}"
	case "$major" in
	22) [ "$(printf '%s\n%s\n' "$v" 22.22.3 | sort -V | tail -n1)" = "$v" ] ;;
	24) [ "$(printf '%s\n%s\n' "$v" 24.15.0 | sort -V | tail -n1)" = "$v" ] ;;
	25) [ "$(printf '%s\n%s\n' "$v" 25.9.0 | sort -V | tail -n1)" = "$v" ] ;;
	2[6-9] | [3-9][0-9]) return 0 ;; # major mới (OpenClaw recommended major 26)
	*) return 1 ;;
	esac
}

# ---------- 1. Xác định thư mục TheGhost ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEGHOST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VENDOR_OPENCLAW="$THEGHOST_DIR/vendor/openclaw"
DEPLOY_DIR="$THEGHOST_DIR/deploy/openclaw"
OPENCLAW_IMAGE="ghcr.io/openclaw/openclaw:latest"
OPENCLAW_PORT="${OPENCLAW_PORT:-18789}"

info "TheGhost dir: $THEGHOST_DIR"

# ---------- 2. Kiểm tra prerequisites + chọn chế độ ----------
for cmd in git curl; do
	command -v "$cmd" >/dev/null 2>&1 || fail "Thiếu '$cmd' — cài trước (vd: sudo apt install $cmd)."
done

INSTALL_MODE="${INSTALL_MODE:-auto}"
if [ "$INSTALL_MODE" = "auto" ]; then
	if command -v docker >/dev/null 2>&1; then
		INSTALL_MODE=docker
	else
		INSTALL_MODE=local
	fi
	info "Tự chọn chế độ: $INSTALL_MODE (ép chế độ: INSTALL_MODE=docker|local)"
fi

case "$INSTALL_MODE" in
docker)
	command -v docker >/dev/null 2>&1 || fail "Thiếu docker — cài Docker Engine/Desktop, hoặc chạy INSTALL_MODE=local."
	docker compose version >/dev/null 2>&1 || fail "Thiếu docker compose plugin."
	;;
local)
	command -v node >/dev/null 2>&1 || fail "Thiếu node — chế độ không-docker cần Node 22.22.3+ / 24.15+ / 25.9+ (nodejs.org)."
	if ! check_node_version; then
		fail "Node $(node --version) không hỗ trợ — cần 22.22.3+ / 24.15+ / 25.9+ (xem openclaw.mjs SUPPORTED_NODE_RANGE)."
	fi
	;;
*)
	fail "INSTALL_MODE không hợp lệ: '$INSTALL_MODE' (chỉ nhận docker|local|auto)."
	;;
esac

# ---------- 3. Clone TheGhost nếu đang chạy từ URL (không phải trong repo) ----------
if [ ! -f "$THEGHOST_DIR/STRATEGY.md" ]; then
	info "Clone TheGhost (SlncTrZ/TheGhost)..."
	git clone --depth 1 https://github.com/SlncTrZ/TheGhost.git "$THEGHOST_DIR"
fi

# ---------- 4. Đồng bộ vendor/openclaw (dependency — cần cho cả 2 chế độ) ----------
if [ ! -d "$VENDOR_OPENCLAW/.git" ]; then
	info "Clone OpenClaw → vendor/openclaw (dependency)..."
	mkdir -p "$THEGHOST_DIR/vendor"
	git clone --depth 1 https://github.com/openclaw/openclaw.git "$VENDOR_OPENCLAW"
else
	info "OpenClaw đã có tại vendor/openclaw — skip (cập nhật: cd vendor/openclaw && git pull)."
fi

# ---------- 5. Config MeiLin (dùng chung) ----------
copy_meilin_config() {
	local dest="$1"
	mkdir -p "$dest"
	if [ -d "$THEGHOST_DIR/vendor/openclaw/meilin" ] && [ -f "$THEGHOST_DIR/vendor/openclaw/meilin/openclaw.json" ]; then
		info "Dùng config MeiLin từ vendor/openclaw/meilin → $dest"
		cp -r "$THEGHOST_DIR/vendor/openclaw/meilin/." "$dest/"
	elif [ ! -f "$dest/openclaw.json" ]; then
		info "Chưa có config MeiLin — tạo openclaw.json tối giản (chỉnh sau theo nhu cầu)"
		cat >"$dest/openclaw.json" <<'EOF'
{
  "agents": { "defaults": { "compaction": { "mode": "safeguard" } } },
  "channels": {}
}
EOF
	fi
}

# ---------- 6. CHẾ ĐỘ DOCKER: compose + up + verify ----------
install_docker() {
	mkdir -p "$DEPLOY_DIR/config"
	if [ ! -f "$DEPLOY_DIR/docker-compose.yml" ]; then
		info "Tạo docker-compose.yml cho OpenClaw gateway..."
		cat >"$DEPLOY_DIR/docker-compose.yml" <<EOF
services:
  openclaw:
    image: ${OPENCLAW_IMAGE}
    user: root
    container_name: openclaw
    restart: unless-stopped
    environment:
      - OPENCLAW_CONFIG_DIR=/root/.openclaw
      - OPENCLAW_STATE_DIR=/root/.openclaw
      - TZ=Asia/Ho_Chi_Minh
      - OPENCLAW_GATEWAY_PORT=${OPENCLAW_PORT}
      - TERM=xterm-256color
    volumes:
      - ./config:/root/.openclaw
    ports:
      - "${OPENCLAW_PORT}:${OPENCLAW_PORT}"
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://127.0.0.1:${OPENCLAW_PORT}/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 20s
EOF
	fi
	copy_meilin_config "$DEPLOY_DIR/config"

	info "Khởi động OpenClaw gateway (image: $OPENCLAW_IMAGE)..."
	cd "$DEPLOY_DIR"
	docker compose up -d 2>&1 | tail -3 || fail "docker compose up thất bại."

	info "Chờ OpenClaw khởi động (tối đa 60s)..."
	for _ in $(seq 1 12); do
		if curl -sf -m 5 "http://127.0.0.1:${OPENCLAW_PORT}/healthz" >/dev/null 2>&1; then
			echo -e "${GREEN}[install] ✅ OpenClaw gateway OK (docker): http://127.0.0.1:${OPENCLAW_PORT}${NC}"
			echo -e "${GREEN}[install] ✅ TheGhost wrapper OK: $(basename "$THEGHOST_DIR")${NC}"
			if [ "${SKIP_POWER_STACK:-0}" = "1" ]; then
				warn "SKIP_POWER_STACK=1 — bỏ qua Power Stack"
			elif [ -f "$SCRIPT_DIR/post-install.sh" ]; then
				info "Áp dụng Power Stack (ADR-032)..."
				OPENCLAW_CMD="docker exec openclaw openclaw" "$SCRIPT_DIR/post-install.sh" ||
					warn "post-install gặp lỗi — xem log trên"
			else
				warn "Thiếu scripts/post-install.sh — bỏ qua Power Stack"
			fi
			exit 0
		fi
		sleep 5
	done
	fail "OpenClaw không health sau 60s — xem: docker logs openclaw"
}

# ---------- 7. CHẾ ĐỘ LOCAL: npm + onboard + verify ----------
install_local() {
	info "Chế độ KHÔNG-docker — cài OpenClaw trực tiếp bằng Node..."
	if ! command -v openclaw >/dev/null 2>&1; then
		info "npm install -g openclaw@latest ..."
		npm install -g openclaw@latest || fail "npm install openclaw thất bại."
	fi

	CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
	copy_meilin_config "$CONFIG_DIR"

	info "Khởi tạo OpenClaw (openclaw onboard --install-daemon)..."
	openclaw onboard --install-daemon || fail "openclaw onboard thất bại — chạy thủ công: openclaw onboard"

	info "Chờ gateway khởi động (tối đa 60s)..."
	for _ in $(seq 1 12); do
		if curl -sf -m 5 "http://127.0.0.1:${OPENCLAW_PORT}/healthz" >/dev/null 2>&1; then
			echo -e "${GREEN}[install] ✅ OpenClaw gateway OK (local): http://127.0.0.1:${OPENCLAW_PORT}${NC}"
			echo -e "${GREEN}[install] ✅ TheGhost wrapper OK: $(basename "$THEGHOST_DIR")${NC}"
			if [ "${SKIP_POWER_STACK:-0}" = "1" ]; then
				warn "SKIP_POWER_STACK=1 — bỏ qua Power Stack"
			elif [ -f "$SCRIPT_DIR/post-install.sh" ]; then
				info "Áp dụng Power Stack (ADR-032)..."
				"$SCRIPT_DIR/post-install.sh" || warn "post-install gặp lỗi — xem log trên"
			else
				warn "Thiếu scripts/post-install.sh — bỏ qua Power Stack"
			fi
			echo -e "${GREEN}[install] 💡 Dashboard: openclaw dashboard${NC}"
			exit 0
		fi
		sleep 5
	done
	info "Gateway chưa health — trạng thái hiện tại:"
	openclaw gateway status 2>&1 | head -5 || true
	fail "OpenClaw không health sau 60s — chạy: openclaw doctor"
}

# ---------- 8. Chạy theo chế độ ----------
if [ "$INSTALL_MODE" = "docker" ]; then
	install_docker
else
	install_local
fi

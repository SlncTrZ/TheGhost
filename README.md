# 👻 TheGhost — Cyber Brain bổ trợ OpenClaw

> **GHOST (Ghost in the Shell)** — Ý thức, Ký ức, Cảm xúc, Bản ngã.
> TheGhost là **Cyber Brain** cho hệ thống: bộ quy trình + chuẩn code + tri thức
> **bao bọc OpenClaw** — để mọi code OpenClaw viết ra đều **đúng ý chúng ta**.
>
> Đọc thêm: [STRATEGY.md](STRATEGY.md)

---

## 🧠 Tầm nhìn

| Trụ cột "Ghost" | TheGhost cung cấp |
| --- | --- |
| **Ý thức** (tự chủ, tỉnh táo) | Quy trình bắt buộc: research → ADR → code → nghiệm thu |
| **Ký ức** (không quên, không bịa) | Config MeiLin (ký ức các phiên) trong `vendor/openclaw/meilin/` |
| **Cảm xúc / Bản ngã** | SOUL/USER/identity — workspace MeiLin (backup từ .227) |
| **Kết nối toàn cầu** | OpenClaw gateway + TheGhost wrapper |

## 📦 Cấu trúc repo

```text
TheGhost/                          ← REPO RIÊNG CỦA CHÚNG TA (wrapper)
├── STRATEGY.md                    ← Vision: Cyber Brain bổ trợ OpenClaw
├── README.md                      ← File này
├── PLAN.md                        ← Kế hoạch & lộ trình
├── framework/                     ← ⭐ Code Standard (sub-framework cho OpenClaw/Pi)
│   ├── AGENTS.md                  ← Quy trình code chuẩn (research→ADR→code→nghiệm thu)
│   ├── research-template.md       ← Form báo cáo nghiên cứu (đầy đủ, không rút gọn)
│   ├── ADR-template.md            ← Form chốt quyết định
│   ├── code-checklist.md          ← Checklist trước khi báo xong
│   └── skills/code-standard/SKILL.md ← Skill nạp bởi OpenClaw / Pi
├── scripts/                       ← Installer 1 lệnh (tự chọn chế độ Docker / không-Docker)
│   ├── install.sh                 ← Linux / macOS
│   ├── install.ps1                ← Windows
│   └── README.md                  ← Hướng dẫn script + phương án khi không có Qdrant
└── vendor/                        ← Dependencies (git-ignored trừ README)
    ├── openclaw/                  ← Source OpenClaw (dependency — cập nhật không ảnh hưởng wrapper)
    │   └── meilin/                ← Config MeiLin (SECRET — git-ignored)
    └── README.md
```

## 🚀 Cài đặt

Installer **tự phát hiện môi trường** và chạy đúng phương án: có Docker → chạy OpenClaw trong container; không có Docker → chạy OpenClaw trực tiếp bằng Node. (Ép chế độ bằng biến `INSTALL_MODE=docker|local`.)

| # | Phương án | Hệ điều hành | Yêu cầu | Lệnh cài |
| --- | --- | --- | --- | --- |
| **A** | Docker | Linux / macOS | Git + Docker Engine | `./scripts/install.sh` |
| **B** | Docker | Windows | Git + Docker Desktop | `powershell -ExecutionPolicy Bypass -File scripts/install.ps1` |
| **C** | Không Docker (Node) | Linux / macOS | Git + Node 22.22.3+ / 24.15+ / 25.9+ | `./scripts/install.sh` |
| **D** | Không Docker (Node) | Windows | Git + Node 22.22.3+ / 24.15+ / 25.9+ | `powershell -ExecutionPolicy Bypass -File scripts/install.ps1` |

### A — Linux / macOS + Docker

```bash
# Sau khi clone repo:
./scripts/install.sh
# Hoặc chạy thẳng từ URL:
# curl -fsSL https://raw.githubusercontent.com/SlncTrZ/TheGhost/master/scripts/install.sh | bash
# Ép chế độ Docker (nếu máy có cả Docker lẫn Node):
INSTALL_MODE=docker ./scripts/install.sh
```

Installer: clone TheGhost → đồng bộ `vendor/openclaw` → tạo `deploy/openclaw/docker-compose.yml` → up container `openclaw` (image `ghcr.io/openclaw/openclaw:latest`) → copy config MeiLin → verify `http://127.0.0.1:18789/healthz`.

### B — Windows + Docker (Docker Desktop)

```powershell
# PowerShell, trong thư mục repo đã clone:
powershell -ExecutionPolicy Bypass -File scripts\install.ps1
# Ép chế độ Docker:
$env:INSTALL_MODE = "docker"; powershell -ExecutionPolicy Bypass -File scripts\install.ps1
```

Installer: tương tự phương án A — OpenClaw chạy trong container Docker Desktop, port `18789`.

### C — Linux / macOS + Không Docker (Node)

Không cần Docker. Yêu cầu: **Node** 22.22.3+ / 24.15+ / 25.9+ (nếu chưa có: `sudo apt install nodejs` hoặc nodejs.org).

```bash
./scripts/install.sh
# Ép chế độ không-Docker:
INSTALL_MODE=local ./scripts/install.sh
```

Installer sẽ: cài `openclaw` toàn cục qua npm (`npm install -g openclaw@latest`) → copy config MeiLin vào `~/.openclaw` → `openclaw onboard --install-daemon` (khởi tạo + cài daemon) → verify `http://127.0.0.1:18789/healthz`.

### D — Windows + Không Docker (Node)

Không cần Docker. Yêu cầu: **Node** 22.22.3+ / 24.15+ / 25.9+ (nodejs.org).

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install.ps1
# Ép chế độ không-Docker:
$env:INSTALL_MODE = "local"; powershell -ExecutionPolicy Bypass -File scripts\install.ps1
```

Installer: cài `openclaw` qua npm → copy config MeiLin vào `%USERPROFILE%\.openclaw` → `openclaw onboard --install-daemon` → verify healthz.

### 🔁 Sau khi cài xong (cả 4 phương án)

```bash
openclaw dashboard        # Mở Control UI (cả khi chạy bằng Docker — CLI nối tới gateway)
# Kiểm tra gateway:
openclaw gateway status
# Docker: xem log container nếu cần
docker logs openclaw
```

> **Chuyển đổi phương án:** mọi cấu hình nằm ở `deploy/openclaw/config` (Docker) hoặc `~/.openclaw` (Node) — dùng chung định dạng OpenClaw, không lock-in vào cách chạy.

## ⚡ Power Stack — tự cài bộ "toàn năng" (ADR-032)

Sau khi OpenClaw lên, installer tự chạy `scripts/post-install.sh` (Linux) / `.ps1` (Windows) để cài bộ skills + plugins đã được **nghiệm thu trên .227**:

| Nhóm | Skill | Mô tả |
| --- | --- | --- |
| Research | `@9438190/deep-research` | Deep research 7 bước, báo cáo có trích nguồn |
| Research | `@brennerspear/research-agent` | Research mở, tài liệu markdown sống |
| Research | `@athola/nm-tome-research` | Multi-source: GitHub, HN, Reddit, arXiv |
| Research | `@fortunto2/solo-research` | Market research: đối thủ, SEO, TAM/SAM/SOM |
| Code | `@wpank/code-review` | Code review hệ thống (security/perf/maintainability) |
| Code | `@wpank/testing-patterns` | Unit/integration/E2E testing patterns |
| Code | `@wpank/e2e-testing-patterns` | E2E Playwright/Cypress, CI/CD |
| Memory | `@rithythul/koompi-memory` | Memory phân tầng, daily logging, compaction |

+ **Plugin `memory-wiki`** (bundled): compiled wiki có provenance — bridge mode nối Markdown-first của TheGhost.
+ **Self-learning `auto`** (mặc định OpenClaw): tự biến lần sửa lỗi / công việc thành công thành skill tái dùng qua Skill Workshop.

Thêm/bớt skill: sửa whitelist trong `scripts/post-install.sh` → chạy lại (idempotent). Gỡ: `clawhub uninstall @owner/slug`. Chi tiết quyết định: [ADR-032](framework/ADR-032-power-stack.md).

### 🧰 Tắt / chạy lại Power Stack

```bash
# Chạy lại (an toàn, idempotent):
./scripts/post-install.sh              # local
OPENCLAW_CMD="docker exec openclaw openclaw" ./scripts/post-install.sh   # docker

# Bỏ qua khi cài mới:
SKIP_POWER_STACK=1 ./scripts/install.sh
```
>
## 🎯 Cách dùng — "OpenClaw code đúng ý"

Khi giao OpenClaw (hoặc Pi) code bất kỳ dự án nào:

1. Nạp skill `code-standard` (hoặc đọc `framework/AGENTS.md`).
2. OpenClaw tuân theo bắt buộc: **research trước (bằng chứng có link) → chốt ADR → docstring → nghiệm thu đo được → không secret trong commit**.
3. Kiểm tra `framework/code-checklist.md` trước khi báo xong.

## 🗺️ Trạng thái

| Hạng mục | Trạng thái |
| --- | --- |
| STRATEGY.md (chốt hướng) | ✅ |
| `vendor/openclaw/` (dependency + config MeiLin) | ✅ |
| `framework/` (Code Standard) | ✅ |
| Installer 1 lệnh (Docker + không-Docker, Windows + Linux) | ✅ |
| Nghiệm thu trên máy sạch | 🔲 Chờ |
| Mount framework vào workspace OpenClaw | 🔲 Chờ |

Chi tiết: [PLAN.md](PLAN.md)

---

*TheGhost — Cyber Brain · Cập nhật: 2026-08-11*

# PLAN.md — Kế hoạch TheGhost (Cyber Brain bổ trợ OpenClaw)

Ngày lập: 2026-08-10 · Cập nhật cuối: 2026-08-10 21:20

> Kế hoạch triển khai theo [STRATEGY.md](STRATEGY.md). Mọi quyết định mới → nghiên cứu + ADR trước (framework).

---

## 1. Mục tiêu

Xây dựng **TheGhost = Cyber Brain** bao bọc OpenClaw: bộ quy trình + chuẩn code + tri thức,
đảm bảo mọi code OpenClaw viết ra **đúng ý chúng ta** — research trước, chốt ADR, nghiệm thu đo được.

## 2. Trạng thái hiện tại (đã xong)

| # | Hạng mục | Commit | Ghi chú |
| --- | --- | --- | --- |
| 1 | STRATEGY.md — chốt hướng | `4288a16` | Vision: wrapper + dependency + installer |
| 2 | Tái cấu trúc = wrapper | `5fa4006` | Chỉ giữ STRATEGY + vendor (code lõi trong git history) |
| 3 | Clone OpenClaw → vendor | — | 631M, .git riêng — cập nhật không ảnh hưởng wrapper |
| 4 | Config MeiLin → vendor/openclaw/meilin | — | Backup từ .227 (74M — git-ignored, chứa secret) |
| 5 | `framework/` Code Standard | `a4cd133` | AGENTS.md + templates + checklist + skill code-standard |
| 6 | Installer 1 lệnh | `f1b448d` | install.sh + install.ps1 |
| 7 | README.md + PLAN.md | — | File này |

## 3. Việc còn lại (theo thứ tự ưu tiên)

### P0 — SELF-BOOTSTRAP (theo yêu cầu Anh 22:05)

- [x] `framework/bootstrap.md` — kế hoạch 8 bước tự cấu hình khi đưa link repo.
- [x] `framework/manifest.json` — bản đồ repo (standards/skills/workspace_files/safety).
- [x] Skill `bootstrap` — kích hoạt quá trình tự cấu hình.
- [x] Nghiệm thu SELF-BOOTSTRAP (22:10 10-08): OpenClaw tự đọc manifest → cài 4 skills → merge AGENTS.md → tạo daily/research → báo cáo. Identity + MEMORY giữ nguyên (MD5 khớp backup 4/4).

### P0 — Nghiệm thu & hoàn thiện installer

- [x] **Nghiệm thu installer** trên .227: OpenClaw mới cài sạch + healthy (healthz 200) — 14:36 10-08.
- [x] **Mount `framework/` vào workspace OpenClaw** — OpenClaw tự đọc + tuân theo (kiểm chứng transcript: đọc AGENTS.md trước khi code).
- [x] Test skill `code-standard` — OpenClaw đọc framework + code chuẩn docstring + nghiệm thu đo được (script hello-ghost.py).

### P1 — Phát triển framework

- [x] Memory Standard + Security Standard + Bootstrap (framework 12 files, 4 skills).
- [ ] Ví dụ ADR mẫu hoàn chỉnh (từ 31 ADR TheGhost cũ — trong git history).
- [x] Skills: code-standard · memory-standard · security-standard · bootstrap.

### P1 — Power Stack (ADR-032 — 2026-08-11)

- [x] Research OpenClaw power stack (framework/research-openclaw-power-stack.md).
- [x] ADR-032 — chọn phương án B (script post-install) + whitelist 8 skills đã nghiệm thu .227.
- [x] scripts/post-install.sh + .ps1 — cài whitelist skills + enable memory-wiki + verify (idempotent).
- [x] Installer gọi post-install tự động (SKIP_POWER_STACK=1 để bỏ qua) + README hướng dẫn.
- [ ] Nghiệm thu Power Stack trọn gói trên máy sạch (đợi máy thử).

### P2 — Tích hợp sâu (dài hạn)

- [ ] TheGhost expose MCP server → OpenClaw gọi như "bộ não phụ trợ" (memory chuẩn, tri thức).
- [ ] Workspace knowledge dùng chung (OpenClaw ↔ TheGhost memory chuẩn).
- [ ] Telemetry OTEL cho OpenClaw (env passthrough đã có sẵn).

## 4. Nguyên tắc

- **Research-first:** tính năng mới → nghiên cứu + ADR trước khi code (framework/AGENTS.md).
- **Không lock-in:** ưu tiên định dạng mở (Markdown, chuẩn ngành).
- **Cập nhật OpenClaw an toàn:** chỉ thay `vendor/openclaw` + image — không đụng wrapper.
- **Nghiệm thu đo được:** mỗi hạng mục phải có kết quả thật, không "hy vọng chạy".

---

*TheGhost — Cyber Brain · Cập nhật: 2026-08-11 10:00*

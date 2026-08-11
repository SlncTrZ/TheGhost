# ADR-032: Power Stack — bộ Skill/Plugin/Config giúp OpenClaw "toàn năng"

- **Trạng thái:** Chấp nhận
- **Ngày:** 2026-08-11
- **Người quyết định:** Anh (SlncTrZ) — duyệt hướng 11-08; nghiệm thu .227

## Bối cảnh (Context)

Mục tiêu: người dùng chỉ cần **cài OpenClaw + TheGhost** là có agent toàn năng (research web → code → nhớ → tự học → đa agent → media → automation). OpenClaw v2026.8.1 đã có ~30+ built-in tools + self-learning (mặc định `auto`) + memory builtin (SQLite FTS5+vector+hybrid) — không cần viết tool mới; cần **đóng gói lựa chọn**: config chuẩn + plugin + whitelist skill đã verify. Nguồn: research `framework/research-openclaw-power-stack.md` (2026-08-11).

## Phương án đã cân nhắc

| Phương án | Ưu | Nhược |
| - | - | - |
| A. Config-only (README hướng dẫn tay) | Rẻ, nhẹ | Người dùng tự làm, mỗi người một kiểu |
| B. Script post-install (installer tự cài) | Một lệnh, tự động, pin version được | Script phải theo dõi ClawHub; cần whitelist kỹ |
| C. Plugin TheGhost đóng gói (skills+config bundled) | Nhất quán nhất, pin version | Đắt (SDK plugin, publish, test) — để P2 |

## Quyết định (Decision)

Chọn **phương án B (script post-install)** cho bản đầu, vì:

- **Nghiệm thu đo được trên .227 (11-08):** `openclaw skills install @wpank/code-review` → tải `code-review@1.0.0` từ ClawHub → cài vào `<workspace>/skills/` → `openclaw skills check` xác nhận sẵn sàng. Quy trình verified end-to-end.
- **ClawHub có cơ chế trust:** release malicious/blocked bị chặn; "risky" cần `--acknowledge-clawhub-risk` — cài được kiểm soát (docs/clawhub/cli.md).
- **Whitelist (đã lọc theo downloads + mô tả, xem trên .227):**

| Nhóm | Skill | Slug | Downloads |
| --- | --- | --- | --- |
| Research | Deep Research | `@9438190/deep-research` | 1.491 |
| Research | Research Agent | `@brennerspear/research-agent` | 3.216 |
| Research | Multi-source (GH/HN/Reddit/arXiv) | `@athola/nm-tome-research` | 1.123 |
| Research | Solo Market Research | `@fortunto2/solo-research` | 2.780 |
| Code | Code Review | `@wpank/code-review` | **17.997** ✅ đã nghiệm thu |
| Code | Testing Patterns | `@wpank/testing-patterns` | 5.662 |
| Code | E2E Testing Patterns | `@wpank/e2e-testing-patterns` | **12.120** |
| Memory | Koompi Memory | `@rithythul/koompi-memory` | 1.208 |

- **Config:** memory provider (ưu tiên Ollama local nếu có — `memory.search.provider=local` + `@openclaw/llama-cpp-provider` khi chưa có OpenAI key; builtin SQLite là mặc định đủ dùng), self-learning giữ `auto`, web provider (searxng key-free hoặc brave).
- **Plugin:** `memory-wiki` (bridge mode — compiled wiki nối Markdown-first của TheGhost).
- **Cơ chế:** `scripts/post-install.sh` / `.ps1` chạy sau khi OpenClaw lên (gọi từ installer) — idempotent, cài thiếu thì cài, có rồi thì bỏ qua.

## Hệ quả (Consequences)

- **Tích cực:** Cài OpenClaw + TheGhost = có ngay bộ toàn năng (research/code/memory) + tự học dần; mọi skill đều cài được bằng CLI chuẩn, gỡ dễ (`clawhub uninstall`); không lock-in (skill là markdown trong workspace).
- **Tiêu cực / chấp nhận:** Whitelist là lựa chọn chủ quan lúc chốt (không có thứ hạng chính thức); skill cộng đồng cần theo dõi cập nhật (lệnh `openclaw skills update`); một số skill có thể yêu cầu thêm API key riêng (ghi trong skill).
- **Cách đổi nếu sai:** sửa whitelist trong post-install script + `clawhub uninstall @owner/slug` — chi phí thấp, không đụng OpenClaw core. Nâng cấp lên phương án C (plugin đóng gói) khi bộ skill ổn định.

## Nguồn tham khảo

- Research: `framework/research-openclaw-power-stack.md` (2026-08-11)
- Docs: vendor/openclaw/docs — tools/index.md, tools/skills.md, clawhub/cli.md, plugins/memory-wiki.md, concepts/memory-builtin.md, tools/self-learning.md
- Nghiệm thu thực tế .227 (11-08): `openclaw skills search/install/check`
- ClawHub: clawhub.ai · awesome-openclaw-plugins (github.com/composio-community)

# Nghiên cứu: Bộ Skill / Tool / Plugin mạnh nhất cho OpenClaw — nâng cấp TheGhost thành "hệ thống toàn năng"

Ngày lập: 2026-08-11 — Loại báo cáo: Nghiên cứu + so sánh (không code)

Phạm vi: Xác định bộ **tools / skills / plugins** giúp một cài đặt OpenClaw trở thành "hệ thống toàn năng" (research web → code → memory → tự học → đa agent → media → automation), và cách **TheGhost** đóng gói bộ đó để người dùng chỉ cần cài OpenClaw + TheGhost là có ngay.
Nguồn chính: docs chính thức `vendor/openclaw/docs` (OpenClaw v2026.8.1, clone local) · docs.openclaw.ai · ClawHub (clawhub.ai) · awesome-openclaw-plugins (github.com/composio-community/awesome-openclaw-plugins) · clawoneclick.com (top skills 2026)

---

## Tóm tắt nội dung (Executive Summary)

- **OpenClaw có đúng 3 lớp mở rộng** — Tools (hàm gọi được), Skills (SKILL.md dạy quy trình), Plugins (capability runtime: kênh, provider, hooks, skills đóng gói) — "toàn năng" = cấu hình đúng 3 lớp này ([docs/tools/index.md](vendor/openclaw/docs/tools/index.md)).
- **Đã mạnh sẵn ~30+ built-in tools** — web_search (12+ providers: brave, duckduckgo, exa, firecrawl, gemini, grok, kimi, minimax, ollama, perplexity, searxng, tavily…), browser, exec/code-execution, MCP client, memory search, image/video/audio gen, subagents + swarm + agent-send (đa agent), automation — người dùng mới **không cần cài gì đã có nền tảng** ([docs/tools](vendor/openclaw/docs/tools)).
- **Self-learning (mặc định `auto`) + Skill Workshop là "game changer"** — OpenClaw tự biến lần sửa lỗi / công việc thành công thành skill tái dùng, qua quy trình proposal → scan → apply có kiểm soát. Đây chính là cơ chế "tự thông minh dần" mà TheGhost nên tận dụng ([docs/tools/self-learning.md](vendor/openclaw/docs/tools/self-learning.md)).
- **Memory mặc định (SQLite builtin: FTS5 + vector + hybrid + MMR) đủ mạnh** — không cần service ngoài; `memory-wiki` (plugin bundled) thêm lớp wiki compiled có provenance — khớp triết lý Markdown-first của TheGhost ([docs/concepts/memory-builtin.md](vendor/openclaw/docs/concepts/memory-builtin.md), [docs/plugins/memory-wiki.md](vendor/openclaw/docs/plugins/memory-wiki.md)).
- **Cộng đồng rất lớn:** ClawHub 13.700+ skills (một số nguồn nói 60K+ skills / 39M downloads), plugins như `claw-format` (format 20+ ngôn ngữ), `testgen-pro`, `doc-writer` — nhưng **không có thứ hạng chính thức duy nhất**, dữ liệu cần chọn lọc (web: clawoneclick.com, awesome-openclaw-plugins).

---

## 1. Ba lớp mở rộng của OpenClaw

### 1.1 Tools — "hàm" agent gọi được

Tool là typed function: `exec`, `browser`, `web_search`, `message`, `image_generate`… Model chỉ thấy tool vượt qua profile, allow/deny policy, provider restriction, sandbox, channel permission, plugin availability ([docs/tools/index.md](vendor/openclaw/docs/tools/index.md)).

### 1.2 Skills — "chỉ dẫn" nạp vào prompt

Skill là thư mục chứa `SKILL.md` (YAML frontmatter + body markdown) dạy agent **khi nào + cách nào** dùng tool. Load theo precedence (cao → thấp): workspace → project `.agents/skills` → personal `~/.agents/skills` → managed state-dir → bundled → extra dirs ([docs/tools/skills.md](vendor/openclaw/docs/tools/skills.md)).

→ **Hệ quả cho TheGhost:** cài skills vào `<workspace>/skills` (ưu tiên cao nhất) hoặc state-dir; allowlist qua `agents.defaults.skills` / `agents.entries.*.skills`.

### 1.3 Plugins — "capability" runtime

Plugin thêm channel, provider, hooks, tools, skills đóng gói. Cài: `openclaw plugins install clawhub:<pkg>` (bắt buộc prefix `clawhub:` để ưu tiên ClawHub hơn npm/git) ([docs/plugins/community.md](vendor/openclaw/docs/plugins/community.md), [docs/clawhub/cli.md](vendor/openclaw/docs/clawhub/cli.md)).

---

## 2. Built-in tools — kho "toàn năng" sẵn có (không cần cài)

Nhóm | Tools (docs) | Ghi chú
--- | --- | ---
**Web research** | `web_search` (provider configurable), `web_fetch`, `x_search`, `browser` (Playwright Chromium: login, JS-heavy), `firecrawl` | web_search cache 15 phút; browser cho site cần login ([tools/web.md], [tools/browser.md], [tools/firecrawl.md])
**Code / hệ thống** | `exec`, `code-execution` (sandbox), `apply-patch`, `diffs`, `llm-task`, `code-mode` | exec approvals + sandbox multi-agent ([tools/exec.md], [tools/code-execution.md])
**Search providers** | brave, duckduckgo, exa, firecrawl, gemini, grok, kimi, minimax, ollama, perplexity, searxng, tavily, parallel | nhiều provider key-free (searxng, ollama) ([tools/])
**Memory** | `memory_search` (keyword FTS5 + vector + hybrid, MMR), `wiki_search`/`wiki_get` (memory-wiki) | builtin SQLite, CJK trigram ([concepts/memory-builtin.md])
**MCP** | MCP client — `mcp.servers` config, `openclaw mcp doctor`, hỗ trợ Streamable HTTP / SSE / Stdio; ngược lại `openclaw mcp serve` | connect MCP server ngoài → tools qua cùng tool-policy ([tools/mcp.md])
**Đa agent** | `subagents`, `swarm` (orchestrate concurrent), `agent-send`, ACP agents, `goal` | ([tools/subagents.md], [tools/swarm.md])
**Media** | `image_generate` (10+ provider), video gen, music gen, TTS | capability contract riêng ([plugins/adding-capabilities.md])
**Tự động** | Automation (cron/trigger), `ask-user`, `reactions`, `show-widget` | ([automation])
**Tiện ích** | `pdf`, `screen`, `steer`, `thinking`, `apply-patch`, `btw`, `tokenjuice`, `trajectory`, `lobster` | ([tools/])

→ **Kết luận 1:** OpenClaw mới cài (bundle) đã là "cỗ máy đa năng"; việc của TheGhost là **chọn + bật + dạy** đúng, không phải tự viết tool.

---

## 3. Skills — cơ chế, ClawHub, và top skills cộng đồng

### 3.1 Cài đặt

```bash
openclaw skills search "calendar"
openclaw skills install @owner/<slug>            # vào <workspace>/skills
openclaw skills install @owner/<slug> --global   # vào managed state-dir
openclaw skills update --all --acknowledge-clawhub-risk
openclaw skills verify @owner/<slug> --card
```

Trust: ClawHub scan trước khi cài; bản "risky" cần `--acknowledge-clawhub-risk`; bản malicious/blocked bị từ chối ([docs/clawhub/cli.md](vendor/openclaw/docs/clawhub/cli.md)).

### 3.2 Thị trường (web research)

- ClawHub: **13.700+ skills** cộng đồng (một số nguồn: 60K+ skills, 39M+ downloads, 56K+ certified — con số chênh lệch giữa các nguồn, xem là chỉ dẫn, không phải chuẩn).
- Top skills theo downloads (clawoneclick.com, 2026): **Capability Evolver** (35.581 downloads), **Wacli**, **ByteRover** — danh sách top chênh lệch giữa nguồn, cần tự verify khi cài.
- Danh mục được xếp hạng: AI/ML, development, productivity…
- Có "awesome list" plugins: github.com/composio-community/awesome-openclaw-plugins.

→ **Kết luận 2:** Không có "top 10 chính thức" — khuyến nghị **tự chọn theo nhu cầu + verify** (không cài mù), và TheGhost nên đóng gói **bộ skill do chính ta viết/chọn** (đã có 4: code-standard, memory-standard, security-standard, bootstrap).

---

## 4. Plugins — memory & cộng đồng

| Plugin | Chức năng | Nguồn |
| --- | --- | --- |
| `memory-wiki` (bundled) | Compiled wiki: page có provenance, claims, dashboards; 3 mode vault: `isolated` / `bridge` / `unsafe-local` | [plugins/memory-wiki.md](vendor/openclaw/docs/plugins/memory-wiki.md) |
| `memory-lancedb` | Vector memory thay thế builtin | [plugins/memory-lancedb.md](vendor/openclaw/docs/plugins/memory-lancedb.md) |
| `@openclaw/llama-cpp-provider` | Embedding GGUF local (không cần API key) | [concepts/memory-builtin.md](vendor/openclaw/docs/concepts/memory-builtin.md) |
| Community: `claw-format` (format 20+ ngôn ngữ), `testgen-pro`, `doc-writer`, MCP extensions… | Cài `openclaw plugins install clawhub:<pkg>` | web: awesome-openclaw-plugins |

→ **Kết luận 3:** `memory-wiki` + builtin memory = đủ cho Cyber Brain; dùng **bridge mode** để nối Markdown-first của TheGhost (workspace memory) với compiled wiki.

---

## 5. Self-learning — cơ chế "tự thông minh dần" ⭐

- **Mặc định `auto`:** OpenClaw bắt tín hiệu học mạnh → Skill Workshop (proposal → scanner → apply) không cần duyệt; `propose` = duyệt từng cái; `off` = tắt ([tools/self-learning.md](vendor/openclaw/docs/tools/self-learning.md)).
- **Immediate repair:** agent sửa trực tiếp skill sai/incomplete trong cùng turn (có receipt ngăn sửa nhầm skill không dùng).
- **Experience review:** sau turn dùng ≥10 model iterations, nền yên 30s → review nền cô lập trích quy trình tái dùng (tiết ≥2 round-trip).
- **Điều kiện an toàn:** chỉ review foreground turn thành công (không phải provider/prompt error); skill qua scanner + hash binding + rollback.

→ **Kết luận 4:** Đây là "hệ thống toàn năng" theo nghĩa **tự học** — TheGhost chỉ cần **bật + thiết lập workshop chuẩn** (đúng chuẩn code-standard của mình), OpenClaw sẽ tự dày skill lên theo thời gian.

---

## 6. So sánh phương án triển khai cho TheGhost

| Tiêu chí | A. Config-only (README hướng dẫn tay) | B. Script post-install (installer tự cài) | C. Plugin TheGhost đóng gói (skills+config bundled) |
| --- | --- | --- | --- |
| Độ tự động | ❌ Người dùng tự làm | ✅ Một lệnh | ✅ Một lệnh (nhất quán nhất) |
| Bảo trì | ✅ Nhẹ | ⚠️ Script phải theo dõi ClawHub | ⚠️ Phải đóng gói + publish |
| Chi phí làm | ✅ Rẻ nhất | ✅ Rẻ | ❌ Đắt (SDK plugin, publish, test) |
| Kiểm soát phiên bản | ❌ Mỗi người một kiểu | ⚠️ Pin version được | ✅ Pin version được |
| Rủi ro cài mù skill | — | ⚠️ Cần whitelist kỹ | ⚠️ Cần whitelist kỹ |

## 7. Khuyến nghị

- **Chọn phương án B (script post-install) cho bản đầu** — thêm bước vào installer: sau khi OpenClaw lên, chạy `openclaw skills install` bộ whitelist (đã verify) + `openclaw plugins enable memory-wiki` + set self-learning `auto` + cấu hình web provider. Nhanh, tự động, có thể pin version. **Phương án C (plugin TheGhost đóng gói) là tầm nhìn P2** — khi bộ skill ổn định.
- **Bộ "Power Stack" đề xuất (bản đầu):**
  1. **Config:** `memory.search.provider` (ưu tiên Ollama local nếu có), self-learning `auto`, web provider (searxng key-free hoặc brave).
  2. **Plugins:** `memory-wiki` (bridge mode) + `@openclaw/llama-cpp-provider` (embedding local, không API key) — nếu chưa có OpenAI key.
  3. **Skills của TheGhost:** giữ 4 skill hiện có (code-standard, memory-standard, security-standard, bootstrap) → bổ sung **skill "power-user"** đóng gói quy trình dùng web research + memory + self-learning.
  4. **Whitelist ClawHub** (sau khi verify từng cái): nhóm research (ví dụ crawler/research), nhóm code (format/test), nhóm automation — **chọn lọc, không cài mù**, ghi nguồn verify vào đây khi chốt.
- **Điều kiện tiên quyết để chốt:** thực nghiệm verify từng skill trên .227 (sân chơi) trước khi đưa vào installer — đúng nguyên tắc "nghiệm thu đo được".
- → **Chờ Anh duyệt phương án + chọn bộ skills cụ thể → mới tạo ADR chính thức + code.**

## 8. Kết luận

OpenClaw đã có nền tảng tools cực mạnh + self-learning tự học; TheGhost không cần viết lại gì — chỉ cần **đóng gói lựa chọn thông minh**: config chuẩn + plugin memory-wiki + whitelist skills đã verify + bật tự học. Kết quả: cài OpenClaw + TheGhost = agent toàn năng (research → code → nhớ → tự học → đa agent → media → automation). Tái kiểm tra khi OpenClaw ra version mới (repo vendor/openclaw có thể `git pull` để rà lại docs).

---

*Ngày cập nhật cuối: 2026-08-11 — nguồn chính: vendor/openclaw/docs (v2026.8.1) + web (ClawHub, awesome-openclaw-plugins)*

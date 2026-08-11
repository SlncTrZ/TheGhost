# STRATEGY — TheGhost: Cyber Brain bổ trợ OpenClaw

Ngày lập: 2026-08-10 · Loại: Chiến lược kiến trúc (Strategy) · Trạng thái: ✅ Chốt hướng

## GHOST (Ghost in the Shell)

Ý thức, Ký ức, Cảm xúc, Bản ngã — Cyber Brain cho hệ thống: kết nối mạng lưới thông tin toàn cầu, phục vụ mọi mục đích.

## Vai trò của TheGhost

**TheGhost không thay thế OpenClaw — TheGhost BAO BỌC OpenClaw** để OpenClaw code đúng ý chúng ta.

---

## 1. Bối cảnh & Vấn đề

- **OpenClaw** là nền tảng agent mạnh (Control UI, multi-platform, skills marketplace) nhưng khi **code thì không đúng ý chúng ta**: không research, không chốt quyết định, không nghiệm thu, không ghi chép, thiếu công cụ cần thiết.
- **TheGhost** hôm nay đã chứng minh quy trình đúng đắn: 1 ngày = **31 ADR + toàn bộ Phase 0–5e code + nghiệm thu đo được** (Telegram/Zalo gateway thật, memory 3 lớp, scheduler, dreaming, plugins, sandbox, telemetry...).
- Giải pháp: **không chọn 1 trong 2** — để mỗi bên làm thế mạnh của nó:
  - **OpenClaw** = nền tảng chạy (giao diện, ecosystem, multi-platform).
  - **TheGhost** = **sub-framework bao bọc** — bộ não quy trình + chuẩn code + tri thức, đảm bảo mọi code OpenClaw viết ra đều đúng ý chúng ta.

## 2. TheGhost tốt hơn OpenClaw ở đâu (đúc kết từ 2026-08-10)

| # | Điểm mạnh TheGhost | OpenClaw |
| --- | --- | --- |
| 1 | **Quy trình Research → ADR → Code** (mọi quyết định có lý do + nguồn) | Code vội, không research, không chốt quyết định |
| 2 | **Tài liệu hóa đầy đủ** (research / decisions / roadmap / progress) | Code xong không ghi chép |
| 3 | **Nghiệm thu đo được** mỗi phase (test thật, không "hy vọng chạy") | Không có khái niệm nghiệm thu |
| 4 | **Kiến trúc tối giản tự chủ** — 1 backend, mọi thứ trong tầm tay | Kết hợp phải nối hàng tá service |
| 5 | **Secret an toàn** (`.env` git-ignored) | Token/API key **plaintext** trong `openclaw.json` |
| 6 | **Backup config tự động** (`.working_<ts>`, giữ 5 bản) | Backup thủ công |
| 7 | **Policy deny-by-default + Sandbox** (an toàn theo lớp) | Tool policy lỏng hơn |
| 8 | **Docstring chuẩn mọi file** + code style đồng nhất | Không bắt buộc |
| 9 | **Tốc độ phát triển** — 31 ADR + 5 phase code/nghiệm thu trong 1 ngày | — |

## 3. Kiến trúc: TheGhost = Wrapper bao bọc OpenClaw

```text
theghost/                                  ← REPO RIÊNG CỦA CHÚNG TA (SlncTrZ/TheGhost)
├── STRATEGY.md                            ← File này
├── AGENTS.md                              ← Chuẩn code quy trình (research→ADR→code→nghiệm thu)
├── framework/                             ← Sub-framework "Code Standard" cho OpenClaw/Pi nạp
│   ├── AGENTS.md                          ← Quy trình code chuẩn
│   ├── research-template.md               ← Form báo cáo nghiên cứu (đầy đủ, không rút gọn)
│   ├── ADR-template.md                    ← Form chốt quyết định
│   ├── code-checklist.md                  ← Checklist hoàn tất (typecheck/docstring/security/nghiệm thu)
│   └── skills/code-standard/SKILL.md      ← Skill nạp được bởi OpenClaw / Pi
├── vendor/openclaw/                       ← ⭐ OpenClaw như DEPENDENCY (clone/vendor bên trong)
│   └── (toàn bộ source OpenClaw — CẬP NHẬT KHÔNG ẢNH HƯỞNG wrapper)
├── packages/agent-server/                 ← Lõi TheGhost (Agent Core + REST + MCP + gateways)
├── packages/ui/                           ← Control UI TheGhost (form OpenClaw)
├── docs/                                  ← Nghiên cứu + ADR + roadmap + progress
└── scripts/
    └── install.sh / install.ps1           ← ⭐ 1 LỆNH CÀI: openclaw + theghost wrapper
```text

### Nguyên tắc phụ thuộc (dependency)

- `vendor/openclaw/` là **bản clone độc lập** (không submodule — tránh phức tạp git; hoặc submodule nếu muốn theo dõi version chuẩn).
- **Cập nhật OpenClaw**: thay nội dung `vendor/openclaw/` — **không đụng gì tới wrapper TheGhost** (AGENTS.md, framework/, scripts/).
- TheGhost wrapper chỉ **đọc/triển khai** dựa trên OpenClaw — không sửa source OpenClaw trực tiếp (nếu cần patch → `vendor/openclaw/patches/` riêng).

## 4. Cơ chế "OpenClaw code đúng ý chúng ta"

Khi Anh bảo OpenClaw (hoặc Pi) code bất kỳ dự án nào:

1. Nạp `framework/skills/code-standard/SKILL.md` (hoặc đọc `framework/AGENTS.md`).
2. Tuân theo quy trình bắt buộc:
   - **Research-first**: nhiệm vụ mới → nghiên cứu trước (bằng chứng có link, KHÔNG đoán).
   - **Chốt ADR/decision** trước khi code.
   - **Docstring chuẩn** mọi file mới/sửa.
   - **Nghiệm thu đo được** cuối (test thật, không "hy vọng chạy").
3. Kiểm tra `framework/code-checklist.md` trước khi xong (typecheck pass, security, backup, git sạch).

## 5. Installer — 1 lệnh cài cả hệ thống

**Mục tiêu:** Anh hoặc người khác chạy **1 lệnh duy nhất** → có đủ OpenClaw + TheGhost bao bọc:

```bash
# Linux/macOS
curl -fsSL <URL> | bash          # hoặc: ./scripts/install.sh
# Windows
powershell -File scripts/install.ps1
```

**Những gì installer làm:**

1. Clone `SlncTrZ/TheGhost` (nếu chưa có).
2. Clone/đồng bộ `openclaw/openclaw` → `vendor/openclaw/` (version pin — cập nhật không vỡ wrapper).
3. Cài dependencies (pnpm install TheGhost + openclaw).
4. Tạo `.env` từ template (tokens: Telegram/Zalo/9router...).
5. Build UI (TheGhost control-ui).
6. Cấu hình + khởi động: OpenClaw gateway + TheGhost agent-server (REST/MCP/gateways).
7. Verify: health check cả 2 hệ thống.

## 6. Lộ trình

- [x] Chốt hướng (STRATEGY.md).
- [x] Clone OpenClaw → `vendor/openclaw/` (558M, .git riêng) + config MeiLin tại `vendor/openclaw/meilin/`.
- [ ] Hoàn thiện `framework/` (AGENTS.md, templates, checklist, skill).
- [x] Installer `scripts/install.sh` + `install.ps1` (1 lệnh cài OpenClaw + wrapper — clone/sync vendor + deploy compose + verify).
- [ ] Nghiệm thu: máy sạch → 1 lệnh → cả OpenClaw + TheGhost chạy + OpenClaw code theo chuẩn.

## 7. Kết luận

TheGhost là **Cyber Brain** (ý thức/ký ức/cảm xúc/bản ngã) — không phải để thay OpenClaw, mà để **bao bọc và điều khiển** nó: OpenClaw chạy nền tảng, TheGhost đảm bảo mọi code ra đời đúng ý chúng ta (research → ADR → code → nghiệm thu). Repo này là **tài sản riêng của chúng ta**, có thể clone openclaw vào trong như dependency — cập nhật OpenClaw không ảnh hưởng, cài đặt chỉ cần **1 lệnh**.

---

*Cập nhật lần cuối: 2026-08-10 22:10*

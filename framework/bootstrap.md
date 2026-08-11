# Bootstrap — Kế hoạch tự cấu hình OpenClaw từ repo TheGhost

> **Mục tiêu:** Sau khi cài OpenClaw (bản sạch), chỉ cần đưa link repo TheGhost
> → OpenClaw **tự hiểu toàn bộ** (vision + chuẩn + skills + memory) và **tự cấu hình**
> các file cần thiết (AGENTS.md, skills, tools, memory...) — không cần thao tác tay.

## 1. Kích hoạt

Nhắn cho OpenClaw (agent mới cài):

> "Đọc và áp dụng repo này cho workspace của em: `https://github.com/SlncTrZ/TheGhost`.
> Thực hiện theo `framework/bootstrap.md` + `framework/manifest.json` trong repo.
> Khi xong, báo cáo danh sách những gì em đã tự cấu hình."

Hoặc nếu workspace đã mount framework → chỉ cần:
> "Chạy bootstrap theo `framework/bootstrap.md`."

## 2. Quy trình tự cấu hình (8 bước — OpenClaw tự làm)

### Bước 1 — Hiểu repo

- Clone (hoặc đọc) repo TheGhost → đọc `STRATEGY.md` (vision) + `README.md` (cấu trúc) + `framework/manifest.json` (bản đồ).
- ✅ Kiểm tra: hiểu TheGhost = wrapper bao bọc, chuẩn code/memory/security.

### Bước 2 — Đảm bảo framework trong workspace

- Nếu chưa có `workspace/framework/` → copy/symlink từ repo (hoặc báo cần mount).
- ✅ Kiểm tra: `workspace/framework/AGENTS.md` đọc được.

### Bước 3 — Cập nhật `workspace/AGENTS.md`

- Nếu `workspace/AGENTS.md` chưa trỏ tới chuẩn TheGhost → sửa/merge: bổ sung quy trình research→ADR→code→nghiệm thu + trỏ `framework/AGENTS.md`.
- ✅ Kiểm tra: AGENTS.md chứa tham chiếu framework.

### Bước 4 — Cài skills (registry OpenClaw)

- Copy `framework/skills/*` → `~/.openclaw/skills/` (hoặc nơi OpenClaw nạp skill): `code-standard`, `memory-standard`, `security-standard`, `bootstrap`.
- ✅ Kiểm tra: `openclaw skills list` hiện đủ 4 skill.

### Bước 5 — Thiết lập cấu trúc memory (memory-standard)

- Đảm bảo tồn tại: `MEMORY.md`, `daily/`, `research/`, `SOUL.md`, `USER.md`, `IDENTITY.md`.
- Nếu thiếu → tạo từ template (framework) — không ghi nội dung giả.
- ✅ Kiểm tra: cấu trúc khớp `framework/memory-standard.md`.

### Bước 6 — Cấu hình config (openclaw.json)

- Đảm bảo: skills được bật, workspace path đúng, TZ=Asia/Ho_Chi_Minh, mô hình/channel theo nhu cầu (không tự thêm secret).
- ✅ Kiểm tra: config hợp lệ (openclaw doctor).

### Bước 7 — Nghiệm thu

- Chạy thử: đọc 1 skill + tra memory + kiểm tra AGENTS.md đã áp dụng.
- ✅ Kiểm tra: các chuẩn hoạt động (giống nghiệm thu code-standard đã chứng minh).

### Bước 8 — Báo cáo

- Liệt kê: những file đã sửa/tạo, skills đã cài, cấu trúc đã thiết lập — để con người kiểm chứng.

## 3. Manifest (`framework/manifest.json`)

Bản đồ repo cho agent đọc nhanh:

- `vision` → STRATEGY.md
- `standards` → AGENTS.md / memory-standard / security-standard
- `skills` → 4 skills cần cài
- `workspace_files` → file nào đặt đâu
- `bootstrap_steps` → 8 bước trên

## 4. Nguyên tắc an toàn khi bootstrap

- KHÔNG tự thêm secret/token vào config (chỉ tạo `.env` rỗng + hướng dẫn).
- KHÔNG xóa dữ liệu hiện có trong workspace (merge, không ghi đè).
- KHÔNG sửa source OpenClaw (vendor/) — chỉ cấu hình workspace/config.
- Mọi thay đổi phải báo cáo lại (con người kiểm chứng).

## 5. Nghiệm thu kế hoạch

- [ ] OpenClaw mới cài → đưa link → tự đọc STRATEGY + manifest.
- [ ] Tự cập nhật AGENTS.md + cài 4 skills + thiết lập memory.
- [ ] Báo cáo danh sách đã làm (kiểm chứng được).
- [ ] Không tự thêm secret / không phá dữ liệu cũ.

---

*Framework v1.0 — TheGhost (Cyber Brain) · Cập nhật: 2026-08-10 22:05*

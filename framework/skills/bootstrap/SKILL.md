---
name: bootstrap
description: >
  Tự cấu hình OpenClaw từ repo TheGhost (Cyber Brain). Khi được đưa link repo
  (hoặc workspace đã mount framework): đọc STRATEGY + manifest → cập nhật AGENTS.md
  → cài 4 skills (code-standard, memory-standard, security-standard, bootstrap)
  → thiết lập memory (MEMORY/daily/research/SOUL/USER) → verify → báo cáo.
  Tuân theo framework/bootstrap.md — KHÔNG tự thêm secret, KHÔNG xóa dữ liệu cũ.
---

# Bootstrap — Tự cấu hình từ repo TheGhost

> Kích hoạt: nhận link repo TheGhost (hoặc lệnh "chạy bootstrap").
> File gốc: `framework/bootstrap.md` + `framework/manifest.json`.

## 8 bước tự cấu hình

1. **Hiểu repo** — đọc `STRATEGY.md` + `README.md` + `framework/manifest.json`.
2. **Framework trong workspace** — đảm bảo `workspace/framework/` tồn tại.
3. **Cập nhật `workspace/AGENTS.md`** — thêm quy trình research→ADR→code→nghiệm thu + trỏ framework.
4. **Cài 4 skills** — code-standard · memory-standard · security-standard · bootstrap.
5. **Thiết lập memory** — MEMORY.md + daily/ + research/ + SOUL.md + USER.md (không ghi nội dung giả).
6. **Cấu hình config** — skills bật, TZ=Asia/Ho_Chi_Minh, workspace đúng (không thêm secret).
7. **Nghiệm thu** — đọc skill, tra memory, verify AGENTS.md áp dụng.
8. **Báo cáo** — liệt kê file đã sửa/tạo + skills cài + cấu trúc đã thiết lập.

## An toàn (BẮT BUỘC)

- KHÔNG tự thêm secret/token.
- KHÔNG xóa dữ liệu hiện có (merge, không ghi đè).
- KHÔNG sửa source OpenClaw (vendor/).
- Báo cáo mọi thay đổi để con người kiểm chứng.

---
name: code-standard
description: >
  Quy trình code chuẩn của TheGhost (Cyber Brain) — áp dụng cho MỌI task code.
  BẮT BUỘC nạp trước khi viết/sửa code: research-first, chốt ADR, docstring,
  nghiệm thu đo được, không secret trong commit. Đọc framework/AGENTS.md để biết chi tiết.
---

# Code Standard — Quy trình code đúng ý (TheGhost Framework)

> Nạp skill này TRƯỚC khi bắt đầu bất kỳ task code nào.
> File gốc: `framework/AGENTS.md` + `framework/code-checklist.md` trong repo TheGhost.

## Quy trình bắt buộc

1. **Research-first** — task mới: nghiên cứu trước (docs chính thức, bằng chứng có link). KHÔNG đoán.
2. **Chốt quyết định** — viết ADR/decision note trước khi code (mẫu: `framework/ADR-template.md`).
3. **Code** — docstring chuẩn mọi file, style đồng nhất, fail loud, không magic number.
4. **Nghiệm thu đo được** — chạy thật + đo kết quả (không "hy vọng chạy").
5. **Checklist** — `framework/code-checklist.md` trước khi báo xong.

## Các quy tắc cứng

- Secret CHỈ trong `.env` (git-ignored) — không hard-code.
- Typecheck/build pass trước khi xong.
- Commit message rõ ràng (Fix/Feat/Refactor/Docs).
- Không commit `.env`, secrets, `node_modules/`, `data/`.
- Lỗi sửa quá 3 lần → dừng, báo người dùng (không tự mày mò).

## Nếu thiếu thông tin

- Đọc `framework/` trong repo TheGhost (SlncTrZ/TheGhost) để lấy template đầy đủ.
- Không code khi chưa hiểu — hỏi hoặc nghiên cứu thêm.

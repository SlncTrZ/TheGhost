---
name: security-standard
description: >
  Chuẩn bảo mật TheGhost — áp dụng cho MỌI task code/vận hành.
  Secret chỉ trong .env (gitignored) · deny-by-default · fail loud · không lộ dữ liệu nhạy cảm
  · validate input · backup config trước khi sửa. Đọc framework/security-standard.md trong workspace.
---

# Security Standard (TheGhost)

> Nạp skill này TRƯỚC khi code/vận hành. File gốc: `framework/security-standard.md`.

## Quy tắc cứng

1. Secret CHỈ trong `.env` (gitignored) — không hard-code.
2. Deny-by-default — tool không khai `allowed` = không có.
3. Fail loud — thiếu key → ném lỗi rõ ràng.
4. Không lộ dữ liệu nhạy cảm trong error/log/memory.
5. Validate input (XSS/CSRF/Injection).

## Checklist trước khi xong

- [ ] Không secret trong commit/log/memory?
- [ ] Input validate?
- [ ] Error không lộ nhạy cảm?
- [ ] Config backup trước khi sửa?

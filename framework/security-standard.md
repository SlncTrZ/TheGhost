# Security Standard — Chuẩn bảo mật TheGhost

> Chuẩn bảo mật cho MỌI agent/developer (OpenClaw / Pi / TheGhost).
> Nguyên tắc: deny-by-default · secret chỉ trong `.env` · fail loud · không lộ dữ liệu nhạy cảm.

## 1. Nguyên tắc cứng (BẮT BUỘC)

1. **Secret CHỈ trong `.env`** (gitignored, `chmod 600`) — KHÔNG hard-code key/token trong code/config.
2. **Deny-by-default:** tool không khai trong `allowed` = không có; `denied` luôn thắng.
3. **Fail loud:** thiếu API key → ném lỗi rõ ràng (vd `Thiếu OPENAI_API_KEY cho provider 'openai'`), không im lặng trả rỗng.
4. **Không lộ dữ liệu nhạy cảm** trong error message gửi client.
5. **Validate input:** XSS / CSRF / Injection — mọi input từ ngoài phải kiểm tra.

## 2. Quy tắc khi code

- API keys chỉ trong `.env` (không commit — kiểm tra `.gitignore`).
- Không đưa token/password vào log, error message, memory (workspace) — secret không ghi vào ký ức.
- Policy deny-by-default khi có tool.
- MCP/gateway bind localhost + origin/host validation (chống DNS rebinding).

## 3. Quy tắc vận hành

- Backup config trước khi sửa (`.working_<ts>` — giữ 5 bản).
- Không expose service ra internet nếu chưa có auth (bearer token).
- Token lộ trong chat/log → reset ngay.

## 4. Checklist bảo mật

- [ ] Không secret trong commit / log / memory?
- [ ] Input được validate?
- [ ] Error message không lộ dữ liệu nhạy cảm?
- [ ] Policy deny-by-default cho tool?
- [ ] Config có backup trước khi sửa?

---

*Framework v1.0 — TheGhost (Cyber Brain) · Cập nhật: 2026-08-10 22:00*

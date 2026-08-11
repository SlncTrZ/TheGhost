# Code Checklist — Trước khi xong bất kỳ task code nào

> Chạy qua checklist này TRƯỚC khi báo "xong". Nếu 1 mục không áp dụng → ghi rõ "N/A" + lý do.

## 1. Quy trình

- [ ] Đã nghiên cứu trước khi code (bằng chứng có link — không đoán)?
- [ ] Quyết định đã được chốt (ADR / decision note)?
- [ ] Roadmap / progress đã cập nhật?

## 2. Chất lượng code

- [ ] Typecheck / build **pass** (không lỗi)?
- [ ] Docstring đủ cho mọi file mới/sửa (chuẩn framework)?
- [ ] Không magic number, không nuốt lỗi, fail loud?
- [ ] Code style đồng nhất codebase (ngôn ngữ, naming)?

## 3. Bảo mật

- [ ] Không hard-code secret (chỉ `.env` git-ignored)?
- [ ] Không đưa dữ liệu nhạy cảm vào error message?
- [ ] Validate input (XSS/CSRF/Injection)?

## 4. Nghiệm thu đo được

- [ ] Đã chạy thật + đo kết quả (không "hy vọng chạy")?
- [ ] Kết quả nghiệm thu ghi lại (bằng chứng cụ thể: output, log, số liệu)?

## 5. Git

- [ ] Không commit `.env` / secrets / `node_modules` / `data/`?
- [ ] Git status sạch (sau khi commit + push)?
- [ ] Commit message rõ ràng (Fix/Feat/Refactor/Docs)?

## 6. Post-action

- [ ] Đã log thay đổi vào Knowledge Base (file, diff, lý do)?

---

*Framework v1.0 — TheGhost (Cyber Brain) · Cập nhật: 2026-08-10*

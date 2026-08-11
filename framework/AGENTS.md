# AGENTS.md — Quy trình Code Chuẩn (TheGhost Framework)

> Sub-framework "Code Standard" — áp dụng cho **mọi dự án** mà OpenClaw / Pi / AI agent được giao code.
> Mục tiêu: **code đúng ý chúng ta** — research trước, chốt quyết định, nghiệm thu đo được.
> Nạp qua: skill `code-standard` hoặc đọc trực tiếp file này trước khi bắt đầu.

## 1. NGUYÊN TẮC NỀN TẢNG (BẮT BUỘC)

1. **Research-first:** Nhiệm vụ/dự án mới → **nghiên cứu trước, code sau**. Không nhảy cóc, không đoán.
2. **Bằng chứng có link:** Mọi kết luận phải có nguồn (docs chính thức / benchmark / thực nghiệm). KHÔNG đoán.
3. **Chốt quyết định trước khi code:** chưa đủ hiểu → viết nghiên cứu + chốt ADR/decision note, rồi mới code.
4. **Nghiệm thu đo được:** kết quả cuối phải đo được (test thật, không "hy vọng chạy").
5. **Tầm nhìn dài:** tự hỏi "10 năm nữa cái này có cản trở mình không?" (lock-in, bảo trì, chi phí).

## 2. QUY TRÌNH BẮT BUỘC (mọi tính năng mới)

```text
Research → Chốt ADR/decision → Cập nhật roadmap/progress → Code → Nghiệm thu đo được → Log KB
```text

| Bước | Việc phải làm | Output |
| --- | --- | --- |
| 1. Research | Đọc tài liệu chính thức, so sánh phương án, ghi nguồn/link | `research/<chủ đề>.md` (theo `research-template.md`) |
| 2. ADR | Chốt quyết định + lý do + hệ quả + cách đổi nếu sai | `decisions/ADR-00X-<tên>.md` (theo `ADR-template.md`) |
| 3. Roadmap | Đánh dấu phase/việc tương ứng | `roadmap.md` + `progress.md` |
| 4. Code | Theo style chuẩn (mục 3), test đi kèm | Code + test |
| 5. Nghiệm thu | Chạy thật, đo kết quả, ghi bằng chứng | Nghiệm thu trong progress |
| 6. Log | Post-action ghi vào KB (file, diff, lý do) | Knowledge base |

> Không nhảy cóc. Phase nghiên cứu là bắt buộc trước mọi code.

## 3. CHUẨN CODE (BẮT BUỘC)

- **Ngôn ngữ:** Tiếng Việt chuyên ngành (biến/comment/error message đồng nhất codebase).
- **Docstring bắt buộc** mọi file mới/sửa (đầu file):

  ```

  /** Module Name — one-line description.

* ADR: ADR-00X | Updated: YYYY-MM-DD HH:MM
   */

  ```

- **Chất lượng:** immutability, centralized error handling (throw rõ ràng, không nuốt lỗi), không magic number, type an toàn (zod cho config).
- **Fail loud:** lỗi phải hiện rõ (vd thiếu API key → ném lỗi cụ thể), không im lặng trả text rỗng.
- **Suy luận** trong `<reasoning>` — output là Code/Tool Call, ngắn gọn.

## 4. BẢO MẬT (BẮT BUỘC)

- API keys/secret **chỉ trong `.env`** (gitignored, `chmod 600`); KHÔNG hard-code key trong code/config.
- Không đưa dữ liệu nhạy cảm vào error message gửi client.
- Validate input (XSS/CSRF/Injection). Policy deny-by-default khi có tool.

## 5. GIT PROTOCOL

- **PRE-CHANGE:** `git status` (sạch) → `git pull` → verify repo đúng.
- **POST-CHANGE:** `git add .` → `git commit -m "Fix/Feat/Refactor/Docs: msg ngắn"` → `git push`.
- **RULES:** Không commit `.env`, secrets, `node_modules/`, `data/`. Identity chuẩn. Valid `.gitignore`.
- **Quy tắc 3 lần:** 1 lỗi sửa quá 3 lần không xong → xin phép người dùng gọi agent hỗ trợ, không tự mày mò.

## 6. CHECKLIST TRƯỚC KHI XONG (xem `code-checklist.md`)

Typecheck pass · Build pass · Nghiệm thu đo được · Docstring đủ · Không secret trong commit · Git sạch · Progress log cập nhật.

---

*Framework v1.0 — TheGhost (Cyber Brain) · Cập nhật: 2026-08-10*

# Memory Standard — Bộ nhớ chuẩn TheGhost (Markdown-first)

> Chuẩn bộ nhớ cho MỌI agent (OpenClaw / Pi / TheGhost) — theo ADR-007 (Memory 3 lớp) + ADR-009 (Markdown-first).
> Nguyên tắc: **Markdown là nguồn sự thật** — vector chỉ là index phái sinh. Không lock-in.

## 1. Nguyên tắc nền tảng

1. **Markdown-first:** Ký ức lưu dưới dạng file `.md` — con người đọc được, git-versionable, mọi công cụ/AI đọc được. 10 năm sau vẫn mở được.
2. **Kho Markdown = nguồn sự thật** — vector/Qdrant chỉ là index tìm nhanh (phái sinh, xóa được).
3. **Không bịa:** trả lời phải có nguồn (memory/tài liệu); không có nguồn → nói rõ "tôi không có thông tin".
4. **Ghi ngay, chốt dần:** daily notes ghi ngay sau mỗi phiên; MEMORY.md chỉ chốt fact quan trọng (có kiểm chứng).

## 2. Cấu trúc kho memory chuẩn

```text
<workspace>/                      ← workspace của agent (mount vào container)
├── SOUL.md                       ← Bản sắc agent (persona, tính cách)
├── USER.md                       ← Hồ sơ người dùng (tên, sở thích, ngữ cảnh)
├── IDENTITY.md                   ← Danh tính agent (nếu tách)
├── MEMORY.md                     ← ⭐ Ký ức bền vững (fact đã chốt — nguồn sự thật chính)
├── daily/                        ← Nhật ký ngày (YYYY-MM-DD.md) — ghi mọi phiên
│   └── 2026-08-10.md
├── research/                     ← Tri thức nghiên cứu (YYYY-MM-DD-<slug>.md)
└── framework/                    ← Code Standard (AGENTS.md + skills) — mount từ TheGhost
```text

## 3. Quy tắc ghi & củng cố

| Sự kiện | Hành động | Ghi vào |
| --- | --- | --- |
| Cuối mỗi phiên | Ghi tóm tắt phiên: việc làm, fact mới, quyết định | `daily/YYYY-MM-DD.md` |
| Fact quan trọng (tên, sở thích, quyết định cá nhân) | Chốt vào MEMORY.md (ghi atomic — tránh mất nếu crash) | `MEMORY.md` |
| Nghiên cứu web/tài liệu | Tổng hợp → ghi tri thức (có nguồn/link) | `research/YYYY-MM-DD-<slug>.md` |
| Consolidation định kỳ (dreaming) | Lookback daily notes → chốt fact quan trọng → MEMORY.md | `MEMORY.md` + review |

## 4. Quy tắc tra cứu (chống bịa)

1. Tra memory (Markdown keyword + vector) TRƯỚC khi trả lời.
2. Có nguồn → trả lời + có thể kèm nguồn.
3. Không có nguồn → **"tôi không có thông tin để xác nhận"** — không bịa.
4. Không chắc → tra ký ức → research web → mới trả lời.

## 5. Nghiệm thu (kiểm chứng bộ nhớ)

- [ ] Hỏi qua **2 session khác nhau** → phải nhớ cùng fact (cross-session).
- [ ] Hỏi ngoài phạm vi → phải từ chối (không bịa).
- [ ] File `.md` đọc được trực tiếp (con người kiểm tra được).
- [ ] Sau restart agent → vẫn nhớ (không mất).

## 6. Bảo mật

- Kho memory chứa dữ liệu cá nhân → **git-ignored** (không commit public).
- Secret KHÔNG ghi vào memory (chỉ trong `.env`).

---

*Framework v1.0 — TheGhost (Cyber Brain) · Cập nhật: 2026-08-10 21:50*

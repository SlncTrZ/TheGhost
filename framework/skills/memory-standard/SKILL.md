---
name: memory-standard
description: >
  Bộ nhớ chuẩn TheGhost (Markdown-first, ADR-007/009) — áp dụng cho MỌI agent.
  Kho Markdown (MEMORY.md + daily/ + research/) là nguồn sự thật; vector là index phái sinh.
  BẮT BUỘC: ghi daily notes cuối phiên, chốt fact vào MEMORY.md, không bịa (thiếu nguồn → nói rõ).
  Đọc framework/memory-standard.md trong workspace để biết chi tiết.
---

# Memory Standard — Bộ nhớ chuẩn (TheGhost)

> Nạp skill này TRƯỚC khi ghi/tra cứu ký ức. File gốc: `framework/memory-standard.md` trong workspace.

## Nguyên tắc

1. **Markdown-first** — ký ức là file `.md` đọc được (không lock-in, git-versionable).
2. **Ghi ngay:** cuối mỗi phiên → ghi `daily/YYYY-MM-DD.md`.
3. **Chốt dần:** fact quan trọng → `MEMORY.md` (ghi atomic).
4. **Không bịa:** thiếu nguồn → "tôi không có thông tin để xác nhận".
5. **Nghiên cứu** → ghi `research/YYYY-MM-DD-<slug>.md` (kèm link).

## Cấu trúc chuẩn

```
workspace/
├── SOUL.md · USER.md · IDENTITY.md   ← bản ngã
├── MEMORY.md                          ← ký ức bền vững (nguồn sự thật)
├── daily/YYYY-MM-DD.md                ← nhật ký phiên
├── research/YYYY-MM-DD-<slug>.md      ← tri thức
└── framework/                         ← code standard (mount sẵn)
```

## Quy tắc tra cứu

Tra memory trước khi trả lời → có nguồn thì trả lời → không có → từ chối rõ ràng → research nếu cần.

## Nghiệm thu

Hỏi qua 2 session khác nhau phải nhớ cùng fact · hỏi ngoài phạm vi phải từ chối · file `.md` con người đọc được.

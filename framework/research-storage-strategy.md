# Nghiên cứu: Kiến trúc lưu trữ tri thức cho hệ sinh thái (Qdrant vs LanceDB vs Markdown-first)

Ngày lập: 2026-08-10 — Loại báo cáo: Nghiên cứu + so sánh (không code)

Phạm vi: Cách lưu trữ tri thức/ký ức cho **toàn bộ hệ sinh thái** (OpenClaw agents: meilin/mei_01/mei_02 + Pi + các agent tương lai + chính người dùng). Đánh giá: giữ Qdrant / chuyển LanceDB / Markdown-only / Hybrid. Bối cảnh: đã gỡ mempalace (rác công nghệ), tri thức đã export sang Markdown.
Nguồn: Research TheGhost `vector-db.md` (ADR-002 — MVP LanceDB, đích Qdrant) · thực trạng .227 · memory-standard TheGhost (Markdown-first) · docs chính thức LanceDB/Qdrant.

---

## Tóm tắt nội dung (Executive Summary)

- **Hiện trạng 3 lớp lưu trữ rời rạc:** (1) Qdrant — 6 collections, 4.595 points (Pi KB + index cũ, embedding nomic-embed-text 768d qua Ollama); (2) workspace Markdown — MEMORY.md + daily/ + research/ + qdrant-export (6.7M — nguồn sự thật của OpenClaw theo memory-standard); (3) mempalace — đã gỡ (rác: format riêng, service thừa, data ẩn).
- **Yêu cầu:** mọi agent trong hệ sinh thái + chính người dùng phải truy cập tri thức; tra cứu **nhanh**; bền vững **10 năm**; không lock-in; không "rác công nghệ" (không service thừa, format ẩn, trùng lặp).
- **Kết luận chính:** Không cần "chuyển hẳn" — **giữ Qdrant làm index vector (nhanh, đang chạy, sẵn có)** + **Markdown làm nguồn sự thật duy nhất** (đã ràng buộc) = **kiến trúc Hybrid 2 lớp rõ ràng**. LanceDB là phương án dự phòng nếu Qdrant thành gánh nặng (embedded, không service) — nhưng hiện tại Qdrant nhanh + đã vận hành nên giữ.
- **Mempalace = rác công nghệ — không hồi sinh.** Cấu trúc palace (rooms/graph) là format độc quyền, thêm service Python, data ẩn trong volume — vi phạm mọi nguyên tắc (đã gỡ + backup 502M để đối chiếu).
- **Điểm cần chuẩn hóa duy nhất:** mô hình embedding — hiện mỗi nơi một kiểu (nomic-embed-text 768d). Khuyến nghị **bge-m3 (1024d)** làm chuẩn (research TheGhost đã chốt) — đổi dần khi cần, không bắt buộc ngay.

## 1. Hiện trạng (thực tế .227 — 2026-08-10)

| Hệ thống | Nơi lưu | Nội dung | Đánh giá |
| --- | --- | --- | --- |
| Qdrant (`meilin_*` 6 collections) | Server container `:6333` | 4.595 points: code_chronicles 2.522, openclaw 1.090, robotics 849, conversation 72, wiki 34, tcdserver 28 | ✅ Nhanh, đang chạy — nhưng data ẩn (chỉ query qua API, con người không đọc trực tiếp) |
| Workspace Markdown (OpenClaw) | `/root/.openclaw/workspace/` (bind host) | MEMORY.md + daily/ + research/ + `qdrant-export-20260810/` (6.7M) | ✅ Nguồn sự thật — con người/AI đọc được, git-versionable |
| Mempalace (đã gỡ) | Volume `.mempalace` | palace graph/rooms — format riêng | ❌ Rác — đã gỡ, backup 502M |

#### Vấn đề trước đây

tri thức rải 3 nơi, format khác nhau, không thống nhất → "rác công nghệ" (mempalace), khó quản, lock-in.

## 2. Yêu cầu (requirements)

1. **Ai dùng:** tất cả agents (meilin/mei_01/mei_02, Pi, agent tương lai) + chính người dùng.
2. **Tốc độ:** tra cứu nhanh (semantic search).
3. **Bền vững 10 năm:** format mở, không lock-in, không phụ thuộc service chết.
4. **Minh bạch:** con người đọc được dữ liệu (không data ẩn trong DB).
5. **Tối giản:** không service thừa, không format độc quyền (bài học mempalace).
6. **Mở rộng:** thêm agent mới chỉ cần trỏ tới tri thức chung.

## 3. Phương án so sánh

| Tiêu chí | A. Giữ Qdrant (index) + Markdown | B. LanceDB (embedded) + Markdown | C. Markdown-only (không vector) | D. Mempalace (đã loại) |
| --- | --- | --- | --- | --- |
| Tra cứu nhanh | ✅ Vector server — nhanh | ✅ Vector local — nhanh (scale vừa) | ❌ Keyword thô — chậm | ⚠️ Palace search |
| Minh bạch (đọc được) | ⚠️ Markdown đọc được; vector ẩn trong Qdrant | ⚠️ Markdown đọc được; `.lance` file mở format | ✅ 100% Markdown | ❌ Format ẩn |
| Phụ thuộc service | ⚠️ 1 container (đang chạy) | ✅ Không service (file) | ✅ Không | ❌ 1 service Python |
| Lock-in | ⚠️ Qdrant format (index) — nhưng index xây lại được từ Markdown | ✅ Open format, local-first | ✅ Không | ❌ Format độc quyền |
| Chi phí vận hành | ⚠️ RAM + container | ✅ Nhẹ | ✅ Nhẹ nhất | ❌ Nhiều |
| Sẵn sàng ngay | ✅ Đang chạy, 4.595 points có sẵn | 🔄 Cần index lại từ Markdown | 🔄 Mất semantic search | ❌ |
| Rủi ro mất dữ liệu | ✅ Thấp — index xây lại từ Markdown | ✅ Thấp | ✅ Thấp nhất | ⚠️ Cao |

## 4. Khuyến nghị

#### Chọn phương án A — Hybrid 2 lớp (Markdown = sự thật + Qdrant = index vector)

1. **Markdown là nguồn sự thật DUY NHẤT** (memory-standard): mọi tri thức ghi vào `workspace/memory/` (MEMORY.md, daily/, research/). Đã ràng buộc ✓ (export 6.7M xong).
2. **Qdrant là index phái sinh** (giữ — nhanh, sẵn có): index được xây lại bất cứ lúc nào từ Markdown (không mất gì nếu Qdrant chết). 6 collections hiện tại giữ nguyên cho Pi KB + index OpenClaw.
3. **Chuẩn hóa embedding dần:** mục tiêu **bge-m3 (1024d)** — chuẩn research TheGhost. Hiện nomic-embed-text (768d) vẫn hoạt động — đổi khi cần re-index, không gấp.
4. **Quy trình ghi tri thức chuẩn:** agent nghiên cứu xong → ghi Markdown (workspace) → (tùy chọn) index vào Qdrant. Không bao giờ ghi tri thức trực tiếp vào Qdrant mà không có Markdown.
5. **LanceDB = phương án dự phòng:** nếu Qdrant thành gánh nặng (RAM/container) → chuyển index sang LanceDB embedded (chỉ đổi lớp index, Markdown không đổi) — chi phí thấp vì Markdown đã tách biệt.

#### Tại sao không chuyển hẳn LanceDB ngay

Qdrant đang chạy tốt, nhanh, dữ liệu có sẵn; chuyển gấp = công sức re-index + rủi ro không cần thiết. Nguyên tắc "không sửa cái đang chạy tốt".

## 5. Quyết định đề xuất (chờ chốt ADR)

- [ ] **ADR:** Kiến trúc tri thức Hybrid — Markdown-first (nguồn sự thật) + Qdrant (index vector, giữ).
- [ ] Chuẩn embedding: giữ nomic-embed-text hiện tại; bge-m3 khi re-index (không gấp).
- [ ] Mempalace: **không hồi sinh** (rác công nghệ — đã gỡ).
- [ ] Quy trình: tri thức mới → ghi Markdown trước → index Qdrant sau.

## 7. Triển khai kho chung (Cyber Brain Workspace) — 2026-08-10 22:30

- **Vị trí:** `/home/dinhtc/cyber_brain_workspace/` — 1 kho gốc DUY NHẤT, bind mount vào mọi agent (OpenClaw → `/root/.openclaw/workspace`).
- **Cấu trúc context-based:** `core_rules/` (framework chuẩn — read-only) · `global_knowledge/` (research/howto/domain) · `projects/<tên>/` (README/architecture/notes/changelog) · `episodic/` (ký ức đối thoại backup) · `templates/`.
- **Migrate:** workspace OpenClaw cũ (MEMORY/daily/research/SOUL/USER/IDENTITY/skills/agents) đã copy vào kho chung — OpenClaw healthy, identity + skills nguyên vẹn.
- **Framework TheGhost:** tại `core_rules/framework/` (4 skills) — 1 nguồn chuẩn.
- **Source field:** đường dẫn tương đối từ gốc kho (vd `projects/app_ban_hang/changelog.md`).

## 6. Kết luận

Không cần "chuyển hẳn" hay "xóa Qdrant" — Qdrant nhanh và đang vận hành, giữ làm index. Điều cần làm là **ràng buộc tri thức vào Markdown (đã xong)** + quy trình ghi chuẩn + chuẩn hóa embedding dần. Mempalace là rác công nghệ — không quay lại. Kiến trúc Hybrid 2 lớp: **Markdown = não bộ, Qdrant = chỉ mục** — bền vững, minh bạch, không lock-in, thêm agent nào cũng trỏ được.

---

*Cập nhật cuối: 2026-08-10 22:10*

# scripts/ — Tiện ích Cyber Brain (Qdrant)

Các script quản lý kho tri thức **Cyber Brain** trên Qdrant (mặc định `192.168.1.227:6333`).

## Scripts

| Script | Chức năng |
| --- | --- |
| `migrate-qdrant.py` | Migrate 6 collection `meilin_*` → 2 collection Cyber Brain (`cyberbrain_knowledge` + `cyberbrain_episodic`), giữ nguyên vector 768d |
| `export-qdrant.py` | Export toàn bộ points → Markdown theo topic (ràng buộc tri thức — memory-standard) |
| `install.sh` / `install.ps1` | Installer OpenClaw 1 lệnh (không phụ thuộc Qdrant) |

## Yêu cầu

- **Qdrant** chạy tại `QD` trong script (mặc định `http://192.168.1.227:6333`)
- **API key:** set env `QDRANT_API_KEY` **hoặc** tạo `~/.pi/agent/secrets/qdrant.json`:

  ```json
  { "qdrant": { "api_key": "..." } }
  ```

- ⚠️ **KHÔNG hardcode key trong script** — script tự raise lỗi rõ ràng nếu thiếu key.

---

## Không có Qdrant? — Dùng phương án thay thế

> Nguyên tắc TheGhost (memory-standard, ADR-007/009): **Markdown là nguồn sự thật, Qdrant chỉ là index tìm kiếm** — mất Qdrant không mất tri thức.

Nếu bạn không có Qdrant (hoặc muốn tránh phụ thuộc), chọn một trong các cách:

1. **Đọc tri thức trực tiếp từ Markdown** — kho `workspace/memory/` (bản export từ `export-qdrant.py`) là nguồn sự thật; không cần Qdrant để đọc, chỉ mất tìm kiếm ngữ nghĩa.
2. **Thay index vector bằng file thường** — dùng `export-qdrant.py` xuất Markdown/JSON, rồi tìm bằng `grep` / `fzf` / editor — đủ cho kho nhỏ.
3. **Thay Qdrant bằng giải pháp khác** — SQLite (FTS5) cho full-text, hoặc LanceDB/Chroma cho vector; payload schema giữ nguyên (`content`, `domain`, `project`, `source`, `agent_name`, `session_id`, `timestamp`).
4. **Chỉ cần vector search mà chưa có Qdrant** — chạy nhanh bằng Docker:

   ```bash
   docker run -d --name qdrant -p 6333:6333 -v qdrant_data:/qdrant/storage qdrant/qdrant
   ```

5. **Qdrant không reachable?** — script báo lỗi rõ ràng và thoát (không treo); đổi biến `QD` để trỏ tới instance khác.

**Tóm lại:** Qdrant là **tuỳ chọn** (chỉ là index), tri thức sống trong Markdown — đúng triết lý "không lock-in" của TheGhost. Mọi script phải hoạt động ngay cả khi index bị thay bằng công cụ khác.

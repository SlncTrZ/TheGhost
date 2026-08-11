# vendor/ — Dependencies (git-ignored)

Thư mục chứa các dependency của TheGhost (đúng STRATEGY.md — wrapper bao bọc OpenClaw).

```
vendor/
├── openclaw/          ← ⭐ Clone source OpenClaw (dependency — cập nhật không ảnh hưởng wrapper)
│   └── meilin/        ← Config MeiLin/OpenClaw (CHỨA SECRET — KHÔNG commit, git-ignored)
```

## Nguyên tắc

- **Cập nhật OpenClaw**: `cd vendor/openclaw && git pull` (hoặc clone mới) — không đụng wrapper TheGhost.
- **Cấu hình MeiLin**: copy từ server .227 (`/home/dinhtc/docker-all/openclaw/config/` + `knowledge/`) — bản tham khảo local, KHÔNG commit.
- **Cài đặt**: installer sẽ clone/đồng bộ vendor/ tự động (xem STRATEGY.md §5).

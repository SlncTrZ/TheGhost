#!/usr/bin/env python3
"""Export Qdrant collections → Markdown (ràng buộc tri thức — memory-standard TheGhost).
Đọc toàn bộ points từ các collection meilin_* → ghi file .md theo collection vào workspace.
Updated: 2026-08-10
"""

import json
import os
import urllib.error
import urllib.request
from pathlib import Path

QD = "http://192.168.1.227:6333"


def get_api_key() -> str:
    """Lấy Qdrant API key từ env QDRANT_API_KEY hoặc ~/.pi/agent/secrets/qdrant.json — không hardcode."""
    key = os.environ.get("QDRANT_API_KEY")
    if key:
        return key
    secrets = Path.home() / ".pi/agent/secrets/qdrant.json"
    try:
        return json.loads(secrets.read_text(encoding="utf-8"))["qdrant"]["api_key"]
    except (OSError, json.JSONDecodeError, KeyError, TypeError) as exc:
        raise RuntimeError(
            f"Không đọc được API key từ {secrets} — tạo file hoặc set QDRANT_API_KEY"
        ) from exc


KEY = get_api_key()
COLLECTIONS = [
    "meilin_tcdserver",
    "meilin_openclaw",
    "meilin_robotics",
    "meilin_code_chronicles",
    "meilin_omniscience_wiki",
    "meilin_conversation",
]
OUT_DIR = "/home/dinhtc/theghost/deploy/openclaw/config/workspace/memory/qdrant-export-20260810"


def scroll_all(collection):
    """Scroll toàn bộ points của collection."""
    points = []
    offset = None
    while True:
        body = {"limit": 100, "with_payload": True}
        if offset:
            body["offset"] = offset
        req = urllib.request.Request(
            f"{QD}/collections/{collection}/points/scroll",
            data=json.dumps(body).encode(),
            headers={"api-key": KEY, "content-type": "application/json"},
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read())
        except (urllib.error.URLError, json.JSONDecodeError) as exc:
            raise RuntimeError(f"Qdrant scroll lỗi ({collection}): {exc}") from exc
        result = data.get("result", {})
        points.extend(result.get("points", []))
        offset = result.get("next_page_offset")
        if offset is None:
            break
    return points


def main():
    try:
        os.makedirs(OUT_DIR, exist_ok=True)
    except OSError as exc:
        raise RuntimeError(f"Không tạo được {OUT_DIR}: {exc}") from exc
    total = 0
    for coll in COLLECTIONS:
        try:
            points = scroll_all(coll)
        except Exception as exc:
            print(f"LỖI {coll}: {exc}")
            continue
        # Gom theo topic
        by_topic = {}
        for p in points:
            pl = p.get("payload", {}) or {}
            topic = pl.get("topic") or pl.get("entity_type") or "general"
            by_topic.setdefault(topic, []).append(pl)
        # Ghi file .md
        fname = f"{coll.replace('meilin_', '')}.md"
        path = os.path.join(OUT_DIR, fname)
        try:
            with open(path, "w", encoding="utf-8") as f:
                f.write(f"# {coll} — Export từ Qdrant ({len(points)} points)\n\n")
                f.write(
                    f"> Ngày export: 2026-08-10 · Nguồn: Qdrant {QD} · Theo memory-standard TheGhost\n\n"
                )
                for topic in sorted(by_topic.keys()):
                    f.write(f"## {topic}\n\n")
                    for pl in by_topic[topic]:
                        content = pl.get("content", "")
                        if content:
                            f.write(content.rstrip() + "\n\n---\n\n")
        except OSError as exc:
            raise RuntimeError(f"Ghi file {path} lỗi: {exc}") from exc
        total += len(points)
        print(f"  {coll}: {len(points)} points -> {fname}")
    print(f"TỔNG: {total} points exported → {OUT_DIR}")


if __name__ == "__main__":
    main()

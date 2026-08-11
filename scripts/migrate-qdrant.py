#!/usr/bin/env python3
"""Migrate Qdrant: 6 collection meilin_* → 2 collection Cyber Brain.
- meilin_code_chronicles/openclaw/robotics/omniscience_wiki/tcdserver → cyberbrain_knowledge
  payload: {content, domain, project, source}
- meilin_conversation → cyberbrain_episodic
  payload: {content, agent_name, project, session_id, timestamp}
Giữ nguyên vector cũ (cùng model nomic-embed-text 768d) — không cần re-embed.
Updated: 2026-08-10
"""

import json
import os
import urllib.error
import urllib.request
from pathlib import Path

QD = "http://192.168.1.227:6333"
DIM = 768


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


try:
    KEY = get_api_key()
except RuntimeError as exc:
    raise SystemExit(f"Lỗi: {exc}") from exc

# Collection cũ → (collection mới, domain)
KNOWLEDGE_SRC = {
    "meilin_code_chronicles": "code",
    "meilin_openclaw": "ops",
    "meilin_robotics": "hardware",
    "meilin_omniscience_wiki": "research",
    "meilin_tcdserver": "ops",
}
EPISODIC_SRC = "meilin_conversation"


def api(method, path, body=None):
    """Gọi Qdrant REST API."""
    req = urllib.request.Request(
        f"{QD}{path}",
        method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"api-key": KEY, "content-type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as exc:
        raise RuntimeError(
            f"Qdrant {method} {path}: HTTP {exc.code} {exc.read().decode()[:200]}"
        ) from exc


def ensure_collection(name):
    """Tạo collection nếu chưa tồn tại (vector 768, Cosine)."""
    try:
        exists = api("GET", f"/collections/{name}")
    except RuntimeError as exc:
        if "404" not in str(exc):
            raise
        exists = {"status": "not-ok"}
    if exists.get("status") != "ok":
        api(
            "PUT",
            f"/collections/{name}",
            {
                "vectors": {"size": DIM, "distance": "Cosine"},
            },
        )
        print(f"  [tạo] {name}")
    else:
        print(f"  [có] {name}")


def scroll_all(collection):
    """Scroll toàn bộ points (kèm vector + payload)."""
    points = []
    offset = None
    while True:
        body = {"limit": 100, "with_payload": True, "with_vector": True}
        if offset:
            body["offset"] = offset
        data = api("POST", f"/collections/{collection}/points/scroll", body)
        result = data.get("result", {})
        points.extend(result.get("points", []))
        offset = result.get("next_page_offset")
        if offset is None:
            break
    return points


def upsert(collection, points):
    """Upsert theo batch 100."""
    for i in range(0, len(points), 100):
        batch = points[i : i + 100]
        api("PUT", f"/collections/{collection}/points", {"points": batch})


def main():
    # 1) Collection mới
    print("=== Collection mới ===")
    ensure_collection("cyberbrain_knowledge")
    ensure_collection("cyberbrain_episodic")

    # 2) Knowledge: 5 collection cũ
    total_knowledge = 0
    for src, domain in KNOWLEDGE_SRC.items():
        points = scroll_all(src)
        mapped = []
        for p in points:
            pl = p.get("payload", {}) or {}
            mapped.append(
                {
                    "id": p["id"],
                    "vector": p.get("vector"),
                    "payload": {
                        "content": pl.get("content", ""),
                        "domain": domain,
                        "project": pl.get("project", ""),
                        "source": pl.get("source_file") or pl.get("source") or "",
                    },
                }
            )
        upsert("cyberbrain_knowledge", mapped)
        total_knowledge += len(mapped)
        print(f"  {src} ({domain}): {len(mapped)} -> cyberbrain_knowledge")
    print(f"  TỔNG knowledge: {total_knowledge}")

    # 3) Episodic: conversation
    points = scroll_all(EPISODIC_SRC)
    mapped = []
    for p in points:
        pl = p.get("payload", {}) or {}
        content = pl.get("content", "")
        # Đoán agent_name từ nội dung (Conversation Pi / Session ... / mặc định meilin)
        agent = "meilin"
        low = content[:80].lower()
        if "pi" in low and "conversation" in low:
            agent = "pi"
        elif "opencode" in low:
            agent = "opencode"
        mapped.append(
            {
                "id": p["id"],
                "vector": p.get("vector"),
                "payload": {
                    "content": content,
                    "agent_name": agent,
                    "project": pl.get("project", ""),
                    "session_id": pl.get("session_id") or pl.get("entity_name", ""),
                    "timestamp": pl.get("timestamp", ""),
                },
            }
        )
    upsert("cyberbrain_episodic", mapped)
    print(f"  {EPISODIC_SRC}: {len(mapped)} -> cyberbrain_episodic")

    # 4) Verify
    print("=== Verify ===")
    for name in ("cyberbrain_knowledge", "cyberbrain_episodic"):
        info = api("GET", f"/collections/{name}")
        print(f"  {name}: {info.get('result', {}).get('points_count')} points")
    print(
        f"  Kỳ vọng tổng: {total_knowledge} + {len(mapped)} = {total_knowledge + len(mapped)} (cũ 4595)"
    )


if __name__ == "__main__":
    main()

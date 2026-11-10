#!/usr/bin/env python3
"""Generate with Iro (色) via https://api.hanzo.ai/v1/images/generations."""
import base64
import json
import os
import sys
import urllib.request

API_KEY = os.environ["HANZO_API_KEY"]
PROMPT = sys.argv[1] if len(sys.argv) > 1 else "Minimalist architectural studio with warm morning sunlight and concrete textures"

req = urllib.request.Request(
    "https://api.hanzo.ai/v1/images/generations",
    data=json.dumps({"model": "iro", "prompt": PROMPT, "size": "1024x1024"}).encode(),
    headers={
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
    },
)
with urllib.request.urlopen(req, timeout=120) as resp:
    payload = json.loads(resp.read().decode())

img_bytes = base64.b64decode(payload["data"][0]["b64_json"])
out_path = "/tmp/iro.jpg"
with open(out_path, "wb") as f:
    f.write(img_bytes)
print(f"Wrote {len(img_bytes)} bytes to {out_path}")

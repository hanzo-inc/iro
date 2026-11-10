#!/usr/bin/env bash
# Render a composed hero frame with Iro + /v1/frame (diffusion plate + @hanzo/font UI overlay).
#
#   HANZO_API_KEY=... ./examples/frame.sh "Describe the change. Dev ships it."
set -euo pipefail

headline=${1:-"Describe the change. Dev ships it."}
: "${HANZO_API_KEY:?set HANZO_API_KEY (https://platform.hanzo.ai → API keys)}"

curl -sS https://api.hanzo.ai/v1/frame \
  -H "Authorization: Bearer $HANZO_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(python3 -c 'import json,sys; print(json.dumps({
    "model": "iro",
    "prompt": "A white canvas with a soft dot-grid, one dark rounded terminal card on the right, thin black contour lines flowing out of it, monochrome",
    "eyebrow": "HANZO DEV",
    "headline": sys.argv[1],
    "subhead": "One compose.yml spec. Native Sandbox & Visor execution.",
    "size": "1344x768"
  }))' "$headline")" \
  | python3 -c '
import base64, json, sys
d = json.load(sys.stdin)
if "data" not in d:
    sys.exit("frame refused: " + json.dumps(d)[:400])
open("/tmp/iro-frame.png", "wb").write(base64.b64decode(d["data"][0]["b64_json"]))
print("Saved /tmp/iro-frame.png")
'

#!/usr/bin/env bash
# Render one image with Iro — the smallest complete call.
#
#   HANZO_API_KEY=... ./examples/generate.sh "a red cube on a white table" 1792x1024
#
# Writes /tmp/iro.jpg and prints its size.
set -euo pipefail

prompt=${1:?usage: generate.sh <prompt> [WxH]}
size=${2:-1024x1024}
: "${HANZO_API_KEY:?set HANZO_API_KEY (https://platform.hanzo.ai → API keys)}"

body=$(printf '{"model":"iro","prompt":%s,"size":"%s"}' \
  "$(printf '%s' "$prompt" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
  "$size")

curl -sS https://api.hanzo.ai/v1/images/generations \
  -H "Authorization: Bearer $HANZO_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$body" \
  | python3 -c '
import base64, json, sys
d = json.load(sys.stdin)
if "data" not in d:
    sys.exit("iro refused: " + json.dumps(d)[:400])
open("/tmp/iro.jpg", "wb").write(base64.b64decode(d["data"][0]["b64_json"]))
'

file /tmp/iro.jpg

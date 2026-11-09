# Iro — agent notes

Iro (`iro`, `iro-1`) is Hanzo's image generation and editing SKU. This repo is its **model card, API contract, and deployment spec**; inference serving runs in [`hanzo-inc/zen`](https://github.com/hanzo-inc/zen). Read this before changing anything that serves `iro`.

## Where Iro lives across the stack

| Layer | Repo / file | What it owns |
|---|---|---|
| The SKU, its price, its rungs | `hanzo/universe` → `charts/app/files/zen/catalog.yaml` | the `iro` entry (`mode: image`, `zen-image: *iro`, `zen3-image: *iro`, alias `iro-1: iro`) |
| The serving plane | [`hanzo-inc/zen`](https://github.com/hanzo-inc/zen) → `media.go` | `mediaProxy` (gate, meter, relay), `nativeImage` (request shape), `fitImage`/`imageSize` (size fitting), `openAIImage` (answer shape) |
| Cloud gateway & Studio | `hanzo-inc/cloud` → `apps/ai/media_rpc.go`, `apps/studio/exec.go` | `/v1/images/generations` and `/v1/images/edits` at `api.hanzo.ai`; Studio step defaults `image.generate` and `image.edit` to `iro` |
| Studio UI & wire client | [`hanzo-inc/studio`](https://github.com/hanzo-inc/studio) → `src/kinds/image.tsx`, `src/wire.ts` | `iro` is the default top image model; decodes `data[0].b64_json` into canvas asset |
| 1-click K8s Stack | [`hanzo-inc/platform`](https://github.com/hanzo-inc/platform) → `src/lib/deploy/stacks.ts` | `iro` stack template (`ghcr.io/hanzoai/iro:latest`) |
| Product page | [`hanzo-inc/app`](https://github.com/hanzo-inc/app) → `lib/creative-models.ts` | `/iro` (`iro-1`, open foundation `zen3-image` / `zenlm/zen-artist`) |

## The translations zen performs for `iro`

1. **Request (`nativeImage`)**: When a rung carries `path:` (e.g. `/v1/genai/black-forest-labs/flux.2-klein-4b`), `model`, `n`, `response_format`, and `cfg_scale` are stripped from the JSON body and `size` (`WxH`) is fitted to a `width`/`height` pair on the 16-pixel grid `[512, 1568]` within `1,062,400` total pixels (`fitImage`).
2. **Answer (`openAIImage`)**: Upstream `{"artifacts":[{"base64":"..."}]}` is translated into OpenAI-compatible `{"data":[{"b64_json":"..."}]}`.

## Verifying a deploy

```bash
# 1. Verify iro is in the live model catalog
curl -s https://api.hanzo.ai/v1/models | jq '.data[] | select(.id=="iro")'

# 2. Generate an image with iro
curl -s https://api.hanzo.ai/v1/images/generations \
  -H "Authorization: Bearer $HANZO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"iro","prompt":"a red cube on a white table","size":"1792x1024"}' \
  | jq -r '.data[0].b64_json' | base64 -d > /tmp/iro.jpg

file /tmp/iro.jpg   # JPEG image data
```

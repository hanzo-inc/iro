<p align="center"><b>iro (色)</b><br><i>Hanzo's image generation & editing model</i></p>

# Iro

Iro (`iro`, `iro-1`) is Hanzo's image generation and editing model, served from Hanzo's inference fabric at `api.hanzo.ai` under the canonical id **`iro`** (open foundation: **`zen3-image`** / [`zenlm/zen-artist`](https://github.com/zenlm/zen-artist)). It renders one image per request from a text prompt at any aspect ratio from a 9:21 portrait to a 21:9 banner, and supports image editing on `/v1/images/edits`.

```bash
curl https://api.hanzo.ai/v1/images/generations \
  -H "Authorization: Bearer $HANZO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"iro","prompt":"a white canvas with a soft dot-grid, one dark rounded terminal showing a small diff, thin black contour lines flowing out of it, monochrome","size":"1792x1024"}'
```

```json
{"data":[{"b64_json":"/9j/4AAQSkZJRgABAQAAAQABAAD…"}]}
```

That is the whole API: the OpenAI images schema, one model id (`iro`), no vendor vocabulary to learn. Iro answers `b64_json` whatever `response_format` asks for.

## What it renders

| | |
|---|---|
| Modes | text → image (`/v1/images/generations`), image + prompt → image (`/v1/images/edits`) |
| Model IDs | `iro`, `iro-1` (open foundation: `zen3-image`, `zen-image`) |
| Output | JPEG, base64 in the OpenAI `data[].b64_json` envelope |
| Images per request | 1 |
| Aspect ratios | 9:21 5:11 1:2 7:13 3:5 2:3 3:4 6:7 1:1 7:6 4:3 3:2 5:3 13:7 2:1 11:5 21:9 |
| Sizes | any `size` you send; Iro fits it to the nearest ratio it can draw |
| Latency | 1.6 s to 4.4 s per render, measured on production hardware |

### Sizes

You may ask for the size you actually want — `1792x1024`, `1024x1792`, `1536x1024`, `256x256`. Iro **fits** the request to the nearest renderable shape instead of refusing it, because each edge is on a 16-pixel grid between 512 and 1568, and the whole image is at most 1,062,400 pixels. `1792x1024` becomes `1344x768` — the same 7:4 ratio, the largest render that fits.

`aspect_ratio` wins when you send it, and drops `size`/`width`/`height`.

| you ask | you get | ratio |
|---|---|---|
| `1024x1024` | `1024x1024` | 1:1 |
| `1792x1024` | `1344x768` | 7:4 |
| `1024x1792` | `768x1344` | 3:7 |
| `1536x1024` | `1248x832` | 3:2 |
| `512x512` | `512x512` | 1:1 |
| `256x256` | `512x512` | lifted to the floor |

## Creative AI Lineup

Each creative modality in Hanzo has its own dedicated model and repository:

| Model | Modality | Endpoint | Repository | Open Foundation |
|---|---|---|---|---|
| **Iro** (`iro`) | Image generation & editing | `POST /v1/images/generations` | [`hanzo-inc/iro`](https://github.com/hanzo-inc/iro) | `zen3-image` (`zenlm/zen-artist`) |
| **Koma** (`koma`) | Video generation & motion | `POST /v1/videos/generations` | [`hanzo-inc/koma`](https://github.com/hanzo-inc/koma) | `zen-director` (`zenlm/zen-director`) |
| **Koe** (`koe`) | Voice & dialogue synthesis | `POST /v1/audio/voice` | [`hanzo-inc/koe`](https://github.com/hanzo-inc/koe) | `zen3-tts` (`zenlm/zen-dub`) |
| **Oto** (`oto`) | Foley & sound effects | `POST /v1/audio/foley` | [`hanzo-inc/oto`](https://github.com/hanzo-inc/oto) | `zen-foley` (`zenlm/zen-foley`) |
| **Uta** (`uta`) | Music & score generation | `POST /v1/audio/music` | [`hanzo-inc/uta`](https://github.com/hanzo-inc/uta) | `zen-musician` (`zenlm/zen-musician`) |
| **Mori** (`mori`) | 3D assets, meshes & scenes | `POST /v1/videos/generations` | [`hanzo-inc/mori`](https://github.com/hanzo-inc/mori) | `zen-3d` (`zenlm/zen-3d`) |

## Surfaces

Iro is served by [`hanzo-inc/zen`](https://github.com/hanzo-inc/zen) and declared in `hanzo/universe` (`charts/app/files/zen/catalog.yaml`), with first-party Studio integration in [`hanzo-inc/studio`](https://github.com/hanzo-inc/studio) (`image.generate` / `image.edit`).

- Product page: <https://hanzo.ai/iro>
- API and docs: <https://api.hanzo.ai/v1>, <https://docs.hanzo.ai>
- Studio & Dashboard: <https://hanzo.ai/studio>, <https://platform.hanzo.ai>
- Agent notes for this repo: [LLM.md](./LLM.md)

## License

The contents of this repository are licensed under Apache-2.0. The proprietary `iro-1` weights are served through the Hanzo API under the [Hanzo Terms](https://hanzo.ai/terms); the open foundation `zen3-image` is available under Apache-2.0 at [`huggingface.co/zenlm/zen3-image`](https://huggingface.co/zenlm/zen3-image).

// TypeScript / Bun / Node 22+ example for Iro (色)
// Run: HANZO_API_KEY=... bun run examples/generate.ts

import { writeFileSync } from "node:fs";

const apiKey = process.env.HANZO_API_KEY;
if (!apiKey) throw new Error("Set HANZO_API_KEY");

const prompt = process.argv[2] ?? "Minimalist architectural studio with warm morning sunlight and concrete textures";

const res = await fetch("https://api.hanzo.ai/v1/images/generations", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${apiKey}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    model: "iro",
    prompt: prompt, size: "1024x1024",
  }),
});

if (!res.ok) {
  throw new Error(`iro failed (${res.status}): ${await res.text()}`);
}

const data = (await res.json()) as { data: Array<{ b64_json: string }> };
const buf = Buffer.from(data.data[0].b64_json, 'base64');
const outPath = "/tmp/iro.jpg";
writeFileSync(outPath, buf);
console.log(`Saved ${buf.byteLength} bytes to ${outPath}`);

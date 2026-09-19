// Renders App/Assets.xcassets/AppIcon.appiconset/AppIcon.png (1024x1024).
// Dependency-free: draws the gem icon pixel-by-pixel and encodes a PNG with
// Node's built-in zlib. Run: node Scripts/make-icon.js
const fs = require("fs");
const path = require("path");
const zlib = require("zlib");

const SIZE = 1024;

// --- geometry (same design as the original SVG sketch) ---
const OUTLINE = [
  [512, 180], [820, 470], [512, 860], [204, 470], [512, 180],
];
const HLINE = [[204, 470], [820, 470]];
const VLINE = [[512, 180], [512, 860]];
const DIAMS = [
  [[512, 180], [424, 470]],
  [[424, 470], [512, 860]],
  [[512, 860], [600, 470]],
  [[600, 470], [512, 180]],
];

// --- tiny geometry helpers ---
function dist2Seg(px, py, ax, ay, bx, by) {
  const dx = bx - ax, dy = by - ay;
  const len2 = dx * dx + dy * dy;
  let t = len2 ? ((px - ax) * dx + (py - ay) * dy) / len2 : 0;
  t = Math.max(0, Math.min(1, t));
  const cx = ax + t * dx, cy = ay + t * dy;
  return Math.hypot(px - cx, py - cy);
}

function pointInQuad(px, py, pts) {
  let inside = true;
  for (let i = 0; i < 4; i++) {
    const [x1, y1] = pts[i];
    const [x2, y2] = pts[(i + 1) % 4];
    const cross = (x2 - x1) * (py - y1) - (y2 - y1) * (px - x1);
    if (cross < 0) { inside = false; break; }
  }
  return inside;
}

// --- PNG encoding (RGBA, single IDAT) ---
function crc32(buf) {
  let c;
  const table = [];
  for (let n = 0; n < 256; n++) {
    c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    table[n] = c >>> 0;
  }
  let crc = 0xffffffff;
  for (const b of buf) crc = table[(crc ^ b) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const body = Buffer.concat([Buffer.from(type, "ascii"), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(body));
  return Buffer.concat([len, body, crc]);
}

function encodePNG(rgba, w, h) {
  const sig = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
  ihdr[8] = 8;  // bit depth
  ihdr[9] = 6;  // color type RGBA
  const raw = Buffer.alloc((w * 4 + 1) * h);
  for (let y = 0; y < h; y++) {
    raw[y * (w * 4 + 1)] = 0; // filter: none
    rgba.copy(raw, y * (w * 4 + 1) + 1, y * w * 4, (y + 1) * w * 4);
  }
  const idat = zlib.deflateSync(raw, { level: 9 });
  return Buffer.concat([sig, chunk("IHDR", ihdr), chunk("IDAT", idat), chunk("IEND", Buffer.alloc(0))]);
}

// --- render ---
function main() {
  const OUTLINE_W = 26;
  const INNER_W = 15;

  const rgba = Buffer.alloc(SIZE * SIZE * 4);

  for (let y = 0; y < SIZE; y++) {
    for (let x = 0; x < SIZE; x++) {
      // diagonal blue gradient background
      const t = (x / SIZE + y / SIZE) / 2;
      let r = Math.round(0x3d + (0x1a - 0x3d) * t);
      let g = Math.round(0x8f + (0x4d - 0x8f) * t);
      let b = Math.round(0xfb + (0xbf - 0xfb) * t);

      // fill the gem with a slightly lighter blue
      if (pointInQuad(x, y, OUTLINE)) {
        const ft = (x / SIZE) * 0.35 + 0.25;
        r = Math.round(0x5a + (0x2a - 0x5a) * ft);
        g = Math.round(0xa8 + (0x63 - 0xa8) * ft);
        b = Math.round(0xfc + (0xd0 - 0xfc) * ft);
      }

      // white strokes: outline (thick, all 4 closed edges), cross lines (thinner)
      let dOut = Infinity;
      for (let i = 0; i < 4; i++) {
        dOut = Math.min(dOut, dist2Seg(x, y, ...OUTLINE[i], ...OUTLINE[i + 1]));
      }
      const dLine = dist2Seg(x, y, ...HLINE[0], ...HLINE[1]);
      const dVert = dist2Seg(x, y, ...VLINE[0], ...VLINE[1]);
      const dDia = Math.min(
        dist2Seg(x, y, ...DIAMS[0][0], ...DIAMS[0][1]),
        dist2Seg(x, y, ...DIAMS[1][0], ...DIAMS[1][1]),
        dist2Seg(x, y, ...DIAMS[2][0], ...DIAMS[2][1]),
        dist2Seg(x, y, ...DIAMS[3][0], ...DIAMS[3][1])
      );

      const onOutline = dOut < OUTLINE_W;
      const onInner = Math.min(dLine, dVert, dDia) < INNER_W;

      if (onOutline || onInner) {
        r = g = b = 255;
      }

      const idx = (y * SIZE + x) * 4;
      rgba[idx] = r;
      rgba[idx + 1] = g;
      rgba[idx + 2] = b;
      rgba[idx + 3] = 255;
    }
  }

  const png = encodePNG(rgba, SIZE, SIZE);
  const out = path.join(__dirname, "..", "App", "Assets.xcassets", "AppIcon.appiconset", "AppIcon.png");
  fs.writeFileSync(out, png);
  console.log("Wrote", out, png.length, "bytes");
}

main();

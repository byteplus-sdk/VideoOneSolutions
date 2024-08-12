export function rgbaToArgb(rgba: Uint8Array) {
  let argb = new Uint8Array(rgba.length);
  for (let i = 0; i < rgba.length; i += 4) {
    argb[i] = rgba[i + 3]; // Alpha
    argb[i + 1] = rgba[i]; // Red
    argb[i + 2] = rgba[i + 1]; // Green
    argb[i + 3] = rgba[i + 2]; // Blue
  }
  return argb;
}

export function rgbaToBgra(rgba: Uint8Array) {
  let bgra = new Uint8Array(rgba.length);
  for (let i = 0; i < rgba.length; i += 4) {
    bgra[i] = rgba[i + 2]; // Blue
    bgra[i + 1] = rgba[i + 1]; // Green
    bgra[i + 2] = rgba[i]; // Red
    bgra[i + 3] = rgba[i + 3]; // Alpha
  }
  return bgra;
}

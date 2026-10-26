#!/usr/bin/env bash
# Writes node.binary to android/local.properties for Gradle / Android Studio.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/android"
LOCAL_PROPS="$ANDROID_DIR/local.properties"

NODE_BIN="${NODE_BINARY:-$(command -v node || true)}"
if [[ -z "$NODE_BIN" ]]; then
  echo "[setup-android-node] node not found in PATH. Load nvm/fnm or set NODE_BINARY."
  exit 1
fi

touch "$LOCAL_PROPS"
if grep -q '^node\.binary=' "$LOCAL_PROPS" 2>/dev/null; then
  sed -i '' "s|^node\.binary=.*|node.binary=$NODE_BIN|" "$LOCAL_PROPS"
else
  printf '\nnode.binary=%s\n' "$NODE_BIN" >> "$LOCAL_PROPS"
fi

ln -sf "$NODE_BIN" "$ANDROID_DIR/node"
echo "[setup-android-node] node.binary=$NODE_BIN"

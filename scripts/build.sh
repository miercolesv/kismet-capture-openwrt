#!/usr/bin/env bash
# Build the kismet-capture-linux-wifi .apk with the OpenWrt SDK.
# Used by CI and for local builds (Linux x86_64, not as root).
#   RELEASE=25.12.6 TARGET=qualcommax/ipq60xx ./scripts/build.sh
set -euo pipefail

RELEASE="${RELEASE:-25.12.6}"
TARGET="${TARGET:-qualcommax/ipq60xx}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${WORK:-$REPO/work}"
OUT="${OUT:-$REPO/dist}"
JOBS="${JOBS:-$(nproc)}"

mkdir -p "$WORK" "$OUT"
cd "$WORK"

BASE="https://downloads.openwrt.org/releases/$RELEASE/targets/$TARGET"
SDK_TAR="$(wget -qO- "$BASE/" | grep -oE 'openwrt-sdk-[^"]+\.tar\.zst' | head -1)"
[ -n "$SDK_TAR" ] || { echo "No SDK found at $BASE" >&2; exit 1; }
SDK_DIR="$WORK/${SDK_TAR%.tar.zst}"

if [ ! -d "$SDK_DIR" ]; then
  echo "== Downloading $SDK_TAR"
  wget -q "$BASE/$SDK_TAR"
  tar --zstd -xf "$SDK_TAR"
  rm -f "$SDK_TAR"
fi

cd "$SDK_DIR"

echo "== Feeds"
cp feeds.conf.default feeds.conf
echo "src-link kismetlocal $REPO" >> feeds.conf
./scripts/feeds update base packages kismetlocal >/dev/null
./scripts/feeds install -p kismetlocal kismet-capture-linux-wifi
./scripts/feeds install libpcap libnl-tiny libwebsockets-mbedtls >/dev/null
make defconfig >/dev/null

echo "== Build"
rm -rf bin/packages/*/kismetlocal
make -j"$JOBS" package/kismet-capture/clean >/dev/null 2>&1 || true
if ! make -j"$JOBS" package/kismet-capture/compile V=s > "$WORK/build.log" 2>&1; then
  echo "Parallel build failed, retrying with -j1 for a readable error" >&2
  make -j1 package/kismet-capture/compile V=s 2>&1 | tee "$WORK/build.log" | tail -80
  exit 1
fi

APK="$(ls bin/packages/*/kismetlocal/kismet-capture-linux-wifi-*.apk | head -1)"
cp "$APK" "$OUT/"
echo "== Built $OUT/$(basename "$APK")"

echo "== Smoke test under qemu-aarch64"
if command -v qemu-aarch64-static >/dev/null || command -v qemu-aarch64 >/dev/null; then
  QEMU="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
  ROOT="$WORK/sysroot"
  rm -rf "$ROOT"; mkdir -p "$ROOT/lib" "$ROOT/usr/lib"
  staging_dir/host/bin/apk extract --allow-untrusted --destination "$ROOT" "$APK"
  cp -a staging_dir/toolchain-*/lib/. "$ROOT/lib/"
  cp -a staging_dir/target-*/usr/lib/*.so* "$ROOT/usr/lib/" 2>/dev/null || true
  file "$ROOT/usr/bin/kismet_cap_linux_wifi"
  HELP="$("$QEMU" -L "$ROOT" "$ROOT/usr/bin/kismet_cap_linux_wifi" --help 2>&1 || true)"
  echo "$HELP" | head -5
  echo "$HELP" | grep -q "capture driver for Kismet" || { echo "Smoke test failed" >&2; exit 1; }
  echo "$HELP" | grep -q -- "--connect" || { echo "Remote capture support missing" >&2; exit 1; }
  echo "Smoke test passed"
else
  echo "qemu-aarch64 not installed, skipping smoke test"
fi

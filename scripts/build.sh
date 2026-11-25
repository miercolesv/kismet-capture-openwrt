#!/usr/bin/env bash
# Build the Kismet packages (.apk) with the OpenWrt SDK and smoke-test them.
# Used by CI and for local builds (Linux x86_64, not as root).
#   RELEASE=25.12.6 TARGET=qualcommax/ipq60xx ./scripts/build.sh
#   PKGS="kismet-capture" ./scripts/build.sh      # build only some source packages
set -euo pipefail
# In CI, any failure becomes an annotation (readable without opening the log).
if [ -n "${GITHUB_ACTIONS:-}" ]; then
  trap 'echo "::error title=build.sh::failed at line $LINENO: ${BASH_COMMAND:0:300}"' ERR
fi

RELEASE="${RELEASE:-25.12.6}"
TARGET="${TARGET:-qualcommax/ipq60xx}"
PKGS="${PKGS:-kismet-capture kismet}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${WORK:-$REPO/work}"
OUT="${OUT:-$REPO/dist}"
JOBS="${JOBS:-$(nproc)}"

mkdir -p "$WORK" "$OUT"
rm -f "$OUT"/*.apk
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
# The feed must contain only the package dirs: linking the repo root would also
# pull in work/ (this SDK) and loop.
FEED="$WORK/feed"
rm -rf "$FEED"; mkdir -p "$FEED"
ln -s "$REPO/net" "$FEED/net"
cp feeds.conf.default feeds.conf
echo "src-link kismetlocal $FEED" >> feeds.conf
./scripts/feeds update base packages kismetlocal >/dev/null
./scripts/feeds install -p kismetlocal -a
./scripts/feeds install libpcap libnl-tiny libwebsockets-mbedtls libopenssl libsqlite3 \
  zlib libpcre2 libstdcpp libusb-1.0 librtlsdr rtl_433 >/dev/null
make defconfig >/dev/null

echo "== Build"
rm -rf bin/packages/*/kismetlocal
# Without V=s, make prints one " make[N] <package> compile" line per package: visible
# progress without the full compiler output. A heartbeat shows long steps are alive.
( while sleep 60; do echo "   ... still building ($(date +%T))"; done ) &
HB=$!
trap 'kill $HB 2>/dev/null || true' EXIT

for PKG in $PKGS; do
  echo "== Building $PKG"
  make -j"$JOBS" package/"$PKG"/clean >/dev/null 2>&1 || true
  if ! make -j"$JOBS" package/"$PKG"/compile; then
    echo "Parallel build of $PKG failed, retrying with -j1 V=s (also catches out-of-memory kills)" >&2
    if make -j1 package/"$PKG"/compile V=s > "$WORK/build.log" 2>&1; then
      echo "$PKG built on the -j1 retry (the parallel failure was probably memory)"
    else
      kill $HB 2>/dev/null || true
      echo "----- compiler errors -----"
      grep -nE 'error:|Error [0-9]+|Killed signal|fatal error' "$WORK/build.log" | head -40 || true
      if [ -n "${GITHUB_ACTIONS:-}" ]; then
        grep -E 'error:|Killed signal|fatal error' "$WORK/build.log" | head -10 | \
          while IFS= read -r l; do echo "::error title=$PKG build::${l:0:400}"; done
      fi
      echo "----- last 120 lines of build.log -----"
      tail -120 "$WORK/build.log"
      CL="$(ls build_dir/target-*/"$PKG"-[0-9]*/config.log 2>/dev/null | head -1 || true)"
      if [ -n "$CL" ] && grep -q 'exit 1' "$CL"; then
        echo "----- end of configure's config.log -----"
        tail -60 "$CL"
      fi
      exit 1
    fi
  fi
done
kill $HB 2>/dev/null || true

cp bin/packages/*/kismetlocal/*.apk "$OUT/"
echo "== Built:"; ls -l "$OUT"/*.apk

echo "== Smoke test under qemu-aarch64"
if command -v qemu-aarch64-static >/dev/null || command -v qemu-aarch64 >/dev/null; then
  QEMU="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
  ROOT="$WORK/sysroot"
  rm -rf "$ROOT"; mkdir -p "$ROOT/lib" "$ROOT/usr/lib"
  for a in "$OUT"/*.apk; do
    staging_dir/host/bin/apk extract --allow-untrusted --destination "$ROOT" "$a"
  done
  cp -a staging_dir/toolchain-*/lib/. "$ROOT/lib/"
  cp -a staging_dir/target-*/usr/lib/*.so* "$ROOT/usr/lib/" 2>/dev/null || true
  fail=0
  check() { # binary expected-text args...
    local b="$1" want="$2"; shift 2
    [ -x "$ROOT/usr/bin/$b" ] || return 0
    local out
    out="$("$QEMU" -L "$ROOT" "$ROOT/usr/bin/$b" "$@" 2>&1 || true)"
    if echo "$out" | grep -q -- "$want"; then
      echo "  ok   $b"
    else
      echo "  FAIL $b"; echo "$out" | head -8; fail=1
      [ -n "${GITHUB_ACTIONS:-}" ] && echo "::error title=smoke test $b::$(echo "$out" | head -3 | tr '\n' ' ' | cut -c1-400)"
    fi
  }
  check kismet_cap_linux_wifi  "supports sending data to a remote" --help
  check kismet_cap_sdr_rtladsb "capture driver for Kismet" --help
  check kismet_cap_sdr_rtl433  "capture driver for Kismet" --help
  check kismet_cap_sdr_rtlais  "capture driver for Kismet" --help
  check kismet                 "Kismet 2026" --version
  [ "$fail" = 0 ] || { echo "Smoke test failed" >&2; exit 1; }
  echo "Smoke test passed"
else
  echo "qemu-aarch64 not installed, skipping smoke test"
fi

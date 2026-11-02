#!/usr/bin/env bash
# Check an APK built by build_apk.sh.
#
# Usage: verify.sh <apk> [TARGET]      (TARGET defaults to v8)
#
# Checks: signature, zip alignment, expected manifest hash, native library hashes, and classes2.dex.
# The raw bytes of classes.dex differ between runs (smali assembler), so it is not hashed here;
# to compare code, disassemble two APKs with baksmali and run `diff -r` on the output.
set -uo pipefail
[ $# -ge 1 ] || { sed -n '2,/^set -/p' "$0" | sed '$d'; exit 1; }

APK="$(readlink -f "$1")"
TARGET="${2:-v8}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

case "$TARGET" in
  v3)         MANIFEST_SHA="78952dbc323ab69410afae974386b15830d76cf7d220ce05ae9e87077a31a034" ;;
  v4|v5|v6)   MANIFEST_SHA="3c44b1ad1b20c80aa0d9bd3c4b8a8cd6100ba58391ac877ec0865d89ee62fd55" ;;
  v7)         MANIFEST_SHA="ad4b05e1dd2c180e26c841427513fbe0ab45a6d4e1dec0845c5012b7b6732aeb" ;;
  v8)         MANIFEST_SHA="124196030e354298831656b74a67615be629cfcc205850371b809c663b47b11a" ;;
  *) echo "TARGET must be one of v3..v8 (got: $TARGET)"; exit 1 ;;
esac
DEX2_SHA="2a8d1c3a809b77d5a9e8e62ddb4ebb157e9a7b23fc1933e4912826c68c8848fe"
LVL="${TARGET#v}"
FAILED=0

check() {   # check <description> <command...>
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "ok    $desc"; else echo "FAIL  $desc"; FAILED=1; fi
}
entry_sha() { unzip -p "$APK" "$1" 2>/dev/null | sha256sum | cut -d' ' -f1; }
sha_is()    { [ "$(entry_sha "$1")" = "$2" ]; }

check "apksigner verify"          apksigner verify "$APK"
check "zipalign -c -p 4"          zipalign -c -p 4 "$APK"
check "AndroidManifest.xml hash ($TARGET)" sha_is AndroidManifest.xml "$MANIFEST_SHA"

while read -r sum name; do
  check "lib/arm64-v8a/$name" sha_is "lib/arm64-v8a/$name" "$sum"
done < "$ROOT/native/prebuilt/SHA256SUMS"

if [ "$LVL" -ge 6 ]; then
  check "classes2.dex hash"       sha_is classes2.dex "$DEX2_SHA"
else
  check "no classes2.dex ($TARGET)" bash -c '! unzip -l "$0" classes2.dex >/dev/null 2>&1' "$APK"
fi

if [ "$FAILED" -eq 0 ]; then echo "All checks passed for $TARGET."; else echo "Some checks failed."; exit 1; fi

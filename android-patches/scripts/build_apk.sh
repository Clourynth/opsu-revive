#!/usr/bin/env bash
# Build the opsu!revive APK from the original Opsu-android 0.16.1a APK.
#
# Requirements (Debian/Ubuntu):
#   sudo apt install openjdk-17-jre-headless libsmali-java zipalign apksigner python3 patch
#
# Usage:
#   [TARGET=v8] [KEYSTORE=... KS_ALIAS=... KS_PASS=...] build_apk.sh <original.apk> <output.apk>
#
# TARGET selects how many changes are applied (default: v8, the newest):
#   v3  arm64 + targetSdk 24 + runtime storage permission + 64-bit pointer fix
#   v4  v3 + low-latency audio, Android 8+ (minSdk 26, targetSdk 26)
#   v5  v4 + hitsounds dispatched from a dedicated thread (removes micro-stutter)
#   v6  v5 + WAV hitsounds resampled to the device's native rate (adds classes2.dex)
#   v7  v6 + version 0.17.0 (versionName, versionCode 3, in-game version string)
#   v8  v7 + opsu!revive branding, @Clourynth credit, repo links, versionCode 4
#
# Signing: set KEYSTORE, KS_ALIAS and KS_PASS (the password is used for the store and the key).
#   Without KEYSTORE a temporary DEBUG keystore is generated. Do NOT use it for public releases.
#   A temporary key differs on every build, so installing over another build requires an uninstall first.
# NATIVE=build: rebuild the native libs from source (needs internet). Default: use native/prebuilt.
# SKIP_CHECKSUM=1: do not verify that <original.apk> is the expected Opsu-android 0.16.1a APK.
set -euo pipefail

TARGET="${TARGET:-v8}"
case "$TARGET" in v3|v4|v5|v6|v7|v8) ;; *) echo "TARGET must be one of v3..v8 (got: $TARGET)"; exit 1;; esac
LVL="${TARGET#v}"
[ $# -eq 2 ] || { sed -n '2,/^set -e/p' "$0" | sed '$d'; exit 1; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PATCHES="$ROOT/patches"
ORIG="$(readlink -f "$1")"
OUT="$(readlink -f "$(dirname "$2")")/$(basename "$2")"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

# The patches only fit this exact APK (Opsu-android0_16_1a.apk).
EXPECTED_SHA256="2f43d8d0f1d50ae8b774b6f275cdfd5b896e5febcca6c71eaffdd94c59538306"
if [ "${SKIP_CHECKSUM:-0}" != "1" ]; then
  ACTUAL_SHA256="$(sha256sum "$ORIG" | cut -d' ' -f1)"
  if [ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]; then
    echo "Unexpected input APK."
    echo "  expected SHA-256: $EXPECTED_SHA256"
    echo "  actual SHA-256:   $ACTUAL_SHA256"
    echo "Use the original Opsu-android 0.16.1a APK, or set SKIP_CHECKSUM=1 to continue anyway."
    exit 1
  fi
fi

# Classpath for smali/baksmali (Debian/Ubuntu package: libsmali-java).
# antlr and stringtemplate only exist in older package versions and are optional.
CP=""
for j in smali baksmali dexlib2 smali-util antlr3-runtime antlr stringtemplate jcommander guava jsr305; do
  if [ -f "/usr/share/java/$j.jar" ]; then
    CP="$CP:/usr/share/java/$j.jar"
  else
    case "$j" in antlr|stringtemplate) ;; *) echo "Missing jar: /usr/share/java/$j.jar"; exit 1;; esac
  fi
done
CP="${CP#:}"

apply_patch() {   # apply_patch <patch file>: apply to the baksmali output
  (cd "$WORK/smali" && patch -p1 < "$PATCHES/smali/$1")
}
add_classes() {   # add_classes <patch name>: copy the new smali classes that belong to a patch
  cp -r "$PATCHES/new-classes/$1/." "$WORK/smali/"
}

echo "== TARGET=$TARGET =="

echo "[1/6] Extract classes.dex and the manifest"
unzip -q -o "$ORIG" classes.dex AndroidManifest.xml -d "$WORK/orig"

echo "[2/6] Disassemble (baksmali) and apply smali patches"
java -cp "$CP" org.jf.baksmali.Main d "$WORK/orig/classes.dex" -o "$WORK/smali"
apply_patch storage-permission.patch; add_classes storage-permission
if [ "$LVL" -ge 4 ]; then apply_patch low-latency-audio.patch; add_classes low-latency-audio; fi
if [ "$LVL" -ge 5 ]; then apply_patch async-hitsounds.patch; add_classes async-hitsounds; fi
# v6+: the new SampleRate class goes into a separate classes2.dex (below), so only the patch is applied here.
if [ "$LVL" -ge 6 ]; then apply_patch resample-hitsounds.patch; fi
if [ "$LVL" -ge 7 ]; then apply_patch version-0.17.0.patch; fi
if [ "$LVL" -ge 8 ]; then apply_patch branding.patch; fi

echo "[3/6] Assemble classes.dex (API 21)"
java -cp "$CP" org.jf.smali.Main a "$WORK/smali" -o "$WORK/classes.dex" --api 21
DEX2=""
if [ "$LVL" -ge 6 ]; then
  java -cp "$CP" org.jf.smali.Main a "$PATCHES/new-classes/resample-hitsounds" -o "$WORK/classes2.dex" --api 21
  DEX2="$WORK/classes2.dex"
fi

echo "[4/6] Patch the manifest"
VERSION_ARGS=""
if   [ "$LVL" -ge 8 ]; then VERSION_ARGS="--version-name 0.16.1a 0.17.0 --version-code 2 4"
elif [ "$LVL" -ge 7 ]; then VERSION_ARGS="--version-name 0.16.1a 0.17.0 --version-code 2 3"; fi
if [ "$TARGET" = v3 ]; then
  python3 "$ROOT/scripts/patch_manifest.py" "$WORK/orig/AndroidManifest.xml" "$WORK/AndroidManifest.xml" 22 24
else
  # targetSdk 26 (not 24): the tested v4/v5 builds were made with apktool/aapt2, which raises targetSdk
  # to minSdk (26) automatically. This script uses the same value so the output matches those builds.
  python3 "$ROOT/scripts/patch_manifest.py" "$WORK/orig/AndroidManifest.xml" "$WORK/AndroidManifest.xml" 22 26 \
    --min-sdk 8 26 \
    --add-feature android.hardware.audio.low_latency --add-feature android.hardware.audio.pro \
    $VERSION_ARGS
fi

echo "[5/6] Native libraries (arm64-v8a)"
if [ "${NATIVE:-prebuilt}" = "build" ]; then
  "$ROOT/scripts/build_native_libs.sh" "$WORK/native"
  LIBDIR="$WORK/native"
else
  (cd "$ROOT/native/prebuilt/arm64-v8a" && sha256sum -c ../SHA256SUMS >/dev/null) \
    || { echo "Checksum mismatch in native/prebuilt"; exit 1; }
  LIBDIR="$ROOT/native/prebuilt/arm64-v8a"
fi

echo "[6/6] Repack, zipalign, sign"
python3 "$ROOT/scripts/repack_apk.py" "$ORIG" "$WORK/unsigned.apk" "$WORK/classes.dex" "$WORK/AndroidManifest.xml" "$LIBDIR" $DEX2
zipalign -p -f 4 "$WORK/unsigned.apk" "$WORK/aligned.apk"
if [ -z "${KEYSTORE:-}" ]; then
  echo "!! KEYSTORE is not set: generating a temporary DEBUG keystore (do not use it for public releases)"
  KEYSTORE="$WORK/debug.jks"; KS_ALIAS=debug; KS_PASS=android
  keytool -genkeypair -keystore "$KEYSTORE" -storepass "$KS_PASS" -keypass "$KS_PASS" -alias "$KS_ALIAS" \
          -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=debug" >/dev/null 2>&1
fi
apksigner sign --ks "$KEYSTORE" --ks-pass "pass:$KS_PASS" --key-pass "pass:$KS_PASS" --ks-key-alias "$KS_ALIAS" \
          --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true --out "$OUT" "$WORK/aligned.apk"
rm -f "$OUT.idsig"
apksigner verify "$OUT" && zipalign -c -p 4 "$OUT" && echo "OK ($TARGET) -> $OUT"

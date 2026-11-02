#!/usr/bin/env bash
# Build libgdx.so and libgdx-freetype.so (arm64-v8a) from the libgdx 1.5.2 source plus the 64-bit pointer fix.
#
# Uses a plain aarch64 cross compiler (NOT the Android NDK). Empty stub shared libraries (libc, libm, libdl,
# liblog, libGLESv2, libstdc++) exist only so the linker records the right DT_NEEDED entries; every symbol
# the libraries use is provided by Android's bionic at runtime. Needs internet access (git clone of libgdx).
#
#   sudo apt install git patch gcc-aarch64-linux-gnu g++-aarch64-linux-gnu libgles2-mesa-dev
# Usage: build_native_libs.sh [output_dir]   (default: <repo>/native/out/arm64-v8a)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/native/out/arm64-v8a}"
CC=aarch64-linux-gnu-gcc; CXX=aarch64-linux-gnu-g++; STRIP=aarch64-linux-gnu-strip
command -v "$CXX" >/dev/null || { echo "g++-aarch64-linux-gnu is required"; exit 1; }
[ -f /usr/include/GLES2/gl2.h ] || { echo "GLES2 headers are required (libgles2-mesa-dev)"; exit 1; }
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT   # scratch directory
mkdir -p "$OUT" "$W/shim/android" "$W/stubs" "$W/o_gdx" "$W/o_ft"
OUT="$(cd "$OUT" && pwd)"   # absolute path: the build below changes directory

git clone --quiet --depth 1 --branch 1.5.2 https://github.com/libgdx/libgdx "$W/libgdx"
(cd "$W/libgdx" && patch -p1 < "$ROOT/patches/libgdx/fix-64bit-pointer.patch")

# Minimal android/log.h (AndroidGL20.cpp only uses __android_log_print)
cat > "$W/shim/android/log.h" <<'H'
#ifndef SHIM_ANDROID_LOG_H
#define SHIM_ANDROID_LOG_H
#ifdef __cplusplus
extern "C" {
#endif
enum { ANDROID_LOG_UNKNOWN=0, ANDROID_LOG_DEFAULT, ANDROID_LOG_VERBOSE, ANDROID_LOG_DEBUG, ANDROID_LOG_INFO, ANDROID_LOG_WARN, ANDROID_LOG_ERROR, ANDROID_LOG_FATAL, ANDROID_LOG_SILENT };
int __android_log_print(int prio, const char *tag, const char *fmt, ...);
int __android_log_write(int prio, const char *tag, const char *text);
#ifdef __cplusplus
}
#endif
#endif
H
# Empty stub shared libraries, only so the linker fills in the correct DT_NEEDED entries
echo 'void __stub(void){}' > "$W/stubs/stub.c"
for n in c m dl log GLESv2 stdc++; do $CC -shared -nostdlib -fPIC -o "$W/stubs/lib$n.so" "$W/stubs/stub.c" -Wl,-soname,lib$n.so; done

LINK_COMMON="-shared -nostdlib -fPIC -L$W/stubs -Wl,--no-as-needed -Wl,--hash-style=both -Wl,-z,noexecstack -Wl,-z,max-page-size=16384"

# ---------------- libgdx.so ----------------
cd "$W/libgdx/gdx/jni"
GF="-fPIC -O2 -Wall -DNDEBUG -D__ANDROID__ -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -fno-asynchronous-unwind-tables -I$W/shim -Ijni-headers -Ijni-headers/linux -I. -Iandroid -Igdx2d -Ietc1"
for f in android/AndroidGL20.cpp com.badlogic.gdx.graphics.g2d.Gdx2DPixmap.cpp com.badlogic.gdx.graphics.glutils.ETC1.cpp com.badlogic.gdx.math.Matrix4.cpp com.badlogic.gdx.utils.BufferUtils.cpp etc1/etc1_utils.cpp gdx2d/jpgd.cpp gdx2d/jpgd_c.cpp; do
  $CXX $GF -fno-exceptions -fno-rtti -std=gnu++98 -c "$f" -o "$W/o_gdx/$(echo "$f" | tr / _).o"
done
$CC $GF -std=gnu99 -c gdx2d/gdx2d.c -o "$W/o_gdx/gdx2d_gdx2d.c.o"
$CXX $LINK_COMMON -o "$OUT/libgdx.so" "$W"/o_gdx/*.o -lGLESv2 -llog -lm -lstdc++ -lc -Wl,-soname,libgdx.so
$STRIP --strip-unneeded "$OUT/libgdx.so"

# ---------------- libgdx-freetype.so ----------------
cd "$W/libgdx/extensions/gdx-freetype/jni"
SRCS=$(sed -n '/LOCAL_SRC_FILES/,/include \$(BUILD_SHARED/p' Android.mk | tr -d '\r' | grep -o -E '[A-Za-z0-9_./-]+\.(c|cpp)')
FF="-fPIC -O2 -Wall -DNDEBUG -D__ANDROID__ -DFT2_BUILD_LIBRARY -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -fno-asynchronous-unwind-tables -Ifreetype-2.4.10/include -Ijni-headers -Ijni-headers/linux -I."
for f in $SRCS; do
  o="$W/o_ft/$(echo "$f" | tr / _).o"
  case "$f" in
    *.cpp) $CXX $FF -fno-exceptions -fno-rtti -c "$f" -o "$o" ;;
    *.c)   $CC  $FF -std=gnu99 -c "$f" -o "$o" ;;
  esac
done
$CXX $LINK_COMMON -o "$OUT/libgdx-freetype.so" "$W"/o_ft/*.o -lm -lstdc++ -lc -Wl,-soname,libgdx-freetype.so
$STRIP --strip-unneeded "$OUT/libgdx-freetype.so"

echo "== Undefined symbols (all must be provided by bionic) =="
for l in libgdx.so libgdx-freetype.so; do echo "-- $l"; aarch64-linux-gnu-nm -D --undefined-only "$OUT/$l" | awk '{print $2}' | grep -v '^gl' | tr '\n' ' '; echo; done
sha256sum "$OUT"/*.so

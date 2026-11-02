#!/usr/bin/env bash
# Regenerate patches/new-classes/resample-hitsounds/.../SampleRate.smali from src/java/fluddokt/opsu/fake/SampleRate.java
#   sudo apt install openjdk-17-jdk-headless dalvik-exchange libsmali-java
# Usage: generate_sample_rate_smali.sh [output_dir]   (default: ./sample_rate_out)
# Pipeline: javac (-source 8 -target 8, against the gdx/android stubs in src/stubs) -> dx (min-sdk 21) -> baksmali.
# The stubs in src/stubs are only used for compilation; they are not shipped in the APK.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mkdir -p "${1:-sample_rate_out}" && cd "${1:-sample_rate_out}" && pwd)"
DX="${DX:-$(command -v dx || echo /usr/lib/android-sdk/build-tools/debian/dx)}"
CP=""; for j in smali baksmali dexlib2 smali-util antlr3-runtime jcommander guava jsr305; do CP="$CP:/usr/share/java/$j.jar"; done; CP="${CP#:}"
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
mkdir -p "$W/stubcls" "$W/cls"
javac -nowarn -source 8 -target 8 -d "$W/stubcls" $(find "$ROOT/src/stubs" -name '*.java') 2>/dev/null
javac -nowarn -source 8 -target 8 -cp "$W/stubcls" -d "$W/cls" "$ROOT/src/java/fluddokt/opsu/fake/SampleRate.java" 2>/dev/null
(cd "$W/cls" && jar cf "$W/sr.jar" fluddokt)
"$DX" --dex --min-sdk-version=21 --output="$OUT/sr.dex" "$W/sr.jar"
java -cp "$CP" org.jf.baksmali.Main d "$OUT/sr.dex" -o "$OUT/smali"
echo "dex : $OUT/sr.dex"; echo "smali: $OUT/smali/fluddokt/opsu/fake/SampleRate.smali"

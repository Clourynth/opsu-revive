# Testing and verification

## Device test status

Test device: POCO X6 Pro (Dimensity 8300), Android 14 / HyperOS. A level is marked "tested" only after the user reports it and names the build.

| Level | Status |
|-------|--------|
| v1-v3 | Tested on device. Stable through gameplay. |
| v4 | User reported "works" on an apktool-built v4 APK, with no latency measurement. `TARGET=v4` from these scripts was not tested separately. |
| v5 | Micro-stutter gone (user report); hitsound latency became inconsistent (see [known issues](known-issues.md)). A v5 build from these scripts was reported working. |
| v6 | **Experimental.** Tested by the user (2026-11-02): hitsound latency still felt inconsistent, so the resampling hypothesis did not fix it. Kept in the build for further experiments. |
| v7 | The About screen showed "opsu! v0.17.0 by @itdelatrisu + @fluddokt". Audio and latency results not reported. |
| v8 | The new About screen and branding display correctly on device (user report, 2026-11-02). Audio behavior is the same as v6 (experimental); no separate audio report. |

## Build verification

Done with smali/baksmali 2.5.2 on Ubuntu 24.04, repeated after the repository was restructured and renamed.

- `apksigner verify` and `zipalign -c -p 4` pass for v3 and v8 (and previously for v4/v5).
- Baksmali disassembly of `classes.dex` and `classes2.dex` is identical (`diff -r` shows 0 differing lines) to the APKs built earlier
  with apktool and to builds from the previous repository layout.
- The decoded manifest is equivalent to the apktool builds (only `uses-sdk` element order, line numbers and raw encoding differ).
  `aapt dump badging`: v6 `2`/`0.16.1a`, v7 `3`/`0.17.0`, v8 `4`/`0.17.0`.
- Compared with the apktool-built APKs, 284 of 288 entries are byte-identical. Differing entries: `AndroidManifest.xml` (different encoder),
  `classes.dex` and `classes2.dex` (different assembler) and `resources.arsc` (apktool/aapt2 drops the redundant `-v4` qualifier; these scripts keep
  the original file, and a build with it was reported working).
- Native libraries: `build_native_libs.sh` reproduced both `.so` files bit-for-bit (`native/prebuilt/SHA256SUMS`), most recently on
  2026-11-03 from this repository layout. Their `Java_*` exports match the
  original armeabi-v7a libraries; undefined symbols are only standard bionic libc/libm/liblog/libGLESv2/libstdc++ functions.
- Resampler: tested only on a desktop JVM. A stereo sine (44.1 to 48 kHz) kept its amplitude (20004 / 19999 for 20000), frame count 22050 to 24000,
  and channels were not swapped. Phone timing was not measured.

## Automated check

`scripts/verify.sh <apk> <TARGET>` runs the checks that are stable between builds (signature, alignment, manifest hash, native libraries, `classes2.dex`).
It passes for all levels v3 to v8 built from this repository.

## Reproducibility

Raw APK bytes are **not** reproducible between runs: the smali assembler produces different `classes.dex` bytes each run (even for earlier
scripts) and the signing block contains random padding. Compare baksmali disassembly instead. Stable between runs:

- disassembly of `classes.dex` and `classes2.dex`;
- the binary manifest and the `.so` files;
- `apksigner verify` and `zipalign -c -p 4` results.

SHA-256 of outputs:

| Item | SHA-256 |
|------|---------|
| Manifest v3 | `78952dbc323ab69410afae974386b15830d76cf7d220ce05ae9e87077a31a034` |
| Manifest v4, v5, v6 | `3c44b1ad1b20c80aa0d9bd3c4b8a8cd6100ba58391ac877ec0865d89ee62fd55` |
| Manifest v7 | `ad4b05e1dd2c180e26c841427513fbe0ab45a6d4e1dec0845c5012b7b6732aeb` |
| Manifest v8 | `124196030e354298831656b74a67615be629cfcc205850371b809c663b47b11a` |
| `classes2.dex` (v6-v8) | `2a8d1c3a809b77d5a9e8e62ddb4ebb157e9a7b23fc1933e4912826c68c8848fe` |
| `SampleRate.java` compiled to dex | `43137345d04a9680dc87b0b3ec6ecb0cf9c5b9cd343473760025d4239991e0cb` |

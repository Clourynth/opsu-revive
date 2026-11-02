# android-patches

Patch set that turns the stock **Opsu-android 0.16.1a** APK (`fluddokt.opsu.android`, the Android port of
[opsu!](https://github.com/itdelatrisu/opsu) by fluddokt, built on libgdx 1.5.2) into **opsu!revive**:
ARM64 support, Android 14 compatibility, low-latency audio and new branding.

The patches are applied to the original APK with baksmali/smali, so no game source is needed.
The original APK is **not** included; provide your own copy. The build checks it against this SHA-256:

```
2f43d8d0f1d50ae8b774b6f275cdfd5b896e5febcca6c71eaffdd94c59538306  Opsu-android0_16_1a.apk
```

## Quick start

```bash
sudo apt install openjdk-17-jre-headless libsmali-java zipalign apksigner python3 patch
scripts/build_apk.sh Opsu-android0_16_1a.apk Opsu-revive.apk          # newest level (v8)
TARGET=v3 scripts/build_apk.sh Opsu-android0_16_1a.apk Opsu-v3.apk    # minimal build (arm64 + Android 14 fixes)
```

Check the result with `scripts/verify.sh Opsu-revive.apk v8`.
See [docs/building.md](docs/building.md) for signing, native libraries and options.

## Build levels

`TARGET` selects how many patches are applied. Each level includes the previous one.

| Level | Adds | Patch / script |
|-------|------|----------------|
| v3 | arm64-v8a libraries, 64-bit pointer fix, targetSdk 24, runtime storage permission | `patches/libgdx/fix-64bit-pointer.patch`, `patches/smali/storage-permission.patch`, `native/prebuilt/` |
| v4 | Low-latency audio (Android 8+), minSdk 26 | `patches/smali/low-latency-audio.patch` |
| v5 | Hitsounds dispatched from a dedicated thread (removes micro-stutter) | `patches/smali/async-hitsounds.patch` |
| v6 | **Experimental.** Hitsounds resampled to the device's native rate; did not make hitsound latency consistent in testing (see [known issues](docs/known-issues.md)) | `patches/smali/resample-hitsounds.patch` |
| v7 | Version 0.17.0 | `patches/smali/version-0.17.0.patch` |
| v8 | opsu!revive branding, `@Clourynth` credit, repository links | `patches/smali/branding.patch` |

**Note on experimental features:** levels are cumulative, so the default build (v8) includes the experimental v6 resampling.
It did not make hitsound latency consistent in testing, adds a cache under `opsu_rs/` and makes the first launch slower. The
stable-tested levels are v3 to v5. Details in [docs/known-issues.md](docs/known-issues.md).

## Repository layout

```
.
├── LICENSE                        GPLv3
├── CHANGELOG.md                   Changes per level
├── docs/
│   ├── building.md                Build, signing, native libraries
│   ├── architecture.md            How each patch works and why
│   ├── testing.md                 Test status and verification results
│   ├── known-issues.md            Open problems and ideas not implemented
│   └── licensing.md               Licenses, attribution, files changed
├── native/prebuilt/               libgdx.so and libgdx-freetype.so for arm64-v8a (+ SHA256SUMS)
├── patches/
│   ├── smali/                     Applied with `patch -p1` to the baksmali output
│   ├── libgdx/                    Applied with `patch -p1` to the libgdx 1.5.2 source
│   └── new-classes/<patch>/       New smali classes added by the patch of the same name
├── scripts/
│   ├── build_apk.sh               Original APK to patched APK
│   ├── build_native_libs.sh       Build the native libraries from libgdx source
│   ├── verify.sh                  Check a built APK (signature, alignment, hashes)
│   ├── generate_sample_rate_smali.sh   SampleRate.java to smali
│   ├── patch_manifest.py          Edit the binary AndroidManifest.xml
│   └── repack_apk.py              Swap dex/manifest, add native libs, drop old signature
└── src/
    ├── java/                      Java source of the SampleRate class
    └── stubs/                     Compile-time stubs for SampleRate only (not shipped)
```

`patches/new-classes/<name>/` holds classes that did not exist in the original APK. A `.patch` file can only modify
existing files, so these are copied in whole. Subfolders follow the Java package path.

## License

GPLv3, inherited from opsu! (see [LICENSE](LICENSE)). Not affiliated with osu! or ppy. Details in [docs/licensing.md](docs/licensing.md).

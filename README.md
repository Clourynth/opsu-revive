# [opsu!revive](https://github.com/Clourynth/opsu-revive)

A maintained fork of [opsu!](https://github.com/itdelatrisu/opsu) for Android, based on [fluddokt's port](https://github.com/fluddokt/opsu), which uses libgdx to fake Slick2D's API.

opsu!revive focuses on **compatibility** and **performance** on modern Android devices.

##
**Download:**

<a href="https://github.com/Clourynth/opsu-revive/releases"><img src="https://img.shields.io/github/v/release/Clourynth/opsu-revive?include_prereleases&label=release" alt="Release"></a>

## What's new in opsu!revive

- **ARM64 support**: native `arm64-v8a` build for modern 64-bit devices.
- **Android 14 compatibility**: builds and runs on Android 14.
- **Low latency audio**: lower audio latency and no more hitsound micro-stutter. Hitsound consistency on dense streams is still being tested (see [known issues](android-patches/docs/known-issues.md)).

## Tested devices

| Device | SoC | Result |
| --- | --- | --- |
| POCO X6 Pro | MediaTek Dimensity 8300 Ultra | Tested |

- Recommended audio offset: -90 ms as a starting point (based on the tested device).

Other devices are untested. Reports are welcome in the [issue tracker](https://github.com/Clourynth/opsu-revive/issues).

## Roadmap

- Fix and improve the beatmap server list (download sources).
- Continue improving compatibility and performance.

## Building

### Build the APK with the patches

The files in [`android-patches/`](android-patches/) turn the original **Opsu-android 0.16.1a** APK into opsu!revive. The source in this repository is not modified by them.

1. Get the original `Opsu-android0_16_1a.apk` (SHA-256 `2f43d8d0f1d50ae8b774b6f275cdfd5b896e5febcca6c71eaffdd94c59538306`).
2. Install the tools (Debian/Ubuntu):
   ```bash
   sudo apt install openjdk-17-jre-headless libsmali-java zipalign apksigner python3 patch
   ```
3. Build:
   ```bash
   cd android-patches
   scripts/build_apk.sh /path/to/Opsu-android0_16_1a.apk Opsu-revive.apk
   ```
4. Check the result:
   ```bash
   scripts/verify.sh Opsu-revive.apk v8
   ```

Notes:
- Requires Android 8.0+. The build uses a temporary debug key unless you set `KEYSTORE`, `KS_ALIAS` and `KS_PASS`; use your own key for public releases.
- `TARGET=v3` builds the minimal version (ARM64 + Android 14 fixes only). Newer levels add low-latency audio (v4-v5), experimental hitsound resampling (v6) and version/branding (v7-v8). The default is v8.
- More options and details: [`android-patches/docs/building.md`](android-patches/docs/building.md).

### Build from source

This repository includes only the source which is directly inherited from the upstream project. To build it, use:

https://github.com/fluddokt/FKGdxOpsuLaunchers

## Credits

- [@itdelatrisu](https://github.com/itdelatrisu) for the original [opsu!](https://github.com/itdelatrisu/opsu).
- [@fluddokt](https://github.com/fluddokt) for the Android port using libgdx.
- [@Clourynth](https://github.com/Clourynth) for opsu!revive.

opsu!revive is an unofficial project and is not affiliated with or endorsed by osu! or ppy.

## License

**This software is licensed under GNU GPL version 3.**
You can find the full text of the license [here](LICENSE).

# [opsu!revive](https://github.com/Clourynth/opsu-revive)

A maintained fork of [opsu!](https://github.com/itdelatrisu/opsu) for Android, based on [fluddokt's port](https://github.com/fluddokt/opsu), which uses libgdx to fake Slick2D's API.

opsu!revive focuses on **compatibility** and **performance** on modern Android devices.

[

![Release](https://img.shields.io/github/v/release/Clourynth/opsu-revive?include_prereleases&label=release)

](https://github.com/Clourynth/opsu-revive/releases)

> ⚠️ **Beta / Experimental.** [Download the latest APK here](https://github.com/Clourynth/opsu-revive/releases).

## What's new in opsu!revive

- **ARM64 support**: native `arm64-v8a` build for modern 64-bit devices.
- **Android 14 compatibility**: builds and runs on Android 14.
- **Low latency audio**: lower and more consistent audio latency, so hitsounds feel more responsive and your timing feels tighter.

## Tested devices

| Device | SoC | Result |
| --- | --- | --- |
| POCO X6 Pro | MediaTek Dimensity 8300 Ultra | Tested |

Other devices are untested. Reports are welcome in the [issue tracker](https://github.com/Clourynth/opsu-revive/issues).

## Roadmap

- Fix and improve the beatmap server list (download sources).
- Continue improving compatibility and performance.

## Building

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

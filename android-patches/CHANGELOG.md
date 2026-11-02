# Changelog

Format based on [Keep a Changelog](https://keepachangelog.com). Levels correspond to the `TARGET` option of
`scripts/build_apk.sh`; each includes everything before it. Test status per level is in [docs/testing.md](docs/testing.md).

## v8 - 2026-10-31
### Changed
- Name shown as `opsu!revive`; About screen title is now three lines, credits add `@Clourynth`.
- Repository, changelog and issue-tracker links point to `Clourynth/opsu-revive`.
- `versionCode` 4 (so it can replace v7 when signed with the same key).

## v7 - 2026-10-31
### Changed
- Version string changed from 0.16.1a to 0.17.0 (game, error handler, update-check constant) and in the manifest (`versionCode` 3).

## v6 - 2026-10-31 (experimental)
### Added
- `SampleRate` class (shipped as `classes2.dex`): resamples PCM WAV hitsounds to the device's native output rate and caches the result.
### Notes
- Experimental: hitsound latency still felt inconsistent in user testing. See [docs/known-issues.md](docs/known-issues.md).

## v5 - 2026-10-31
### Fixed
- Micro-stutter when a hitsound plays: sound calls now run on a dedicated `HandlerThread` instead of the render thread.

## v4 - 2026-10-31
### Added
- Low-latency audio: `AudioTrack` with `PERFORMANCE_MODE_LOW_LATENCY`, `SoundPool.Builder`, `USAGE_GAME` attributes for `MediaPlayer`.
- `uses-feature` entries for `audio.low_latency` and `audio.pro` (not required).
### Changed
- `minSdkVersion` 8 to 26, `targetSdkVersion` 26. The APK no longer installs below Android 8.

## v3 - 2026-10-31
### Fixed
- Crash (`SIGSEGV` in `glBufferData`) on 64-bit devices: libgdx truncated native pointers to 32 bits.

## v2 - 2026-10-31
### Added
- Runtime request for `WRITE_EXTERNAL_STORAGE` (the app restarts once granted, closes if denied).
### Changed
- `targetSdkVersion` 22 to 24 so Android 14 accepts the install.
### Fixed
- Crash caused by the first permission-dialog attempt (`InstantiationError`, abstract `ApplicationAdapter`).

## v1 - 2026-10-31
### Added
- `arm64-v8a` builds of `libgdx.so` and `libgdx-freetype.so`, built from libgdx 1.5.2 source.

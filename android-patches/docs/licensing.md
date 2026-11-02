# Licensing and attribution (not legal advice)

- The GPLv3 text is in [LICENSE](../LICENSE).
- opsu! (itdelatrisu) and the fluddokt Android port are GPLv3. A modified APK you distribute must come with the modification source
  (this repository) and a change log ([CHANGELOG.md](../CHANGELOG.md)).
- libgdx is Apache License 2.0; `patches/libgdx/fix-64bit-pointer.patch` follows it. FreeType 2.4.10 inside `libgdx-freetype` is under the
  FreeType License / GPLv2. Keep the original notices.
- `patches/smali/low-latency-audio.patch` modifies `AndroidAudio.smali` and `AndroidAudioDevice.smali` (libgdx backend, Apache 2.0).
  The modifications are listed below and in the headers of new files.
- `src/java/fluddokt/opsu/fake/SampleRate.java` was written for opsu!revive and follows the GPLv3 of the parent project.
  `src/stubs/` holds compile-time stubs only and is not shipped in the APK.
- Not affiliated with osu! or ppy.

## Files changed per patch

| Patch | Files | Original license |
|-------|-------|------------------|
| storage-permission | `fluddokt/opsu/android/AndroidLauncher.smali` (modified), `EmptyListener.smali` (new) | opsu-android, GPLv3 |
| fix-64bit-pointer | `gdx/jni/android/AndroidGL20.cpp` in libgdx 1.5.2 source | Apache 2.0 |
| low-latency-audio | `com/badlogic/gdx/backends/android/AndroidAudioDevice.smali`, `AndroidAudio.smali` (modified), `LowLatency.smali` (new), manifest | libgdx backend, Apache 2.0 |
| async-hitsounds | `fluddokt/opsu/fake/ClipGDXSound.smali` (modified), `AsyncSound.smali` (new) | opsu-android, GPLv3 |
| resample-hitsounds | `fluddokt/opsu/fake/ClipGDXSound.smali` (modified), `SampleRate.smali` (new) | opsu-android, GPLv3 |
| version-0.17.0 | `fluddokt/opsu/fake/GameOpsu.smali`, `itdelatrisu/opsu/ErrorHandler.smali`, `itdelatrisu/opsu/downloads/Updater.smali`, manifest | opsu-android, GPLv3 |
| branding | `itdelatrisu/opsu/states/ButtonMenu$MenuState$9.smali`, `states/MainMenu.smali`, `OpsuConstants.smali`, `ErrorHandler.smali`, manifest | opsu (itdelatrisu) / opsu-android, GPLv3 |

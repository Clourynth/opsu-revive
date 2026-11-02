# Architecture

How each patch works and why. Patch names refer to files in `patches/smali/` (and `patches/libgdx/`); classes that did not
exist before are in `patches/new-classes/<patch>/`.

## fix-64bit-pointer (libgdx, native)

- Symptom: `SIGSEGV (SEGV_MAPERR)` in `libGLES_mali.so`, called from `AndroidGL20.glBufferData`, fault address `0xffffffffb1cf0240`
  (a 64-bit pointer truncated to 32 bits, then sign-extended).
- Cause: `getPointer()` in `gdx/jni/android/AndroidGL20.cpp` did `return (void *) (jint) pointer;`.
- Fix: `(void *) (intptr_t) pointer`. The two `int` to pointer casts for VBO offsets (`glDrawElements__IIII`,
  `glVertexAttribPointer__IIIZII`) became an explicit `(intptr_t)`. Other pointers in `Gdx2DPixmap`/`BufferUtils` already use `jlong`.
- libgdx 1.5.2 ships no arm64 binaries, so `scripts/build_native_libs.sh` builds both libraries from source.
  The version was read from `com.badlogic.gdx.Version.VERSION` in the DEX.

## storage-permission

- Android 14 refuses to install apps with targetSdk < 23, so `targetSdkVersion` goes 22 to 24 (Android 15 requires >= 24).
  That stops granting `WRITE_EXTERNAL_STORAGE` at install time, and the app had no runtime request.
- `AndroidLauncher.onCreate`: if SDK >= 23 and the permission is missing, call `initialize()` with a dummy listener, then
  `requestPermissions`, then return. `onRequestPermissionsResult`: granted calls `recreate()`, denied calls `finish()`.
- The dummy `initialize()` is needed because libgdx `onPause/onResume` touch `graphics`; leaving `onCreate` before `initialize`
  makes the permission dialog cause an NPE.
- The dummy listener is `fluddokt.opsu.android.EmptyListener`, a concrete class. `ApplicationAdapter` cannot be used directly:
  it is abstract in libgdx 1.5.2 and crashes with `InstantiationError`.

## low-latency-audio

Original audio paths (all legacy APIs, no performance mode):

1. `AndroidAudioDevice`: `new AudioTrack(STREAM_MUSIC, ...)`. Main music (`MusicJL3 -> AudioDevicePlayer2/3 -> Gdx.audio.newAudioDevice`).
2. `AndroidAudio`: `new SoundPool(max, STREAM_MUSIC, 100)` for hitsounds and effects.
3. `AndroidAudio.newMusic`: `new MediaPlayer()` without audio attributes.

New class `com.badlogic.gdx.backends.android.LowLatency` provides:

- `createTrack(rate, channelMask, bufferBytes)`: `AudioTrack.Builder` with `USAGE_GAME`, `PCM_16BIT`, `MODE_STREAM` and
  `PERFORMANCE_MODE_LOW_LATENCY` (requests a fast track / MMAP path; the old constructor cannot). Buffer size is still `getMinBufferSize`.
- `createSoundPool(maxStreams)`: `SoundPool.Builder` with `USAGE_GAME`, `CONTENT_TYPE_SONIFICATION`.
- `applyMusicAttrs(MediaPlayer)`: `USAGE_GAME`, `CONTENT_TYPE_MUSIC`. `MediaPlayer` has no low-latency flag, so only routing changes.

Manifest: `minSdkVersion` 26 (`setPerformanceMode` needs API 26), `targetSdkVersion` 26, and two non-required `uses-feature` entries
(`android.hardware.audio.low_latency`, `android.hardware.audio.pro`). targetSdk is 26 rather than 24 because the originally tested
apktool builds had aapt2 raise targetSdk to minSdk; behavior is the same (scoped storage only applies from targetSdk 29).

## async-hitsounds

- Symptom: micro-stutter on every hitsound.
- Path: `SoundController.playHitSound -> ... -> ClipGDXSound.play -> AndroidSound.play -> SoundPool.play()`, all on the render thread.
  `SoundPool.play()` is a synchronous binder call to the audio server and occasionally holds a frame.
- New class `fluddokt.opsu.fake.AsyncSound` owns a `HandlerThread("OpsuHitSound", priority -16)`. `ClipGDXSound.play/stop/destroy` call
  `AsyncSound.postPlay/postStop/postDispose`, so operations run in order on one thread. `play` returns 0 because `Clip.id` is only written, never read.
  Errors on that thread are caught so they cannot kill the app.

## resample-hitsounds (experimental)

Status: did not make hitsound latency consistent in user testing; kept for further experiments.

- Hypothesis (not measured): if a sample's rate differs from the device's native output rate, Android cannot use the fast mixer path,
  so sound starts are quantized to the normal mixer period (10-20 ms) and latency varies. In the original APK 29 of 38 WAV files are 44.1 kHz,
  while most phones output 48 kHz.
- New class `fluddokt.opsu.fake.SampleRate` (source `src/java/fluddokt/opsu/fake/SampleRate.java`): `prepare(FileHandle)` reads the native rate
  with `AudioTrack.getNativeOutputSampleRate`, processes only PCM WAV (8/16-bit, mono/stereo), resamples with a windowed sinc (32 taps, Hann
  window), caches the result as `java.io.tmpdir/opsu_rs/<rate>_<crc32>_<size>.wav` and returns its path. Any failure returns `null` and the
  original file is used.
- `ClipGDXSound.<init>` calls `prepare` and swaps the `FileHandle` when a cached file is returned.
- The class is assembled into a separate `classes2.dex` (native multidex, minSdk 26) rather than `classes.dex`.

## version-0.17.0

- The string `"0.16.1a"` becomes `"0.17.0"` in `GameOpsu.VERSION`, `ErrorHandler` and `Updater`. The update-check logic is unchanged.
- Manifest: `versionName` replaced in place in the string pool, `versionCode` 2 to 3 (`scripts/patch_manifest.py`).

## branding

- About screen (`ButtonMenu$MenuState$9.getTitle`): three lines, `opsu!revive v0.17.0` / `by @itdelatrisu + @fluddokt + @Clourynth` /
  `Click an option below to learn more!`.
- `MainMenu` tooltip, `OpsuConstants` (`PROJECT_AUTHOR`, `REPOSITORY_URI`, `CHANGELOG_URL`, `ISSUES_URL`) and `ErrorHandler` issue URLs updated.
- Intentionally unchanged: `CREDITS_URI` (still the fluddokt credits), `PROJECT_NAME`, and functional `"opsu!"` strings such as the autoplay user name.
- Manifest `versionCode` 4.

## Build tooling

- `scripts/patch_manifest.py` edits the binary manifest in place (targetSdk, minSdk, versionName, versionCode, `uses-feature`).
- `scripts/repack_apk.py` replaces `classes.dex` and the manifest, adds `lib/arm64-v8a` and an optional `classes2.dex`, and drops `META-INF`.
- The original `resources.arsc` is kept unchanged.

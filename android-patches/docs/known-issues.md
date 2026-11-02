# Known issues and ideas

## Open problems

- **Hitsound latency can vary.** After the dedicated-thread change (v5) micro-stutter disappeared but latency became inconsistent on dense
  streams (200 BPM test). A custom dispatcher thread with polling was tried and the user reported "still the same", so the thread is not the
  only cause. Resampling (v6, experimental) was tested by the user on 2026-11-02 and hitsounds still felt inconsistent, so it is not a confirmed fix; latency was never measured.
- **Music position ignores device latency.** `AudioDevicePlayer2/3` (`$PlayThread`) compute `latency = (float)(device.getLatency() / sampleRate)`
  with **integer division**, so the result is always 0 seconds. Music position is the number of samples written to the `AudioTrack`, not heard,
  so the game runs slightly ahead of the audible sound. The -90 ms offset recommended in the repository README may be a manual compensation
  for this (not verified). Not patched.
- **Touch input is quantized per frame.** libgdx handles touch events at the start of the render frame; unchanged and a possible source of variation.
- **SampleRate cache is never cleaned.** Files under `java.io.tmpdir/opsu_rs/` pile up if skins change often. The first launch is slower while
  WAV files are resampled. `.ogg`, `.mp3` and non-PCM WAV are not processed.
- **Per-sound `AudioTrack`.** `SoundPool` creates one track per sound; during dense streams some may not get a fast track.
- **Storage permission dialog** on Android 13+ may read "photos and media".

## Ideas not implemented

- A custom mixer on a single low-latency `AudioTrack` (hitsounds decoded to PCM in memory, playing a sound adds a voice). Prototype toolchain
  was started but never finished.
- Marking `AudioAttributes` with `FLAG_LOW_LATENCY` (hidden API; needs reflection and a fallback).
- Fixing the integer division in `AudioDevicePlayer2/3` so music position compensates for device latency.

## Dead ends

- Converting `.class` to dex with enjarify: it only converts dex to jar. `dx` from Ubuntu's `dalvik-exchange` is used instead.

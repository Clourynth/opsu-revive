# Building

## Requirements

```bash
sudo apt install openjdk-17-jre-headless libsmali-java zipalign apksigner python3 patch
```

## Tested tool versions

All verification was done on Ubuntu 24.04 with these packages. Other versions may work, but the patches and the manifest/disassembly
checks were only confirmed with these:

| Tool | Version |
|------|---------|
| smali / baksmali (`libsmali-java`) | 2.5.2 |
| Java | OpenJDK 17+ (also run with 21) |
| `apksigner` | 31.0.2 |
| `zipalign` | 10.0.0 |
| `dx` (`dalvik-exchange`, SampleRate only) | 10.0.0 |
| `gcc-aarch64-linux-gnu` (native libs only) | 13.2.0 |
| Python | 3.12+ |

The smali patches apply to the baksmali output of the exact original APK; a different smali/baksmali version can change the
smali text and make a patch fail to apply.

You also need the original `Opsu-android0_16_1a.apk`. The build refuses any other file unless it matches
`2f43d8d0f1d50ae8b774b6f275cdfd5b896e5febcca6c71eaffdd94c59538306` (override with `SKIP_CHECKSUM=1`, at your own risk: the patches will probably not apply).

## Build the APK

```bash
[TARGET=v8] [KEYSTORE=... KS_ALIAS=... KS_PASS=...] scripts/build_apk.sh <original.apk> <output.apk>
```

| Variable | Meaning |
|----------|---------|
| `TARGET` | Build level, `v3` to `v8` (default `v8`). See the table in the README. |
| `KEYSTORE`, `KS_ALIAS`, `KS_PASS` | Signing key. The password is used for both the store and the key. |
| `SKIP_CHECKSUM=1` | Skip the check that the input is the expected original APK. |
| `NATIVE=build` | Rebuild the native libraries from source first instead of using `native/prebuilt/`. |

Pipeline: baksmali the original `classes.dex`, apply the smali patches, add new classes, assemble with smali (API 21),
patch the binary manifest, repack (`scripts/repack_apk.py`), `zipalign -p 4`, sign with `apksigner`.

## Verify the result

```bash
scripts/verify.sh <output.apk> [TARGET]
```

Checks the signature, zip alignment, manifest hash, native library hashes and `classes2.dex`. See [testing.md](testing.md) for what is and is not reproducible.

## Signing

- Without `KEYSTORE` a throwaway debug keystore is generated. Do not use it for public releases.
- To update an installed build without uninstalling it, sign with the **same** keystore every time.
- v3 is signed with v1+v2+v3. v4 and later only get v2+v3 because minSdk is 26 (Android 14 does not need v1).
- Builds earlier shared with the tester used throwaway sandbox keys that are not part of this repository:
  `CN=opsu patch` (certificate SHA-256 `096785fcdec291797af312f866dfe19e2724a0e3067a02afa6b2145cad056494`, v6-v8) and the
  uber-apk-signer debug key (`1e08a903aef9c3a721510b64ec764d01d3d094eb954161b62544ea8f187b5953`, v4/v5).
  Users on another key must uninstall before installing a build signed with a different key.

## Native libraries

`native/prebuilt/arm64-v8a/` holds `libgdx.so` and `libgdx-freetype.so`. To rebuild them from the libgdx 1.5.2 source:

```bash
sudo apt install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu libgles2-mesa-dev git
scripts/build_native_libs.sh [output-dir]   # default: native/out/arm64-v8a
```

The toolchain is a plain `aarch64-linux-gnu` cross-compiler, not the NDK, with empty stub shared libraries only to create the
`DT_NEEDED` entries. Flags: `-DNDEBUG -fno-stack-protector -U_FORTIFY_SOURCE -Wl,-z,max-page-size=16384` (16 KB aligned segments).
The result is bit-for-bit reproducible: rebuilt on 2026-11-03 with the layout in this repository, both files matched
`native/prebuilt/SHA256SUMS`. Needs internet (clones libgdx 1.5.2) and about 30 seconds.

## Regenerating SampleRate.smali

`patches/new-classes/resample-hitsounds/.../SampleRate.smali` is generated from `src/java/fluddokt/opsu/fake/SampleRate.java`:

```bash
scripts/generate_sample_rate_smali.sh [output-dir]   # default: ./sample_rate_out
```

Regenerating on 2026-11-03 produced smali identical to the shipped file (comment lines aside) and the same dex hash as recorded in
[testing.md](testing.md). It compiles against the stubs in `src/stubs/` (`javac -source 8 -target 8`), converts with `dx --min-sdk-version=21` and disassembles with baksmali.

## Device tips

- Storage permission: with targetSdk 24/26 the app uses legacy storage. On Android 13+ the dialog may say "photos and media".
  Manual alternative: `adb shell pm grant fluddokt.opsu.android android.permission.WRITE_EXTERNAL_STORAGE`
- Android 15 requires targetSdk >= 24 (satisfied).
- Debug crashes: `adb logcat | grep -i -E "opsu|gdx|AndroidRuntime|DEBUG"`

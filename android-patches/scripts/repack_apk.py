#!/usr/bin/env python3
"""Create a new APK from the original one.

Replaces classes.dex and AndroidManifest.xml, adds lib/arm64-v8a/*.so, and drops META-INF (the old signature).
The result is NOT zip-aligned and NOT signed yet.

Usage: repack_apk.py <original.apk> <output.apk> <classes.dex> <AndroidManifest.xml> <arm64-v8a_dir> [classes2.dex]
The optional classes2.dex (v6+) is appended as a new entry at the end of the APK.
"""
import sys, os, zipfile

src, dst, dex, manifest, libdir = sys.argv[1:6]
dex2 = sys.argv[6] if len(sys.argv) > 6 else None
repl = {'classes.dex': dex, 'AndroidManifest.xml': manifest}
with zipfile.ZipFile(src) as zi, zipfile.ZipFile(dst, 'w') as zo:
    for it in zi.infolist():
        if it.filename.startswith('META-INF/'):
            continue
        data = open(repl[it.filename], 'rb').read() if it.filename in repl else zi.read(it.filename)
        ni = zipfile.ZipInfo(it.filename, date_time=it.date_time)
        ni.compress_type = it.compress_type
        ni.external_attr = it.external_attr
        zo.writestr(ni, data)
    for fn in sorted(os.listdir(libdir)):
        if fn.endswith('.so'):
            ni = zipfile.ZipInfo('lib/arm64-v8a/' + fn, date_time=(2026, 10, 31, 0, 0, 0))
            ni.compress_type = zipfile.ZIP_DEFLATED
            zo.writestr(ni, open(os.path.join(libdir, fn), 'rb').read())
    if dex2:
        ni = zipfile.ZipInfo('classes2.dex', date_time=(2026, 10, 31, 0, 0, 0))
        ni.compress_type = zipfile.ZIP_DEFLATED
        zo.writestr(ni, open(dex2, 'rb').read())
print('ok ->', dst)

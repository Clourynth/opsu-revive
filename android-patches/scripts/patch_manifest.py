#!/usr/bin/env python3
"""Patch a binary AndroidManifest.xml (AXML) in place, and optionally add <uses-feature> elements.

Usage:
  patch_manifest.py <input> <output> [OLD_TARGET NEW_TARGET] [options...]

  OLD_TARGET NEW_TARGET        targetSdkVersion (default 22 24; this is the v3 behaviour)
  --min-sdk OLD NEW            change minSdkVersion (v4+: 8 26)
  --add-feature NAME           add <uses-feature android:name=NAME android:required="false"/> right after the
                               existing <uses-feature> (may be repeated)
  --version-name OLD NEW       replace the versionName string in place (NEW must not be longer than OLD;
                               the rest of the slot is zero-filled, so the file size does not change)
  --version-code OLD NEW       change versionCode (int32, in place)

Without --add-feature the file size does not change (int32 values are replaced in place), same as v3.
With --add-feature the string pool grows (new strings are appended at the end of the pool) and the element
chunks are inserted; header and chunk sizes are recomputed.
"""
import struct, sys

args = sys.argv[1:]
if len(args) < 2:
    sys.exit(__doc__)
src, dst = args[0], args[1]
rest = args[2:]
old_t, new_t = 22, 24
if len(rest) >= 2 and not rest[0].startswith('--'):
    old_t, new_t = int(rest[0]), int(rest[1]); rest = rest[2:]
min_sdk = None
features = []
version_name = None
version_code = None
i = 0
while i < len(rest):
    if rest[i] == '--min-sdk':
        min_sdk = (int(rest[i + 1]), int(rest[i + 2])); i += 3
    elif rest[i] == '--add-feature':
        features.append(rest[i + 1]); i += 2
    elif rest[i] == '--version-name':
        version_name = (rest[i + 1], rest[i + 2]); i += 3
    elif rest[i] == '--version-code':
        version_code = (int(rest[i + 1]), int(rest[i + 2])); i += 3
    else:
        sys.exit('unknown option: ' + rest[i])

d = bytearray(open(src, 'rb').read())

def pool_info(d):
    n, nstyles, flags, strings_start, styles_start = struct.unpack_from('<IIIII', d, 16)
    offsets = struct.unpack_from('<%dI' % n, d, 8 + 28)
    return n, nstyles, flags, strings_start, offsets

def string_at(d, i):
    n, _s, flags, strings_start, offsets = pool_info(d)
    p = 8 + strings_start + offsets[i]
    if flags & 0x100:
        l = d[p]; p += 1 if l < 0x80 else 2
        l2 = d[p]; p += 1
        return bytes(d[p:p + l2]).decode('utf8', 'replace')
    l = struct.unpack_from('<H', d, p)[0]
    return bytes(d[p + 2:p + 2 + 2 * l]).decode('utf-16le')

def find_string(d, s):
    n = pool_info(d)[0]
    return next(i for i in range(n) if string_at(d, i) == s)

def patch_int_attr(d, attr, old, new):
    idx = find_string(d, attr)
    # attribute layout: name(4) rawValue(4)=0xFFFFFFFF  size/res0/type(4)=0x10000008  data(4)
    pat = struct.pack('<IIi', idx, 0xFFFFFFFF, 0x10000008)
    hits = [i for i in range(len(d) - 16) if d[i:i + 12] == pat]
    assert len(hits) == 1, 'attribute %s not found or not unique: %r' % (attr, hits)
    p = hits[0] + 12
    cur = struct.unpack_from('<I', d, p)[0]
    assert cur == old, '%s is currently %d, not %d' % (attr, cur, old)
    struct.pack_into('<I', d, p, new)
    print('%s %d -> %d' % (attr, old, new))

patch_int_attr(d, 'targetSdkVersion', old_t, new_t)
if min_sdk:
    patch_int_attr(d, 'minSdkVersion', *min_sdk)
if version_code:
    patch_int_attr(d, 'versionCode', *version_code)

def patch_string_inplace(d, old, new):
    """Replace one string-pool entry in place (the slot stays the same size; the new string must not be longer)."""
    n, _s, flags, strings_start, offsets = pool_info(d)
    hits = [i for i in range(n) if string_at(d, i) == old]
    assert len(hits) == 1, 'string %r not found or not unique in the pool: %r' % (old, hits)
    p = 8 + strings_start + offsets[hits[0]]
    if flags & 0x100:                       # UTF-8: [charLen][byteLen] bytes 0x00
        assert len(old) < 0x80 and len(new) < 0x80
        ob, nb = old.encode('utf8'), new.encode('utf8')
        assert len(nb) <= len(ob), 'new string is longer than the slot'
        slot = 2 + len(ob) + 1
        blob = bytes([len(new), len(nb)]) + nb + b'\x00'
    else:                                   # UTF-16LE: [u16 len] chars 0x0000
        assert len(new) <= len(old), 'new string is longer than the slot'
        slot = 2 + 2 * len(old) + 2
        blob = struct.pack('<H', len(new)) + new.encode('utf-16le') + b'\x00\x00'
    blob += b'\x00' * (slot - len(blob))
    d[p:p + slot] = blob
    print('string %r -> %r' % (old, new))

if version_name:
    patch_string_inplace(d, *version_name)

def add_features(d, names):
    n, nstyles, flags, ss, offsets = pool_info(d)
    assert nstyles == 0, 'styled string pools are not supported'
    pool_size = struct.unpack_from('<I', d, 12)[0]
    k = len(names)
    # --- append the new strings at the end of the pool
    data_len = pool_size - ss                      # length of the old string area (including padding)
    new_blob = bytearray(); new_offs = []
    for nm in names:
        new_offs.append(data_len + len(new_blob))
        if flags & 0x100:
            b = nm.encode('utf8')
            assert len(nm) < 0x80 and len(b) < 0x80
            new_blob += bytes([len(nm), len(b)]) + b + b'\x00'
        else:
            new_blob += struct.pack('<H', len(nm)) + nm.encode('utf-16le') + b'\x00\x00'
    pad = (-(pool_size + len(new_blob))) % 4
    new_blob += b'\x00' * pad
    old_pool = bytes(d[8:8 + pool_size])
    hdr = bytearray(old_pool[:28])
    offs_old = old_pool[28:28 + 4 * n]
    area_old = old_pool[ss:]
    new_pool = bytearray(hdr) + offs_old + struct.pack('<%dI' % k, *new_offs) + area_old + new_blob
    struct.pack_into('<I', new_pool, 4, len(new_pool))           # chunk size
    struct.pack_into('<I', new_pool, 8, n + k)                   # stringCount
    struct.pack_into('<I', new_pool, 20, ss + 4 * k)             # stringsStart
    body = bytearray(d[8 + pool_size:])
    d2 = bytearray(d[:8]) + new_pool + body
    struct.pack_into('<I', d2, 4, len(d2))
    base_idx = n
    # --- insert the elements after the existing </uses-feature>
    uf = find_string(d2, 'uses-feature'); nm_idx = find_string(d2, 'name'); rq_idx = find_string(d2, 'required')
    pos = 8 + struct.unpack_from('<I', d2, 12)[0]
    start = end = None
    while pos < len(d2):
        t, hs, sz = struct.unpack_from('<HHI', d2, pos)
        if t == 0x0102 and struct.unpack_from('<I', d2, pos + 20)[0] == uf and start is None:
            start = pos
        if t == 0x0103 and start is not None and struct.unpack_from('<I', d2, pos + 20)[0] == uf:
            end = pos + sz; break
        pos += sz
    assert start is not None and end is not None, '<uses-feature> not found'
    s_chunk = bytearray(d2[start:start + struct.unpack_from('<I', d2, start + 4)[0]])
    e_chunk = bytes(d2[end - 24:end])
    ans = struct.unpack_from('<I', s_chunk, 36)[0]                # namespace of the android: attributes
    assert struct.unpack_from('<H', s_chunk, 28)[0] == 2, 'the existing uses-feature must have exactly 2 attributes'
    ins = bytearray()
    for j in range(k):
        c = bytearray(s_chunk)
        struct.pack_into('<IIIHBBI', c, 36, ans, nm_idx, base_idx + j, 8, 0, 0x03, base_idx + j)   # android:name (string)
        struct.pack_into('<IIIHBBI', c, 56, ans, rq_idx, 0xFFFFFFFF, 8, 0, 0x12, 0)                # android:required=false
        ins += c + e_chunk
    d3 = bytearray(d2[:end]) + ins + d2[end:]
    struct.pack_into('<I', d3, 4, len(d3))
    for nm in names:
        print('uses-feature added: %s (required=false)' % nm)
    return d3

if features:
    d = add_features(d, features)
open(dst, 'wb').write(d)

package fluddokt.opsu.fake;

import com.badlogic.gdx.files.FileHandle;
import android.media.AudioTrack;
import java.io.File;
import java.io.FileOutputStream;
import java.util.zip.CRC32;

/**
 * Resamples WAV hitsounds to the device's native output sample rate so
 * SoundPool can use the fast mixer path (constant, low latency) instead of
 * the normal mixer whose start time is quantized to a 10-20 ms period.
 * Any failure returns null and the caller falls back to the original file.
 */
public final class SampleRate {
    private static int nativeRate = -1;

    private SampleRate() {}

    private static int getNativeRate() {
        if (nativeRate < 0) {
            int r = 0;
            try { r = AudioTrack.getNativeOutputSampleRate(3); } catch (Throwable t) { }
            nativeRate = (r >= 8000 && r <= 192000) ? r : 0;
        }
        return nativeRate;
    }

    /** Returns absolute path of a resampled copy, or null to use the original. */
    public static String prepare(FileHandle fh) {
        try {
            if (fh == null) return null;
            int target = getNativeRate();
            if (target == 0) return null;
            byte[] in = fh.readBytes();
            if (in == null || in.length < 44) return null;
            if (!(in[0] == 'R' && in[1] == 'I' && in[2] == 'F' && in[3] == 'F')) return null;

            CRC32 crc = new CRC32();
            crc.update(in, 0, in.length);
            File dir = new File(System.getProperty("java.io.tmpdir", "/data/local/tmp"), "opsu_rs");
            File out = new File(dir, target + "_" + Long.toHexString(crc.getValue()) + "_" + in.length + ".wav");
            if (out.isFile() && out.length() > 44) return out.getAbsolutePath();

            byte[] res = resampleWav(in, target);
            if (res == null) return null;
            if (!dir.isDirectory() && !dir.mkdirs() && !dir.isDirectory()) return null;
            File tmp = new File(dir, out.getName() + ".tmp");
            FileOutputStream fos = new FileOutputStream(tmp);
            try { fos.write(res); } finally { fos.close(); }
            if (!tmp.renameTo(out)) { tmp.delete(); return null; }
            return out.getAbsolutePath();
        } catch (Throwable t) {
            return null;
        }
    }

    private static int le16(byte[] b, int o) { return (b[o] & 0xff) | ((b[o + 1] & 0xff) << 8); }
    private static int le32(byte[] b, int o) {
        return (b[o] & 0xff) | ((b[o + 1] & 0xff) << 8) | ((b[o + 2] & 0xff) << 16) | ((b[o + 3] & 0xff) << 24);
    }
    private static void put16(byte[] b, int o, int v) { b[o] = (byte) v; b[o + 1] = (byte) (v >> 8); }
    private static void put32(byte[] b, int o, int v) {
        b[o] = (byte) v; b[o + 1] = (byte) (v >> 8); b[o + 2] = (byte) (v >> 16); b[o + 3] = (byte) (v >> 24);
    }

    static byte[] resampleWav(byte[] in, int target) {
        int pos = 12;
        int fmtTag = -1, ch = 0, rate = 0, bits = 0;
        int dataOff = -1, dataLen = 0;
        while (pos + 8 <= in.length) {
            int id0 = in[pos], id1 = in[pos + 1], id2 = in[pos + 2], id3 = in[pos + 3];
            int len = le32(in, pos + 4);
            int body = pos + 8;
            if (id0 == 'f' && id1 == 'm' && id2 == 't' && id3 == ' ') {
                if (len < 16 || body + 16 > in.length) return null;
                fmtTag = le16(in, body);
                ch = le16(in, body + 2);
                rate = le32(in, body + 4);
                bits = le16(in, body + 14);
                if (fmtTag == 0xFFFE && len >= 26 && body + 26 <= in.length) fmtTag = le16(in, body + 24);
            } else if (id0 == 'd' && id1 == 'a' && id2 == 't' && id3 == 'a') {
                dataOff = body;
                dataLen = len;
                if (dataLen < 0 || dataOff + dataLen > in.length) dataLen = in.length - dataOff;
                break;
            }
            if (len < 0) return null;
            pos = body + len + (len & 1);
        }
        if (fmtTag != 1 || dataOff < 0 || ch < 1 || ch > 2 || (bits != 8 && bits != 16)) return null;
        if (rate < 4000 || rate == target) return null;

        int bytesPer = bits / 8;
        int frames = dataLen / (bytesPer * ch);
        if (frames < 2) return null;

        float[][] src = new float[ch][frames];
        for (int i = 0; i < frames; i++) {
            for (int c = 0; c < ch; c++) {
                int o = dataOff + (i * ch + c) * bytesPer;
                src[c][i] = bits == 16 ? (short) le16(in, o) / 32768f : ((in[o] & 0xff) - 128) / 128f;
            }
        }

        double ratio = (double) target / rate;
        int outFrames = (int) Math.max(1, Math.round(frames * ratio));
        double step = 1.0 / ratio;
        double cutoff = ratio < 1.0 ? ratio : 1.0;
        final int half = 16;
        byte[] out = new byte[44 + outFrames * ch * 2];

        for (int i = 0; i < outFrames; i++) {
            double t = i * step;
            int ti = (int) Math.floor(t);
            for (int c = 0; c < ch; c++) {
                double acc = 0, wsum = 0;
                float[] s = src[c];
                for (int k = -half + 1; k <= half; k++) {
                    int idx = ti + k;
                    double x = t - idx;
                    double sinc = x == 0 ? cutoff : Math.sin(Math.PI * cutoff * x) / (Math.PI * x);
                    double w = 0.5 + 0.5 * Math.cos(Math.PI * x / half);
                    double coef = sinc * w;
                    wsum += coef;
                    if (idx >= 0 && idx < frames) acc += s[idx] * coef;
                }
                if (wsum != 0) acc /= wsum;
                int v = (int) Math.round(acc * 32767.0);
                if (v > 32767) v = 32767; else if (v < -32768) v = -32768;
                put16(out, 44 + (i * ch + c) * 2, v);
            }
        }

        int dlen = outFrames * ch * 2;
        out[0] = 'R'; out[1] = 'I'; out[2] = 'F'; out[3] = 'F';
        put32(out, 4, 36 + dlen);
        out[8] = 'W'; out[9] = 'A'; out[10] = 'V'; out[11] = 'E';
        out[12] = 'f'; out[13] = 'm'; out[14] = 't'; out[15] = ' ';
        put32(out, 16, 16);
        put16(out, 20, 1);
        put16(out, 22, ch);
        put32(out, 24, target);
        put32(out, 28, target * ch * 2);
        put16(out, 32, ch * 2);
        put16(out, 34, 16);
        out[36] = 'd'; out[37] = 'a'; out[38] = 't'; out[39] = 'a';
        put32(out, 40, dlen);
        return out;
    }
}

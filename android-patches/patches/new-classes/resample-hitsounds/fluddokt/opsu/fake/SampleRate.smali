# opsu!revive (modification of Opsu-android, GPLv3) - see CHANGELOG.md
# Resamples WAV hitsounds to the device's native sample rate (cached in java.io.tmpdir/opsu_rs).
# Generated from src/java/fluddokt/opsu/fake/SampleRate.java by scripts/generate_sample_rate_smali.sh
.class public final Lfluddokt/opsu/fake/SampleRate;
.super Ljava/lang/Object;
.source "SampleRate.java"


# static fields
.field private static nativeRate:I


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .prologue
    .line 16
    const/4 v0, -0x1

    sput v0, Lfluddokt/opsu/fake/SampleRate;->nativeRate:I

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .prologue
    .line 18
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static getNativeRate()I
    .registers 3

    .prologue
    const/4 v1, 0x0

    .line 21
    sget v0, Lfluddokt/opsu/fake/SampleRate;->nativeRate:I

    if-gez v0, :cond_15

    .line 23
    const/4 v0, 0x3

    :try_start_6
    invoke-static {v0}, Landroid/media/AudioTrack;->getNativeOutputSampleRate(I)I
    :try_end_9
    .catch Ljava/lang/Throwable; {:try_start_6 .. :try_end_9} :catch_18

    move-result v0

    .line 24
    :goto_a
    const/16 v2, 0x1f40

    if-lt v0, v2, :cond_1b

    const v2, 0x2ee00

    if-gt v0, v2, :cond_1b

    :goto_13
    sput v0, Lfluddokt/opsu/fake/SampleRate;->nativeRate:I

    .line 26
    :cond_15
    sget v0, Lfluddokt/opsu/fake/SampleRate;->nativeRate:I

    return v0

    .line 23
    :catch_18
    move-exception v0

    move v0, v1

    goto :goto_a

    :cond_1b
    move v0, v1

    .line 24
    goto :goto_13
.end method

.method private static le16([BI)I
    .registers 4

    .prologue
    .line 58
    aget-byte v0, p0, p1

    and-int/lit16 v0, v0, 0xff

    add-int/lit8 v1, p1, 0x1

    aget-byte v1, p0, v1

    and-int/lit16 v1, v1, 0xff

    shl-int/lit8 v1, v1, 0x8

    or-int/2addr v0, v1

    return v0
.end method

.method private static le32([BI)I
    .registers 4

    .prologue
    .line 60
    aget-byte v0, p0, p1

    and-int/lit16 v0, v0, 0xff

    add-int/lit8 v1, p1, 0x1

    aget-byte v1, p0, v1

    and-int/lit16 v1, v1, 0xff

    shl-int/lit8 v1, v1, 0x8

    or-int/2addr v0, v1

    add-int/lit8 v1, p1, 0x2

    aget-byte v1, p0, v1

    and-int/lit16 v1, v1, 0xff

    shl-int/lit8 v1, v1, 0x10

    or-int/2addr v0, v1

    add-int/lit8 v1, p1, 0x3

    aget-byte v1, p0, v1

    and-int/lit16 v1, v1, 0xff

    shl-int/lit8 v1, v1, 0x18

    or-int/2addr v0, v1

    return v0
.end method

.method public static prepare(Lcom/badlogic/gdx/files/FileHandle;)Ljava/lang/String;
    .registers 11

    .prologue
    const/16 v5, 0x46

    const/4 v0, 0x0

    .line 32
    if-nez p0, :cond_6

    .line 54
    :cond_5
    :goto_5
    return-object v0

    .line 33
    :cond_6
    :try_start_6
    invoke-static {}, Lfluddokt/opsu/fake/SampleRate;->getNativeRate()I

    move-result v1

    .line 34
    if-eqz v1, :cond_5

    .line 35
    invoke-virtual {p0}, Lcom/badlogic/gdx/files/FileHandle;->readBytes()[B

    move-result-object v2

    .line 36
    if-eqz v2, :cond_5

    array-length v3, v2

    const/16 v4, 0x2c

    if-lt v3, v4, :cond_5

    .line 37
    const/4 v3, 0x0

    aget-byte v3, v2, v3

    const/16 v4, 0x52

    if-ne v3, v4, :cond_5

    const/4 v3, 0x1

    aget-byte v3, v2, v3

    const/16 v4, 0x49

    if-ne v3, v4, :cond_5

    const/4 v3, 0x2

    aget-byte v3, v2, v3

    if-ne v3, v5, :cond_5

    const/4 v3, 0x3

    aget-byte v3, v2, v3

    if-ne v3, v5, :cond_5

    .line 39
    new-instance v3, Ljava/util/zip/CRC32;

    invoke-direct {v3}, Ljava/util/zip/CRC32;-><init>()V

    .line 40
    const/4 v4, 0x0

    array-length v5, v2

    invoke-virtual {v3, v2, v4, v5}, Ljava/util/zip/CRC32;->update([BII)V

    .line 41
    new-instance v4, Ljava/io/File;

    const-string v5, "java.io.tmpdir"

    const-string v6, "/data/local/tmp"

    invoke-static {v5, v6}, Ljava/lang/System;->getProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    const-string v6, "opsu_rs"

    invoke-direct {v4, v5, v6}, Ljava/io/File;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 42
    new-instance v5, Ljava/io/File;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "_"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v3}, Ljava/util/zip/CRC32;->getValue()J

    move-result-wide v8

    invoke-static {v8, v9}, Ljava/lang/Long;->toHexString(J)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v6, "_"

    invoke-virtual {v3, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    array-length v6, v2

    invoke-virtual {v3, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v6, ".wav"

    invoke-virtual {v3, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v5, v4, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 43
    invoke-virtual {v5}, Ljava/io/File;->isFile()Z

    move-result v3

    if-eqz v3, :cond_93

    invoke-virtual {v5}, Ljava/io/File;->length()J

    move-result-wide v6

    const-wide/16 v8, 0x2c

    cmp-long v3, v6, v8

    if-lez v3, :cond_93

    invoke-virtual {v5}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v0

    goto/16 :goto_5

    .line 45
    :cond_93
    invoke-static {v2, v1}, Lfluddokt/opsu/fake/SampleRate;->resampleWav([BI)[B

    move-result-object v1

    .line 46
    if-eqz v1, :cond_5

    .line 47
    invoke-virtual {v4}, Ljava/io/File;->isDirectory()Z

    move-result v2

    if-nez v2, :cond_ab

    invoke-virtual {v4}, Ljava/io/File;->mkdirs()Z

    move-result v2

    if-nez v2, :cond_ab

    invoke-virtual {v4}, Ljava/io/File;->isDirectory()Z

    move-result v2

    if-eqz v2, :cond_5

    .line 48
    :cond_ab
    new-instance v2, Ljava/io/File;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v3, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v6, ".tmp"

    invoke-virtual {v3, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v2, v4, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 49
    new-instance v3, Ljava/io/FileOutputStream;

    invoke-direct {v3, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    :try_end_cc
    .catch Ljava/lang/Throwable; {:try_start_6 .. :try_end_cc} :catch_dd

    .line 50
    :try_start_cc
    invoke-virtual {v3, v1}, Ljava/io/FileOutputStream;->write([B)V
    :try_end_cf
    .catchall {:try_start_cc .. :try_end_cf} :catchall_e0

    :try_start_cf
    invoke-virtual {v3}, Ljava/io/FileOutputStream;->close()V

    .line 51
    invoke-virtual {v2, v5}, Ljava/io/File;->renameTo(Ljava/io/File;)Z

    move-result v1

    if-nez v1, :cond_e5

    invoke-virtual {v2}, Ljava/io/File;->delete()Z

    goto/16 :goto_5

    .line 53
    :catch_dd
    move-exception v1

    goto/16 :goto_5

    .line 50
    :catchall_e0
    move-exception v1

    invoke-virtual {v3}, Ljava/io/FileOutputStream;->close()V

    throw v1

    .line 52
    :cond_e5
    invoke-virtual {v5}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    :try_end_e8
    .catch Ljava/lang/Throwable; {:try_start_cf .. :try_end_e8} :catch_dd

    move-result-object v0

    goto/16 :goto_5
.end method

.method private static put16([BII)V
    .registers 5

    .prologue
    .line 62
    int-to-byte v0, p2

    aput-byte v0, p0, p1

    add-int/lit8 v0, p1, 0x1

    shr-int/lit8 v1, p2, 0x8

    int-to-byte v1, v1

    aput-byte v1, p0, v0

    return-void
.end method

.method private static put32([BII)V
    .registers 5

    .prologue
    .line 64
    int-to-byte v0, p2

    aput-byte v0, p0, p1

    add-int/lit8 v0, p1, 0x1

    shr-int/lit8 v1, p2, 0x8

    int-to-byte v1, v1

    aput-byte v1, p0, v0

    add-int/lit8 v0, p1, 0x2

    shr-int/lit8 v1, p2, 0x10

    int-to-byte v1, v1

    aput-byte v1, p0, v0

    add-int/lit8 v0, p1, 0x3

    shr-int/lit8 v1, p2, 0x18

    int-to-byte v1, v1

    aput-byte v1, p0, v0

    .line 65
    return-void
.end method

.method static resampleWav([BI)[B
    .registers 36

    .prologue
    .line 68
    const/16 v7, 0xc

    .line 69
    const/4 v6, -0x1

    const/4 v5, 0x0

    const/4 v4, 0x0

    const/4 v2, 0x0

    .line 70
    const/4 v10, -0x1

    const/4 v9, 0x0

    move v3, v2

    .line 71
    :goto_9
    add-int/lit8 v2, v7, 0x8

    move-object/from16 v0, p0

    array-length v8, v0

    if-gt v2, v8, :cond_291

    .line 72
    aget-byte v2, p0, v7

    add-int/lit8 v8, v7, 0x1

    aget-byte v11, p0, v8

    add-int/lit8 v8, v7, 0x2

    aget-byte v12, p0, v8

    add-int/lit8 v8, v7, 0x3

    aget-byte v13, p0, v8

    .line 73
    add-int/lit8 v8, v7, 0x4

    move-object/from16 v0, p0

    invoke-static {v0, v8}, Lfluddokt/opsu/fake/SampleRate;->le32([BI)I

    move-result v8

    .line 74
    add-int/lit8 v7, v7, 0x8

    .line 75
    const/16 v14, 0x66

    if-ne v2, v14, :cond_80

    const/16 v14, 0x6d

    if-ne v11, v14, :cond_80

    const/16 v14, 0x74

    if-ne v12, v14, :cond_80

    const/16 v14, 0x20

    if-ne v13, v14, :cond_80

    .line 76
    const/16 v2, 0x10

    if-lt v8, v2, :cond_43

    add-int/lit8 v2, v7, 0x10

    move-object/from16 v0, p0

    array-length v3, v0

    if-le v2, v3, :cond_45

    :cond_43
    const/4 v2, 0x0

    .line 149
    :goto_44
    return-object v2

    .line 77
    :cond_45
    move-object/from16 v0, p0

    invoke-static {v0, v7}, Lfluddokt/opsu/fake/SampleRate;->le16([BI)I

    move-result v6

    .line 78
    add-int/lit8 v2, v7, 0x2

    move-object/from16 v0, p0

    invoke-static {v0, v2}, Lfluddokt/opsu/fake/SampleRate;->le16([BI)I

    move-result v5

    .line 79
    add-int/lit8 v2, v7, 0x4

    move-object/from16 v0, p0

    invoke-static {v0, v2}, Lfluddokt/opsu/fake/SampleRate;->le32([BI)I

    move-result v4

    .line 80
    add-int/lit8 v2, v7, 0xe

    move-object/from16 v0, p0

    invoke-static {v0, v2}, Lfluddokt/opsu/fake/SampleRate;->le16([BI)I

    move-result v3

    .line 81
    const v2, 0xfffe

    if-ne v6, v2, :cond_28e

    const/16 v2, 0x1a

    if-lt v8, v2, :cond_28e

    add-int/lit8 v2, v7, 0x1a

    move-object/from16 v0, p0

    array-length v11, v0

    if-gt v2, v11, :cond_28e

    add-int/lit8 v2, v7, 0x18

    move-object/from16 v0, p0

    invoke-static {v0, v2}, Lfluddokt/opsu/fake/SampleRate;->le16([BI)I

    move-result v6

    move v2, v3

    .line 88
    :goto_7c
    if-gez v8, :cond_b3

    const/4 v2, 0x0

    goto :goto_44

    .line 82
    :cond_80
    const/16 v14, 0x64

    if-ne v2, v14, :cond_28e

    const/16 v2, 0x61

    if-ne v11, v2, :cond_28e

    const/16 v2, 0x74

    if-ne v12, v2, :cond_28e

    const/16 v2, 0x61

    if-ne v13, v2, :cond_28e

    .line 85
    if-ltz v8, :cond_99

    add-int v2, v7, v8

    move-object/from16 v0, p0

    array-length v9, v0

    if-le v2, v9, :cond_28a

    :cond_99
    move-object/from16 v0, p0

    array-length v2, v0

    sub-int/2addr v2, v7

    move v10, v7

    .line 91
    :goto_9e
    const/4 v7, 0x1

    if-ne v6, v7, :cond_b1

    if-ltz v10, :cond_b1

    const/4 v6, 0x1

    if-lt v5, v6, :cond_b1

    const/4 v6, 0x2

    if-gt v5, v6, :cond_b1

    const/16 v6, 0x8

    if-eq v3, v6, :cond_bb

    const/16 v6, 0x10

    if-eq v3, v6, :cond_bb

    :cond_b1
    const/4 v2, 0x0

    goto :goto_44

    .line 89
    :cond_b3
    add-int v3, v7, v8

    and-int/lit8 v7, v8, 0x1

    add-int/2addr v7, v3

    move v3, v2

    .line 90
    goto/16 :goto_9

    .line 92
    :cond_bb
    const/16 v6, 0xfa0

    if-lt v4, v6, :cond_c3

    move/from16 v0, p1

    if-ne v4, v0, :cond_c5

    :cond_c3
    const/4 v2, 0x0

    goto :goto_44

    .line 94
    :cond_c5
    div-int/lit8 v9, v3, 0x8

    .line 95
    mul-int v6, v9, v5

    div-int v16, v2, v6

    .line 96
    const/4 v2, 0x2

    move/from16 v0, v16

    if-ge v0, v2, :cond_d3

    const/4 v2, 0x0

    goto/16 :goto_44

    .line 98
    :cond_d3
    move/from16 v0, v16

    filled-new-array {v5, v0}, [I

    move-result-object v2

    sget-object v6, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    invoke-static {v6, v2}, Ljava/lang/reflect/Array;->newInstance(Ljava/lang/Class;[I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, [[F

    .line 99
    const/4 v6, 0x0

    move v8, v6

    :goto_e3
    move/from16 v0, v16

    if-ge v8, v0, :cond_116

    .line 100
    const/4 v6, 0x0

    move v7, v6

    :goto_e9
    if-ge v7, v5, :cond_112

    .line 101
    mul-int v6, v8, v5

    add-int/2addr v6, v7

    mul-int/2addr v6, v9

    add-int/2addr v6, v10

    .line 102
    aget-object v11, v2, v7

    const/16 v12, 0x10

    if-ne v3, v12, :cond_107

    move-object/from16 v0, p0

    invoke-static {v0, v6}, Lfluddokt/opsu/fake/SampleRate;->le16([BI)I

    move-result v6

    int-to-short v6, v6

    int-to-float v6, v6

    const/high16 v12, 0x47000000    # 32768.0f

    div-float/2addr v6, v12

    :goto_101
    aput v6, v11, v8

    .line 100
    add-int/lit8 v6, v7, 0x1

    move v7, v6

    goto :goto_e9

    .line 102
    :cond_107
    aget-byte v6, p0, v6

    and-int/lit16 v6, v6, 0xff

    add-int/lit8 v6, v6, -0x80

    int-to-float v6, v6

    const/high16 v12, 0x43000000    # 128.0f

    div-float/2addr v6, v12

    goto :goto_101

    .line 99
    :cond_112
    add-int/lit8 v6, v8, 0x1

    move v8, v6

    goto :goto_e3

    .line 106
    :cond_116
    move/from16 v0, p1

    int-to-double v6, v0

    int-to-double v8, v4

    div-double/2addr v6, v8

    .line 107
    const-wide/16 v8, 0x1

    move/from16 v0, v16

    int-to-double v10, v0

    mul-double/2addr v10, v6

    invoke-static {v10, v11}, Ljava/lang/Math;->round(D)J

    move-result-wide v10

    invoke-static {v8, v9, v10, v11}, Ljava/lang/Math;->max(JJ)J

    move-result-wide v8

    long-to-int v0, v8

    move/from16 v17, v0

    .line 108
    const-wide/high16 v8, 0x3ff0000000000000L    # 1.0

    div-double v18, v8, v6

    .line 109
    const-wide/high16 v8, 0x3ff0000000000000L    # 1.0

    cmpg-double v3, v6, v8

    if-gez v3, :cond_19d

    .line 111
    :goto_136
    mul-int v3, v17, v5

    mul-int/lit8 v3, v3, 0x2

    add-int/lit8 v3, v3, 0x2c

    new-array v4, v3, [B

    .line 113
    const/4 v3, 0x0

    move v15, v3

    :goto_140
    move/from16 v0, v17

    if-ge v15, v0, :cond_1e9

    .line 114
    int-to-double v8, v15

    mul-double v20, v8, v18

    .line 115
    invoke-static/range {v20 .. v21}, Ljava/lang/Math;->floor(D)D

    move-result-wide v8

    double-to-int v0, v8

    move/from16 v22, v0

    .line 116
    const/4 v3, 0x0

    move v14, v3

    :goto_150
    if-ge v14, v5, :cond_1e4

    .line 117
    const-wide/16 v10, 0x0

    const-wide/16 v8, 0x0

    .line 118
    aget-object v23, v2, v14

    .line 119
    const/16 v3, -0xf

    move-wide v12, v8

    :goto_15b
    const/16 v8, 0x10

    if-gt v3, v8, :cond_1b6

    .line 120
    add-int v24, v22, v3

    .line 121
    move/from16 v0, v24

    int-to-double v8, v0

    sub-double v26, v20, v8

    .line 122
    const-wide/16 v8, 0x0

    cmpl-double v8, v26, v8

    if-nez v8, :cond_1a0

    move-wide v8, v6

    .line 123
    :goto_16d
    const-wide/high16 v28, 0x3fe0000000000000L    # 0.5

    const-wide/high16 v30, 0x3fe0000000000000L    # 0.5

    const-wide v32, 0x400921fb54442d18L    # Math.PI

    mul-double v26, v26, v32

    const-wide/high16 v32, 0x4030000000000000L    # 16.0

    div-double v26, v26, v32

    invoke-static/range {v26 .. v27}, Ljava/lang/Math;->cos(D)D

    move-result-wide v26

    mul-double v26, v26, v30

    add-double v26, v26, v28

    .line 124
    mul-double v8, v8, v26

    .line 125
    add-double/2addr v12, v8

    .line 126
    if-ltz v24, :cond_287

    move/from16 v0, v24

    move/from16 v1, v16

    if-ge v0, v1, :cond_287

    aget v24, v23, v24

    move/from16 v0, v24

    float-to-double v0, v0

    move-wide/from16 v24, v0

    mul-double v8, v8, v24

    add-double/2addr v8, v10

    .line 119
    :goto_199
    add-int/lit8 v3, v3, 0x1

    move-wide v10, v8

    goto :goto_15b

    .line 109
    :cond_19d
    const-wide/high16 v6, 0x3ff0000000000000L    # 1.0

    goto :goto_136

    .line 122
    :cond_1a0
    const-wide v8, 0x400921fb54442d18L    # Math.PI

    mul-double/2addr v8, v6

    mul-double v8, v8, v26

    invoke-static {v8, v9}, Ljava/lang/Math;->sin(D)D

    move-result-wide v8

    const-wide v28, 0x400921fb54442d18L    # Math.PI

    mul-double v28, v28, v26

    div-double v8, v8, v28

    goto :goto_16d

    .line 128
    :cond_1b6
    const-wide/16 v8, 0x0

    cmpl-double v3, v12, v8

    if-eqz v3, :cond_1bd

    div-double/2addr v10, v12

    .line 129
    :cond_1bd
    const-wide v8, 0x40dfffc000000000L    # 32767.0

    mul-double/2addr v8, v10

    invoke-static {v8, v9}, Ljava/lang/Math;->round(D)J

    move-result-wide v8

    long-to-int v3, v8

    .line 130
    const/16 v8, 0x7fff

    if-le v3, v8, :cond_1dd

    const/16 v3, 0x7fff

    .line 131
    :cond_1ce
    :goto_1ce
    mul-int v8, v15, v5

    add-int/2addr v8, v14

    mul-int/lit8 v8, v8, 0x2

    add-int/lit8 v8, v8, 0x2c

    invoke-static {v4, v8, v3}, Lfluddokt/opsu/fake/SampleRate;->put16([BII)V

    .line 116
    add-int/lit8 v3, v14, 0x1

    move v14, v3

    goto/16 :goto_150

    .line 130
    :cond_1dd
    const/16 v8, -0x8000

    if-ge v3, v8, :cond_1ce

    const/16 v3, -0x8000

    goto :goto_1ce

    .line 113
    :cond_1e4
    add-int/lit8 v3, v15, 0x1

    move v15, v3

    goto/16 :goto_140

    .line 135
    :cond_1e9
    mul-int v2, v17, v5

    mul-int/lit8 v2, v2, 0x2

    .line 136
    const/4 v3, 0x0

    const/16 v6, 0x52

    aput-byte v6, v4, v3

    const/4 v3, 0x1

    const/16 v6, 0x49

    aput-byte v6, v4, v3

    const/4 v3, 0x2

    const/16 v6, 0x46

    aput-byte v6, v4, v3

    const/4 v3, 0x3

    const/16 v6, 0x46

    aput-byte v6, v4, v3

    .line 137
    const/4 v3, 0x4

    add-int/lit8 v6, v2, 0x24

    invoke-static {v4, v3, v6}, Lfluddokt/opsu/fake/SampleRate;->put32([BII)V

    .line 138
    const/16 v3, 0x8

    const/16 v6, 0x57

    aput-byte v6, v4, v3

    const/16 v3, 0x9

    const/16 v6, 0x41

    aput-byte v6, v4, v3

    const/16 v3, 0xa

    const/16 v6, 0x56

    aput-byte v6, v4, v3

    const/16 v3, 0xb

    const/16 v6, 0x45

    aput-byte v6, v4, v3

    .line 139
    const/16 v3, 0xc

    const/16 v6, 0x66

    aput-byte v6, v4, v3

    const/16 v3, 0xd

    const/16 v6, 0x6d

    aput-byte v6, v4, v3

    const/16 v3, 0xe

    const/16 v6, 0x74

    aput-byte v6, v4, v3

    const/16 v3, 0xf

    const/16 v6, 0x20

    aput-byte v6, v4, v3

    .line 140
    const/16 v3, 0x10

    const/16 v6, 0x10

    invoke-static {v4, v3, v6}, Lfluddokt/opsu/fake/SampleRate;->put32([BII)V

    .line 141
    const/16 v3, 0x14

    const/4 v6, 0x1

    invoke-static {v4, v3, v6}, Lfluddokt/opsu/fake/SampleRate;->put16([BII)V

    .line 142
    const/16 v3, 0x16

    invoke-static {v4, v3, v5}, Lfluddokt/opsu/fake/SampleRate;->put16([BII)V

    .line 143
    const/16 v3, 0x18

    move/from16 v0, p1

    invoke-static {v4, v3, v0}, Lfluddokt/opsu/fake/SampleRate;->put32([BII)V

    .line 144
    const/16 v3, 0x1c

    mul-int v6, p1, v5

    mul-int/lit8 v6, v6, 0x2

    invoke-static {v4, v3, v6}, Lfluddokt/opsu/fake/SampleRate;->put32([BII)V

    .line 145
    const/16 v3, 0x20

    mul-int/lit8 v5, v5, 0x2

    invoke-static {v4, v3, v5}, Lfluddokt/opsu/fake/SampleRate;->put16([BII)V

    .line 146
    const/16 v3, 0x22

    const/16 v5, 0x10

    invoke-static {v4, v3, v5}, Lfluddokt/opsu/fake/SampleRate;->put16([BII)V

    .line 147
    const/16 v3, 0x24

    const/16 v5, 0x64

    aput-byte v5, v4, v3

    const/16 v3, 0x25

    const/16 v5, 0x61

    aput-byte v5, v4, v3

    const/16 v3, 0x26

    const/16 v5, 0x74

    aput-byte v5, v4, v3

    const/16 v3, 0x27

    const/16 v5, 0x61

    aput-byte v5, v4, v3

    .line 148
    const/16 v3, 0x28

    invoke-static {v4, v3, v2}, Lfluddokt/opsu/fake/SampleRate;->put32([BII)V

    move-object v2, v4

    .line 149
    goto/16 :goto_44

    :cond_287
    move-wide v8, v10

    goto/16 :goto_199

    :cond_28a
    move v2, v8

    move v10, v7

    goto/16 :goto_9e

    :cond_28e
    move v2, v3

    goto/16 :goto_7c

    :cond_291
    move v2, v9

    goto/16 :goto_9e
.end method

# opsu!revive (modification of Opsu-android, GPLv3) - see CHANGELOG.md
# Moves the hitsound SoundPool.play/stop/dispose calls from the render thread to the "OpsuHitSound" HandlerThread
.class public Lfluddokt/opsu/fake/AsyncSound;
.super Ljava/lang/Object;
.source "AsyncSound.java"

# interfaces
.implements Ljava/lang/Runnable;


# static fields
.field private static final handler:Landroid/os/Handler;


# instance fields
.field private final op:I

.field private final sound:Lcom/badlogic/gdx/audio/Sound;

.field private final volume:F


# direct methods
.method static constructor <clinit>()V
    .locals 3

    new-instance v0, Landroid/os/HandlerThread;

    const-string v1, "OpsuHitSound"

    const/16 v2, -0x10

    invoke-direct {v0, v1, v2}, Landroid/os/HandlerThread;-><init>(Ljava/lang/String;I)V

    invoke-virtual {v0}, Landroid/os/HandlerThread;->start()V

    new-instance v1, Landroid/os/Handler;

    invoke-virtual {v0}, Landroid/os/HandlerThread;->getLooper()Landroid/os/Looper;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    sput-object v1, Lfluddokt/opsu/fake/AsyncSound;->handler:Landroid/os/Handler;

    return-void
.end method

.method private constructor <init>(Lcom/badlogic/gdx/audio/Sound;FI)V
    .locals 0
    .param p1, "sound"    # Lcom/badlogic/gdx/audio/Sound;
    .param p2, "volume"    # F
    .param p3, "op"    # I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lfluddokt/opsu/fake/AsyncSound;->sound:Lcom/badlogic/gdx/audio/Sound;

    iput p2, p0, Lfluddokt/opsu/fake/AsyncSound;->volume:F

    iput p3, p0, Lfluddokt/opsu/fake/AsyncSound;->op:I

    return-void
.end method

.method private static post(Lcom/badlogic/gdx/audio/Sound;FI)V
    .locals 2

    new-instance v0, Lfluddokt/opsu/fake/AsyncSound;

    invoke-direct {v0, p0, p1, p2}, Lfluddokt/opsu/fake/AsyncSound;-><init>(Lcom/badlogic/gdx/audio/Sound;FI)V

    sget-object v1, Lfluddokt/opsu/fake/AsyncSound;->handler:Landroid/os/Handler;

    invoke-virtual {v1, v0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method

.method public static postDispose(Lcom/badlogic/gdx/audio/Sound;)V
    .locals 2

    const/4 v0, 0x0

    const/4 v1, 0x2

    invoke-static {p0, v0, v1}, Lfluddokt/opsu/fake/AsyncSound;->post(Lcom/badlogic/gdx/audio/Sound;FI)V

    return-void
.end method

.method public static postPlay(Lcom/badlogic/gdx/audio/Sound;F)V
    .locals 1

    const/4 v0, 0x0

    invoke-static {p0, p1, v0}, Lfluddokt/opsu/fake/AsyncSound;->post(Lcom/badlogic/gdx/audio/Sound;FI)V

    return-void
.end method

.method public static postStop(Lcom/badlogic/gdx/audio/Sound;)V
    .locals 2

    const/4 v0, 0x0

    const/4 v1, 0x1

    invoke-static {p0, v0, v1}, Lfluddokt/opsu/fake/AsyncSound;->post(Lcom/badlogic/gdx/audio/Sound;FI)V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    :try_start_0
    iget v0, p0, Lfluddokt/opsu/fake/AsyncSound;->op:I

    iget-object v1, p0, Lfluddokt/opsu/fake/AsyncSound;->sound:Lcom/badlogic/gdx/audio/Sound;

    if-nez v0, :cond_0

    iget v2, p0, Lfluddokt/opsu/fake/AsyncSound;->volume:F

    invoke-interface {v1, v2}, Lcom/badlogic/gdx/audio/Sound;->play(F)J

    goto :goto_0

    :cond_0
    const/4 v2, 0x1

    if-ne v0, v2, :cond_1

    invoke-interface {v1}, Lcom/badlogic/gdx/audio/Sound;->stop()V

    goto :goto_0

    :cond_1
    invoke-interface {v1}, Lcom/badlogic/gdx/audio/Sound;->dispose()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :goto_0
    return-void

    :catch_0
    move-exception v0

    goto :goto_0
.end method

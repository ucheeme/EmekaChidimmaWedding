# Web & PWA deployment (QR guest access)

Guests open **Forever Moments** in the browser by scanning a QR code at the wedding. No App Store or Play Store install is required. They can optionally **Add to Home Screen** for a full-screen app-like experience.

## How access works

1. You deploy the Flutter web build to **Firebase Hosting** (or any static host with SPA rewrites).
2. The QR code points to your hosted URL with a query flag, for example:
   ```
   https://YOUR-PROJECT.web.app/?from=qr
   ```
   Optional wedding id:
   ```
   https://YOUR-PROJECT.web.app/?from=qr&w=emeka-wedding-2026
   ```
3. On first visit with `from=qr`, the app stores a local flag and unlocks all routes.
4. Guests who open the site **without** scanning see a **“Scan the QR code”** screen (`/join`).
5. In **release** web builds, direct URL access is blocked until QR entry. For local testing:
   ```bash
   flutter run -d chrome --dart-define=ALLOW_DIRECT_WEB_ACCESS=true
   ```

## Build & deploy

```bash
cd forever_moments
flutter pub get
flutter build web --release --dart-define=FIREBASE_CONFIGURED=true
firebase deploy --only hosting
```

After `flutterfire configure`, ensure `lib/core/firebase/firebase_options.dart` exists.

## QR code for print

Generate a QR that encodes your **production** URL (include `?from=qr`):

| Item | Example |
|------|---------|
| Base URL | `https://emeka-wedding-2026.web.app` |
| Full launch URL | `https://emeka-wedding-2026.web.app/?from=qr` |

Use any QR generator; test on a phone before printing table cards.

## Add to Home Screen (PWA)

- **iPhone (Safari):** Share → **Add to Home Screen**
- **Android (Chrome):** Menu (⋮) → **Install app** or **Add to Home screen**

The home screen shows a short banner with these steps. `web/manifest.json` uses `display: standalone` and wedding theme colors.

## Configuration

| Dart define | Purpose |
|-------------|---------|
| `FIREBASE_CONFIGURED=true` | Enable Firebase (required for uploads/live gallery) |
| `ALLOW_DIRECT_WEB_ACCESS=true` | Skip QR gate on web (debug / staging) |

## Native apps (optional)

iOS/Android projects remain in the repo for future use. **Guest distribution** is intended via **web + QR**, not store listings.

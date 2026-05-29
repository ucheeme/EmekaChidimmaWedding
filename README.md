# Forever Moments

An immersive wedding memory app for guests — love story, gallery, capture & share, and live wall.

## Stack

- Flutter · BLoC · GoRouter · GetIt · Clean Architecture
- Firebase Auth (anonymous) · Firestore · Storage · Cloud Functions
- Lottie · Rive · Animated Text Kit

## Getting started

```bash
cd forever_moments
make setup          # or: flutter pub get
make help           # list all commands
```

Configure Firebase: see [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md).

```bash
flutter run --dart-define=FIREBASE_CONFIGURED=true
```

### Web / QR / PWA (guest access)

Guests use the **browser** — scan a QR code at the wedding; no app store install. Optional **Add to Home Screen** for quick access.

```bash
flutter run -d chrome --dart-define=FIREBASE_CONFIGURED=true
flutter build web --release --dart-define=FIREBASE_CONFIGURED=true
firebase deploy --only hosting
```

See [docs/WEB_PWA_DEPLOY.md](docs/WEB_PWA_DEPLOY.md) for QR URL format and deployment.

## Project structure

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Build stages

| Stage | Status |
|-------|--------|
| 1–3 Architecture, folders, dependencies | Done |
| 4 Firebase setup | Done |
| 5 UI implementation | Done |
| 6 BLoC setup | Done |
| 7 Animations | Planned |
| 8 Camera module | Done |
| 9 Upload logic | Done |
| 10 Polish | Done |
| Web / PWA + QR gate | Done |

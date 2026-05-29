# Firebase Setup — Forever Moments

## 1. Create Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Create project (e.g. `forever-moments-wedding`)
3. Enable:
   - **Authentication** → Anonymous
   - **Cloud Firestore**
   - **Cloud Storage**
   - **Cloud Functions** (Blaze plan required for external APIs)

## 2. Link Flutter app

```bash
dart pub global activate flutterfire_cli
cd forever_moments
flutterfire configure
```

This generates:

- `lib/core/firebase/firebase_options.dart` (overwrites placeholders)
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Update `.firebaserc` project id:

```json
{
  "projects": {
    "default": "YOUR_PROJECT_ID"
  }
}
```

## 3. Run the app

```bash
flutter run --dart-define=FIREBASE_CONFIGURED=true
```

### Emulators (optional)

```bash
npx -y firebase-tools@latest emulators:start
flutter run \
  --dart-define=FIREBASE_CONFIGURED=true \
  --dart-define=USE_FIREBASE_EMULATOR=true
```

## 4. Deploy rules & functions

```bash
npx -y firebase-tools@latest login
npx -y firebase-tools@latest use YOUR_PROJECT_ID
npx -y firebase-tools@latest deploy --only firestore:rules,storage:rules
```

### Cloud Function: Google Drive sync

1. Enable **Google Drive API** in Google Cloud Console (same project as Firebase).
2. Create a folder in Drive: `Wedding Day` and share it with your Functions service account  
   (`PROJECT_ID@appspot.gserviceaccount.com` or the default compute SA).
3. Copy the folder ID from the URL.
4. Set secret:

```bash
npx -y firebase-tools@latest functions:secrets:set GOOGLE_DRIVE_ROOT_FOLDER_ID
```

5. Deploy:

```bash
cd functions && npm install && cd ..
npx -y firebase-tools@latest deploy --only functions
```

When a document is created in `memories/`, the function downloads the media URL and uploads to Drive under `Photos/` or `Videos/`.

## 5. Firestore data model

### `memories` collection

| Field         | Type      | Required |
|---------------|-----------|----------|
| imageUrl      | string    | yes      |
| timestamp     | timestamp | yes      |
| mediaType     | string    | yes (`photo` \| `video`) |
| weddingId     | string    | yes      |
| guestName     | string    | no       |
| message       | string    | no       |
| tableNumber   | string    | no       |
| storagePath   | string    | no       |
| driveSyncStatus | string  | set by function |

### Storage layout

```
weddings/{weddingId}/memories/{memoryId}.jpg|mp4
```

## 6. Wedding config

Edit `lib/core/config/wedding_config.dart`:

- `brideName`
- `weddingId` (must match Firestore queries)

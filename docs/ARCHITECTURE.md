# Architecture — Forever Moments

## Layers

```
presentation/   → UI, BLoC/Cubit (Stage 5–6)
domain/         → entities, repositories (interfaces), use cases
data/           → Firebase datasources, models, repository implementations
core/           → config, DI, router, theme, errors, Firebase bootstrap
```

## Data flow (guest upload)

```
CaptureScreen → UploadMemoryCubit → UploadMemory use case
  → MemoryRepository → FirebaseMemoryDataSource
    → Storage (file) + Firestore (metadata)
      → Cloud Function → Google Drive
```

## Dependency injection

`GetIt` in `lib/core/di/injection.dart`. Registered after successful Firebase init.

## Routing

`GoRouter` in `lib/core/router/app_router.dart`.

## State management

`flutter_bloc` with feature cubits:

| Cubit | Responsibility |
|-------|----------------|
| `AuthCubit` | Anonymous guest session |
| `MemoriesCubit` | Real-time Firestore memory stream (shared app-wide) |
| `UploadMemoryCubit` | Photo/video upload lifecycle (per capture route) |
| `ConnectivityCubit` | App-wide online/offline status |
| `GuestMessageCubit` | Guest text messages to the couple |
| `CaptureCubit` | Camera capture flow state |

Registered via `GetIt` + `AppBlocProviders` at app root.

## Offline & performance

- `ConnectivityService` + top `OfflineBanner` when offline
- Firestore persistence enabled for cached reads
- Gallery images use width-aware `memCacheWidth` for memory efficiency

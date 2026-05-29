import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../core/services/connectivity_service.dart';
import '../../core/services/media_capture_service.dart';
import '../../core/services/qr_entry_service.dart';
import '../../data/datasources/firebase/firebase_auth_datasource.dart';
import '../../data/datasources/firebase/firebase_guest_message_datasource.dart';
import '../../data/datasources/firebase/firebase_memory_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/guest_message_repository_impl.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/guest_message_repository.dart';
import '../../domain/repositories/memory_repository.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/submit_guest_message.dart';
import '../../domain/usecases/upload_memory.dart';
import '../../domain/usecases/watch_memories.dart';
import '../../presentation/cubit/auth/auth_cubit.dart';
import '../../presentation/cubit/capture/capture_cubit.dart';
import '../../presentation/cubit/connectivity/connectivity_cubit.dart';
import '../../presentation/cubit/guest_message/guest_message_cubit.dart';
import '../../presentation/cubit/memories/memories_cubit.dart';
import '../../presentation/cubit/upload/upload_memory_cubit.dart';

final GetIt sl = GetIt.instance;

/// Registers all dependencies. Call after [FirebaseBootstrap.initialize].
Future<void> configureDependencies({required bool firebaseReady}) async {
  if (sl.isRegistered<MemoriesCubit>()) {
    return;
  }

  sl
    ..registerLazySingleton<QrEntryService>(QrEntryService.new)
    ..registerLazySingleton<MediaCaptureService>(MediaCaptureService.new)
    ..registerLazySingleton<ConnectivityService>(ConnectivityService.new)
    ..registerLazySingleton<ConnectivityCubit>(
      () => ConnectivityCubit(sl<ConnectivityService>()),
    );

  if (firebaseReady) {
    sl
      ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
      ..registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
      )
      ..registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance)
      ..registerLazySingleton<FirebaseAuthDataSource>(
        () => FirebaseAuthDataSource(sl()),
      )
      ..registerLazySingleton<FirebaseMemoryDataSource>(
        () => FirebaseMemoryDataSource(
          firestore: sl(),
          storage: sl(),
        ),
      )
      ..registerLazySingleton<FirebaseGuestMessageDataSource>(
        () => FirebaseGuestMessageDataSource(firestore: sl()),
      )
      ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl()),
      )
      ..registerLazySingleton<MemoryRepository>(
        () => MemoryRepositoryImpl(sl()),
      )
      ..registerLazySingleton<GuestMessageRepository>(
        () => GuestMessageRepositoryImpl(sl()),
      )
      ..registerLazySingleton(() => SignInAnonymously(sl()))
      ..registerLazySingleton(() => UploadMemory(sl()))
      ..registerLazySingleton(() => WatchMemories(sl()))
      ..registerLazySingleton(() => SubmitGuestMessage(sl()))
      ..registerLazySingleton<AuthCubit>(
        () => AuthCubit(
          authRepository: sl(),
          signInAnonymously: sl(),
        ),
      )
      ..registerFactory<UploadMemoryCubit>(
        () => UploadMemoryCubit(
          sl(),
          connectivity: sl<ConnectivityService>(),
        ),
      )
      ..registerFactory<GuestMessageCubit>(
        () => GuestMessageCubit(
          submitGuestMessage: sl(),
          connectivity: sl<ConnectivityService>(),
        ),
      );
  } else {
    sl
      ..registerFactory<UploadMemoryCubit>(
        () => UploadMemoryCubit(
          null,
          connectivity: sl<ConnectivityService>(),
        ),
      )
      ..registerFactory<GuestMessageCubit>(
        () => GuestMessageCubit(
          connectivity: sl<ConnectivityService>(),
        ),
      );
  }

  sl.registerFactory<CaptureCubit>(
    () => CaptureCubit(sl<MediaCaptureService>()),
  );

  sl.registerLazySingleton<MemoriesCubit>(
    () => MemoriesCubit(
      watchMemories: firebaseReady ? sl<WatchMemories>() : null,
    ),
  );
}

void resetDependencies() {
  if (sl.isRegistered<MemoriesCubit>()) {
    sl.reset();
  }
}

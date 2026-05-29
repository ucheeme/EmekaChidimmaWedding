import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';
import '../utils/app_logger.dart';
import 'firebase_options.dart';

/// Result of Firebase initialization and anonymous sign-in.
class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({
    required this.initialized,
    this.userId,
    this.errorMessage,
  });

  final bool initialized;
  final String? userId;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
}

/// Initializes Firebase, connects emulators when enabled, and signs in anonymously.
class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<FirebaseBootstrapResult> initialize() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      AppLogger.warning(
        'Firebase not configured. Run flutterfire configure and pass '
        '--dart-define=FIREBASE_CONFIGURED=true',
        tag: 'Firebase',
      );
      return const FirebaseBootstrapResult(
        initialized: false,
        errorMessage:
            'Firebase is not configured yet. See docs/FIREBASE_SETUP.md',
      );
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (AppConfig.useFirebaseEmulator) {
        await _connectEmulators();
      } else {
        await _configureFirestoreCache();
      }

      final user = await _ensureAnonymousUser();

      AppLogger.info('Firebase ready (uid: ${user.uid})', tag: 'Firebase');

      return FirebaseBootstrapResult(
        initialized: true,
        userId: user.uid,
      );
    } on FirebaseException catch (e, stack) {
      AppLogger.error(
        'Firebase initialization failed',
        tag: 'Firebase',
        error: e,
        stackTrace: stack,
      );
      return FirebaseBootstrapResult(
        initialized: false,
        errorMessage: _mapFirebaseErrorMessage(e),
      );
    } catch (e, stack) {
      AppLogger.error(
        'Unexpected Firebase error',
        tag: 'Firebase',
        error: e,
        stackTrace: stack,
      );
      return FirebaseBootstrapResult(
        initialized: false,
        errorMessage: 'Unable to connect to wedding services.',
      );
    }
  }

  static Future<void> _configureFirestoreCache() async {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } on FirebaseException catch (e, stack) {
      // Do not block app startup if browser/runtime cannot enable persistence.
      AppLogger.warning(
        'Firestore offline cache unavailable (${e.code}). Continuing online-only.',
        tag: 'Firebase',
      );
      AppLogger.error(
        'Firestore cache configuration failed',
        tag: 'Firebase',
        error: e,
        stackTrace: stack,
      );
    }
  }

  static Future<void> _connectEmulators() async {
    const host = 'localhost';
    AppLogger.info('Connecting to Firebase emulators', tag: 'Firebase');

    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  }

  static Future<User> _ensureAnonymousUser() async {
    final auth = FirebaseAuth.instance;
    final existing = auth.currentUser;
    if (existing != null) {
      return existing;
    }
    final credential = await auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw const AuthException('Anonymous sign-in returned no user.');
    }
    return user;
  }

  static String _mapFirebaseErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'operation-not-allowed':
      case 'admin-restricted-operation':
        return 'Anonymous sign-in is not enabled for this Firebase project yet.';
      case 'invalid-api-key':
      case 'app-not-authorized':
        return 'Firebase web credentials are invalid for this deployment.';
      case 'permission-denied':
        return 'Firebase permissions are not configured correctly yet.';
      case 'unavailable':
      case 'network-request-failed':
        return 'Unable to reach Firebase right now. Check your connection and retry.';
      default:
        return 'Unable to connect to wedding services.';
    }
  }
}

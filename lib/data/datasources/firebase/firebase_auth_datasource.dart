import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/exceptions.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  Future<String> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final uid = credential.user?.uid;
      if (uid == null) {
        throw const AuthException('Anonymous sign-in failed.');
      }
      return uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed.', e.code);
    }
  }

  String? getCurrentUserId() => _auth.currentUser?.uid;
}

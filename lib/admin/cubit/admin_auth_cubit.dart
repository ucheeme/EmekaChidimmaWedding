import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/utils/app_logger.dart';

enum AdminAuthStatus { unknown, signedOut, authenticating, authenticated, error }

class AdminAuthState extends Equatable {
  const AdminAuthState({
    this.status = AdminAuthStatus.unknown,
    this.email,
    this.message,
  });

  final AdminAuthStatus status;
  final String? email;
  final String? message;

  bool get isAuthenticated => status == AdminAuthStatus.authenticated;
  bool get isBusy => status == AdminAuthStatus.authenticating;

  AdminAuthState copyWith({
    AdminAuthStatus? status,
    String? email,
    String? message,
  }) {
    return AdminAuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, email, message];
}

/// Email/password authentication for admins, gated by an `admins/{uid}` doc.
class AdminAuthCubit extends Cubit<AdminAuthState> {
  AdminAuthCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const AdminAuthState());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const _tag = 'AdminAuth';

  Future<void> checkExistingSession() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(const AdminAuthState(status: AdminAuthStatus.signedOut));
      return;
    }
    final isAdmin = await _verifyAdmin(user.uid);
    if (isAdmin) {
      emit(AdminAuthState(
        status: AdminAuthStatus.authenticated,
        email: user.email,
      ));
    } else {
      await _auth.signOut();
      emit(const AdminAuthState(status: AdminAuthStatus.signedOut));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AdminAuthState(status: AdminAuthStatus.authenticating));
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        emit(const AdminAuthState(
          status: AdminAuthStatus.error,
          message: 'Sign-in failed. Please try again.',
        ));
        return;
      }
      final isAdmin = await _verifyAdmin(user.uid);
      if (!isAdmin) {
        await _auth.signOut();
        emit(const AdminAuthState(
          status: AdminAuthStatus.error,
          message: 'This account is not authorized for admin access.',
        ));
        return;
      }
      emit(AdminAuthState(
        status: AdminAuthStatus.authenticated,
        email: user.email,
      ));
    } on FirebaseAuthException catch (e) {
      emit(AdminAuthState(
        status: AdminAuthStatus.error,
        message: _mapAuthError(e),
      ));
    } catch (e, stack) {
      AppLogger.error('Admin sign-in error', tag: _tag, error: e, stackTrace: stack);
      emit(const AdminAuthState(
        status: AdminAuthStatus.error,
        message: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } finally {
      emit(const AdminAuthState(status: AdminAuthStatus.signedOut));
    }
  }

  Future<bool> _verifyAdmin(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.admins)
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e, stack) {
      AppLogger.error('Admin verification failed', tag: _tag, error: e, stackTrace: stack);
      return false;
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this project yet.';
      default:
        return 'Unable to sign in right now. Please try again.';
    }
  }
}

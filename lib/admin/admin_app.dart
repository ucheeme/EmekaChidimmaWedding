import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../data/datasources/firebase/firebase_guest_message_datasource.dart';
import '../data/datasources/firebase/firebase_memory_datasource.dart';
import 'cubit/admin_auth_cubit.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_shell_screen.dart';
import 'screens/admin_unavailable_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key, required this.firebaseReady, this.initError});

  final bool firebaseReady;
  final String? initError;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Forever Moments · Admin',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: firebaseReady
          ? const _AdminGate()
          : AdminUnavailableScreen(message: initError),
    );

    if (!firebaseReady) {
      return app;
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseMemoryDataSource>(
          create: (_) => FirebaseMemoryDataSource(
            firestore: FirebaseFirestore.instance,
            storage: FirebaseStorage.instance,
          ),
        ),
        RepositoryProvider<FirebaseGuestMessageDataSource>(
          create: (_) => FirebaseGuestMessageDataSource(
            firestore: FirebaseFirestore.instance,
          ),
        ),
      ],
      child: BlocProvider<AdminAuthCubit>(
        create: (_) => AdminAuthCubit()..checkExistingSession(),
        child: app,
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.noir,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.roseGold,
        secondary: AppColors.mint,
        surface: Color(0xFF1A130C),
        error: AppColors.wine,
      ),
      textTheme: GoogleFonts.latoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.ivory,
        displayColor: AppColors.ivory,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.noir,
        foregroundColor: AppColors.ivory,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.roseGold,
          foregroundColor: AppColors.noir,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A130C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2118)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.roseGold),
        ),
        labelStyle: const TextStyle(color: AppColors.champagne),
        prefixIconColor: AppColors.roseGold,
      ),
    );
  }
}

class _AdminGate extends StatelessWidget {
  const _AdminGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminAuthCubit, AdminAuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AdminAuthStatus.unknown:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.roseGold),
              ),
            );
          case AdminAuthStatus.authenticated:
            return const AdminShellScreen();
          case AdminAuthStatus.signedOut:
          case AdminAuthStatus.authenticating:
          case AdminAuthStatus.error:
            return const AdminLoginScreen();
        }
      },
    );
  }
}

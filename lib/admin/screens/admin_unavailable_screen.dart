import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Shown when Firebase could not be initialized for the admin app.
class AdminUnavailableScreen extends StatelessWidget {
  const AdminUnavailableScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientProgram),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off,
                      size: 56, color: AppColors.champagne),
                  const SizedBox(height: 20),
                  Text(
                    message ?? 'Admin services are unavailable right now.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.ivory,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../cubit/connectivity/connectivity_cubit.dart';
import '../cubit/connectivity/connectivity_state.dart';

/// Subtle banner shown when the device has no network connection.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      buildWhen: (prev, curr) => prev.isOnline != curr.isOnline,
      builder: (context, state) {
        if (state.isOnline) {
          return const SizedBox.shrink();
        }

        return Material(
          color: AppColors.deepWine,
          elevation: 2,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You\'re offline — uploads will resume when connected.',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

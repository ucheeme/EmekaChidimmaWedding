import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/memory_upload.dart';
import '../../../domain/enums/media_type.dart';
import '../../cubit/capture/capture_cubit.dart';
import '../../cubit/capture/capture_state.dart';
import '../../cubit/connectivity/connectivity_cubit.dart';
import '../../cubit/upload/upload_memory_cubit.dart';
import '../../cubit/upload/upload_memory_state.dart';
import '../../widgets/nav_buttons.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/romantic_background.dart';
import 'widgets/capture_details_form.dart';
import 'widgets/media_preview.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, this.initialMediaType});

  final MediaType? initialMediaType;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  @override
  void initState() {
    super.initState();
    final type = widget.initialMediaType;
    // On web (notably iOS Safari/PWA) the camera can only be opened from a
    // direct user tap, not a post-frame callback — so we present the idle view
    // with the capture buttons instead of auto-launching. On native platforms
    // we keep the smooth auto-launch behaviour.
    if (type != null && !kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final cubit = context.read<CaptureCubit>();
        if (type == MediaType.photo) {
          cubit.capturePhoto();
        } else {
          cubit.captureVideo();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UploadMemoryCubit, UploadMemoryState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == UploadMemoryStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memory shared successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<CaptureCubit>().reset();
              context.read<UploadMemoryCubit>().reset();
              context.pop();
            }
            if (state.status == UploadMemoryStatus.failure &&
                state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
        BlocListener<CaptureCubit, CaptureState>(
          listenWhen: (prev, curr) =>
              prev.step == CaptureStep.capturing &&
              curr.step == CaptureStep.idle &&
              !curr.hasCapture,
          listener: (context, state) {
            if (widget.initialMediaType != null && !state.hasCapture) {
              context.pop();
            }
          },
        ),
      ],
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            tooltip: 'Back',
            onPressed: () {
              context.read<CaptureCubit>().reset();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.home);
              }
            },
          ),
          title: const Text('Capture Moment'),
          actions: const [AppNavActions()],
        ),
        body: RomanticBackground(
          child: SafeArea(
            child: BlocBuilder<UploadMemoryCubit, UploadMemoryState>(
              builder: (context, uploadState) {
                return BlocBuilder<CaptureCubit, CaptureState>(
                  builder: (context, captureState) {
                    if (uploadState.isUploading) {
                      return _UploadingView(progress: uploadState.progress);
                    }

                    return switch (captureState.step) {
                      CaptureStep.idle => _IdleView(
                          errorMessage: captureState.errorMessage,
                        ),
                      CaptureStep.capturing => const _CapturingView(),
                      CaptureStep.preview => _PreviewView(state: captureState),
                      CaptureStep.details => _DetailsView(
                          state: captureState,
                          onShare: () => _submitUpload(context, captureState),
                        ),
                    };
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _submitUpload(BuildContext context, CaptureState state) {
    final file = state.capturedFile;
    final type = state.mediaType;
    if (file == null || type == null) return;

    final connectivity = context.read<ConnectivityCubit>().state;
    if (!connectivity.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You\'re offline. Connect to upload your memory.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final upload = MemoryUpload(
      mediaFile: file,
      mediaType: type,
      guestName: state.guestName.isEmpty ? null : state.guestName,
      message: state.message.isEmpty ? null : state.message,
      tableNumber: state.tableNumber.isEmpty ? null : state.tableNumber,
    );

    context.read<UploadMemoryCubit>().upload(upload);
  }
}

class _UploadingView extends StatelessWidget {
  const _UploadingView({this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                color: AppColors.deepWine,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sharing your moment…',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                color: AppColors.deepWine,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a moment on slower connections.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: AppColors.deepWine.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapturingView extends StatelessWidget {
  const _CapturingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Opening camera…',
            style: GoogleFonts.lato(color: AppColors.deepWine),
          ),
        ],
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.deepWine.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                errorMessage!,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.deepWine,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 72,
                    color: AppColors.deepWine.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Share a moment',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      color: AppColors.deepWine,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PremiumButton(
            label: 'Take Picture',
            icon: Icons.photo_camera_outlined,
            onPressed: () => context.read<CaptureCubit>().capturePhoto(),
          ),
          const SizedBox(height: 12),
          PremiumButton(
            label: 'Record Video (30s)',
            icon: Icons.videocam_outlined,
            outlined: true,
            onPressed: () => context.read<CaptureCubit>().captureVideo(),
          ),
        ],
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({required this.state});

  final CaptureState state;

  @override
  Widget build(BuildContext context) {
    final file = state.capturedFile!;
    final type = state.mediaType!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Expanded(
            child: MediaPreview(file: file, mediaType: type),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<CaptureCubit>().retake(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepWine,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => context.read<CaptureCubit>().goToDetails(),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView({
    required this.state,
    required this.onShare,
  });

  final CaptureState state;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CaptureCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: MediaPreview(
              file: state.capturedFile!,
              mediaType: state.mediaType!,
            ),
          ),
          const SizedBox(height: 16),
          CaptureDetailsForm(
            guestName: state.guestName,
            message: state.message,
            tableNumber: state.tableNumber,
            onGuestNameChanged: cubit.updateGuestName,
            onMessageChanged: cubit.updateMessage,
            onTableNumberChanged: cubit.updateTableNumber,
          ),
          const SizedBox(height: 20),
          PremiumButton(
            label: 'Share Memory',
            icon: Icons.cloud_upload_outlined,
            onPressed: onShare,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: cubit.backToPreview,
            child: const Text('Back to preview'),
          ),
        ],
      ),
    );
  }
}

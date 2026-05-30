import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubit/guest_message/guest_message_cubit.dart';
import '../../cubit/guest_message/guest_message_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nav_buttons.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/romantic_background.dart';

class GuestMessageScreen extends StatefulWidget {
  const GuestMessageScreen({super.key});

  @override
  State<GuestMessageScreen> createState() => _GuestMessageScreenState();
}

class _GuestMessageScreenState extends State<GuestMessageScreen> {
  final _textController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestMessageCubit, GuestMessageState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == GuestMessageStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your message was shared with the couple!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
        if (state.status == GuestMessageStatus.failure && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Leave a Message'),
          actions: const [AppNavActions()],
        ),
        body: RomanticBackground(
          showPetals: true,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Share your wishes',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepWine,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send a heartfelt note to ${WeddingConfig.coupleDisplayName}.',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.deepWine.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: GoogleFonts.lato(color: AppColors.deepWine),
                            decoration: _decoration(
                              label: 'Your name (optional)',
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _textController,
                            maxLines: 6,
                            maxLength: 500,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please write a message';
                              }
                              return null;
                            },
                            style: GoogleFonts.lato(color: AppColors.deepWine),
                            decoration: _decoration(
                              label: 'Your message',
                              icon: Icons.favorite_border,
                              alignLabel: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<GuestMessageCubit, GuestMessageState>(
                      builder: (context, state) {
                        return PremiumButton(
                          label: state.isSubmitting
                              ? 'Sending…'
                              : 'Send Message',
                          icon: Icons.send_rounded,
                          onPressed: state.isSubmitting ? () {} : _submit,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    bool alignLabel = false,
  }) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: alignLabel,
      prefixIcon: Icon(icon, color: AppColors.deepWine, size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<GuestMessageCubit>().submit(
          text: _textController.text,
          guestName: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
        );
  }
}

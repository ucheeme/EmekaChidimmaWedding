import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class CaptureDetailsForm extends StatelessWidget {
  const CaptureDetailsForm({
    super.key,
    required this.guestName,
    required this.message,
    required this.tableNumber,
    required this.onGuestNameChanged,
    required this.onMessageChanged,
    required this.onTableNumberChanged,
  });

  final String guestName;
  final String message;
  final String tableNumber;
  final ValueChanged<String> onGuestNameChanged;
  final ValueChanged<String> onMessageChanged;
  final ValueChanged<String> onTableNumberChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Optional details',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.deepWine,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Help us remember who shared this moment.',
            style: GoogleFonts.lato(
              fontSize: 12,
              color: AppColors.deepWine.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 16),
          _Field(
            label: 'Your name',
            hint: 'e.g. Sarah',
            value: guestName,
            onChanged: onGuestNameChanged,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Message',
            hint: 'A note for the couple',
            value: message,
            onChanged: onMessageChanged,
            icon: Icons.favorite_border,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Table number',
            hint: 'e.g. 7',
            value: tableNumber,
            onChanged: onTableNumberChanged,
            icon: Icons.table_bar_outlined,
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.roseGold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.lato(color: AppColors.deepWine),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.deepWine),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

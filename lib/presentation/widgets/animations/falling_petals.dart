import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Gentle falling petal animation.
class FallingPetals extends StatefulWidget {
  const FallingPetals({super.key, this.count = 18});

  final int count;

  @override
  State<FallingPetals> createState() => _FallingPetalsState();
}

class _FallingPetalsState extends State<FallingPetals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Petal> _petals;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _petals = List.generate(widget.count, (i) {
      return _Petal(
        x: _random.nextDouble(),
        delay: _random.nextDouble(),
        size: 6 + _random.nextDouble() * 10,
        rotation: _random.nextDouble() * pi,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _PetalsPainter(
            petals: _petals,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Petal {
  const _Petal({
    required this.x,
    required this.delay,
    required this.size,
    required this.rotation,
  });

  final double x;
  final double delay;
  final double size;
  final double rotation;
}

class _PetalsPainter extends CustomPainter {
  _PetalsPainter({required this.petals, required this.progress});

  final List<_Petal> petals;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < petals.length; i++) {
      final p = petals[i];
      final t = (progress + p.delay) % 1.0;
      final y = t * size.height * 1.2 - size.height * 0.1;
      final x = p.x * size.width + sin(t * pi * 4) * 20;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * pi * 2);

      final accent = i.isEven ? AppColors.olive : AppColors.roseGold;
      final paint = Paint()..color = accent.withValues(alpha: 0.28);

      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

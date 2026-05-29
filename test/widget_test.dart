import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forever_moments/core/config/wedding_config.dart';
import 'package:forever_moments/core/content/wedding_content.dart';
import 'package:forever_moments/presentation/widgets/glass_card.dart';

void main() {
  test('Wedding config has couple names', () {
    expect(WeddingConfig.groomName, 'Emeka');
    expect(WeddingConfig.coupleDisplayName, contains('Emeka'));
    expect(WeddingContent.loveStoryChapters.length, 4);
    expect(WeddingContent.loveNotes.length, greaterThanOrEqualTo(3));
  });

  testWidgets('GlassCard renders child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            child: Text('Forever Moments'),
          ),
        ),
      ),
    );

    expect(find.text('Forever Moments'), findsOneWidget);
  });
}

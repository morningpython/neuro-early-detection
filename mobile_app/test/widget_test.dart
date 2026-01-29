// NeuroAccess Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const NeuroAccessApp());
    await tester.pumpAndSettle();

    // Verify splash screen appears
    expect(find.text('NeuroAccess'), findsOneWidget);
  });
}

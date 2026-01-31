// NeuroAccess Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:neuro_access/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LocaleProvider can be created', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final locale = context.watch<LocaleProvider>().locale;
              return Scaffold(
                body: Center(
                  child: Text('Locale: ${locale.languageCode}'),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Locale: en'), findsOneWidget);
  });

  testWidgets('MaterialApp renders correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('NeuroAccess Test')),
          body: const Center(child: Text('Test Content')),
        ),
      ),
    );

    expect(find.text('NeuroAccess Test'), findsOneWidget);
    expect(find.text('Test Content'), findsOneWidget);
  });
}

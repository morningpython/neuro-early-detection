import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neuro_access/app.dart';
import 'package:neuro_access/providers/locale_provider.dart';
import 'package:neuro_access/services/encryption_service.dart';
import 'package:neuro_access/services/ml_inference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize LocaleProvider
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();
  
  // Initialize Encryption Service (must be before any encrypted data access)
  try {
    await EncryptionService().initialize();
    debugPrint('✓ Encryption service initialized');
  } catch (e) {
    debugPrint('✗ Encryption service initialization failed: $e');
  }
  
  // Initialize ML model (async, non-blocking)
  MLInferenceService().initialize().then((_) {
    debugPrint('✓ ML Model initialized');
  }).catchError((e) {
    debugPrint('✗ ML Model initialization failed: $e');
  });
  
  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: const NeuroAccessApp(),
    ),
  );
}

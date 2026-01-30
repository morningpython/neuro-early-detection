import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/app_settings.dart';
import 'package:neuro_access/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsProvider', () {
    late SettingsProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = SettingsProvider();
    });

    test('should initialize with default settings', () async {
      await provider.initialize();
      
      expect(provider.isLoading, false);
      expect(provider.settings.languageCode, 'en');
      expect(provider.settings.themeMode, AppThemeMode.system);
      expect(provider.settings.enableNotifications, true);
    });

    test('should update settings and persist', () async {
      await provider.initialize();
      
      final newSettings = provider.settings.copyWith(
        languageCode: 'sw',
        themeMode: AppThemeMode.light,
      );
      
      await provider.updateSettings(newSettings);
      
      expect(provider.settings.languageCode, 'sw');
      expect(provider.settings.themeMode, AppThemeMode.light);
    });

    test('should set language', () async {
      await provider.initialize();
      await provider.setLanguage('sw');
      
      expect(provider.settings.languageCode, 'sw');
    });

    test('should set theme mode', () async {
      await provider.initialize();
      await provider.setThemeMode(AppThemeMode.dark);
      
      expect(provider.settings.themeMode, AppThemeMode.dark);
    });

    test('should set notifications enabled', () async {
      await provider.initialize();
      await provider.setNotifications(false);
      
      expect(provider.settings.enableNotifications, false);
    });

    test('should set sync frequency', () async {
      await provider.initialize();
      await provider.setSyncFrequency(SyncFrequency.manual);
      
      expect(provider.settings.syncFrequency, SyncFrequency.manual);
    });

    test('should set audio quality', () async {
      await provider.initialize();
      await provider.setAudioQuality(AudioQuality.low);
      
      expect(provider.settings.audioQuality, AudioQuality.low);
    });

    test('should set recording duration', () async {
      await provider.initialize();
      await provider.setRecordingDuration(60);
      
      expect(provider.settings.recordingDuration, 60);
    });

    test('should set require pin on resume', () async {
      await provider.initialize();
      await provider.setRequirePinOnResume(true);
      
      expect(provider.settings.requirePinOnResume, true);
    });

    test('should set enable biometric', () async {
      await provider.initialize();
      await provider.setEnableBiometric(true);
      
      expect(provider.settings.enableBiometric, true);
    });

    test('should set encrypt local data', () async {
      await provider.initialize();
      await provider.setEncryptLocalData(false);
      
      expect(provider.settings.encryptLocalData, false);
    });

    test('should set auto delete days', () async {
      await provider.initialize();
      await provider.setAutoDeleteDays(60);
      
      expect(provider.settings.autoDeleteDays, 60);
    });

    test('should reset to defaults', () async {
      await provider.initialize();
      await provider.setLanguage('sw');
      await provider.setThemeMode(AppThemeMode.dark);
      
      expect(provider.settings.languageCode, 'sw');
      
      await provider.resetToDefaults();
      
      expect(provider.settings.languageCode, 'en');
      expect(provider.settings.themeMode, AppThemeMode.system);
      expect(provider.settings.enableNotifications, true);
    });

    test('should provide storage info', () async {
      await provider.initialize();
      
      final storageInfo = provider.storageInfo;
      
      expect(storageInfo, isNotNull);
      expect(storageInfo.totalBytes, greaterThanOrEqualTo(0));
      expect(storageInfo.usedBytes, greaterThanOrEqualTo(0));
    });

    test('should notify listeners on settings change', () async {
      await provider.initialize();
      
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      
      await provider.setLanguage('sw');
      await provider.setThemeMode(AppThemeMode.dark);
      
      expect(notifyCount, 2);
    });

    test('should handle clear cache', () async {
      await provider.initialize();
      
      // Should complete without error
      await expectLater(provider.clearCache(), completes);
    });

    test('should handle clear all data', () async {
      await provider.initialize();
      
      // Should complete without error
      await expectLater(provider.clearAllData(), completes);
    });

    test('should provide quick accessors', () async {
      await provider.initialize();
      
      expect(provider.languageCode, provider.settings.languageCode);
      expect(provider.themeMode, provider.settings.themeMode);
      expect(provider.enableNotifications, provider.settings.enableNotifications);
      expect(provider.audioQuality, provider.settings.audioQuality);
      expect(provider.recordingDuration, provider.settings.recordingDuration);
    });
  });
}

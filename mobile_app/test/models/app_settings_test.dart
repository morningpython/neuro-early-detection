import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('should create with default values', () {
      final settings = AppSettings();
      
      expect(settings.languageCode, 'en');
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.enableNotifications, true);
      expect(settings.syncFrequency, SyncFrequency.daily);
      expect(settings.syncOnWifiOnly, true);
      expect(settings.audioQuality, AudioQuality.medium);
      expect(settings.recordingDuration, 30);
      expect(settings.requirePinOnResume, false);
      expect(settings.enableBiometric, false);
      expect(settings.encryptLocalData, true);
      expect(settings.autoDeleteDays, 30);
    });

    test('should create from map', () {
      final map = {
        'language_code': 'sw',
        'theme_mode': 'dark',
        'enable_notifications': false,
        'sync_frequency': 24, // daily
        'sync_on_wifi_only': false,
        'auto_upload': false,
        'audio_quality': 16000, // low
        'recording_duration': 45,
        'require_pin_on_resume': true,
        'pin_timeout': 10,
        'enable_biometric': true,
        'encrypt_local_data': false,
        'auto_delete_days': 60,
      };
      
      final settings = AppSettings.fromMap(map);
      
      expect(settings.languageCode, 'sw');
      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.enableNotifications, false);
      expect(settings.syncFrequency, SyncFrequency.daily);
      expect(settings.syncOnWifiOnly, false);
      expect(settings.audioQuality, AudioQuality.low);
      expect(settings.recordingDuration, 45);
      expect(settings.requirePinOnResume, true);
      expect(settings.pinTimeout, 10);
      expect(settings.enableBiometric, true);
      expect(settings.encryptLocalData, false);
      expect(settings.autoDeleteDays, 60);
    });

    test('should convert to map', () {
      final settings = AppSettings(
        languageCode: 'sw',
        themeMode: AppThemeMode.light,
        enableNotifications: false,
        syncFrequency: SyncFrequency.manual,
        audioQuality: AudioQuality.high,
        recordingDuration: 20,
        autoDeleteDays: 14,
      );
      
      final map = settings.toMap();
      
      expect(map['language_code'], 'sw');
      expect(map['theme_mode'], 'light');
      expect(map['enable_notifications'], false);
      expect(map['sync_frequency'], 0); // manual
      expect(map['audio_quality'], 44100); // high
      expect(map['recording_duration'], 20);
      expect(map['auto_delete_days'], 14);
    });

    test('should create copy with updated values', () {
      final original = AppSettings();
      final updated = original.copyWith(
        languageCode: 'sw',
        themeMode: AppThemeMode.dark,
        enableNotifications: false,
      );
      
      // Original unchanged
      expect(original.languageCode, 'en');
      expect(original.themeMode, AppThemeMode.system);
      expect(original.enableNotifications, true);
      
      // Updated values
      expect(updated.languageCode, 'sw');
      expect(updated.themeMode, AppThemeMode.dark);
      expect(updated.enableNotifications, false);
      
      // Other values preserved
      expect(updated.syncFrequency, original.syncFrequency);
      expect(updated.audioQuality, original.audioQuality);
    });
  });

  group('AppThemeMode', () {
    test('should have correct labels', () {
      expect(AppThemeMode.system.label, '시스템 설정');
      expect(AppThemeMode.light.label, '라이트 모드');
      expect(AppThemeMode.dark.label, '다크 모드');
    });

    test('should have correct values', () {
      expect(AppThemeMode.system.value, 'system');
      expect(AppThemeMode.light.value, 'light');
      expect(AppThemeMode.dark.value, 'dark');
    });
  });

  group('SyncFrequency', () {
    test('should have correct labels', () {
      expect(SyncFrequency.manual.label, '수동');
      expect(SyncFrequency.hourly.label, '매시간');
      expect(SyncFrequency.daily.label, '매일');
      expect(SyncFrequency.weekly.label, '매주');
    });

    test('should have correct hours', () {
      expect(SyncFrequency.manual.hours, 0);
      expect(SyncFrequency.hourly.hours, 1);
      expect(SyncFrequency.daily.hours, 24);
      expect(SyncFrequency.weekly.hours, 168);
    });
  });

  group('AudioQuality', () {
    test('should have correct labels', () {
      expect(AudioQuality.low.label, '저화질 (16kHz)');
      expect(AudioQuality.medium.label, '중화질 (22kHz)');
      expect(AudioQuality.high.label, '고화질 (44kHz)');
    });

    test('should have correct sample rates', () {
      expect(AudioQuality.low.sampleRate, 16000);
      expect(AudioQuality.medium.sampleRate, 22050);
      expect(AudioQuality.high.sampleRate, 44100);
    });
  });

  group('StorageInfo', () {
    test('should create with values', () {
      final info = StorageInfo(
        totalBytes: 1024 * 1024 * 1024, // 1 GB
        usedBytes: 512 * 1024 * 1024, // 512 MB
        screeningCount: 100,
        audioFileCount: 50,
      );
      
      expect(info.totalBytes, 1024 * 1024 * 1024);
      expect(info.usedBytes, 512 * 1024 * 1024);
      expect(info.screeningCount, 100);
      expect(info.audioFileCount, 50);
    });

    test('should calculate usage percent', () {
      final info = StorageInfo(
        totalBytes: 1000,
        usedBytes: 250,
        screeningCount: 10,
        audioFileCount: 5,
      );
      
      expect(info.usagePercent, 25.0);
    });

    test('should format bytes correctly', () {
      // Bytes
      var info = StorageInfo(totalBytes: 500, usedBytes: 500, screeningCount: 0, audioFileCount: 0);
      expect(info.usedFormatted, '500 B');
      
      // KB
      info = StorageInfo(totalBytes: 2048, usedBytes: 2048, screeningCount: 0, audioFileCount: 0);
      expect(info.usedFormatted, '2.0 KB');
      
      // MB
      info = StorageInfo(totalBytes: 5 * 1024 * 1024, usedBytes: 5 * 1024 * 1024, screeningCount: 0, audioFileCount: 0);
      expect(info.usedFormatted, '5.0 MB');
    });

    test('should create empty storage info', () {
      final info = StorageInfo.empty();
      
      expect(info.totalBytes, 0);
      expect(info.usedBytes, 0);
      expect(info.screeningCount, 0);
      expect(info.audioFileCount, 0);
    });
  });
}

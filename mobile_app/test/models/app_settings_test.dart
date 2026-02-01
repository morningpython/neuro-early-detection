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

  group('AppSettings - Advanced copyWith Tests', () {
    test('copyWith should update languageCode', () {
      final original = AppSettings();
      final updated = original.copyWith(languageCode: 'sw');
      expect(updated.languageCode, 'sw');
      expect(original.languageCode, 'en');
    });

    test('copyWith should update themeMode', () {
      final original = AppSettings();
      final updated = original.copyWith(themeMode: AppThemeMode.dark);
      expect(updated.themeMode, AppThemeMode.dark);
    });

    test('copyWith should update enableNotifications', () {
      final original = AppSettings();
      final updated = original.copyWith(enableNotifications: false);
      expect(updated.enableNotifications, false);
    });

    test('copyWith should update enableSounds', () {
      final original = AppSettings();
      final updated = original.copyWith(enableSounds: false);
      expect(updated.enableSounds, false);
    });

    test('copyWith should update enableHapticFeedback', () {
      final original = AppSettings();
      final updated = original.copyWith(enableHapticFeedback: false);
      expect(updated.enableHapticFeedback, false);
    });

    test('copyWith should update syncFrequency', () {
      final original = AppSettings();
      final updated = original.copyWith(syncFrequency: SyncFrequency.hourly);
      expect(updated.syncFrequency, SyncFrequency.hourly);
    });

    test('copyWith should update syncOnWifiOnly', () {
      final original = AppSettings();
      final updated = original.copyWith(syncOnWifiOnly: false);
      expect(updated.syncOnWifiOnly, false);
    });

    test('copyWith should update autoUpload', () {
      final original = AppSettings();
      final updated = original.copyWith(autoUpload: false);
      expect(updated.autoUpload, false);
    });

    test('copyWith should update audioQuality', () {
      final original = AppSettings();
      final updated = original.copyWith(audioQuality: AudioQuality.high);
      expect(updated.audioQuality, AudioQuality.high);
    });

    test('copyWith should update recordingDuration', () {
      final original = AppSettings();
      final updated = original.copyWith(recordingDuration: 60);
      expect(updated.recordingDuration, 60);
    });

    test('copyWith should update autoValidateAudio', () {
      final original = AppSettings();
      final updated = original.copyWith(autoValidateAudio: false);
      expect(updated.autoValidateAudio, false);
    });

    test('copyWith should update showConfidenceScore', () {
      final original = AppSettings();
      final updated = original.copyWith(showConfidenceScore: true);
      expect(updated.showConfidenceScore, true);
    });

    test('copyWith should update requirePinOnResume', () {
      final original = AppSettings();
      final updated = original.copyWith(requirePinOnResume: true);
      expect(updated.requirePinOnResume, true);
    });

    test('copyWith should update pinTimeout', () {
      final original = AppSettings();
      final updated = original.copyWith(pinTimeout: 15);
      expect(updated.pinTimeout, 15);
    });

    test('copyWith should update enableBiometric', () {
      final original = AppSettings();
      final updated = original.copyWith(enableBiometric: true);
      expect(updated.enableBiometric, true);
    });

    test('copyWith should update encryptLocalData', () {
      final original = AppSettings();
      final updated = original.copyWith(encryptLocalData: false);
      expect(updated.encryptLocalData, false);
    });

    test('copyWith should update autoDeleteDays', () {
      final original = AppSettings();
      final updated = original.copyWith(autoDeleteDays: 60);
      expect(updated.autoDeleteDays, 60);
    });

    test('copyWith should update compressAudioFiles', () {
      final original = AppSettings();
      final updated = original.copyWith(compressAudioFiles: false);
      expect(updated.compressAudioFiles, false);
    });

    test('copyWith should update maxStorageMb', () {
      final original = AppSettings();
      final updated = original.copyWith(maxStorageMb: 1000);
      expect(updated.maxStorageMb, 1000);
    });

    test('copyWith should update multiple fields', () {
      final original = AppSettings();
      final updated = original.copyWith(
        languageCode: 'sw',
        themeMode: AppThemeMode.light,
        enableNotifications: false,
        syncFrequency: SyncFrequency.weekly,
        audioQuality: AudioQuality.low,
        recordingDuration: 45,
        requirePinOnResume: true,
        autoDeleteDays: 90,
      );
      
      expect(updated.languageCode, 'sw');
      expect(updated.themeMode, AppThemeMode.light);
      expect(updated.enableNotifications, false);
      expect(updated.syncFrequency, SyncFrequency.weekly);
      expect(updated.audioQuality, AudioQuality.low);
      expect(updated.recordingDuration, 45);
      expect(updated.requirePinOnResume, true);
      expect(updated.autoDeleteDays, 90);
    });
  });

  group('AppSettings - toMap comprehensive', () {
    test('toMap should include all fields', () {
      final settings = AppSettings(
        languageCode: 'sw',
        themeMode: AppThemeMode.dark,
        enableNotifications: false,
        enableSounds: false,
        enableHapticFeedback: false,
        syncFrequency: SyncFrequency.hourly,
        syncOnWifiOnly: false,
        autoUpload: false,
        audioQuality: AudioQuality.low,
        recordingDuration: 20,
        autoValidateAudio: false,
        showConfidenceScore: true,
        requirePinOnResume: true,
        pinTimeout: 10,
        enableBiometric: true,
        encryptLocalData: false,
        autoDeleteDays: 90,
        compressAudioFiles: false,
        maxStorageMb: 1000,
      );

      final map = settings.toMap();

      expect(map['language_code'], 'sw');
      expect(map['theme_mode'], 'dark');
      expect(map['enable_notifications'], false);
      expect(map['enable_sounds'], false);
      expect(map['enable_haptic_feedback'], false);
      expect(map['sync_frequency'], 1);
      expect(map['sync_on_wifi_only'], false);
      expect(map['auto_upload'], false);
      expect(map['audio_quality'], 16000);
      expect(map['recording_duration'], 20);
      expect(map['auto_validate_audio'], false);
      expect(map['show_confidence_score'], true);
      expect(map['require_pin_on_resume'], true);
      expect(map['pin_timeout'], 10);
      expect(map['enable_biometric'], true);
      expect(map['encrypt_local_data'], false);
      expect(map['auto_delete_days'], 90);
      expect(map['compress_audio_files'], false);
      expect(map['max_storage_mb'], 1000);
    });

    test('toMap should have correct keys count', () {
      final settings = AppSettings();
      final map = settings.toMap();
      expect(map.keys.length, 19);
    });
  });

  group('AppSettings - fromMap comprehensive', () {
    test('fromMap should handle all fields', () {
      final map = {
        'language_code': 'sw',
        'theme_mode': 'light',
        'enable_notifications': false,
        'enable_sounds': false,
        'enable_haptic_feedback': false,
        'sync_frequency': 168, // weekly
        'sync_on_wifi_only': false,
        'auto_upload': false,
        'audio_quality': 44100, // high
        'recording_duration': 60,
        'auto_validate_audio': false,
        'show_confidence_score': true,
        'require_pin_on_resume': true,
        'pin_timeout': 20,
        'enable_biometric': true,
        'encrypt_local_data': false,
        'auto_delete_days': 7,
        'compress_audio_files': false,
        'max_storage_mb': 2000,
      };

      final settings = AppSettings.fromMap(map);

      expect(settings.languageCode, 'sw');
      expect(settings.themeMode, AppThemeMode.light);
      expect(settings.enableNotifications, false);
      expect(settings.enableSounds, false);
      expect(settings.enableHapticFeedback, false);
      expect(settings.syncFrequency, SyncFrequency.weekly);
      expect(settings.syncOnWifiOnly, false);
      expect(settings.autoUpload, false);
      expect(settings.audioQuality, AudioQuality.high);
      expect(settings.recordingDuration, 60);
      expect(settings.autoValidateAudio, false);
      expect(settings.showConfidenceScore, true);
      expect(settings.requirePinOnResume, true);
      expect(settings.pinTimeout, 20);
      expect(settings.enableBiometric, true);
      expect(settings.encryptLocalData, false);
      expect(settings.autoDeleteDays, 7);
      expect(settings.compressAudioFiles, false);
      expect(settings.maxStorageMb, 2000);
    });

    test('fromMap should use defaults for missing fields', () {
      final map = <String, dynamic>{};
      final settings = AppSettings.fromMap(map);

      expect(settings.languageCode, 'en');
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.enableNotifications, true);
      expect(settings.syncFrequency, SyncFrequency.daily);
      expect(settings.audioQuality, AudioQuality.medium);
      expect(settings.recordingDuration, 30);
      expect(settings.requirePinOnResume, false);
      expect(settings.pinTimeout, 5);
      expect(settings.autoDeleteDays, 30);
      expect(settings.maxStorageMb, 500);
    });

    test('fromMap should handle invalid theme mode', () {
      final map = {'theme_mode': 'invalid'};
      final settings = AppSettings.fromMap(map);
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('fromMap should handle invalid sync frequency', () {
      final map = {'sync_frequency': 999};
      final settings = AppSettings.fromMap(map);
      expect(settings.syncFrequency, SyncFrequency.daily);
    });

    test('fromMap should handle invalid audio quality', () {
      final map = {'audio_quality': 99999};
      final settings = AppSettings.fromMap(map);
      expect(settings.audioQuality, AudioQuality.medium);
    });
  });

  group('AppSettings - defaults factory', () {
    test('defaults should match const constructor', () {
      final defaultSettings = AppSettings.defaults();
      final constSettings = const AppSettings();

      expect(defaultSettings.languageCode, constSettings.languageCode);
      expect(defaultSettings.themeMode, constSettings.themeMode);
      expect(defaultSettings.enableNotifications, constSettings.enableNotifications);
      expect(defaultSettings.syncFrequency, constSettings.syncFrequency);
      expect(defaultSettings.audioQuality, constSettings.audioQuality);
      expect(defaultSettings.recordingDuration, constSettings.recordingDuration);
    });
  });

  group('AppThemeMode - comprehensive', () {
    test('all values should have unique labels', () {
      final labels = AppThemeMode.values.map((t) => t.label).toSet();
      expect(labels.length, AppThemeMode.values.length);
    });

    test('all values should have unique values', () {
      final values = AppThemeMode.values.map((t) => t.value).toSet();
      expect(values.length, AppThemeMode.values.length);
    });

    test('should have exactly 3 values', () {
      expect(AppThemeMode.values.length, 3);
    });
  });

  group('SyncFrequency - comprehensive', () {
    test('all values should have unique labels', () {
      final labels = SyncFrequency.values.map((s) => s.label).toSet();
      expect(labels.length, SyncFrequency.values.length);
    });

    test('all values should have unique hours', () {
      final hours = SyncFrequency.values.map((s) => s.hours).toSet();
      expect(hours.length, SyncFrequency.values.length);
    });

    test('should have exactly 4 values', () {
      expect(SyncFrequency.values.length, 4);
    });

    test('hours should be in ascending order', () {
      expect(SyncFrequency.manual.hours, lessThan(SyncFrequency.hourly.hours));
      expect(SyncFrequency.hourly.hours, lessThan(SyncFrequency.daily.hours));
      expect(SyncFrequency.daily.hours, lessThan(SyncFrequency.weekly.hours));
    });
  });

  group('AudioQuality - comprehensive', () {
    test('all values should have unique labels', () {
      final labels = AudioQuality.values.map((a) => a.label).toSet();
      expect(labels.length, AudioQuality.values.length);
    });

    test('all values should have unique sample rates', () {
      final rates = AudioQuality.values.map((a) => a.sampleRate).toSet();
      expect(rates.length, AudioQuality.values.length);
    });

    test('should have exactly 3 values', () {
      expect(AudioQuality.values.length, 3);
    });

    test('sample rates should be in ascending order', () {
      expect(AudioQuality.low.sampleRate, lessThan(AudioQuality.medium.sampleRate));
      expect(AudioQuality.medium.sampleRate, lessThan(AudioQuality.high.sampleRate));
    });
  });

  group('AppSettings - edge cases', () {
    test('should handle zero recording duration', () {
      final settings = AppSettings(recordingDuration: 0);
      expect(settings.recordingDuration, 0);
    });

    test('should handle large recording duration', () {
      final settings = AppSettings(recordingDuration: 3600);
      expect(settings.recordingDuration, 3600);
    });

    test('should handle zero autoDeleteDays', () {
      final settings = AppSettings(autoDeleteDays: 0);
      expect(settings.autoDeleteDays, 0);
    });

    test('should handle large maxStorageMb', () {
      final settings = AppSettings(maxStorageMb: 10000);
      expect(settings.maxStorageMb, 10000);
    });

    test('should handle very short pin timeout', () {
      final settings = AppSettings(pinTimeout: 1);
      expect(settings.pinTimeout, 1);
    });

    test('should handle very long pin timeout', () {
      final settings = AppSettings(pinTimeout: 120);
      expect(settings.pinTimeout, 120);
    });
  });

  group('AppSettings - serialization round trip', () {
    test('should preserve all values through toMap/fromMap', () {
      final original = AppSettings(
        languageCode: 'sw',
        themeMode: AppThemeMode.light,
        enableNotifications: false,
        enableSounds: false,
        enableHapticFeedback: false,
        syncFrequency: SyncFrequency.weekly,
        syncOnWifiOnly: false,
        autoUpload: false,
        audioQuality: AudioQuality.high,
        recordingDuration: 45,
        autoValidateAudio: false,
        showConfidenceScore: true,
        requirePinOnResume: true,
        pinTimeout: 15,
        enableBiometric: true,
        encryptLocalData: false,
        autoDeleteDays: 14,
        compressAudioFiles: false,
        maxStorageMb: 750,
      );

      final map = original.toMap();
      final restored = AppSettings.fromMap(map);

      expect(restored.languageCode, original.languageCode);
      expect(restored.themeMode, original.themeMode);
      expect(restored.enableNotifications, original.enableNotifications);
      expect(restored.enableSounds, original.enableSounds);
      expect(restored.enableHapticFeedback, original.enableHapticFeedback);
      expect(restored.syncFrequency, original.syncFrequency);
      expect(restored.syncOnWifiOnly, original.syncOnWifiOnly);
      expect(restored.autoUpload, original.autoUpload);
      expect(restored.audioQuality, original.audioQuality);
      expect(restored.recordingDuration, original.recordingDuration);
      expect(restored.autoValidateAudio, original.autoValidateAudio);
      expect(restored.showConfidenceScore, original.showConfidenceScore);
      expect(restored.requirePinOnResume, original.requirePinOnResume);
      expect(restored.pinTimeout, original.pinTimeout);
      expect(restored.enableBiometric, original.enableBiometric);
      expect(restored.encryptLocalData, original.encryptLocalData);
      expect(restored.autoDeleteDays, original.autoDeleteDays);
      expect(restored.compressAudioFiles, original.compressAudioFiles);
      expect(restored.maxStorageMb, original.maxStorageMb);
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

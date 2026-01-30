/// App Settings Model
/// STORY-030: Settings Screen Implementation
///
/// 앱 설정 데이터 모델입니다.
library;

/// 테마 모드
enum AppThemeMode {
  system('시스템 설정', 'system'),
  light('라이트 모드', 'light'),
  dark('다크 모드', 'dark');

  const AppThemeMode(this.label, this.value);
  final String label;
  final String value;
}

/// 데이터 동기화 빈도
enum SyncFrequency {
  manual('수동', 0),
  hourly('매시간', 1),
  daily('매일', 24),
  weekly('매주', 168);

  const SyncFrequency(this.label, this.hours);
  final String label;
  final int hours;
}

/// 오디오 품질
enum AudioQuality {
  low('저화질 (16kHz)', 16000),
  medium('중화질 (22kHz)', 22050),
  high('고화질 (44kHz)', 44100);

  const AudioQuality(this.label, this.sampleRate);
  final String label;
  final int sampleRate;
}

/// 앱 설정
class AppSettings {
  // 일반 설정
  final String languageCode;
  final AppThemeMode themeMode;
  final bool enableNotifications;
  final bool enableSounds;
  final bool enableHapticFeedback;
  
  // 동기화 설정
  final SyncFrequency syncFrequency;
  final bool syncOnWifiOnly;
  final bool autoUpload;
  
  // 스크리닝 설정
  final AudioQuality audioQuality;
  final int recordingDuration; // 초
  final bool autoValidateAudio;
  final bool showConfidenceScore;
  
  // 보안 설정
  final bool requirePinOnResume;
  final int pinTimeout; // 분
  final bool enableBiometric;
  final bool encryptLocalData;
  
  // 데이터 관리
  final int autoDeleteDays; // 자동 삭제 기간 (0 = 비활성)
  final bool compressAudioFiles;
  final int maxStorageMb;

  const AppSettings({
    this.languageCode = 'en',
    this.themeMode = AppThemeMode.system,
    this.enableNotifications = true,
    this.enableSounds = true,
    this.enableHapticFeedback = true,
    this.syncFrequency = SyncFrequency.daily,
    this.syncOnWifiOnly = true,
    this.autoUpload = true,
    this.audioQuality = AudioQuality.medium,
    this.recordingDuration = 30,
    this.autoValidateAudio = true,
    this.showConfidenceScore = false,
    this.requirePinOnResume = false,
    this.pinTimeout = 5,
    this.enableBiometric = false,
    this.encryptLocalData = true,
    this.autoDeleteDays = 30,
    this.compressAudioFiles = true,
    this.maxStorageMb = 500,
  });

  /// 기본 설정
  factory AppSettings.defaults() => const AppSettings();

  /// 복사본 생성
  AppSettings copyWith({
    String? languageCode,
    AppThemeMode? themeMode,
    bool? enableNotifications,
    bool? enableSounds,
    bool? enableHapticFeedback,
    SyncFrequency? syncFrequency,
    bool? syncOnWifiOnly,
    bool? autoUpload,
    AudioQuality? audioQuality,
    int? recordingDuration,
    bool? autoValidateAudio,
    bool? showConfidenceScore,
    bool? requirePinOnResume,
    int? pinTimeout,
    bool? enableBiometric,
    bool? encryptLocalData,
    int? autoDeleteDays,
    bool? compressAudioFiles,
    int? maxStorageMb,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSounds: enableSounds ?? this.enableSounds,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      autoUpload: autoUpload ?? this.autoUpload,
      audioQuality: audioQuality ?? this.audioQuality,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      autoValidateAudio: autoValidateAudio ?? this.autoValidateAudio,
      showConfidenceScore: showConfidenceScore ?? this.showConfidenceScore,
      requirePinOnResume: requirePinOnResume ?? this.requirePinOnResume,
      pinTimeout: pinTimeout ?? this.pinTimeout,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      encryptLocalData: encryptLocalData ?? this.encryptLocalData,
      autoDeleteDays: autoDeleteDays ?? this.autoDeleteDays,
      compressAudioFiles: compressAudioFiles ?? this.compressAudioFiles,
      maxStorageMb: maxStorageMb ?? this.maxStorageMb,
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'language_code': languageCode,
      'theme_mode': themeMode.value,
      'enable_notifications': enableNotifications,
      'enable_sounds': enableSounds,
      'enable_haptic_feedback': enableHapticFeedback,
      'sync_frequency': syncFrequency.hours,
      'sync_on_wifi_only': syncOnWifiOnly,
      'auto_upload': autoUpload,
      'audio_quality': audioQuality.sampleRate,
      'recording_duration': recordingDuration,
      'auto_validate_audio': autoValidateAudio,
      'show_confidence_score': showConfidenceScore,
      'require_pin_on_resume': requirePinOnResume,
      'pin_timeout': pinTimeout,
      'enable_biometric': enableBiometric,
      'encrypt_local_data': encryptLocalData,
      'auto_delete_days': autoDeleteDays,
      'compress_audio_files': compressAudioFiles,
      'max_storage_mb': maxStorageMb,
    };
  }

  /// Map에서 생성
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      languageCode: map['language_code'] as String? ?? 'en',
      themeMode: AppThemeMode.values.firstWhere(
        (t) => t.value == map['theme_mode'],
        orElse: () => AppThemeMode.system,
      ),
      enableNotifications: map['enable_notifications'] as bool? ?? true,
      enableSounds: map['enable_sounds'] as bool? ?? true,
      enableHapticFeedback: map['enable_haptic_feedback'] as bool? ?? true,
      syncFrequency: SyncFrequency.values.firstWhere(
        (s) => s.hours == map['sync_frequency'],
        orElse: () => SyncFrequency.daily,
      ),
      syncOnWifiOnly: map['sync_on_wifi_only'] as bool? ?? true,
      autoUpload: map['auto_upload'] as bool? ?? true,
      audioQuality: AudioQuality.values.firstWhere(
        (a) => a.sampleRate == map['audio_quality'],
        orElse: () => AudioQuality.medium,
      ),
      recordingDuration: map['recording_duration'] as int? ?? 30,
      autoValidateAudio: map['auto_validate_audio'] as bool? ?? true,
      showConfidenceScore: map['show_confidence_score'] as bool? ?? false,
      requirePinOnResume: map['require_pin_on_resume'] as bool? ?? false,
      pinTimeout: map['pin_timeout'] as int? ?? 5,
      enableBiometric: map['enable_biometric'] as bool? ?? false,
      encryptLocalData: map['encrypt_local_data'] as bool? ?? true,
      autoDeleteDays: map['auto_delete_days'] as int? ?? 30,
      compressAudioFiles: map['compress_audio_files'] as bool? ?? true,
      maxStorageMb: map['max_storage_mb'] as int? ?? 500,
    );
  }
}

/// 저장 용량 정보
class StorageInfo {
  final int usedBytes;
  final int totalBytes;
  final int screeningCount;
  final int audioFileCount;

  const StorageInfo({
    required this.usedBytes,
    required this.totalBytes,
    required this.screeningCount,
    required this.audioFileCount,
  });

  double get usagePercent => totalBytes > 0 ? usedBytes / totalBytes * 100 : 0;
  
  String get usedFormatted {
    if (usedBytes < 1024) return '$usedBytes B';
    if (usedBytes < 1024 * 1024) return '${(usedBytes / 1024).toStringAsFixed(1)} KB';
    if (usedBytes < 1024 * 1024 * 1024) {
      return '${(usedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(usedBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get totalFormatted {
    if (totalBytes < 1024 * 1024) return '${(totalBytes / 1024).toStringAsFixed(0)} KB';
    if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    }
    return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  factory StorageInfo.empty() {
    return const StorageInfo(
      usedBytes: 0,
      totalBytes: 0,
      screeningCount: 0,
      audioFileCount: 0,
    );
  }
}

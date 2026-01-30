/// Settings Provider
/// STORY-030: Settings Screen Implementation
///
/// 앱 설정 상태 관리 프로바이더입니다.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

/// 설정 프로바이더
class SettingsProvider extends ChangeNotifier {
  static const String _settingsKey = 'app_settings';
  
  SharedPreferences? _prefs;
  AppSettings _settings = AppSettings.defaults();
  StorageInfo _storageInfo = StorageInfo.empty();
  bool _isLoading = true;

  AppSettings get settings => _settings;
  StorageInfo get storageInfo => _storageInfo;
  bool get isLoading => _isLoading;

  // 빠른 접근자
  String get languageCode => _settings.languageCode;
  AppThemeMode get themeMode => _settings.themeMode;
  bool get enableNotifications => _settings.enableNotifications;
  AudioQuality get audioQuality => _settings.audioQuality;
  int get recordingDuration => _settings.recordingDuration;

  /// 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _loadStorageInfo();
    _isLoading = false;
    notifyListeners();
    debugPrint('✓ SettingsProvider initialized');
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    final json = _prefs?.getString(_settingsKey);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _settings = AppSettings.fromMap(map);
      } catch (e) {
        debugPrint('⚠️ Failed to load settings: $e');
        _settings = AppSettings.defaults();
      }
    }
  }

  /// 설정 저장
  Future<void> _saveSettings() async {
    final json = jsonEncode(_settings.toMap());
    await _prefs?.setString(_settingsKey, json);
  }

  /// 저장 공간 정보 로드
  Future<void> _loadStorageInfo() async {
    // TODO: 실제 저장 공간 계산
    _storageInfo = const StorageInfo(
      usedBytes: 45 * 1024 * 1024, // 45 MB 시뮬레이션
      totalBytes: 500 * 1024 * 1024, // 500 MB
      screeningCount: 127,
      audioFileCount: 98,
    );
  }

  /// 설정 업데이트
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }

  /// 언어 변경
  Future<void> setLanguage(String languageCode) async {
    _settings = _settings.copyWith(languageCode: languageCode);
    await _saveSettings();
    notifyListeners();
  }

  /// 테마 변경
  Future<void> setThemeMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _saveSettings();
    notifyListeners();
  }

  /// 알림 설정 변경
  Future<void> setNotifications(bool enabled) async {
    _settings = _settings.copyWith(enableNotifications: enabled);
    await _saveSettings();
    notifyListeners();
  }

  /// 동기화 빈도 변경
  Future<void> setSyncFrequency(SyncFrequency frequency) async {
    _settings = _settings.copyWith(syncFrequency: frequency);
    await _saveSettings();
    notifyListeners();
  }

  /// 오디오 품질 변경
  Future<void> setAudioQuality(AudioQuality quality) async {
    _settings = _settings.copyWith(audioQuality: quality);
    await _saveSettings();
    notifyListeners();
  }

  /// 녹음 시간 변경
  Future<void> setRecordingDuration(int seconds) async {
    _settings = _settings.copyWith(recordingDuration: seconds);
    await _saveSettings();
    notifyListeners();
  }

  /// PIN 요구 설정 변경
  Future<void> setRequirePinOnResume(bool required) async {
    _settings = _settings.copyWith(requirePinOnResume: required);
    await _saveSettings();
    notifyListeners();
  }

  /// 생체 인증 설정 변경
  Future<void> setEnableBiometric(bool enabled) async {
    _settings = _settings.copyWith(enableBiometric: enabled);
    await _saveSettings();
    notifyListeners();
  }

  /// 로컬 데이터 암호화 설정 변경
  Future<void> setEncryptLocalData(bool encrypt) async {
    _settings = _settings.copyWith(encryptLocalData: encrypt);
    await _saveSettings();
    notifyListeners();
  }

  /// 자동 삭제 기간 변경
  Future<void> setAutoDeleteDays(int days) async {
    _settings = _settings.copyWith(autoDeleteDays: days);
    await _saveSettings();
    notifyListeners();
  }

  /// 설정 초기화
  Future<void> resetToDefaults() async {
    _settings = AppSettings.defaults();
    await _saveSettings();
    notifyListeners();
  }

  /// 캐시 삭제
  Future<void> clearCache() async {
    // TODO: 실제 캐시 삭제 구현
    debugPrint('✓ Cache cleared');
    await _loadStorageInfo();
    notifyListeners();
  }

  /// 모든 데이터 삭제
  Future<void> clearAllData() async {
    // TODO: 실제 데이터 삭제 구현
    debugPrint('✓ All data cleared');
    _storageInfo = StorageInfo.empty();
    notifyListeners();
  }
}

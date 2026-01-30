import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 언어 설정을 관리하는 Provider
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  /// 지원하는 언어 목록
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('sw'), // Swahili
  ];
  
  /// 언어 표시 이름 매핑
  static const Map<String, String> localeNames = {
    'en': 'English',
    'sw': 'Kiswahili',
  };
  
  /// 저장된 언어 설정 로드
  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        _locale = Locale(localeCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }
  
  /// 언어 설정 변경
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      debugPrint('Unsupported locale: $locale');
      return;
    }
    
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }
  
  /// 언어 코드로 이름 가져오기
  String getLocaleName(String code) {
    return localeNames[code] ?? code;
  }
  
  /// 현재 언어 이름
  String get currentLocaleName => getLocaleName(_locale.languageCode);
}

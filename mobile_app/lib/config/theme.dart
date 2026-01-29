import 'package:flutter/material.dart';

/// 앱 테마 설정
class AppTheme {
  // 브랜드 컬러
  static const Color primaryColor = Color(0xFF2196F3);      // Blue
  static const Color secondaryColor = Color(0xFF4CAF50);    // Green (건강/성공)
  static const Color errorColor = Color(0xFFE53935);        // Red (위험/경고)
  static const Color warningColor = Color(0xFFFFA726);      // Orange (주의)
  
  // 상태 색상
  static const Color recordingColor = Color(0xFFE53935);    // 녹음 중
  static const Color readyColor = Color(0xFF4CAF50);        // 준비됨
  static const Color processingColor = Color(0xFF9E9E9E);   // 처리 중
  
  /// 라이트 테마
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// 다크 테마
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// 앱 상수 정의
class AppConstants {
  // 녹음 설정
  static const int recordingDurationSeconds = 30;
  static const int sampleRate = 16000;        // 16kHz
  static const int bitDepth = 16;             // 16-bit
  static const int channels = 1;              // Mono
  
  // 음질 검증
  static const double minRecordingDuration = 10.0;  // 최소 10초
  static const double silenceThreshold = 0.05;      // 5% 미만은 무음
  static const double maxSilenceRatio = 0.8;        // 80% 이상 무음이면 실패
  static const double clippingThreshold = 0.1;      // 10% 이상 클리핑이면 실패
  
  // 위험도 임계값
  static const double lowRiskThreshold = 0.3;       // 30% 미만 = 낮음
  static const double highRiskThreshold = 0.7;      // 70% 이상 = 높음
  
  // 파일 경로
  static const String audioDirectory = 'audio';
  static const String databaseName = 'neuroaccess.db';
  
  // 버전
  static const String appVersion = '1.0.0';
  static const String modelVersion = '1.0.0';
}

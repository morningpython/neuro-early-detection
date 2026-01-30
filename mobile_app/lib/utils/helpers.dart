// 유틸리티 헬퍼 함수들
import 'package:intl/intl.dart';

class Helpers {
  /// 날짜 포맷팅
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
  
  /// 상대적 시간 표시 (예: "2시간 전")
  static String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}년 전';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
  
  /// 위험도 레벨에 따른 텍스트
  static String riskLevelText(double riskScore) {
    if (riskScore < 0.3) return '낮음';
    if (riskScore < 0.7) return '보통';
    return '높음';
  }
  
  /// 퍼센트 포맷팅
  static String formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  
  /// 파일 크기 포맷팅
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

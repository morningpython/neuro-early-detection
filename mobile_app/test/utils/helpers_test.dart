import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/utils/helpers.dart';

void main() {
  group('Helpers.formatDate', () {
    test('formats date as yyyy-MM-dd HH:mm', () {
      final date = DateTime(2026, 1, 31, 9, 5);
      expect(Helpers.formatDate(date), '2026-01-31 09:05');
    });
  });

  group('Helpers.timeAgo', () {
    test('returns years ago when over 365 days', () {
      final date = DateTime.now().subtract(const Duration(days: 366));
      expect(Helpers.timeAgo(date), '1년 전');
    });

    test('returns months ago when over 30 days', () {
      final date = DateTime.now().subtract(const Duration(days: 61));
      expect(Helpers.timeAgo(date), '2개월 전');
    });

    test('returns days ago when over 0 days', () {
      final date = DateTime.now().subtract(const Duration(days: 3));
      expect(Helpers.timeAgo(date), '3일 전');
    });

    test('returns hours ago when over 0 hours', () {
      final date = DateTime.now().subtract(const Duration(hours: 5));
      expect(Helpers.timeAgo(date), '5시간 전');
    });

    test('returns minutes ago when over 0 minutes', () {
      final date = DateTime.now().subtract(const Duration(minutes: 10));
      expect(Helpers.timeAgo(date), '10분 전');
    });

    test('returns just now for recent time', () {
      final date = DateTime.now().subtract(const Duration(seconds: 30));
      expect(Helpers.timeAgo(date), '방금 전');
    });
  });

  group('Helpers.riskLevelText', () {
    test('returns low for score below 0.3', () {
      expect(Helpers.riskLevelText(0.0), '낮음');
      expect(Helpers.riskLevelText(0.299), '낮음');
    });

    test('returns medium for score below 0.7', () {
      expect(Helpers.riskLevelText(0.3), '보통');
      expect(Helpers.riskLevelText(0.699), '보통');
    });

    test('returns high for score 0.7 and above', () {
      expect(Helpers.riskLevelText(0.7), '높음');
      expect(Helpers.riskLevelText(1.0), '높음');
    });
  });

  group('Helpers.formatPercent', () {
    test('formats percentage with one decimal', () {
      expect(Helpers.formatPercent(0.0), '0.0%');
      expect(Helpers.formatPercent(0.1234), '12.3%');
      expect(Helpers.formatPercent(1.0), '100.0%');
    });
  });

  group('Helpers.formatFileSize', () {
    test('formats bytes under 1KB', () {
      expect(Helpers.formatFileSize(0), '0 B');
      expect(Helpers.formatFileSize(512), '512 B');
      expect(Helpers.formatFileSize(1023), '1023 B');
    });

    test('formats KB range', () {
      expect(Helpers.formatFileSize(1024), '1.0 KB');
      expect(Helpers.formatFileSize(1536), '1.5 KB');
      expect(Helpers.formatFileSize(1024 * 1024 - 1), '1024.0 KB');
    });

    test('formats MB range', () {
      expect(Helpers.formatFileSize(1024 * 1024), '1.0 MB');
      expect(Helpers.formatFileSize(5 * 1024 * 1024), '5.0 MB');
    });

    test('formats GB range', () {
      expect(Helpers.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
      expect(Helpers.formatFileSize(3 * 1024 * 1024 * 1024), '3.0 GB');
    });
  });
}

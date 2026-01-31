import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/dashboard_stats.dart';

void main() {
  group('DashboardStats', () {
    test('should create with all fields', () {
      final stats = DashboardStats(
        totalScreenings: 100,
        screeningsToday: 5,
        screeningsThisWeek: 25,
        screeningsThisMonth: 80,
        totalReferrals: 20,
        pendingReferrals: 5,
        completedReferrals: 15,
        avgRiskScore: 0.45,
        highRiskCount: 10,
        mediumRiskCount: 30,
        lowRiskCount: 60,
        lastUpdated: DateTime(2024, 1, 15),
      );

      expect(stats.totalScreenings, 100);
      expect(stats.screeningsToday, 5);
      expect(stats.totalReferrals, 20);
      expect(stats.avgRiskScore, 0.45);
    });

    test('empty factory should create zero stats', () {
      final stats = DashboardStats.empty();

      expect(stats.totalScreenings, 0);
      expect(stats.screeningsToday, 0);
      expect(stats.totalReferrals, 0);
      expect(stats.avgRiskScore, 0);
      expect(stats.lastUpdated, isNotNull);
    });

    test('highRiskRate should calculate correctly', () {
      final stats = DashboardStats(
        totalScreenings: 100,
        screeningsToday: 0,
        screeningsThisWeek: 0,
        screeningsThisMonth: 0,
        totalReferrals: 0,
        pendingReferrals: 0,
        completedReferrals: 0,
        avgRiskScore: 0,
        highRiskCount: 25,
        mediumRiskCount: 25,
        lowRiskCount: 50,
        lastUpdated: DateTime.now(),
      );

      expect(stats.highRiskRate, 0.25);
    });

    test('referralCompletionRate should calculate correctly', () {
      final stats = DashboardStats(
        totalScreenings: 100,
        screeningsToday: 0,
        screeningsThisWeek: 0,
        screeningsThisMonth: 0,
        totalReferrals: 20,
        pendingReferrals: 5,
        completedReferrals: 15,
        avgRiskScore: 0,
        highRiskCount: 0,
        mediumRiskCount: 0,
        lowRiskCount: 0,
        lastUpdated: DateTime.now(),
      );

      expect(stats.referralCompletionRate, 0.75);
    });

    test('rates should handle zero totals', () {
      final stats = DashboardStats.empty();

      expect(stats.highRiskRate, 0);
      expect(stats.referralCompletionRate, 0);
    });

    test('toMap should convert all fields', () {
      final stats = DashboardStats(
        totalScreenings: 100,
        screeningsToday: 5,
        screeningsThisWeek: 25,
        screeningsThisMonth: 80,
        totalReferrals: 20,
        pendingReferrals: 5,
        completedReferrals: 15,
        avgRiskScore: 0.45,
        highRiskCount: 10,
        mediumRiskCount: 30,
        lowRiskCount: 60,
        lastUpdated: DateTime(2024, 1, 15, 10, 30),
      );

      final map = stats.toMap();

      expect(map['total_screenings'], 100);
      expect(map['screenings_today'], 5);
      expect(map['total_referrals'], 20);
      expect(map['avg_risk_score'], 0.45);
      expect(map['high_risk_count'], 10);
    });

    test('fromMap should restore all fields', () {
      final map = {
        'total_screenings': 150,
        'screenings_today': 10,
        'screenings_this_week': 40,
        'screenings_this_month': 120,
        'total_referrals': 30,
        'pending_referrals': 8,
        'completed_referrals': 22,
        'avg_risk_score': 0.55,
        'high_risk_count': 20,
        'medium_risk_count': 50,
        'low_risk_count': 80,
        'last_updated': '2024-01-15T10:30:00.000',
      };

      final stats = DashboardStats.fromMap(map);

      expect(stats.totalScreenings, 150);
      expect(stats.screeningsToday, 10);
      expect(stats.avgRiskScore, 0.55);
      expect(stats.highRiskCount, 20);
    });
  });

  group('TimeSeriesDataPoint', () {
    test('should create with required fields', () {
      final point = TimeSeriesDataPoint(
        date: DateTime(2024, 1, 15),
        value: 10.5,
      );

      expect(point.date.day, 15);
      expect(point.value, 10.5);
      expect(point.label, isNull);
    });

    test('should create with label', () {
      final point = TimeSeriesDataPoint(
        date: DateTime(2024, 1, 15),
        value: 10.5,
        label: 'Jan 15',
      );

      expect(point.label, 'Jan 15');
    });

    test('toMap should convert all fields', () {
      final point = TimeSeriesDataPoint(
        date: DateTime(2024, 1, 15),
        value: 10.5,
        label: 'Test',
      );

      final map = point.toMap();

      expect(map['value'], 10.5);
      expect(map['label'], 'Test');
    });

    test('fromMap should restore all fields', () {
      final map = {
        'date': '2024-01-15T00:00:00.000',
        'value': 25.0,
        'label': 'Point 1',
      };

      final point = TimeSeriesDataPoint.fromMap(map);

      expect(point.date.day, 15);
      expect(point.value, 25.0);
      expect(point.label, 'Point 1');
    });
  });

  group('ChartData', () {
    test('should create with data points', () {
      final points = [
        TimeSeriesDataPoint(date: DateTime(2024, 1, 1), value: 10),
        TimeSeriesDataPoint(date: DateTime(2024, 1, 2), value: 20),
        TimeSeriesDataPoint(date: DateTime(2024, 1, 3), value: 15),
      ];

      final chart = ChartData(
        title: 'Test Chart',
        dataPoints: points,
      );

      expect(chart.title, 'Test Chart');
      expect(chart.dataPoints.length, 3);
      expect(chart.chartType, ChartType.line);
    });

    test('maxValue should find maximum', () {
      final points = [
        TimeSeriesDataPoint(date: DateTime(2024, 1, 1), value: 10),
        TimeSeriesDataPoint(date: DateTime(2024, 1, 2), value: 50),
        TimeSeriesDataPoint(date: DateTime(2024, 1, 3), value: 30),
      ];

      final chart = ChartData(title: 'Test', dataPoints: points);

      expect(chart.maxValue, 50);
    });

    test('maxValue should return 0 for empty data', () {
      final chart = ChartData(title: 'Empty', dataPoints: []);

      expect(chart.maxValue, 0);
    });

    test('minValue should find minimum', () {
      final points = [
        TimeSeriesDataPoint(date: DateTime(2024, 1, 1), value: 10),
        TimeSeriesDataPoint(date: DateTime(2024, 1, 2), value: 50),
        TimeSeriesDataPoint(date: DateTime(2024, 1, 3), value: 5),
      ];

      final chart = ChartData(title: 'Test', dataPoints: points);

      expect(chart.minValue, 5);
    });

    test('avgValue should calculate correctly', () {
      final points = [
        TimeSeriesDataPoint(date: DateTime(2024, 1, 1), value: 10),
        TimeSeriesDataPoint(date: DateTime(2024, 1, 2), value: 20),
        TimeSeriesDataPoint(date: DateTime(2024, 1, 3), value: 30),
      ];

      final chart = ChartData(title: 'Test', dataPoints: points);

      expect(chart.avgValue, 20);
    });
  });

  group('ChartType', () {
    test('should have all types', () {
      expect(ChartType.values.length, 4);
      expect(ChartType.values, contains(ChartType.line));
      expect(ChartType.values, contains(ChartType.bar));
      expect(ChartType.values, contains(ChartType.pie));
      expect(ChartType.values, contains(ChartType.area));
    });
  });
}

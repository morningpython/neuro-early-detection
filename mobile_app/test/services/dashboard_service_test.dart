import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/dashboard_stats.dart';

void main() {
  group('DashboardService models', () {
    // Most dashboard service tests require database, 
    // but we can test the models and data structures

    group('ChartData', () {
      test('should create with required properties', () {
        final chartData = ChartData(
          title: 'Test Chart',
          dataPoints: [],
          chartType: ChartType.line,
        );

        expect(chartData.title, 'Test Chart');
        expect(chartData.dataPoints, isEmpty);
        expect(chartData.chartType, ChartType.line);
        expect(chartData.unit, isNull);
      });

      test('should create with unit', () {
        final chartData = ChartData(
          title: 'Daily Screenings',
          dataPoints: [],
          chartType: ChartType.bar,
          unit: '건',
        );

        expect(chartData.unit, '건');
        expect(chartData.chartType, ChartType.bar);
      });

      test('should create with data points', () {
        final dataPoints = [
          TimeSeriesDataPoint(date: DateTime(2024, 6, 1), value: 10),
          TimeSeriesDataPoint(date: DateTime(2024, 6, 2), value: 15),
          TimeSeriesDataPoint(date: DateTime(2024, 6, 3), value: 8),
        ];

        final chartData = ChartData(
          title: 'Weekly Trend',
          dataPoints: dataPoints,
          chartType: ChartType.line,
        );

        expect(chartData.dataPoints.length, 3);
        expect(chartData.dataPoints[0].value, 10);
        expect(chartData.dataPoints[1].value, 15);
        expect(chartData.dataPoints[2].value, 8);
      });
    });

    group('TimeSeriesDataPoint', () {
      test('should create with date and value', () {
        final point = TimeSeriesDataPoint(
          date: DateTime(2024, 6, 15),
          value: 42.5,
        );

        expect(point.date, DateTime(2024, 6, 15));
        expect(point.value, 42.5);
      });

      test('should handle zero value', () {
        final point = TimeSeriesDataPoint(
          date: DateTime.now(),
          value: 0,
        );

        expect(point.value, 0);
      });

      test('should handle negative value', () {
        final point = TimeSeriesDataPoint(
          date: DateTime.now(),
          value: -5.5,
        );

        expect(point.value, -5.5);
      });
    });

    group('ChartType', () {
      test('should have line type', () {
        expect(ChartType.line, isNotNull);
        expect(ChartType.line.name, 'line');
      });

      test('should have bar type', () {
        expect(ChartType.bar, isNotNull);
        expect(ChartType.bar.name, 'bar');
      });

      test('should have pie type', () {
        expect(ChartType.pie, isNotNull);
        expect(ChartType.pie.name, 'pie');
      });
    });

    group('RiskDistribution', () {
      test('should create with counts', () {
        final dist = RiskDistribution(
          highRisk: 10,
          mediumRisk: 25,
          lowRisk: 40,
          noRisk: 25,
        );

        expect(dist.highRisk, 10);
        expect(dist.mediumRisk, 25);
        expect(dist.lowRisk, 40);
        expect(dist.noRisk, 25);
      });

      test('total should return sum of all counts', () {
        final dist = RiskDistribution(
          highRisk: 10,
          mediumRisk: 20,
          lowRisk: 30,
          noRisk: 40,
        );

        expect(dist.total, 100);
      });

      test('empty should return all zeros', () {
        final dist = RiskDistribution.empty();

        expect(dist.highRisk, 0);
        expect(dist.mediumRisk, 0);
        expect(dist.lowRisk, 0);
        expect(dist.noRisk, 0);
        expect(dist.total, 0);
      });

      test('percentages should be calculated correctly', () {
        final dist = RiskDistribution(
          highRisk: 10,
          mediumRisk: 20,
          lowRisk: 30,
          noRisk: 40,
        );

        expect(dist.highRiskPercent, closeTo(10.0, 0.01));
        expect(dist.mediumRiskPercent, closeTo(20.0, 0.01));
        expect(dist.lowRiskPercent, closeTo(30.0, 0.01));
        expect(dist.noRiskPercent, closeTo(40.0, 0.01));
      });

      test('percentages should handle empty distribution', () {
        final dist = RiskDistribution.empty();

        expect(dist.highRiskPercent, 0.0);
        expect(dist.mediumRiskPercent, 0.0);
        expect(dist.lowRiskPercent, 0.0);
        expect(dist.noRiskPercent, 0.0);
      });

      test('percentages should handle single category', () {
        final dist = RiskDistribution(
          highRisk: 100,
          mediumRisk: 0,
          lowRisk: 0,
          noRisk: 0,
        );

        expect(dist.highRiskPercent, 100.0);
        expect(dist.mediumRiskPercent, 0.0);
      });
    });

    group('DashboardStats', () {
      test('should create with all properties', () {
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
          lastUpdated: DateTime(2024, 6, 15),
        );

        expect(stats.totalScreenings, 100);
        expect(stats.screeningsToday, 5);
        expect(stats.screeningsThisWeek, 25);
        expect(stats.screeningsThisMonth, 80);
        expect(stats.totalReferrals, 20);
        expect(stats.pendingReferrals, 5);
        expect(stats.completedReferrals, 15);
        expect(stats.avgRiskScore, 0.45);
        expect(stats.highRiskCount, 10);
        expect(stats.mediumRiskCount, 30);
        expect(stats.lowRiskCount, 60);
      });

      test('empty should return all zeros', () {
        final stats = DashboardStats.empty();

        expect(stats.totalScreenings, 0);
        expect(stats.screeningsToday, 0);
        expect(stats.screeningsThisWeek, 0);
        expect(stats.screeningsThisMonth, 0);
        expect(stats.totalReferrals, 0);
        expect(stats.pendingReferrals, 0);
        expect(stats.completedReferrals, 0);
        expect(stats.avgRiskScore, 0.0);
        expect(stats.highRiskCount, 0);
        expect(stats.mediumRiskCount, 0);
        expect(stats.lowRiskCount, 0);
        expect(stats.lastUpdated, isNotNull);
      });

      test('should calculate referral completion rate correctly', () {
        final stats = DashboardStats(
          totalScreenings: 100,
          screeningsToday: 0,
          screeningsThisWeek: 0,
          screeningsThisMonth: 0,
          totalReferrals: 25,
          pendingReferrals: 5,
          completedReferrals: 20,
          avgRiskScore: 0.0,
          highRiskCount: 0,
          mediumRiskCount: 0,
          lowRiskCount: 0,
          lastUpdated: DateTime.now(),
        );

        expect(stats.referralCompletionRate, closeTo(0.8, 0.01));
      });

      test('referral completion rate should handle zero referrals', () {
        final stats = DashboardStats.empty();

        expect(stats.referralCompletionRate, 0.0);
      });

      test('high risk rate should be calculated correctly', () {
        final stats = DashboardStats(
          totalScreenings: 100,
          screeningsToday: 0,
          screeningsThisWeek: 0,
          screeningsThisMonth: 0,
          totalReferrals: 0,
          pendingReferrals: 0,
          completedReferrals: 0,
          avgRiskScore: 0.0,
          highRiskCount: 20,
          mediumRiskCount: 30,
          lowRiskCount: 50,
          lastUpdated: DateTime.now(),
        );

        expect(stats.highRiskRate, closeTo(0.2, 0.01));
      });
    });
  });
}

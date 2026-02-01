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

  group('RiskDistribution', () {
    test('should create with all risk levels', () {
      const distribution = RiskDistribution(
        highRisk: 10,
        mediumRisk: 20,
        lowRisk: 30,
        noRisk: 40,
      );

      expect(distribution.highRisk, 10);
      expect(distribution.mediumRisk, 20);
      expect(distribution.lowRisk, 30);
      expect(distribution.noRisk, 40);
    });

    test('total should sum all categories', () {
      const distribution = RiskDistribution(
        highRisk: 10,
        mediumRisk: 20,
        lowRisk: 30,
        noRisk: 40,
      );

      expect(distribution.total, 100);
    });

    test('percentages should calculate correctly', () {
      const distribution = RiskDistribution(
        highRisk: 10,
        mediumRisk: 20,
        lowRisk: 30,
        noRisk: 40,
      );

      expect(distribution.highRiskPercent, 10.0);
      expect(distribution.mediumRiskPercent, 20.0);
      expect(distribution.lowRiskPercent, 30.0);
      expect(distribution.noRiskPercent, 40.0);
    });

    test('percentages should handle zero total', () {
      const distribution = RiskDistribution(
        highRisk: 0,
        mediumRisk: 0,
        lowRisk: 0,
        noRisk: 0,
      );

      expect(distribution.highRiskPercent, 0);
      expect(distribution.mediumRiskPercent, 0);
      expect(distribution.lowRiskPercent, 0);
      expect(distribution.noRiskPercent, 0);
    });

    test('empty factory should create zero distribution', () {
      final distribution = RiskDistribution.empty();

      expect(distribution.highRisk, 0);
      expect(distribution.mediumRisk, 0);
      expect(distribution.lowRisk, 0);
      expect(distribution.noRisk, 0);
      expect(distribution.total, 0);
    });

    test('fromMap should restore all fields', () {
      final map = {
        'high_risk': 15,
        'medium_risk': 25,
        'low_risk': 35,
        'no_risk': 25,
      };

      final distribution = RiskDistribution.fromMap(map);

      expect(distribution.highRisk, 15);
      expect(distribution.mediumRisk, 25);
      expect(distribution.lowRisk, 35);
      expect(distribution.noRisk, 25);
      expect(distribution.total, 100);
    });

    test('fromMap should handle missing fields', () {
      final map = <String, dynamic>{};

      final distribution = RiskDistribution.fromMap(map);

      expect(distribution.highRisk, 0);
      expect(distribution.mediumRisk, 0);
      expect(distribution.lowRisk, 0);
      expect(distribution.noRisk, 0);
    });
  });

  group('RegionalStats', () {
    test('should create with all fields', () {
      const stats = RegionalStats(
        regionCode: 'TZ-01',
        regionName: 'Dar es Salaam',
        screeningCount: 100,
        referralCount: 25,
        avgRiskScore: 0.35,
        chwCount: 10,
      );

      expect(stats.regionCode, 'TZ-01');
      expect(stats.regionName, 'Dar es Salaam');
      expect(stats.screeningCount, 100);
      expect(stats.referralCount, 25);
      expect(stats.avgRiskScore, 0.35);
      expect(stats.chwCount, 10);
    });

    test('referralRate should calculate correctly', () {
      const stats = RegionalStats(
        regionCode: 'TZ-01',
        regionName: 'Region',
        screeningCount: 100,
        referralCount: 25,
        avgRiskScore: 0.0,
        chwCount: 10,
      );

      expect(stats.referralRate, 0.25);
    });

    test('referralRate should handle zero screenings', () {
      const stats = RegionalStats(
        regionCode: 'TZ-01',
        regionName: 'Region',
        screeningCount: 0,
        referralCount: 0,
        avgRiskScore: 0.0,
        chwCount: 10,
      );

      expect(stats.referralRate, 0);
    });

    test('screeningsPerChw should calculate correctly', () {
      const stats = RegionalStats(
        regionCode: 'TZ-01',
        regionName: 'Region',
        screeningCount: 50,
        referralCount: 0,
        avgRiskScore: 0.0,
        chwCount: 10,
      );

      expect(stats.screeningsPerChw, 5.0);
    });

    test('screeningsPerChw should handle zero CHWs', () {
      const stats = RegionalStats(
        regionCode: 'TZ-01',
        regionName: 'Region',
        screeningCount: 50,
        referralCount: 0,
        avgRiskScore: 0.0,
        chwCount: 0,
      );

      expect(stats.screeningsPerChw, 0);
    });

    test('fromMap should restore all fields', () {
      final map = {
        'region_code': 'TZ-02',
        'region_name': 'Arusha',
        'screening_count': 200,
        'referral_count': 40,
        'avg_risk_score': 0.45,
        'chw_count': 15,
      };

      final stats = RegionalStats.fromMap(map);

      expect(stats.regionCode, 'TZ-02');
      expect(stats.regionName, 'Arusha');
      expect(stats.screeningCount, 200);
      expect(stats.referralCount, 40);
      expect(stats.avgRiskScore, 0.45);
      expect(stats.chwCount, 15);
    });

    test('fromMap should handle missing optional fields', () {
      final map = {
        'region_code': 'TZ-03',
        'region_name': 'Mwanza',
      };

      final stats = RegionalStats.fromMap(map);

      expect(stats.screeningCount, 0);
      expect(stats.referralCount, 0);
      expect(stats.avgRiskScore, 0);
      expect(stats.chwCount, 0);
    });
  });

  group('ChwPerformanceStats', () {
    test('should create with all fields', () {
      final stats = ChwPerformanceStats(
        chwId: 'CHW-001',
        chwName: 'John Doe',
        screeningsCompleted: 50,
        referralsMade: 15,
        avgRiskScore: 0.4,
        trainingModulesCompleted: 5,
        lastActiveAt: DateTime(2024, 1, 15),
      );

      expect(stats.chwId, 'CHW-001');
      expect(stats.chwName, 'John Doe');
      expect(stats.screeningsCompleted, 50);
      expect(stats.referralsMade, 15);
      expect(stats.avgRiskScore, 0.4);
      expect(stats.trainingModulesCompleted, 5);
    });

    test('isActive should return true for recent activity', () {
      final stats = ChwPerformanceStats(
        chwId: 'CHW-001',
        chwName: 'Active CHW',
        screeningsCompleted: 50,
        referralsMade: 15,
        avgRiskScore: 0.4,
        trainingModulesCompleted: 5,
        lastActiveAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      expect(stats.isActive, true);
    });

    test('isActive should return false for inactive CHW', () {
      final stats = ChwPerformanceStats(
        chwId: 'CHW-002',
        chwName: 'Inactive CHW',
        screeningsCompleted: 10,
        referralsMade: 2,
        avgRiskScore: 0.3,
        trainingModulesCompleted: 2,
        lastActiveAt: DateTime.now().subtract(const Duration(days: 14)),
      );

      expect(stats.isActive, false);
    });

    test('isActive boundary at 7 days', () {
      // Exactly 7 days ago should be inactive
      final stats = ChwPerformanceStats(
        chwId: 'CHW-003',
        chwName: 'Boundary CHW',
        screeningsCompleted: 30,
        referralsMade: 8,
        avgRiskScore: 0.35,
        trainingModulesCompleted: 3,
        lastActiveAt: DateTime.now().subtract(const Duration(days: 7)),
      );

      expect(stats.isActive, false);
    });

    test('fromMap should restore all fields', () {
      final map = {
        'chw_id': 'CHW-100',
        'chw_name': 'Jane Smith',
        'screenings_completed': 75,
        'referrals_made': 20,
        'avg_risk_score': 0.5,
        'training_modules_completed': 8,
        'last_active_at': '2024-01-15T10:30:00.000',
      };

      final stats = ChwPerformanceStats.fromMap(map);

      expect(stats.chwId, 'CHW-100');
      expect(stats.chwName, 'Jane Smith');
      expect(stats.screeningsCompleted, 75);
      expect(stats.referralsMade, 20);
      expect(stats.avgRiskScore, 0.5);
      expect(stats.trainingModulesCompleted, 8);
      expect(stats.lastActiveAt.day, 15);
    });

    test('fromMap should handle missing optional fields', () {
      final map = {
        'chw_id': 'CHW-200',
        'chw_name': 'New CHW',
        'last_active_at': '2024-02-01T00:00:00.000',
      };

      final stats = ChwPerformanceStats.fromMap(map);

      expect(stats.screeningsCompleted, 0);
      expect(stats.referralsMade, 0);
      expect(stats.avgRiskScore, 0);
      expect(stats.trainingModulesCompleted, 0);
    });
  });

  group('DashboardStats - dailyGrowthRate', () {
    test('dailyGrowthRate should return 10 for positive screenings', () {
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
        lastUpdated: DateTime.now(),
      );

      expect(stats.dailyGrowthRate, 10.0);
    });

    test('dailyGrowthRate should return 0 for zero screenings today', () {
      final stats = DashboardStats(
        totalScreenings: 100,
        screeningsToday: 0,
        screeningsThisWeek: 25,
        screeningsThisMonth: 80,
        totalReferrals: 20,
        pendingReferrals: 5,
        completedReferrals: 15,
        avgRiskScore: 0.45,
        highRiskCount: 10,
        mediumRiskCount: 30,
        lowRiskCount: 60,
        lastUpdated: DateTime.now(),
      );

      expect(stats.dailyGrowthRate, 0.0);
    });
  });

  group('DashboardStats - fromMap edge cases', () {
    test('fromMap should handle null values', () {
      final map = <String, dynamic>{
        'last_updated': null,
      };

      final stats = DashboardStats.fromMap(map);

      expect(stats.totalScreenings, 0);
      expect(stats.avgRiskScore, 0);
      expect(stats.lastUpdated, isNotNull);
    });

    test('fromMap should handle numeric type conversion', () {
      final map = {
        'total_screenings': 100,
        'screenings_today': 5,
        'screenings_this_week': 25,
        'screenings_this_month': 80,
        'total_referrals': 20,
        'pending_referrals': 5,
        'completed_referrals': 15,
        'avg_risk_score': 0.45,  // double
        'high_risk_count': 10,
        'medium_risk_count': 30,
        'low_risk_count': 60,
        'last_updated': '2024-01-15T00:00:00.000',
      };

      final stats = DashboardStats.fromMap(map);

      expect(stats.avgRiskScore, 0.45);
    });
  });

  group('TimeSeriesDataPoint - edge cases', () {
    test('toMap should not include null label', () {
      final point = TimeSeriesDataPoint(
        date: DateTime(2024, 1, 15),
        value: 10.0,
      );

      final map = point.toMap();

      expect(map.containsKey('label'), false);
    });
  });
}

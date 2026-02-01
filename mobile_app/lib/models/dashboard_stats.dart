/// Dashboard Statistics Model
/// STORY-028: Screening Statistics Dashboard
///
/// 대시보드 통계 데이터 모델입니다.
library;

/// 전체 통계 요약
class DashboardStats {
  final int totalScreenings;
  final int screeningsToday;
  final int screeningsThisWeek;
  final int screeningsThisMonth;
  final int totalReferrals;
  final int pendingReferrals;
  final int completedReferrals;
  final double avgRiskScore;
  final int highRiskCount;
  final int mediumRiskCount;
  final int lowRiskCount;
  final DateTime lastUpdated;

  const DashboardStats({
    required this.totalScreenings,
    required this.screeningsToday,
    required this.screeningsThisWeek,
    required this.screeningsThisMonth,
    required this.totalReferrals,
    required this.pendingReferrals,
    required this.completedReferrals,
    required this.avgRiskScore,
    required this.highRiskCount,
    required this.mediumRiskCount,
    required this.lowRiskCount,
    required this.lastUpdated,
  });

  /// 오늘 vs 어제 비교 (%)
  double get dailyGrowthRate => screeningsToday > 0 ? 10.0 : 0.0; // TODO: 실제 계산

  /// 고위험 비율
  double get highRiskRate => 
      totalScreenings > 0 ? highRiskCount / totalScreenings : 0;

  /// 의뢰 완료율
  double get referralCompletionRate => 
      totalReferrals > 0 ? completedReferrals / totalReferrals : 0;

  factory DashboardStats.empty() {
    return DashboardStats(
      totalScreenings: 0,
      screeningsToday: 0,
      screeningsThisWeek: 0,
      screeningsThisMonth: 0,
      totalReferrals: 0,
      pendingReferrals: 0,
      completedReferrals: 0,
      avgRiskScore: 0,
      highRiskCount: 0,
      mediumRiskCount: 0,
      lowRiskCount: 0,
      lastUpdated: DateTime.now(),
    );
  }

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      totalScreenings: map['total_screenings'] as int? ?? 0,
      screeningsToday: map['screenings_today'] as int? ?? 0,
      screeningsThisWeek: map['screenings_this_week'] as int? ?? 0,
      screeningsThisMonth: map['screenings_this_month'] as int? ?? 0,
      totalReferrals: map['total_referrals'] as int? ?? 0,
      pendingReferrals: map['pending_referrals'] as int? ?? 0,
      completedReferrals: map['completed_referrals'] as int? ?? 0,
      avgRiskScore: (map['avg_risk_score'] as num?)?.toDouble() ?? 0,
      highRiskCount: map['high_risk_count'] as int? ?? 0,
      mediumRiskCount: map['medium_risk_count'] as int? ?? 0,
      lowRiskCount: map['low_risk_count'] as int? ?? 0,
      lastUpdated: map['last_updated'] != null 
          ? DateTime.parse(map['last_updated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_screenings': totalScreenings,
      'screenings_today': screeningsToday,
      'screenings_this_week': screeningsThisWeek,
      'screenings_this_month': screeningsThisMonth,
      'total_referrals': totalReferrals,
      'pending_referrals': pendingReferrals,
      'completed_referrals': completedReferrals,
      'avg_risk_score': avgRiskScore,
      'high_risk_count': highRiskCount,
      'medium_risk_count': mediumRiskCount,
      'low_risk_count': lowRiskCount,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

/// 시계열 데이터 포인트
class TimeSeriesDataPoint {
  final DateTime date;
  final double value;
  final String? label;

  const TimeSeriesDataPoint({
    required this.date,
    required this.value,
    this.label,
  });

  factory TimeSeriesDataPoint.fromMap(Map<String, dynamic> map) {
    return TimeSeriesDataPoint(
      date: DateTime.parse(map['date'] as String),
      value: (map['value'] as num).toDouble(),
      label: map['label'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      if (label != null) 'label': label,
    };
  }
}

/// 차트 데이터
class ChartData {
  final String title;
  final List<TimeSeriesDataPoint> dataPoints;
  final ChartType chartType;
  final String? unit;

  const ChartData({
    required this.title,
    required this.dataPoints,
    this.chartType = ChartType.line,
    this.unit,
  });

  /// 최대값
  double get maxValue => dataPoints.isEmpty 
      ? 0 
      : dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);

  /// 최소값
  double get minValue => dataPoints.isEmpty 
      ? 0 
      : dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);

  /// 평균값
  double get avgValue => dataPoints.isEmpty 
      ? 0 
      : dataPoints.map((p) => p.value).reduce((a, b) => a + b) / dataPoints.length;
}

/// 차트 유형
enum ChartType {
  line,
  bar,
  pie,
  area,
}

/// 위험 수준 분포
class RiskDistribution {
  final int highRisk;
  final int mediumRisk;
  final int lowRisk;
  final int noRisk;

  const RiskDistribution({
    required this.highRisk,
    required this.mediumRisk,
    required this.lowRisk,
    required this.noRisk,
  });

  int get total => highRisk + mediumRisk + lowRisk + noRisk;

  double get highRiskPercent => total > 0 ? highRisk / total * 100 : 0;
  double get mediumRiskPercent => total > 0 ? mediumRisk / total * 100 : 0;
  double get lowRiskPercent => total > 0 ? lowRisk / total * 100 : 0;
  double get noRiskPercent => total > 0 ? noRisk / total * 100 : 0;

  factory RiskDistribution.empty() {
    return const RiskDistribution(
      highRisk: 0,
      mediumRisk: 0,
      lowRisk: 0,
      noRisk: 0,
    );
  }

  factory RiskDistribution.fromMap(Map<String, dynamic> map) {
    return RiskDistribution(
      highRisk: map['high_risk'] as int? ?? 0,
      mediumRisk: map['medium_risk'] as int? ?? 0,
      lowRisk: map['low_risk'] as int? ?? 0,
      noRisk: map['no_risk'] as int? ?? 0,
    );
  }
}

/// 지역별 통계
class RegionalStats {
  final String regionCode;
  final String regionName;
  final int screeningCount;
  final int referralCount;
  final double avgRiskScore;
  final int chwCount;

  const RegionalStats({
    required this.regionCode,
    required this.regionName,
    required this.screeningCount,
    required this.referralCount,
    required this.avgRiskScore,
    required this.chwCount,
  });

  /// 스크리닝 당 의뢰 비율
  double get referralRate => 
      screeningCount > 0 ? referralCount / screeningCount : 0;

  /// CHW 당 스크리닝 수
  double get screeningsPerChw => 
      chwCount > 0 ? screeningCount / chwCount : 0;

  factory RegionalStats.fromMap(Map<String, dynamic> map) {
    return RegionalStats(
      regionCode: map['region_code'] as String,
      regionName: map['region_name'] as String,
      screeningCount: map['screening_count'] as int? ?? 0,
      referralCount: map['referral_count'] as int? ?? 0,
      avgRiskScore: (map['avg_risk_score'] as num?)?.toDouble() ?? 0,
      chwCount: map['chw_count'] as int? ?? 0,
    );
  }
}

/// CHW 성과 통계
class ChwPerformanceStats {
  final String chwId;
  final String chwName;
  final int screeningsCompleted;
  final int referralsMade;
  final double avgRiskScore;
  final int trainingModulesCompleted;
  final DateTime lastActiveAt;

  const ChwPerformanceStats({
    required this.chwId,
    required this.chwName,
    required this.screeningsCompleted,
    required this.referralsMade,
    required this.avgRiskScore,
    required this.trainingModulesCompleted,
    required this.lastActiveAt,
  });

  /// 활동 상태
  bool get isActive {
    final diff = DateTime.now().difference(lastActiveAt);
    return diff.inDays < 7;
  }

  factory ChwPerformanceStats.fromMap(Map<String, dynamic> map) {
    return ChwPerformanceStats(
      chwId: map['chw_id'] as String,
      chwName: map['chw_name'] as String,
      screeningsCompleted: map['screenings_completed'] as int? ?? 0,
      referralsMade: map['referrals_made'] as int? ?? 0,
      avgRiskScore: (map['avg_risk_score'] as num?)?.toDouble() ?? 0,
      trainingModulesCompleted: map['training_modules_completed'] as int? ?? 0,
      lastActiveAt: DateTime.parse(map['last_active_at'] as String),
    );
  }
}

/// Dashboard Service
/// STORY-028: Screening Statistics Dashboard
///
/// 대시보드 데이터 조회 서비스입니다.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dashboard_stats.dart';
import '../models/screening.dart';

/// 대시보드 서비스
class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  Database? _database;

  /// 초기화
  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'neuro_access.db');

    _database = await openDatabase(path, version: 1);
    debugPrint('✓ DashboardService initialized');
  }

  /// 전체 통계 조회
  Future<DashboardStats> getOverallStats() async {
    final db = _database;
    if (db == null) return DashboardStats.empty();

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(const Duration(days: 7));
      final monthAgo = DateTime(now.year, now.month - 1, now.day);

      // 총 스크리닝 수
      final totalScreenings = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM screenings'),
      ) ?? 0;

      // 오늘 스크리닝
      final screeningsToday = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE created_at >= ?',
          [today.toIso8601String()],
        ),
      ) ?? 0;

      // 이번 주 스크리닝
      final screeningsThisWeek = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE created_at >= ?',
          [weekAgo.toIso8601String()],
        ),
      ) ?? 0;

      // 이번 달 스크리닝
      final screeningsThisMonth = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE created_at >= ?',
          [monthAgo.toIso8601String()],
        ),
      ) ?? 0;

      // 의뢰 통계
      final totalReferrals = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM referrals'),
      ) ?? 0;

      final pendingReferrals = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM referrals WHERE status = 'pending'",
        ),
      ) ?? 0;

      final completedReferrals = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM referrals WHERE status = 'completed'",
        ),
      ) ?? 0;

      // 위험 수준별 통계
      final avgRiskResult = await db.rawQuery(
        'SELECT AVG(risk_score) as avg FROM screenings',
      );
      final avgRiskScore = avgRiskResult.isNotEmpty 
          ? (avgRiskResult.first['avg'] as num?)?.toDouble() ?? 0.0
          : 0.0;

      final highRiskCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE risk_score >= 0.7',
        ),
      ) ?? 0;

      final mediumRiskCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE risk_score >= 0.4 AND risk_score < 0.7',
        ),
      ) ?? 0;

      final lowRiskCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE risk_score < 0.4',
        ),
      ) ?? 0;

      return DashboardStats(
        totalScreenings: totalScreenings,
        screeningsToday: screeningsToday,
        screeningsThisWeek: screeningsThisWeek,
        screeningsThisMonth: screeningsThisMonth,
        totalReferrals: totalReferrals,
        pendingReferrals: pendingReferrals,
        completedReferrals: completedReferrals,
        avgRiskScore: avgRiskScore,
        highRiskCount: highRiskCount,
        mediumRiskCount: mediumRiskCount,
        lowRiskCount: lowRiskCount,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('✗ Error getting dashboard stats: $e');
      return DashboardStats.empty();
    }
  }

  /// 일별 스크리닝 트렌드 (최근 30일)
  Future<ChartData> getDailyScreeningTrend({int days = 30}) async {
    final db = _database;
    final dataPoints = <TimeSeriesDataPoint>[];
    
    if (db == null) {
      return ChartData(
        title: '일별 스크리닝',
        dataPoints: dataPoints,
        chartType: ChartType.line,
      );
    }

    try {
      for (int i = days - 1; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final count = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM screenings WHERE created_at >= ? AND created_at < ?',
            [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
          ),
        ) ?? 0;

        dataPoints.add(TimeSeriesDataPoint(
          date: startOfDay,
          value: count.toDouble(),
        ));
      }

      return ChartData(
        title: '일별 스크리닝',
        dataPoints: dataPoints,
        chartType: ChartType.line,
        unit: '건',
      );
    } catch (e) {
      debugPrint('✗ Error getting daily trend: $e');
      return ChartData(
        title: '일별 스크리닝',
        dataPoints: dataPoints,
        chartType: ChartType.line,
      );
    }
  }

  /// 위험 수준 분포
  Future<RiskDistribution> getRiskDistribution() async {
    final db = _database;
    if (db == null) return RiskDistribution.empty();

    try {
      final highRisk = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE risk_score >= 0.7',
        ),
      ) ?? 0;

      final mediumRisk = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE risk_score >= 0.4 AND risk_score < 0.7',
        ),
      ) ?? 0;

      final lowRisk = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE risk_score >= 0.1 AND risk_score < 0.4',
        ),
      ) ?? 0;

      final noRisk = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM screenings WHERE risk_score < 0.1',
        ),
      ) ?? 0;

      return RiskDistribution(
        highRisk: highRisk,
        mediumRisk: mediumRisk,
        lowRisk: lowRisk,
        noRisk: noRisk,
      );
    } catch (e) {
      debugPrint('✗ Error getting risk distribution: $e');
      return RiskDistribution.empty();
    }
  }

  /// 최근 스크리닝 목록
  Future<List<Screening>> getRecentScreenings({int limit = 10}) async {
    final db = _database;
    if (db == null) return [];

    try {
      final maps = await db.query(
        'screenings',
        orderBy: 'created_at DESC',
        limit: limit,
      );

      return maps.map((m) => Screening.fromMap(m)).toList();
    } catch (e) {
      debugPrint('✗ Error getting recent screenings: $e');
      return [];
    }
  }

  /// 고위험 스크리닝 목록
  Future<List<Screening>> getHighRiskScreenings({int limit = 10}) async {
    final db = _database;
    if (db == null) return [];

    try {
      final maps = await db.query(
        'screenings',
        where: 'risk_score >= ?',
        whereArgs: [0.7],
        orderBy: 'risk_score DESC',
        limit: limit,
      );

      return maps.map((m) => Screening.fromMap(m)).toList();
    } catch (e) {
      debugPrint('✗ Error getting high risk screenings: $e');
      return [];
    }
  }

  void dispose() {
    _database?.close();
  }
}

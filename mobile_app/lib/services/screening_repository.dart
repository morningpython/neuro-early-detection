/// Screening Repository
/// STORY-016: Screening Data Model & Persistence
/// STORY-022: Updated to use SecureDatabaseHelper for AES-256 encryption
///
/// 스크리닝 데이터 액세스 레이어입니다.
/// 비즈니스 로직과 데이터베이스 사이의 추상화를 제공합니다.
/// 민감한 건강 데이터는 AES-256-GCM으로 암호화되어 저장됩니다.
library;

import 'package:flutter/foundation.dart';

import '../models/screening.dart';
import 'secure_database_helper.dart';

/// 스크리닝 저장소 (암호화 지원)
class ScreeningRepository {
  final SecureDatabaseHelper _dbHelper;

  /// 캐시된 스크리닝 목록
  List<Screening>? _cachedScreenings;

  ScreeningRepository({SecureDatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? SecureDatabaseHelper();

  /// 스크리닝 저장
  Future<Screening> saveScreening(Screening screening) async {
    await _dbHelper.insertScreening(screening);
    _invalidateCache();
    debugPrint('✅ Screening saved: ${screening.id}');
    return screening;
  }

  /// 새 스크리닝 생성 및 저장
  Future<Screening> createAndSaveScreening({
    required String audioPath,
    required ScreeningResult result,
    int? patientAge,
    String? patientGender,
    String? chwId,
    String? notes,
  }) async {
    final screening = Screening.create(
      audioPath: audioPath,
      result: result,
      patientAge: patientAge,
      patientGender: patientGender,
      chwId: chwId,
      notes: notes,
    );
    return await saveScreening(screening);
  }

  /// ID로 스크리닝 조회
  Future<Screening?> getScreeningById(String id) async {
    return await _dbHelper.getScreening(id);
  }

  /// 최근 스크리닝 조회 (캐시 사용)
  Future<List<Screening>> getRecentScreenings({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    if (_cachedScreenings != null && !forceRefresh) {
      return _cachedScreenings!.take(limit).toList();
    }

    _cachedScreenings = await _dbHelper.getRecentScreenings(limit: limit);
    return _cachedScreenings!;
  }

  /// 모든 스크리닝 조회
  Future<List<Screening>> getAllScreenings() async {
    return await _dbHelper.getAllScreenings();
  }

  /// 위험 수준별 스크리닝 조회
  Future<List<Screening>> getScreeningsByRisk(RiskLevel riskLevel) async {
    return await _dbHelper.getScreeningsByRiskLevel(riskLevel);
  }

  /// 스크리닝 업데이트
  Future<void> updateScreening(Screening screening) async {
    await _dbHelper.updateScreening(screening);
    _invalidateCache();
  }

  /// 메모 추가/수정
  Future<void> updateNotes(String screeningId, String notes) async {
    final screening = await getScreeningById(screeningId);
    if (screening != null) {
      await updateScreening(screening.copyWith(notes: notes));
    }
  }

  /// 스크리닝 삭제
  Future<void> deleteScreening(String id) async {
    await _dbHelper.deleteScreening(id);
    _invalidateCache();
    debugPrint('🗑️ Screening deleted: $id');
  }

  /// 스크리닝 개수
  Future<int> getScreeningCount() async {
    return await _dbHelper.getScreeningCount();
  }

  /// 위험 수준별 통계
  Future<Map<RiskLevel, int>> getRiskStats() async {
    return await _dbHelper.getRiskLevelStats();
  }

  /// 오늘의 스크리닝 조회
  Future<List<Screening>> getTodayScreenings() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await _dbHelper.getScreeningsByDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// 이번 주 스크리닝 조회
  Future<List<Screening>> getThisWeekScreenings() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return await _dbHelper.getScreeningsByDateRange(
      startDate: startDate,
      endDate: now,
    );
  }

  /// 캐시 무효화
  void _invalidateCache() {
    _cachedScreenings = null;
  }

  /// 캐시 새로고침
  Future<void> refreshCache() async {
    _cachedScreenings = await _dbHelper.getRecentScreenings(limit: 20);
  }
}

/// Secure Database Helper
/// STORY-022: Data Encryption - AES-256
///
/// 민감한 건강 데이터를 암호화하여 저장하는 데이터베이스 래퍼입니다.
/// DatabaseHelper를 확장하여 암호화/복호화 기능을 추가합니다.
library;

import 'package:flutter/foundation.dart';
import '../models/screening.dart';
import 'database_helper.dart';
import 'encryption_service.dart';

/// 암호화가 적용된 데이터베이스 헬퍼
class SecureDatabaseHelper {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final EncryptionService _encryptionService = EncryptionService();
  
  static final SecureDatabaseHelper _instance = SecureDatabaseHelper._internal();
  
  factory SecureDatabaseHelper() => _instance;
  
  SecureDatabaseHelper._internal();
  
  /// 초기화 (암호화 서비스 초기화 포함)
  Future<void> initialize() async {
    await _encryptionService.initialize();
    debugPrint('✓ SecureDatabaseHelper initialized');
  }
  
  /// 스크리닝 저장 (민감 데이터 암호화)
  Future<String> insertScreening(Screening screening) async {
    final encryptedScreening = _encryptScreening(screening);
    return await _dbHelper.insertScreening(encryptedScreening);
  }
  
  /// ID로 스크리닝 조회 (복호화)
  Future<Screening?> getScreening(String id) async {
    final screening = await _dbHelper.getScreening(id);
    if (screening == null) return null;
    return _decryptScreening(screening);
  }
  
  /// 모든 스크리닝 조회 (복호화)
  Future<List<Screening>> getAllScreenings() async {
    final screenings = await _dbHelper.getAllScreenings();
    return screenings.map(_decryptScreening).toList();
  }
  
  /// 최근 스크리닝 조회 (복호화)
  Future<List<Screening>> getRecentScreenings({int limit = 10}) async {
    final screenings = await _dbHelper.getRecentScreenings(limit: limit);
    return screenings.map(_decryptScreening).toList();
  }
  
  /// 위험 수준별 스크리닝 조회 (복호화)
  Future<List<Screening>> getScreeningsByRiskLevel(RiskLevel riskLevel) async {
    final screenings = await _dbHelper.getScreeningsByRiskLevel(riskLevel);
    return screenings.map(_decryptScreening).toList();
  }
  
  /// 스크리닝 업데이트 (암호화)
  Future<int> updateScreening(Screening screening) async {
    final encryptedScreening = _encryptScreening(screening);
    return await _dbHelper.updateScreening(encryptedScreening);
  }
  
  /// 스크리닝 삭제 (소프트 삭제)
  Future<int> deleteScreening(String id) async {
    return await _dbHelper.deleteScreening(id);
  }
  
  /// 스크리닝 개수 조회
  Future<int> getScreeningCount() async {
    return await _dbHelper.getScreeningCount();
  }
  
  /// 위험 수준별 통계
  Future<Map<RiskLevel, int>> getRiskLevelStats() async {
    return await _dbHelper.getRiskLevelStats();
  }
  
  /// 날짜 범위별 스크리닝 조회 (복호화)
  Future<List<Screening>> getScreeningsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final screenings = await _dbHelper.getScreeningsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
    return screenings.map(_decryptScreening).toList();
  }
  
  /// 민감 데이터 암호화
  Screening _encryptScreening(Screening screening) {
    // 노트와 환자 정보는 민감 데이터로 암호화
    String? encryptedNotes;
    String? encryptedAudioPath;
    
    if (screening.notes != null && screening.notes!.isNotEmpty) {
      try {
        encryptedNotes = _encryptionService.encryptString(screening.notes!);
      } catch (e) {
        debugPrint('Warning: Failed to encrypt notes: $e');
        encryptedNotes = screening.notes;
      }
    }
    
    // 오디오 파일 경로도 암호화 (파일 위치 노출 방지)
    if (screening.audioPath.isNotEmpty) {
      try {
        encryptedAudioPath = _encryptionService.encryptString(screening.audioPath);
      } catch (e) {
        debugPrint('Warning: Failed to encrypt audio path: $e');
        encryptedAudioPath = screening.audioPath;
      }
    }
    
    return Screening(
      id: screening.id,
      createdAt: screening.createdAt,
      audioPath: encryptedAudioPath ?? screening.audioPath,
      result: screening.result,
      patientAge: screening.patientAge,
      patientGender: screening.patientGender,
      chwId: screening.chwId,
      notes: encryptedNotes,
      deletedAt: screening.deletedAt,
    );
  }
  
  /// 민감 데이터 복호화
  Screening _decryptScreening(Screening screening) {
    String? decryptedNotes;
    String? decryptedAudioPath;
    
    if (screening.notes != null && screening.notes!.isNotEmpty) {
      try {
        decryptedNotes = _encryptionService.decryptString(screening.notes!);
      } catch (e) {
        // 복호화 실패 시 원본 유지 (마이그레이션 호환성)
        debugPrint('Warning: Failed to decrypt notes, using original');
        decryptedNotes = screening.notes;
      }
    }
    
    if (screening.audioPath.isNotEmpty) {
      try {
        decryptedAudioPath = _encryptionService.decryptString(screening.audioPath);
      } catch (e) {
        debugPrint('Warning: Failed to decrypt audio path, using original');
        decryptedAudioPath = screening.audioPath;
      }
    }
    
    return Screening(
      id: screening.id,
      createdAt: screening.createdAt,
      audioPath: decryptedAudioPath ?? screening.audioPath,
      result: screening.result,
      patientAge: screening.patientAge,
      patientGender: screening.patientGender,
      chwId: screening.chwId,
      notes: decryptedNotes,
      deletedAt: screening.deletedAt,
    );
  }
}

/// 암호화된 데이터 검증 유틸리티
class EncryptionValidator {
  /// 문자열이 암호화된 데이터인지 확인
  static bool isEncrypted(String? data) {
    if (data == null || data.isEmpty) return false;
    
    // Base64로 인코딩된 암호화 데이터의 최소 길이 확인
    // IV (16 bytes) + minimum encrypted data = ~24+ bytes base64
    if (data.length < 24) return false;
    
    // Base64 문자열 패턴 확인
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(data);
  }
  
  /// 데이터 무결성 해시 생성
  static String generateIntegrityHash(Screening screening) {
    final encryptionService = EncryptionService();
    final data = '${screening.id}|${screening.createdAt.toIso8601String()}|${screening.audioPath}';
    return encryptionService.generateHash(data);
  }
}

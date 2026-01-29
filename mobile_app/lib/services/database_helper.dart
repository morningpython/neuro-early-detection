/// Database Helper
/// STORY-015: SQLite Database Setup
///
/// SQLite 데이터베이스 관리를 위한 헬퍼 클래스입니다.
/// 싱글톤 패턴을 사용하여 앱 전체에서 하나의 인스턴스만 사용합니다.
library;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/screening.dart';

/// 데이터베이스 헬퍼 (싱글톤)
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// 데이터베이스 이름
  static const String _databaseName = 'neuroAccess.db';
  
  /// 데이터베이스 버전
  static const int _databaseVersion = 1;

  /// 테이블 이름
  static const String tableScreenings = 'screenings';

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    debugPrint('📁 Database path: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// 데이터베이스 설정 (외래 키 활성화)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🔧 Creating database tables...');

    await db.execute('''
      CREATE TABLE $tableScreenings (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        audio_path TEXT NOT NULL,
        risk_score REAL,
        risk_level TEXT,
        confidence REAL,
        features TEXT,
        patient_age INTEGER,
        patient_gender TEXT,
        chw_id TEXT,
        notes TEXT,
        deleted_at TEXT
      )
    ''');

    // 인덱스 생성 (조회 성능 향상)
    await db.execute('''
      CREATE INDEX idx_screenings_created_at 
      ON $tableScreenings (created_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_screenings_risk_level 
      ON $tableScreenings (risk_level)
    ''');

    debugPrint('✅ Database tables created successfully');
  }

  /// 데이터베이스 업그레이드
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('⬆️ Upgrading database from v$oldVersion to v$newVersion');

    // 버전별 마이그레이션 로직 추가
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE screenings ADD COLUMN new_field TEXT');
    // }
  }

  // ============ CRUD Operations ============

  /// 스크리닝 삽입
  Future<String> insertScreening(Screening screening) async {
    final db = await database;
    await db.insert(
      tableScreenings,
      screening.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('💾 Saved screening: ${screening.id}');
    return screening.id;
  }

  /// ID로 스크리닝 조회
  Future<Screening?> getScreening(String id) async {
    final db = await database;
    final maps = await db.query(
      tableScreenings,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Screening.fromMap(maps.first);
  }

  /// 모든 스크리닝 조회 (삭제되지 않은 것만)
  Future<List<Screening>> getAllScreenings() async {
    final db = await database;
    final maps = await db.query(
      tableScreenings,
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Screening.fromMap(map)).toList();
  }

  /// 최근 스크리닝 조회
  Future<List<Screening>> getRecentScreenings({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      tableScreenings,
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => Screening.fromMap(map)).toList();
  }

  /// 위험 수준별 스크리닝 조회
  Future<List<Screening>> getScreeningsByRiskLevel(RiskLevel riskLevel) async {
    final db = await database;
    final maps = await db.query(
      tableScreenings,
      where: 'risk_level = ? AND deleted_at IS NULL',
      whereArgs: [riskLevel.name],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Screening.fromMap(map)).toList();
  }

  /// 스크리닝 업데이트
  Future<int> updateScreening(Screening screening) async {
    final db = await database;
    return await db.update(
      tableScreenings,
      screening.toMap(),
      where: 'id = ?',
      whereArgs: [screening.id],
    );
  }

  /// 스크리닝 삭제 (소프트 삭제)
  Future<int> deleteScreening(String id) async {
    final db = await database;
    return await db.update(
      tableScreenings,
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 스크리닝 완전 삭제 (하드 삭제 - 테스트용)
  Future<int> hardDeleteScreening(String id) async {
    final db = await database;
    return await db.delete(
      tableScreenings,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 스크리닝 개수 조회
  Future<int> getScreeningCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableScreenings WHERE deleted_at IS NULL',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 위험 수준별 통계
  Future<Map<RiskLevel, int>> getRiskLevelStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT risk_level, COUNT(*) as count 
      FROM $tableScreenings 
      WHERE deleted_at IS NULL AND risk_level IS NOT NULL
      GROUP BY risk_level
    ''');

    final stats = <RiskLevel, int>{};
    for (final row in result) {
      final level = RiskLevel.fromString(row['risk_level'] as String);
      stats[level] = row['count'] as int;
    }
    return stats;
  }

  /// 기간별 스크리닝 조회
  Future<List<Screening>> getScreeningsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await database;
    final maps = await db.query(
      tableScreenings,
      where: 'created_at >= ? AND created_at <= ? AND deleted_at IS NULL',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Screening.fromMap(map)).toList();
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// 데이터베이스 삭제 (테스트용)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    debugPrint('🗑️ Database deleted');
  }
}

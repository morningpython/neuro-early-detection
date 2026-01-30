/// Sync Service
/// STORY-024: Offline Sync Queue
/// STORY-025: Batch Data Upload
/// STORY-026: Connection Status Monitoring
///
/// 오프라인 동기화 서비스입니다.
/// 데이터를 큐에 저장하고 연결 시 서버와 동기화합니다.
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/sync_queue.dart';
import '../models/screening.dart';
import '../models/referral.dart';

/// 연결 상태
enum ConnectionStatus {
  online('온라인', true),
  offline('오프라인', false),
  unknown('알 수 없음', false);

  const ConnectionStatus(this.label, this.isConnected);
  final String label;
  final bool isConnected;
}

/// 동기화 서비스
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Database? _database;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  // 연결 상태 스트림
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;
  
  // 동기화 진행 스트림
  final _syncProgressController = StreamController<SyncProgress>.broadcast();
  Stream<SyncProgress> get syncProgressStream => _syncProgressController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.unknown;
  ConnectionStatus get currentStatus => _currentStatus;
  
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// 초기화
  Future<void> initialize() async {
    await _initDatabase();
    await _initConnectivity();
    debugPrint('✓ SyncService initialized');
  }

  /// 데이터베이스 초기화
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sync_queue.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sync_queue (
            id TEXT PRIMARY KEY,
            created_at TEXT NOT NULL,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            operation_type TEXT NOT NULL,
            status TEXT NOT NULL,
            payload TEXT NOT NULL,
            retry_count INTEGER DEFAULT 0,
            max_retries INTEGER DEFAULT 3,
            last_attempt_at TEXT,
            error_message TEXT,
            priority INTEGER DEFAULT 10
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_sync_status ON sync_queue(status)
        ''');

        await db.execute('''
          CREATE INDEX idx_sync_priority ON sync_queue(priority, created_at)
        ''');
      },
    );
  }

  /// 연결 상태 모니터링 초기화
  Future<void> _initConnectivity() async {
    // 초기 상태 확인
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // 연결 상태 변화 구독
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// 연결 상태 업데이트
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => 
      r == ConnectivityResult.wifi || 
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet
    );

    final newStatus = hasConnection ? ConnectionStatus.online : ConnectionStatus.offline;
    
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _connectionStatusController.add(newStatus);
      debugPrint('🌐 Connection status: ${newStatus.label}');

      // 온라인으로 변경 시 자동 동기화 시도
      if (newStatus == ConnectionStatus.online && !_isSyncing) {
        syncAll();
      }
    }
  }

  /// 동기화 큐에 항목 추가
  Future<void> enqueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required Map<String, dynamic> data,
    int priority = 10,
  }) async {
    final item = SyncQueueItem.create(
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payload: jsonEncode(data),
      priority: priority,
    );

    await _database?.insert('sync_queue', item.toMap());
    debugPrint('📥 Enqueued: ${item.entityType.label} - ${item.operationType.label}');

    // 온라인이면 즉시 동기화 시도
    if (_currentStatus == ConnectionStatus.online && !_isSyncing) {
      syncAll();
    }
  }

  /// 스크리닝 동기화 큐에 추가
  Future<void> enqueueScreening(Screening screening, {SyncOperationType operation = SyncOperationType.create}) async {
    await enqueue(
      entityType: SyncEntityType.screening,
      entityId: screening.id,
      operationType: operation,
      data: screening.toMap(),
      priority: 5, // 스크리닝은 높은 우선순위
    );
  }

  /// 의뢰 동기화 큐에 추가
  Future<void> enqueueReferral(Referral referral, {SyncOperationType operation = SyncOperationType.create}) async {
    await enqueue(
      entityType: SyncEntityType.referral,
      entityId: referral.id,
      operationType: operation,
      data: referral.toMap(),
      priority: 3, // 의뢰는 가장 높은 우선순위
    );
  }

  /// 대기 중인 항목 조회
  Future<List<SyncQueueItem>> getPendingItems({int? limit}) async {
    final db = _database;
    if (db == null) return [];

    final maps = await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: [SyncStatus.pending.name],
      orderBy: 'priority ASC, created_at ASC',
      limit: limit,
    );

    return maps.map((m) => SyncQueueItem.fromMap(m)).toList();
  }

  /// 실패한 항목 조회
  Future<List<SyncQueueItem>> getFailedItems() async {
    final db = _database;
    if (db == null) return [];

    final maps = await db.query(
      'sync_queue',
      where: 'status = ? AND retry_count < max_retries',
      whereArgs: [SyncStatus.failed.name],
      orderBy: 'priority ASC, created_at ASC',
    );

    return maps.map((m) => SyncQueueItem.fromMap(m)).toList();
  }

  /// 동기화 통계 조회
  Future<SyncStats> getStats() async {
    final db = _database;
    if (db == null) {
      return const SyncStats(
        pendingCount: 0,
        inProgressCount: 0,
        completedCount: 0,
        failedCount: 0,
      );
    }

    final pending = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM sync_queue WHERE status = ?',
      [SyncStatus.pending.name],
    )) ?? 0;

    final inProgress = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM sync_queue WHERE status = ?',
      [SyncStatus.inProgress.name],
    )) ?? 0;

    final completed = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM sync_queue WHERE status = ?',
      [SyncStatus.completed.name],
    )) ?? 0;

    final failed = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM sync_queue WHERE status = ? AND retry_count < max_retries',
      [SyncStatus.failed.name],
    )) ?? 0;

    return SyncStats(
      pendingCount: pending,
      inProgressCount: inProgress,
      completedCount: completed,
      failedCount: failed,
    );
  }

  /// 모든 대기 항목 동기화
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      debugPrint('⚠️ Sync already in progress');
      return SyncResult.empty();
    }

    if (_currentStatus != ConnectionStatus.online) {
      debugPrint('⚠️ Cannot sync: offline');
      return SyncResult.empty();
    }

    _isSyncing = true;
    final errors = <String>[];
    int successCount = 0;
    int failedCount = 0;

    try {
      // 대기 중인 항목과 재시도 가능한 실패 항목 조회
      final pendingItems = await getPendingItems();
      final failedItems = await getFailedItems();
      final allItems = [...pendingItems, ...failedItems];

      final totalItems = allItems.length;
      
      if (totalItems == 0) {
        debugPrint('✓ No items to sync');
        return SyncResult.empty();
      }

      debugPrint('🔄 Starting sync: $totalItems items');

      for (int i = 0; i < allItems.length; i++) {
        final item = allItems[i];
        
        // 진행 상황 업데이트
        _syncProgressController.add(SyncProgress(
          current: i + 1,
          total: totalItems,
          currentItem: item,
        ));

        try {
          await _syncItem(item);
          successCount++;
        } catch (e) {
          failedCount++;
          errors.add('${item.entityType.label}: $e');
          debugPrint('✗ Sync failed for ${item.id}: $e');
        }

        // 작은 딜레이로 서버 부하 방지
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✓ Sync complete: $successCount success, $failedCount failed');

      return SyncResult(
        totalItems: totalItems,
        successCount: successCount,
        failedCount: failedCount,
        errors: errors,
        completedAt: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// 단일 항목 동기화
  Future<void> _syncItem(SyncQueueItem item) async {
    final db = _database;
    if (db == null) return;

    // 진행 중으로 상태 변경
    final inProgressItem = item.markInProgress();
    await db.update(
      'sync_queue',
      inProgressItem.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );

    try {
      // 실제 서버 동기화 로직 (현재는 시뮬레이션)
      await _performSync(item);

      // 성공 시 완료로 표시
      final completedItem = item.markCompleted();
      await db.update(
        'sync_queue',
        completedItem.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );

      debugPrint('✓ Synced: ${item.entityType.label} ${item.entityId}');
    } catch (e) {
      // 실패 시 상태 업데이트
      final failedItem = item.markFailed(e.toString());
      await db.update(
        'sync_queue',
        failedItem.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
      rethrow;
    }
  }

  /// 실제 서버 동기화 수행 (추후 API 연동)
  Future<void> _performSync(SyncQueueItem item) async {
    // TODO: 실제 API 호출 구현
    // 현재는 시뮬레이션 (약간의 딜레이)
    await Future.delayed(const Duration(milliseconds: 200));

    // 시뮬레이션: 랜덤하게 실패 (테스트용)
    // if (Random().nextDouble() < 0.1) {
    //   throw Exception('Simulated network error');
    // }
  }

  /// 완료된 항목 정리
  Future<int> cleanupCompleted({Duration olderThan = const Duration(days: 7)}) async {
    final db = _database;
    if (db == null) return 0;

    final cutoff = DateTime.now().subtract(olderThan).toIso8601String();
    
    return await db.delete(
      'sync_queue',
      where: 'status = ? AND created_at < ?',
      whereArgs: [SyncStatus.completed.name, cutoff],
    );
  }

  /// 특정 항목 삭제
  Future<void> removeItem(String id) async {
    await _database?.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 실패한 항목 재시도
  Future<void> retryFailed() async {
    final db = _database;
    if (db == null) return;

    await db.update(
      'sync_queue',
      {'status': SyncStatus.pending.name},
      where: 'status = ? AND retry_count < max_retries',
      whereArgs: [SyncStatus.failed.name],
    );

    if (_currentStatus == ConnectionStatus.online) {
      syncAll();
    }
  }

  /// 리소스 정리
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
    _syncProgressController.close();
    _database?.close();
  }
}

/// 동기화 진행 상황
class SyncProgress {
  final int current;
  final int total;
  final SyncQueueItem currentItem;

  const SyncProgress({
    required this.current,
    required this.total,
    required this.currentItem,
  });

  double get progress => total > 0 ? current / total : 0;
  String get description => '${currentItem.entityType.label} 동기화 중... ($current/$total)';
}

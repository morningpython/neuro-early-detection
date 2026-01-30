/// Sync Provider
/// STORY-024: Offline Sync Queue
/// STORY-026: Connection Status Monitoring
///
/// 동기화 상태 관리 프로바이더입니다.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../models/sync_queue.dart';

/// 동기화 상태 관리 프로바이더
class SyncProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  
  ConnectionStatus _connectionStatus = ConnectionStatus.unknown;
  SyncStats _stats = const SyncStats(
    pendingCount: 0,
    inProgressCount: 0,
    completedCount: 0,
    failedCount: 0,
  );
  SyncProgress? _currentProgress;
  bool _isInitialized = false;
  String? _lastError;

  StreamSubscription<ConnectionStatus>? _connectionSubscription;
  StreamSubscription<SyncProgress>? _progressSubscription;

  // Getters
  ConnectionStatus get connectionStatus => _connectionStatus;
  SyncStats get stats => _stats;
  SyncProgress? get currentProgress => _currentProgress;
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _syncService.isSyncing;
  bool get isOnline => _connectionStatus == ConnectionStatus.online;
  bool get hasPendingItems => _stats.pendingCount > 0;
  String? get lastError => _lastError;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _syncService.initialize();

      // 연결 상태 구독
      _connectionSubscription = _syncService.connectionStatusStream.listen((status) {
        _connectionStatus = status;
        notifyListeners();
      });

      // 동기화 진행 상황 구독
      _progressSubscription = _syncService.syncProgressStream.listen((progress) {
        _currentProgress = progress;
        notifyListeners();
      });

      _connectionStatus = _syncService.currentStatus;
      await refreshStats();
      
      _isInitialized = true;
      _lastError = null;
      notifyListeners();
      
      debugPrint('✓ SyncProvider initialized');
    } catch (e) {
      _lastError = e.toString();
      debugPrint('✗ SyncProvider initialization failed: $e');
      notifyListeners();
    }
  }

  /// 통계 새로고침
  Future<void> refreshStats() async {
    _stats = await _syncService.getStats();
    notifyListeners();
  }

  /// 수동 동기화 시작
  Future<SyncResult> syncNow() async {
    if (!isOnline) {
      _lastError = '오프라인 상태입니다. 인터넷 연결을 확인하세요.';
      notifyListeners();
      return SyncResult.empty();
    }

    _lastError = null;
    notifyListeners();

    try {
      final result = await _syncService.syncAll();
      _currentProgress = null;
      await refreshStats();

      if (result.failedCount > 0) {
        _lastError = '${result.failedCount}개 항목 동기화 실패';
      }

      return result;
    } catch (e) {
      _lastError = '동기화 중 오류 발생: $e';
      notifyListeners();
      return SyncResult.empty();
    }
  }

  /// 실패 항목 재시도
  Future<void> retryFailed() async {
    await _syncService.retryFailed();
    await refreshStats();
  }

  /// 완료된 항목 정리
  Future<int> cleanup({int days = 7}) async {
    final count = await _syncService.cleanupCompleted(
      olderThan: Duration(days: days),
    );
    await refreshStats();
    return count;
  }

  /// 대기 중인 항목 조회
  Future<List<SyncQueueItem>> getPendingItems() async {
    return _syncService.getPendingItems();
  }

  /// 실패한 항목 조회
  Future<List<SyncQueueItem>> getFailedItems() async {
    return _syncService.getFailedItems();
  }

  /// 연결 상태 아이콘
  String get connectionIcon {
    switch (_connectionStatus) {
      case ConnectionStatus.online:
        return '🌐';
      case ConnectionStatus.offline:
        return '📴';
      case ConnectionStatus.unknown:
        return '❓';
    }
  }

  /// 연결 상태 색상 코드
  int get connectionColorCode {
    switch (_connectionStatus) {
      case ConnectionStatus.online:
        return 0xFF4CAF50; // 녹색
      case ConnectionStatus.offline:
        return 0xFFF44336; // 빨간색
      case ConnectionStatus.unknown:
        return 0xFF9E9E9E; // 회색
    }
  }

  /// 동기화 상태 요약
  String get statusSummary {
    if (!_isInitialized) return '초기화 중...';
    
    if (isSyncing && _currentProgress != null) {
      return _currentProgress!.description;
    }

    if (_stats.totalPending > 0) {
      return '${_stats.totalPending}개 항목 대기 중';
    }

    return '동기화 완료';
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _progressSubscription?.cancel();
    _syncService.dispose();
    super.dispose();
  }
}

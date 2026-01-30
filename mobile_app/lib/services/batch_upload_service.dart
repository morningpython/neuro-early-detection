/// Batch Upload Service
/// STORY-025: Batch Data Upload
///
/// 대량 데이터 일괄 업로드 서비스입니다.
/// 다중 항목을 효율적으로 서버에 업로드합니다.
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/sync_queue.dart';
import '../models/screening.dart';
import '../models/referral.dart';

/// 배치 업로드 설정
class BatchUploadConfig {
  /// 배치당 최대 항목 수
  final int maxBatchSize;
  
  /// 요청 간 딜레이 (ms)
  final int requestDelayMs;
  
  /// 최대 재시도 횟수
  final int maxRetries;
  
  /// 재시도 간 딜레이 (ms)
  final int retryDelayMs;
  
  /// 압축 사용 여부
  final bool useCompression;
  
  /// 타임아웃 (초)
  final int timeoutSeconds;

  const BatchUploadConfig({
    this.maxBatchSize = 50,
    this.requestDelayMs = 100,
    this.maxRetries = 3,
    this.retryDelayMs = 1000,
    this.useCompression = true,
    this.timeoutSeconds = 30,
  });

  /// 저대역폭 환경용 설정
  static const BatchUploadConfig lowBandwidth = BatchUploadConfig(
    maxBatchSize: 10,
    requestDelayMs: 500,
    maxRetries: 5,
    retryDelayMs: 2000,
    useCompression: true,
    timeoutSeconds: 60,
  );

  /// 고속 연결용 설정
  static const BatchUploadConfig highSpeed = BatchUploadConfig(
    maxBatchSize: 100,
    requestDelayMs: 50,
    maxRetries: 2,
    retryDelayMs: 500,
    useCompression: false,
    timeoutSeconds: 15,
  );
}

/// 배치 업로드 결과
class BatchUploadResult {
  final int totalItems;
  final int successCount;
  final int failedCount;
  final List<BatchError> errors;
  final Duration duration;
  final DateTime completedAt;

  const BatchUploadResult({
    required this.totalItems,
    required this.successCount,
    required this.failedCount,
    required this.errors,
    required this.duration,
    required this.completedAt,
  });

  bool get isSuccess => failedCount == 0;
  double get successRate => totalItems > 0 ? successCount / totalItems : 0;

  factory BatchUploadResult.empty() {
    return BatchUploadResult(
      totalItems: 0,
      successCount: 0,
      failedCount: 0,
      errors: [],
      duration: Duration.zero,
      completedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_items': totalItems,
      'success_count': successCount,
      'failed_count': failedCount,
      'errors': errors.map((e) => e.toMap()).toList(),
      'duration_ms': duration.inMilliseconds,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}

/// 배치 에러
class BatchError {
  final String itemId;
  final String entityType;
  final String errorMessage;
  final int? errorCode;

  const BatchError({
    required this.itemId,
    required this.entityType,
    required this.errorMessage,
    this.errorCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'entity_type': entityType,
      'error_message': errorMessage,
      if (errorCode != null) 'error_code': errorCode,
    };
  }
}

/// 배치 업로드 진행 상황
class BatchUploadProgress {
  final int currentBatch;
  final int totalBatches;
  final int itemsProcessed;
  final int totalItems;
  final String? currentStatus;

  const BatchUploadProgress({
    required this.currentBatch,
    required this.totalBatches,
    required this.itemsProcessed,
    required this.totalItems,
    this.currentStatus,
  });

  double get progress => totalItems > 0 ? itemsProcessed / totalItems : 0;
  double get batchProgress => totalBatches > 0 ? currentBatch / totalBatches : 0;
  
  String get description {
    return '배치 $currentBatch/$totalBatches 업로드 중 ($itemsProcessed/$totalItems 항목)';
  }
}

/// 업로드 항목
class UploadItem {
  final String id;
  final SyncEntityType entityType;
  final SyncOperationType operation;
  final Map<String, dynamic> data;

  const UploadItem({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityType.name,
      'operation': operation.name,
      'data': data,
    };
  }
}

/// 배치 업로드 서비스
class BatchUploadService {
  static final BatchUploadService _instance = BatchUploadService._internal();
  factory BatchUploadService() => _instance;
  BatchUploadService._internal();

  BatchUploadConfig _config = const BatchUploadConfig();
  bool _isUploading = false;
  
  // 진행 상황 스트림
  final _progressController = StreamController<BatchUploadProgress>.broadcast();
  Stream<BatchUploadProgress> get progressStream => _progressController.stream;

  bool get isUploading => _isUploading;

  /// 설정 업데이트
  void updateConfig(BatchUploadConfig config) {
    _config = config;
    debugPrint('✓ BatchUploadConfig updated: maxBatchSize=${config.maxBatchSize}');
  }

  /// 스크리닝 데이터 일괄 업로드
  Future<BatchUploadResult> uploadScreenings(List<Screening> screenings) async {
    final items = screenings.map((s) => UploadItem(
      id: s.id,
      entityType: SyncEntityType.screening,
      operation: SyncOperationType.create,
      data: s.toMap(),
    )).toList();

    return uploadBatch(items);
  }

  /// 의뢰 데이터 일괄 업로드
  Future<BatchUploadResult> uploadReferrals(List<Referral> referrals) async {
    final items = referrals.map((r) => UploadItem(
      id: r.id,
      entityType: SyncEntityType.referral,
      operation: SyncOperationType.create,
      data: r.toMap(),
    )).toList();

    return uploadBatch(items);
  }

  /// 일괄 업로드 실행
  Future<BatchUploadResult> uploadBatch(List<UploadItem> items) async {
    if (_isUploading) {
      debugPrint('⚠️ Upload already in progress');
      return BatchUploadResult.empty();
    }

    if (items.isEmpty) {
      debugPrint('⚠️ No items to upload');
      return BatchUploadResult.empty();
    }

    _isUploading = true;
    final startTime = DateTime.now();
    final errors = <BatchError>[];
    int successCount = 0;

    try {
      // 배치로 분할
      final batches = _splitIntoBatches(items);
      final totalBatches = batches.length;

      debugPrint('🚀 Starting batch upload: ${items.length} items in $totalBatches batches');

      for (int batchIndex = 0; batchIndex < batches.length; batchIndex++) {
        final batch = batches[batchIndex];
        
        // 진행 상황 업데이트
        _progressController.add(BatchUploadProgress(
          currentBatch: batchIndex + 1,
          totalBatches: totalBatches,
          itemsProcessed: successCount,
          totalItems: items.length,
          currentStatus: '배치 ${batchIndex + 1} 업로드 중...',
        ));

        // 배치 업로드 실행
        final batchResult = await _uploadSingleBatch(batch, batchIndex + 1);
        
        successCount += batchResult.successCount;
        errors.addAll(batchResult.errors);

        // 배치 간 딜레이
        if (batchIndex < batches.length - 1) {
          await Future.delayed(Duration(milliseconds: _config.requestDelayMs));
        }
      }

      final duration = DateTime.now().difference(startTime);
      
      debugPrint('✓ Batch upload complete: $successCount/${items.length} success in ${duration.inSeconds}s');

      return BatchUploadResult(
        totalItems: items.length,
        successCount: successCount,
        failedCount: errors.length,
        errors: errors,
        duration: duration,
        completedAt: DateTime.now(),
      );
    } finally {
      _isUploading = false;
    }
  }

  /// 항목을 배치로 분할
  List<List<UploadItem>> _splitIntoBatches(List<UploadItem> items) {
    final batches = <List<UploadItem>>[];
    
    for (int i = 0; i < items.length; i += _config.maxBatchSize) {
      final end = (i + _config.maxBatchSize < items.length) 
          ? i + _config.maxBatchSize 
          : items.length;
      batches.add(items.sublist(i, end));
    }
    
    return batches;
  }

  /// 단일 배치 업로드
  Future<_BatchResult> _uploadSingleBatch(List<UploadItem> batch, int batchNumber) async {
    final errors = <BatchError>[];
    int successCount = 0;
    int retryCount = 0;

    while (retryCount < _config.maxRetries) {
      try {
        // 배치 데이터 준비
        final payload = _preparePayload(batch);
        
        // 서버 업로드 실행 (시뮬레이션)
        await _performUpload(payload);
        
        successCount = batch.length;
        debugPrint('  ✓ Batch $batchNumber: ${batch.length} items uploaded');
        break;
      } catch (e) {
        retryCount++;
        
        if (retryCount >= _config.maxRetries) {
          // 최대 재시도 초과 - 개별 항목 처리
          for (final item in batch) {
            errors.add(BatchError(
              itemId: item.id,
              entityType: item.entityType.name,
              errorMessage: e.toString(),
            ));
          }
          debugPrint('  ✗ Batch $batchNumber failed after $retryCount retries: $e');
        } else {
          debugPrint('  ⚠️ Batch $batchNumber retry $retryCount: $e');
          await Future.delayed(Duration(milliseconds: _config.retryDelayMs));
        }
      }
    }

    return _BatchResult(
      successCount: successCount,
      errors: errors,
    );
  }

  /// 페이로드 준비
  Map<String, dynamic> _preparePayload(List<UploadItem> items) {
    final payload = {
      'items': items.map((i) => i.toMap()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
      'batch_id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    if (_config.useCompression) {
      // 실제 환경에서는 gzip 압축 적용
      // 현재는 시뮬레이션
      payload['compressed'] = true;
    }

    return payload;
  }

  /// 서버 업로드 실행 (추후 실제 API 연동)
  Future<void> _performUpload(Map<String, dynamic> payload) async {
    // TODO: 실제 HTTP 요청 구현
    // 현재는 시뮬레이션
    await Future.delayed(Duration(milliseconds: 200));

    // 시뮬레이션: 10% 확률로 실패
    // if (Random().nextDouble() < 0.1) {
    //   throw Exception('Simulated network error');
    // }
  }

  /// 리소스 정리
  void dispose() {
    _progressController.close();
  }
}

/// 내부 배치 결과
class _BatchResult {
  final int successCount;
  final List<BatchError> errors;

  const _BatchResult({
    required this.successCount,
    required this.errors,
  });
}

/// 배치 업로드 유틸리티
class BatchUploadUtils {
  /// 엔티티 타입별로 항목 그룹화
  static Map<SyncEntityType, List<UploadItem>> groupByEntityType(List<UploadItem> items) {
    final grouped = <SyncEntityType, List<UploadItem>>{};
    
    for (final item in items) {
      grouped.putIfAbsent(item.entityType, () => []).add(item);
    }
    
    return grouped;
  }

  /// 우선순위별 정렬
  static List<UploadItem> sortByPriority(List<UploadItem> items) {
    // 의뢰 > 스크리닝 > 기타 순
    final sorted = List<UploadItem>.from(items);
    sorted.sort((a, b) {
      final priorityA = _getPriority(a.entityType);
      final priorityB = _getPriority(b.entityType);
      return priorityA.compareTo(priorityB);
    });
    return sorted;
  }

  static int _getPriority(SyncEntityType type) {
    switch (type) {
      case SyncEntityType.referral:
        return 1;
      case SyncEntityType.screening:
        return 2;
      case SyncEntityType.trainingProgress:
        return 3;
      case SyncEntityType.chwProfile:
        return 4;
    }
  }

  /// 페이로드 크기 추정 (bytes)
  static int estimatePayloadSize(List<UploadItem> items) {
    final json = jsonEncode(items.map((i) => i.toMap()).toList());
    return utf8.encode(json).length;
  }

  /// 업로드 시간 추정 (초)
  static double estimateUploadTime(
    List<UploadItem> items, {
    double bandwidthKbps = 100, // 기본 100 Kbps (2G)
  }) {
    final sizeBytes = estimatePayloadSize(items);
    final sizeKb = sizeBytes / 1024;
    return sizeKb / (bandwidthKbps / 8); // Kbps to KB/s
  }
}

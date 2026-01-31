import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/screening.dart';
import 'package:neuro_access/models/referral.dart';
import 'package:neuro_access/services/batch_upload_service.dart';
import 'package:neuro_access/models/sync_queue.dart';

/// Batch Upload Service Tests
/// 
/// Note: Full batch upload tests require mocking HTTP client
/// These tests verify the model contracts and batch logic
void main() {
  group('BatchUploadConfig', () {
    test('default config values', () {
      const config = BatchUploadConfig();
      
      expect(config.maxBatchSize, 50);
      expect(config.requestDelayMs, 100);
      expect(config.maxRetries, 3);
      expect(config.retryDelayMs, 1000);
      expect(config.useCompression, true);
      expect(config.timeoutSeconds, 30);
    });

    test('low bandwidth config', () {
      const config = BatchUploadConfig.lowBandwidth;
      
      expect(config.maxBatchSize, 10);
      expect(config.requestDelayMs, 500);
      expect(config.maxRetries, 5);
      expect(config.retryDelayMs, 2000);
      expect(config.useCompression, true);
      expect(config.timeoutSeconds, 60);
    });

    test('high speed config', () {
      const config = BatchUploadConfig.highSpeed;
      
      expect(config.maxBatchSize, 100);
      expect(config.requestDelayMs, 50);
      expect(config.maxRetries, 2);
      expect(config.retryDelayMs, 500);
      expect(config.useCompression, false);
      expect(config.timeoutSeconds, 15);
    });
  });

  group('BatchUploadResult', () {
    test('should create with all fields', () {
      final result = BatchUploadResult(
        totalItems: 100,
        successCount: 95,
        failedCount: 5,
        errors: [],
        duration: const Duration(seconds: 30),
        completedAt: DateTime(2024, 1, 1),
      );
      
      expect(result.totalItems, 100);
      expect(result.successCount, 95);
      expect(result.failedCount, 5);
      expect(result.errors.isEmpty, true);
      expect(result.duration, const Duration(seconds: 30));
    });

    test('isSuccess should be true when no failures', () {
      final result = BatchUploadResult(
        totalItems: 10,
        successCount: 10,
        failedCount: 0,
        errors: [],
        duration: Duration.zero,
        completedAt: DateTime.now(),
      );
      
      expect(result.isSuccess, true);
    });

    test('isSuccess should be false when there are failures', () {
      final result = BatchUploadResult(
        totalItems: 10,
        successCount: 8,
        failedCount: 2,
        errors: [],
        duration: Duration.zero,
        completedAt: DateTime.now(),
      );
      
      expect(result.isSuccess, false);
    });

    test('successRate calculation', () {
      final result = BatchUploadResult(
        totalItems: 100,
        successCount: 80,
        failedCount: 20,
        errors: [],
        duration: Duration.zero,
        completedAt: DateTime.now(),
      );
      
      expect(result.successRate, 0.8);
    });

    test('successRate with zero items', () {
      final result = BatchUploadResult(
        totalItems: 0,
        successCount: 0,
        failedCount: 0,
        errors: [],
        duration: Duration.zero,
        completedAt: DateTime.now(),
      );
      
      expect(result.successRate, 0.0);
    });

    test('empty factory', () {
      final result = BatchUploadResult.empty();
      
      expect(result.totalItems, 0);
      expect(result.successCount, 0);
      expect(result.failedCount, 0);
      expect(result.errors.isEmpty, true);
      expect(result.duration, Duration.zero);
    });

    test('toMap should contain all fields', () {
      final result = BatchUploadResult(
        totalItems: 10,
        successCount: 8,
        failedCount: 2,
        errors: [
          const BatchError(
            itemId: 'item-1',
            entityType: 'screening',
            errorMessage: 'Test error',
          ),
        ],
        duration: const Duration(milliseconds: 5000),
        completedAt: DateTime(2024, 1, 1, 12, 0),
      );
      
      final map = result.toMap();
      
      expect(map['total_items'], 10);
      expect(map['success_count'], 8);
      expect(map['failed_count'], 2);
      expect(map['duration_ms'], 5000);
      expect(map['errors'], isA<List>());
      expect((map['errors'] as List).length, 1);
    });
  });

  group('BatchError', () {
    test('should create with required fields', () {
      const error = BatchError(
        itemId: 'item-001',
        entityType: 'screening',
        errorMessage: 'Upload failed',
      );
      
      expect(error.itemId, 'item-001');
      expect(error.entityType, 'screening');
      expect(error.errorMessage, 'Upload failed');
      expect(error.errorCode, isNull);
    });

    test('should create with optional error code', () {
      const error = BatchError(
        itemId: 'item-001',
        entityType: 'referral',
        errorMessage: 'Server error',
        errorCode: 500,
      );
      
      expect(error.errorCode, 500);
    });

    test('toMap should contain all fields', () {
      const error = BatchError(
        itemId: 'item-001',
        entityType: 'screening',
        errorMessage: 'Upload failed',
        errorCode: 500,
      );
      
      final map = error.toMap();
      
      expect(map['item_id'], 'item-001');
      expect(map['entity_type'], 'screening');
      expect(map['error_message'], 'Upload failed');
      expect(map['error_code'], 500);
    });

    test('toMap should not include error code when null', () {
      const error = BatchError(
        itemId: 'item-001',
        entityType: 'screening',
        errorMessage: 'Upload failed',
      );
      
      final map = error.toMap();
      
      expect(map.containsKey('error_code'), false);
    });
  });

  group('BatchUploadProgress', () {
    test('should create with all fields', () {
      const progress = BatchUploadProgress(
        currentBatch: 3,
        totalBatches: 10,
        itemsProcessed: 25,
        totalItems: 100,
        currentStatus: 'Uploading batch 3...',
      );
      
      expect(progress.currentBatch, 3);
      expect(progress.totalBatches, 10);
      expect(progress.itemsProcessed, 25);
      expect(progress.totalItems, 100);
      expect(progress.currentStatus, 'Uploading batch 3...');
    });

    test('progress calculation', () {
      const progress = BatchUploadProgress(
        currentBatch: 5,
        totalBatches: 10,
        itemsProcessed: 50,
        totalItems: 100,
      );
      
      expect(progress.progress, 0.5);
    });

    test('batchProgress calculation', () {
      const progress = BatchUploadProgress(
        currentBatch: 3,
        totalBatches: 10,
        itemsProcessed: 30,
        totalItems: 100,
      );
      
      expect(progress.batchProgress, 0.3);
    });

    test('progress with zero total items', () {
      const progress = BatchUploadProgress(
        currentBatch: 0,
        totalBatches: 0,
        itemsProcessed: 0,
        totalItems: 0,
      );
      
      expect(progress.progress, 0.0);
    });

    test('batchProgress with zero total batches', () {
      const progress = BatchUploadProgress(
        currentBatch: 0,
        totalBatches: 0,
        itemsProcessed: 0,
        totalItems: 0,
      );
      
      expect(progress.batchProgress, 0.0);
    });

    test('description generation', () {
      const progress = BatchUploadProgress(
        currentBatch: 3,
        totalBatches: 10,
        itemsProcessed: 25,
        totalItems: 100,
      );
      
      expect(progress.description, '배치 3/10 업로드 중 (25/100 항목)');
    });
  });

  group('UploadItem', () {
    test('should create with all fields', () {
      const item = UploadItem(
        id: 'item-001',
        entityType: SyncEntityType.screening,
        operation: SyncOperationType.create,
        data: {'key': 'value'},
      );
      
      expect(item.id, 'item-001');
      expect(item.entityType, SyncEntityType.screening);
      expect(item.operation, SyncOperationType.create);
      expect(item.data, {'key': 'value'});
    });

    test('toMap should contain all fields', () {
      const item = UploadItem(
        id: 'item-001',
        entityType: SyncEntityType.referral,
        operation: SyncOperationType.update,
        data: {'field': 'data'},
      );
      
      final map = item.toMap();
      
      expect(map['id'], 'item-001');
      expect(map['entity_type'], 'referral');
      expect(map['operation'], 'update');
      expect(map['data'], {'field': 'data'});
    });
  });

  group('BatchUploadService', () {
    late BatchUploadService service;

    setUp(() {
      service = BatchUploadService();
    });

    test('should be singleton', () {
      final instance1 = BatchUploadService();
      final instance2 = BatchUploadService();
      
      expect(identical(instance1, instance2), true);
    });

    test('isUploading should be false initially', () {
      expect(service.isUploading, false);
    });

    test('progressStream should be accessible', () {
      expect(service.progressStream, isA<Stream<BatchUploadProgress>>());
    });

    test('updateConfig should update configuration', () {
      const config = BatchUploadConfig(
        maxBatchSize: 25,
        requestDelayMs: 200,
      );
      
      service.updateConfig(config);
      // Configuration is updated internally
      // No public getter but method should complete without error
    });

    test('uploadBatch with empty items returns empty result', () async {
      final result = await service.uploadBatch([]);
      
      expect(result.totalItems, 0);
      expect(result.successCount, 0);
    });
  });

  group('BatchUploadUtils', () {
    test('groupByEntityType should group correctly', () {
      final items = [
        const UploadItem(
          id: '1',
          entityType: SyncEntityType.screening,
          operation: SyncOperationType.create,
          data: {},
        ),
        const UploadItem(
          id: '2',
          entityType: SyncEntityType.referral,
          operation: SyncOperationType.create,
          data: {},
        ),
        const UploadItem(
          id: '3',
          entityType: SyncEntityType.screening,
          operation: SyncOperationType.update,
          data: {},
        ),
      ];
      
      final grouped = BatchUploadUtils.groupByEntityType(items);
      
      expect(grouped[SyncEntityType.screening]?.length, 2);
      expect(grouped[SyncEntityType.referral]?.length, 1);
    });

    test('sortByPriority should sort referrals first', () {
      final items = [
        const UploadItem(
          id: '1',
          entityType: SyncEntityType.screening,
          operation: SyncOperationType.create,
          data: {},
        ),
        const UploadItem(
          id: '2',
          entityType: SyncEntityType.referral,
          operation: SyncOperationType.create,
          data: {},
        ),
        const UploadItem(
          id: '3',
          entityType: SyncEntityType.trainingProgress,
          operation: SyncOperationType.create,
          data: {},
        ),
      ];
      
      final sorted = BatchUploadUtils.sortByPriority(items);
      
      expect(sorted[0].entityType, SyncEntityType.referral);
      expect(sorted[1].entityType, SyncEntityType.screening);
      expect(sorted[2].entityType, SyncEntityType.trainingProgress);
    });

    test('estimatePayloadSize should return positive value', () {
      final items = [
        const UploadItem(
          id: 'item-001',
          entityType: SyncEntityType.screening,
          operation: SyncOperationType.create,
          data: {'key': 'value', 'nested': {'a': 1, 'b': 2}},
        ),
      ];
      
      final size = BatchUploadUtils.estimatePayloadSize(items);
      
      expect(size, greaterThan(0));
    });

    test('estimateUploadTime calculation', () {
      final items = List.generate(10, (i) => UploadItem(
        id: 'item-$i',
        entityType: SyncEntityType.screening,
        operation: SyncOperationType.create,
        data: {'index': i},
      ));
      
      final time = BatchUploadUtils.estimateUploadTime(
        items,
        bandwidthKbps: 100,
      );
      
      expect(time, greaterThan(0));
    });

    test('groupByEntityType with empty list', () {
      final grouped = BatchUploadUtils.groupByEntityType([]);
      
      expect(grouped.isEmpty, true);
    });

    test('sortByPriority with empty list', () {
      final sorted = BatchUploadUtils.sortByPriority([]);
      
      expect(sorted.isEmpty, true);
    });

    test('estimatePayloadSize with empty list', () {
      final size = BatchUploadUtils.estimatePayloadSize([]);
      
      expect(size, greaterThanOrEqualTo(0));
    });

    test('estimateUploadTime with zero bandwidth', () {
      final items = [
        const UploadItem(
          id: 'item-1',
          entityType: SyncEntityType.screening,
          operation: SyncOperationType.create,
          data: {'test': 'data'},
        ),
      ];
      
      // Should handle edge case of very low bandwidth
      final time = BatchUploadUtils.estimateUploadTime(
        items,
        bandwidthKbps: 1,
      );
      
      expect(time, greaterThan(0));
    });
  });

  group('BatchUploadConfig - Custom Values', () {
    test('should create with custom values', () {
      const config = BatchUploadConfig(
        maxBatchSize: 25,
        requestDelayMs: 200,
        maxRetries: 4,
        retryDelayMs: 1500,
        useCompression: false,
        timeoutSeconds: 45,
      );
      
      expect(config.maxBatchSize, 25);
      expect(config.requestDelayMs, 200);
      expect(config.maxRetries, 4);
      expect(config.retryDelayMs, 1500);
      expect(config.useCompression, false);
      expect(config.timeoutSeconds, 45);
    });

    test('low bandwidth should have higher timeout', () {
      const lowBandwidth = BatchUploadConfig.lowBandwidth;
      const highSpeed = BatchUploadConfig.highSpeed;
      
      expect(lowBandwidth.timeoutSeconds, greaterThan(highSpeed.timeoutSeconds));
    });

    test('low bandwidth should have more retries', () {
      const lowBandwidth = BatchUploadConfig.lowBandwidth;
      const highSpeed = BatchUploadConfig.highSpeed;
      
      expect(lowBandwidth.maxRetries, greaterThan(highSpeed.maxRetries));
    });

    test('low bandwidth should have smaller batch size', () {
      const lowBandwidth = BatchUploadConfig.lowBandwidth;
      const highSpeed = BatchUploadConfig.highSpeed;
      
      expect(lowBandwidth.maxBatchSize, lessThan(highSpeed.maxBatchSize));
    });
  });

  group('BatchUploadResult - Edge Cases', () {
    test('100% success rate', () {
      final result = BatchUploadResult(
        totalItems: 50,
        successCount: 50,
        failedCount: 0,
        errors: [],
        duration: const Duration(seconds: 10),
        completedAt: DateTime.now(),
      );
      
      expect(result.successRate, 1.0);
      expect(result.isSuccess, true);
    });

    test('0% success rate', () {
      final result = BatchUploadResult(
        totalItems: 50,
        successCount: 0,
        failedCount: 50,
        errors: [],
        duration: const Duration(seconds: 10),
        completedAt: DateTime.now(),
      );
      
      expect(result.successRate, 0.0);
      expect(result.isSuccess, false);
    });

    test('partial success rate', () {
      final result = BatchUploadResult(
        totalItems: 100,
        successCount: 75,
        failedCount: 25,
        errors: [],
        duration: const Duration(seconds: 30),
        completedAt: DateTime.now(),
      );
      
      expect(result.successRate, 0.75);
      expect(result.isSuccess, false);
    });
  });

  group('BatchUploadProgress - Edge Cases', () {
    test('complete progress', () {
      const progress = BatchUploadProgress(
        currentBatch: 10,
        totalBatches: 10,
        itemsProcessed: 100,
        totalItems: 100,
        currentStatus: 'Complete',
      );
      
      expect(progress.progress, 1.0);
      expect(progress.batchProgress, 1.0);
    });

    test('starting progress', () {
      const progress = BatchUploadProgress(
        currentBatch: 1,
        totalBatches: 10,
        itemsProcessed: 10,
        totalItems: 100,
        currentStatus: 'Starting...',
      );
      
      expect(progress.progress, 0.1);
      expect(progress.batchProgress, 0.1);
    });

    test('description with large numbers', () {
      const progress = BatchUploadProgress(
        currentBatch: 99,
        totalBatches: 100,
        itemsProcessed: 9900,
        totalItems: 10000,
      );
      
      expect(progress.description, contains('99/100'));
      expect(progress.description, contains('9900/10000'));
    });
  });

  group('UploadItem - Different Entity Types', () {
    test('screening item', () {
      const item = UploadItem(
        id: 'scr-001',
        entityType: SyncEntityType.screening,
        operation: SyncOperationType.create,
        data: {'patientAge': 65, 'riskScore': 0.7},
      );
      
      final map = item.toMap();
      expect(map['entity_type'], 'screening');
    });

    test('referral item', () {
      const item = UploadItem(
        id: 'ref-001',
        entityType: SyncEntityType.referral,
        operation: SyncOperationType.update,
        data: {'status': 'pending'},
      );
      
      final map = item.toMap();
      expect(map['entity_type'], 'referral');
      expect(map['operation'], 'update');
    });

    test('training progress item', () {
      const item = UploadItem(
        id: 'trn-001',
        entityType: SyncEntityType.trainingProgress,
        operation: SyncOperationType.create,
        data: {'moduleId': 'm1', 'score': 85},
      );
      
      final map = item.toMap();
      expect(map['entity_type'], 'trainingProgress');
    });

    test('delete operation', () {
      const item = UploadItem(
        id: 'del-001',
        entityType: SyncEntityType.screening,
        operation: SyncOperationType.delete,
        data: {},
      );
      
      final map = item.toMap();
      expect(map['operation'], 'delete');
    });
  });

  group('BatchError - Different Error Codes', () {
    test('client error code', () {
      const error = BatchError(
        itemId: 'item-1',
        entityType: 'screening',
        errorMessage: 'Bad request',
        errorCode: 400,
      );
      
      expect(error.errorCode, 400);
    });

    test('server error code', () {
      const error = BatchError(
        itemId: 'item-2',
        entityType: 'referral',
        errorMessage: 'Internal server error',
        errorCode: 500,
      );
      
      expect(error.errorCode, 500);
    });

    test('timeout error without code', () {
      const error = BatchError(
        itemId: 'item-3',
        entityType: 'screening',
        errorMessage: 'Request timeout',
      );
      
      final map = error.toMap();
      expect(map.containsKey('error_code'), false);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/providers/batch_upload_provider.dart';
import 'package:neuro_access/services/batch_upload_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BatchUploadProvider', () {
    late BatchUploadProvider provider;

    setUp(() {
      provider = BatchUploadProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('should not be uploading initially', () {
      expect(provider.isUploading, false);
    });

    test('currentProgress should be null initially', () {
      expect(provider.currentProgress, isNull);
    });

    test('lastResult should be null initially', () {
      expect(provider.lastResult, isNull);
    });

    test('lastError should be null initially', () {
      expect(provider.lastError, isNull);
    });

    test('progress should be zero initially', () {
      expect(provider.progress, 0.0);
    });

    test('statusText should be "대기 중" initially', () {
      expect(provider.statusText, '대기 중');
    });
  });

  group('BatchUploadProgress', () {
    test('should create with all fields', () {
      const progress = BatchUploadProgress(
        currentBatch: 2,
        totalBatches: 5,
        itemsProcessed: 20,
        totalItems: 50,
        currentStatus: 'Uploading',
      );

      expect(progress.currentBatch, 2);
      expect(progress.totalBatches, 5);
      expect(progress.itemsProcessed, 20);
      expect(progress.totalItems, 50);
    });

    test('progress should calculate correctly', () {
      const progress = BatchUploadProgress(
        currentBatch: 1,
        totalBatches: 5,
        itemsProcessed: 30,
        totalItems: 100,
      );

      expect(progress.progress, 0.3);
    });

    test('progress should handle zero total', () {
      const progress = BatchUploadProgress(
        currentBatch: 0,
        totalBatches: 0,
        itemsProcessed: 0,
        totalItems: 0,
      );

      expect(progress.progress, 0);
    });

    test('description should provide summary', () {
      const progress = BatchUploadProgress(
        currentBatch: 2,
        totalBatches: 5,
        itemsProcessed: 20,
        totalItems: 50,
      );

      expect(progress.description, contains('2/5'));
      expect(progress.description, contains('20/50'));
    });
  });

  group('BatchUploadResult', () {
    test('empty should create zero result', () {
      final result = BatchUploadResult.empty();

      expect(result.totalItems, 0);
      expect(result.successCount, 0);
      expect(result.failedCount, 0);
      expect(result.errors, isEmpty);
    });

    test('isSuccess should check failedCount', () {
      final success = BatchUploadResult(
        totalItems: 5,
        successCount: 5,
        failedCount: 0,
        errors: [],
        duration: const Duration(seconds: 10),
        completedAt: DateTime.now(),
      );

      final failure = BatchUploadResult(
        totalItems: 5,
        successCount: 3,
        failedCount: 2,
        errors: [
          const BatchError(
            itemId: 'item-1',
            entityType: 'screening',
            errorMessage: 'Failed',
          ),
        ],
        duration: const Duration(seconds: 10),
        completedAt: DateTime.now(),
      );

      expect(success.isSuccess, true);
      expect(failure.isSuccess, false);
    });

    test('successRate should calculate correctly', () {
      final result = BatchUploadResult(
        totalItems: 10,
        successCount: 8,
        failedCount: 2,
        errors: [],
        duration: const Duration(seconds: 5),
        completedAt: DateTime.now(),
      );

      expect(result.successRate, 0.8);
    });
  });

  group('BatchUploadConfig', () {
    test('lowBandwidth should have correct values', () {
      const config = BatchUploadConfig.lowBandwidth;

      expect(config.maxBatchSize, 10);
      expect(config.useCompression, true);
      expect(config.maxRetries, 5);
    });

    test('highSpeed should have correct values', () {
      const config = BatchUploadConfig.highSpeed;

      expect(config.maxBatchSize, 100);
      expect(config.useCompression, false);
      expect(config.maxRetries, 2);
    });

    test('default constructor should have correct defaults', () {
      const config = BatchUploadConfig();

      expect(config.maxBatchSize, 50);
      expect(config.useCompression, true);
      expect(config.timeoutSeconds, 30);
    });
  });

  group('BatchError', () {
    test('should create with required fields', () {
      const error = BatchError(
        itemId: 'item-001',
        entityType: 'screening',
        errorMessage: 'Network timeout',
      );

      expect(error.itemId, 'item-001');
      expect(error.entityType, 'screening');
      expect(error.errorMessage, 'Network timeout');
      expect(error.errorCode, isNull);
    });

    test('should create with error code', () {
      const error = BatchError(
        itemId: 'item-002',
        entityType: 'referral',
        errorMessage: 'Server error',
        errorCode: 500,
      );

      expect(error.errorCode, 500);
    });

    test('toMap should convert all fields', () {
      const error = BatchError(
        itemId: 'item-001',
        entityType: 'screening',
        errorMessage: 'Error',
        errorCode: 400,
      );

      final map = error.toMap();

      expect(map['item_id'], 'item-001');
      expect(map['entity_type'], 'screening');
      expect(map['error_message'], 'Error');
      expect(map['error_code'], 400);
    });
  });

  group('BatchUploadProvider - initialize', () {
    late BatchUploadProvider provider;

    setUp(() {
      provider = BatchUploadProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initialize should set up progress listener', () {
      // Should not throw
      expect(() => provider.initialize(), returnsNormally);
    });
  });

  group('BatchUploadProvider - updateConfigForNetwork', () {
    late BatchUploadProvider provider;

    setUp(() {
      provider = BatchUploadProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('should update to lowBandwidth config', () {
      expect(() => provider.updateConfigForNetwork(isLowBandwidth: true), returnsNormally);
    });

    test('should update to highSpeed config', () {
      expect(() => provider.updateConfigForNetwork(isLowBandwidth: false), returnsNormally);
    });
  });

  group('BatchUploadProvider - ChangeNotifier', () {
    late BatchUploadProvider provider;

    setUp(() {
      provider = BatchUploadProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('can add and remove listeners', () {
      var notified = false;
      void listener() {
        notified = true;
      }

      provider.addListener(listener);
      provider.removeListener(listener);

      expect(notified, false);
    });
  });
}

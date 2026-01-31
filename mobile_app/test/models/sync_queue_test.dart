import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/sync_queue.dart';

void main() {
  group('SyncOperationType', () {
    test('should have correct labels', () {
      expect(SyncOperationType.create.label, '생성');
      expect(SyncOperationType.update.label, '수정');
      expect(SyncOperationType.delete.label, '삭제');
    });

    test('fromString should parse correctly', () {
      expect(SyncOperationType.fromString('create'), SyncOperationType.create);
      expect(SyncOperationType.fromString('update'), SyncOperationType.update);
      expect(SyncOperationType.fromString('delete'), SyncOperationType.delete);
      expect(SyncOperationType.fromString('invalid'), SyncOperationType.create);
    });
  });

  group('SyncStatus', () {
    test('should have correct labels', () {
      expect(SyncStatus.pending.label, '대기중');
      expect(SyncStatus.inProgress.label, '진행중');
      expect(SyncStatus.completed.label, '완료');
      expect(SyncStatus.failed.label, '실패');
      expect(SyncStatus.cancelled.label, '취소됨');
    });

    test('should have correct color values', () {
      expect(SyncStatus.pending.colorValue, 0xFFFF9800);
      expect(SyncStatus.completed.colorValue, 0xFF4CAF50);
      expect(SyncStatus.failed.colorValue, 0xFFF44336);
    });

    test('fromString should parse correctly', () {
      expect(SyncStatus.fromString('pending'), SyncStatus.pending);
      expect(SyncStatus.fromString('completed'), SyncStatus.completed);
      expect(SyncStatus.fromString('invalid'), SyncStatus.pending);
    });
  });

  group('SyncEntityType', () {
    test('should have correct labels', () {
      expect(SyncEntityType.screening.label, '스크리닝');
      expect(SyncEntityType.referral.label, '의뢰');
      expect(SyncEntityType.trainingProgress.label, '교육 진행');
      expect(SyncEntityType.chwProfile.label, 'CHW 프로필');
    });

    test('fromString should parse correctly', () {
      expect(SyncEntityType.fromString('screening'), SyncEntityType.screening);
      expect(SyncEntityType.fromString('referral'), SyncEntityType.referral);
      expect(SyncEntityType.fromString('invalid'), SyncEntityType.screening);
    });
  });

  group('SyncQueueItem', () {
    test('should create with all required fields', () {
      final item = SyncQueueItem(
        id: 'sync-001',
        createdAt: DateTime(2024, 1, 15),
        entityType: SyncEntityType.screening,
        entityId: 'scr-001',
        operationType: SyncOperationType.create,
        status: SyncStatus.pending,
        payload: '{"test": "data"}',
      );

      expect(item.id, 'sync-001');
      expect(item.entityType, SyncEntityType.screening);
      expect(item.status, SyncStatus.pending);
      expect(item.retryCount, 0);
      expect(item.maxRetries, 3);
    });

    test('SyncQueueItem.create should auto-generate id', () {
      final item = SyncQueueItem.create(
        entityType: SyncEntityType.referral,
        entityId: 'ref-001',
        operationType: SyncOperationType.update,
        payload: '{"status": "sent"}',
      );

      expect(item.id, isNotEmpty);
      expect(item.status, SyncStatus.pending);
      expect(item.priority, 10);
    });

    test('toMap should convert all fields', () {
      final item = SyncQueueItem(
        id: 'sync-001',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        entityType: SyncEntityType.screening,
        entityId: 'scr-001',
        operationType: SyncOperationType.create,
        status: SyncStatus.pending,
        payload: '{"test": "data"}',
        retryCount: 1,
        priority: 5,
      );

      final map = item.toMap();

      expect(map['id'], 'sync-001');
      expect(map['entity_type'], 'screening');
      expect(map['entity_id'], 'scr-001');
      expect(map['operation_type'], 'create');
      expect(map['status'], 'pending');
      expect(map['retry_count'], 1);
      expect(map['priority'], 5);
    });

    test('fromMap should restore all fields', () {
      final map = {
        'id': 'sync-002',
        'created_at': '2024-01-15T10:30:00.000',
        'entity_type': 'referral',
        'entity_id': 'ref-001',
        'operation_type': 'update',
        'status': 'completed',
        'payload': '{"status": "sent"}',
        'retry_count': 2,
        'max_retries': 5,
        'priority': 3,
      };

      final item = SyncQueueItem.fromMap(map);

      expect(item.id, 'sync-002');
      expect(item.entityType, SyncEntityType.referral);
      expect(item.operationType, SyncOperationType.update);
      expect(item.status, SyncStatus.completed);
      expect(item.retryCount, 2);
      expect(item.maxRetries, 5);
    });

    test('copyWith should update specified fields', () {
      final original = SyncQueueItem(
        id: 'sync-001',
        createdAt: DateTime(2024, 1, 15),
        entityType: SyncEntityType.screening,
        entityId: 'scr-001',
        operationType: SyncOperationType.create,
        status: SyncStatus.pending,
        payload: '{}',
      );

      final updated = original.copyWith(
        status: SyncStatus.inProgress,
        retryCount: 1,
        lastAttemptAt: DateTime(2024, 1, 15, 10, 30),
      );

      expect(updated.id, 'sync-001'); // unchanged
      expect(updated.status, SyncStatus.inProgress); // updated
      expect(updated.retryCount, 1); // updated
      expect(updated.lastAttemptAt, isNotNull); // added
    });

    test('canRetry should check retry count and max retries', () {
      final canRetry = SyncQueueItem(
        id: '1',
        createdAt: DateTime.now(),
        entityType: SyncEntityType.screening,
        entityId: 'scr-001',
        operationType: SyncOperationType.create,
        status: SyncStatus.failed,
        payload: '{}',
        retryCount: 2,
        maxRetries: 3,
      );

      final cantRetry = SyncQueueItem(
        id: '2',
        createdAt: DateTime.now(),
        entityType: SyncEntityType.screening,
        entityId: 'scr-002',
        operationType: SyncOperationType.create,
        status: SyncStatus.failed,
        payload: '{}',
        retryCount: 3,
        maxRetries: 3,
      );

      expect(canRetry.canRetry, true);
      expect(cantRetry.canRetry, false);
    });

    test('markInProgress should update status', () {
      final pending = SyncQueueItem(
        id: '1',
        createdAt: DateTime.now(),
        entityType: SyncEntityType.screening,
        entityId: 'scr-001',
        operationType: SyncOperationType.create,
        status: SyncStatus.pending,
        payload: '{}',
      );

      final inProgress = pending.markInProgress();

      expect(inProgress.status, SyncStatus.inProgress);
      expect(inProgress.lastAttemptAt, isNotNull);
    });

    test('markCompleted should update status', () {
      final pending = SyncQueueItem(
        id: '1',
        createdAt: DateTime.now(),
        entityType: SyncEntityType.screening,
        entityId: 'scr-001',
        operationType: SyncOperationType.create,
        status: SyncStatus.pending,
        payload: '{}',
      );

      final completed = pending.markCompleted();

      expect(completed.status, SyncStatus.completed);
    });

    test('markFailed should update status and increment retry count', () {
      final pending = SyncQueueItem(
        id: '1',
        createdAt: DateTime.now(),
        entityType: SyncEntityType.screening,
        entityId: 'scr-001',
        operationType: SyncOperationType.create,
        status: SyncStatus.pending,
        payload: '{}',
        retryCount: 0,
      );

      final failed = pending.markFailed('Network error');

      expect(failed.status, SyncStatus.failed);
      expect(failed.retryCount, 1);
      expect(failed.errorMessage, 'Network error');
    });
  });
}

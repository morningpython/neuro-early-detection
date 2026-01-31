import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/providers/sync_provider.dart';
import 'package:neuro_access/services/sync_service.dart';
import 'package:neuro_access/models/sync_queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncProvider', () {
    late SyncProvider provider;

    setUp(() {
      provider = SyncProvider();
    });

    test('should have initial connection status unknown', () {
      expect(provider.connectionStatus, ConnectionStatus.unknown);
    });

    test('should not be initialized initially', () {
      expect(provider.isInitialized, false);
    });

    test('should not be syncing initially', () {
      expect(provider.isSyncing, false);
    });

    test('isOnline should be false for unknown status', () {
      expect(provider.isOnline, false);
    });

    test('hasPendingItems should be false with empty stats', () {
      expect(provider.hasPendingItems, false);
    });

    test('lastError should be null initially', () {
      expect(provider.lastError, isNull);
    });

    test('should have empty stats initially', () {
      final stats = provider.stats;
      expect(stats.pendingCount, 0);
      expect(stats.inProgressCount, 0);
      expect(stats.completedCount, 0);
      expect(stats.failedCount, 0);
    });

    test('currentProgress should be null initially', () {
      expect(provider.currentProgress, isNull);
    });

    test('connectionIcon should return correct icon for unknown', () {
      expect(provider.connectionIcon, '❓');
    });

    test('connectionColorCode should return correct color for unknown', () {
      expect(provider.connectionColorCode, isA<int>());
    });
  });

  group('ConnectionStatus', () {
    test('should have all required values', () {
      expect(ConnectionStatus.values.length, 3);
      expect(ConnectionStatus.values, contains(ConnectionStatus.online));
      expect(ConnectionStatus.values, contains(ConnectionStatus.offline));
      expect(ConnectionStatus.values, contains(ConnectionStatus.unknown));
    });
  });

  group('SyncStats', () {
    test('should create with all fields', () {
      const stats = SyncStats(
        pendingCount: 5,
        inProgressCount: 2,
        completedCount: 10,
        failedCount: 1,
      );

      expect(stats.pendingCount, 5);
      expect(stats.inProgressCount, 2);
      expect(stats.completedCount, 10);
      expect(stats.failedCount, 1);
    });

    test('totalCount should sum all counts', () {
      const stats = SyncStats(
        pendingCount: 5,
        inProgressCount: 2,
        completedCount: 10,
        failedCount: 3,
      );

      expect(stats.totalCount, 20);
    });

    test('hasPending should check pendingCount', () {
      const withPending = SyncStats(
        pendingCount: 3,
        inProgressCount: 0,
        completedCount: 0,
        failedCount: 0,
      );

      const noPending = SyncStats(
        pendingCount: 0,
        inProgressCount: 0,
        completedCount: 5,
        failedCount: 0,
      );

      expect(withPending.hasPending, true);
      expect(noPending.hasPending, false);
    });
  });

  group('SyncResult', () {
    test('empty should create zero result', () {
      final result = SyncResult.empty();

      expect(result.totalItems, 0);
      expect(result.successCount, 0);
      expect(result.failedCount, 0);
      expect(result.errors, isEmpty);
    });

    test('isSuccess should check failedCount', () {
      final success = SyncResult(
        totalItems: 5,
        successCount: 5,
        failedCount: 0,
        errors: [],
        completedAt: DateTime.now(),
      );

      final failure = SyncResult(
        totalItems: 5,
        successCount: 3,
        failedCount: 2,
        errors: ['Error 1', 'Error 2'],
        completedAt: DateTime.now(),
      );

      expect(success.isSuccess, true);
      expect(failure.isSuccess, false);
    });

    test('successRate should calculate correctly', () {
      final result = SyncResult(
        totalItems: 10,
        successCount: 8,
        failedCount: 2,
        errors: [],
        completedAt: DateTime.now(),
      );

      expect(result.successRate, 0.8);
    });

    test('successRate should handle zero total', () {
      final result = SyncResult.empty();
      expect(result.successRate, 0);
    });
  });
}

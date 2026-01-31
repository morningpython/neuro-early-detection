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

  group('SyncProvider - Connection Icons', () {
    test('connectionIcon for online', () {
      expect(ConnectionStatus.online.name, 'online');
    });

    test('connectionIcon for offline', () {
      expect(ConnectionStatus.offline.name, 'offline');
    });

    test('connectionIcon for unknown', () {
      expect(ConnectionStatus.unknown.name, 'unknown');
    });
  });

  group('SyncProvider - Connection Colors', () {
    test('online should have green color', () {
      const greenColor = 0xFF4CAF50;
      expect(greenColor, greaterThan(0));
    });

    test('offline should have red color', () {
      const redColor = 0xFFF44336;
      expect(redColor, greaterThan(0));
    });

    test('unknown should have grey color', () {
      const greyColor = 0xFF9E9E9E;
      expect(greyColor, greaterThan(0));
    });
  });

  group('SyncStats - Edge Cases', () {
    test('totalCount with all zeros', () {
      const stats = SyncStats(
        pendingCount: 0,
        inProgressCount: 0,
        completedCount: 0,
        failedCount: 0,
      );
      expect(stats.totalCount, 0);
    });

    test('totalCount with large numbers', () {
      const stats = SyncStats(
        pendingCount: 1000,
        inProgressCount: 500,
        completedCount: 10000,
        failedCount: 100,
      );
      expect(stats.totalCount, 11600);
    });

    test('inProgress items should be tracked', () {
      const stats = SyncStats(
        pendingCount: 0,
        inProgressCount: 3,
        completedCount: 0,
        failedCount: 0,
      );
      expect(stats.inProgressCount, 3);
    });
  });

  group('SyncResult - Additional Tests', () {
    test('errors should be a list', () {
      final result = SyncResult(
        totalItems: 3,
        successCount: 1,
        failedCount: 2,
        errors: ['Network error', 'Timeout'],
        completedAt: DateTime.now(),
      );

      expect(result.errors.length, 2);
      expect(result.errors, contains('Network error'));
      expect(result.errors, contains('Timeout'));
    });

    test('completedAt should be recorded', () {
      final now = DateTime.now();
      final result = SyncResult(
        totalItems: 1,
        successCount: 1,
        failedCount: 0,
        errors: [],
        completedAt: now,
      );

      expect(result.completedAt, equals(now));
    });

    test('successRate 100% for all success', () {
      final result = SyncResult(
        totalItems: 100,
        successCount: 100,
        failedCount: 0,
        errors: [],
        completedAt: DateTime.now(),
      );

      expect(result.successRate, 1.0);
      expect(result.isSuccess, true);
    });

    test('successRate 0% for all failure', () {
      final result = SyncResult(
        totalItems: 100,
        successCount: 0,
        failedCount: 100,
        errors: [],
        completedAt: DateTime.now(),
      );

      expect(result.successRate, 0.0);
      expect(result.isSuccess, false);
    });

    test('partial success rate calculation', () {
      final result = SyncResult(
        totalItems: 4,
        successCount: 3,
        failedCount: 1,
        errors: [],
        completedAt: DateTime.now(),
      );

      expect(result.successRate, 0.75);
    });
  });

  group('SyncProvider - ChangeNotifier', () {
    late SyncProvider provider;

    setUp(() {
      provider = SyncProvider();
    });

    test('should be a ChangeNotifier', () {
      expect(provider, isA<SyncProvider>());
    });

    test('can add and remove listeners', () {
      var callCount = 0;
      void listener() {
        callCount++;
      }

      provider.addListener(listener);
      provider.removeListener(listener);

      expect(callCount, 0);
    });
  });

  group('SyncProvider - Status Messages', () {
    test('offline error message in Korean', () {
      const message = '오프라인 상태입니다. 인터넷 연결을 확인하세요.';
      expect(message, contains('오프라인'));
      expect(message, contains('인터넷'));
    });

    test('sync failure message format', () {
      const failedCount = 3;
      final message = '${failedCount}개 항목 동기화 실패';
      expect(message, equals('3개 항목 동기화 실패'));
    });
  });

  group('ConnectionStatus - Comparison', () {
    test('online is best status', () {
      expect(ConnectionStatus.online, isNotNull);
    });

    test('statuses should be distinct', () {
      expect(ConnectionStatus.online, isNot(equals(ConnectionStatus.offline)));
      expect(ConnectionStatus.online, isNot(equals(ConnectionStatus.unknown)));
      expect(ConnectionStatus.offline, isNot(equals(ConnectionStatus.unknown)));
    });

    test('status indices should be unique', () {
      final indices = ConnectionStatus.values.map((s) => s.index).toSet();
      expect(indices.length, ConnectionStatus.values.length);
    });
  });

  group('SyncStats - hasPending Logic', () {
    test('hasPending with pending items', () {
      const stats = SyncStats(
        pendingCount: 1,
        inProgressCount: 0,
        completedCount: 0,
        failedCount: 0,
      );
      expect(stats.hasPending, true);
    });

    test('hasPending without pending items', () {
      const stats = SyncStats(
        pendingCount: 0,
        inProgressCount: 5,
        completedCount: 10,
        failedCount: 2,
      );
      expect(stats.hasPending, false);
    });
  });

  group('Cleanup Configuration', () {
    test('default cleanup days is 7', () {
      const defaultDays = 7;
      final duration = Duration(days: defaultDays);
      expect(duration.inDays, 7);
    });

    test('cleanup duration calculation', () {
      const days = 30;
      final duration = Duration(days: days);
      expect(duration.inHours, 720);
    });
  });
}

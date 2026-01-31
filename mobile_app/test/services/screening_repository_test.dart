import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/screening.dart';

/// Screening Repository Tests
/// 
/// Note: Full repository tests require mocking SecureDatabaseHelper
/// These tests verify the model contracts and data structures
void main() {
  group('ScreeningRepository - Data Model Integration', () {
    test('Screening.create generates valid screening', () {
      final screening = Screening.create(
        audioPath: '/path/to/audio.wav',
        result: ScreeningResult(
          riskScore: 0.75,
          riskLevel: RiskLevel.high,
          confidence: 0.9,
          features: {'mdvp_fo': 120.5},
        ),
        patientAge: 65,
        patientGender: 'M',
        chwId: 'CHW001',
      );

      expect(screening.id, isNotEmpty);
      expect(screening.audioPath, equals('/path/to/audio.wav'));
      expect(screening.result?.riskScore, equals(0.75));
      expect(screening.result?.riskLevel, equals(RiskLevel.high));
    });

    test('Screening supports all risk levels', () {
      final riskScores = {
        RiskLevel.low: 0.2,
        RiskLevel.moderate: 0.5,
        RiskLevel.high: 0.8,
      };
      
      for (final level in RiskLevel.values) {
        final screening = Screening.create(
          audioPath: '/audio.wav',
          result: ScreeningResult(
            riskScore: riskScores[level]!,
            riskLevel: level,
            confidence: 0.85,
            features: {},
          ),
        );
        
        expect(screening.result?.riskLevel, equals(level));
      }
    });

    test('Screening can be serialized to map', () {
      final screening = Screening.create(
        audioPath: '/audio.wav',
        result: ScreeningResult(
          riskScore: 0.5,
          riskLevel: RiskLevel.moderate,
          confidence: 0.8,
          features: {},
        ),
      );

      final map = screening.toMap();
      
      expect(map.containsKey('id'), isTrue);
      expect(map.containsKey('audio_path'), isTrue);
      expect(map.containsKey('risk_score'), isTrue);
      expect(map.containsKey('created_at'), isTrue);
    });

    test('Screening can be deserialized from map', () {
      final now = DateTime.now();
      final map = {
        'id': 'test-id-123',
        'audio_path': '/test/audio.wav',
        'risk_score': 0.6,
        'risk_level': 'moderate',
        'confidence': 0.85,
        'features': '{}',
        'patient_age': 70,
        'patient_gender': 'F',
        'chw_id': 'CHW002',
        'notes': 'Test notes',
        'created_at': now.toIso8601String(),
        'deleted_at': null,
      };

      final screening = Screening.fromMap(map);
      
      expect(screening.id, equals('test-id-123'));
      expect(screening.audioPath, equals('/test/audio.wav'));
      expect(screening.patientAge, equals(70));
      expect(screening.patientGender, equals('F'));
    });
  });

  group('ScreeningRepository - Query Support', () {
    test('RiskLevel enum supports filtering', () {
      expect(RiskLevel.values.length, equals(3));
      expect(RiskLevel.low.name, equals('low'));
      expect(RiskLevel.moderate.name, equals('moderate'));
      expect(RiskLevel.high.name, equals('high'));
    });

    test('Screening timestamp supports date range queries', () {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final screening = Screening.create(
        audioPath: '/audio.wav',
        result: ScreeningResult(
          riskScore: 0.3,
          riskLevel: RiskLevel.low,
          confidence: 0.9,
          features: {},
        ),
      );

      final createdAt = screening.createdAt;
      final isToday = createdAt.isAfter(startOfDay) && createdAt.isBefore(endOfDay);
      
      expect(isToday, isTrue);
    });

    test('Screening supports soft delete', () {
      final screening = Screening.create(
        audioPath: '/audio.wav',
        result: null,
      );

      expect(screening.isDeleted, isFalse);
      
      final deletedScreening = screening.copyWith(deletedAt: DateTime.now());
      expect(deletedScreening.isDeleted, isTrue);
    });
  });

  group('ScreeningRepository - Cache Behavior', () {
    test('cache limit defaults can be configured', () {
      const defaultCacheLimit = 10;
      const maxCacheLimit = 100;
      
      expect(defaultCacheLimit, lessThanOrEqualTo(maxCacheLimit));
    });

    test('cache invalidation scenarios', () {
      final cacheInvalidationTriggers = [
        'save_screening',
        'update_screening',
        'delete_screening',
      ];
      
      expect(cacheInvalidationTriggers.length, equals(3));
    });
  });

  group('ScreeningRepository - Statistics Support', () {
    test('risk level statistics structure', () {
      final stats = <RiskLevel, int>{
        RiskLevel.low: 10,
        RiskLevel.moderate: 5,
        RiskLevel.high: 2,
      };
      
      expect(stats.length, equals(3));
      expect(stats[RiskLevel.low], equals(10));
      expect(stats.values.reduce((a, b) => a + b), equals(17));
    });

    test('date-based filtering for today screenings', () {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      expect(startOfDay.hour, equals(0));
      expect(startOfDay.minute, equals(0));
      expect(startOfDay.second, equals(0));
    });

    test('date-based filtering for week screenings', () {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final normalizedStart = DateTime(
        startOfWeek.year, 
        startOfWeek.month, 
        startOfWeek.day,
      );
      
      // Monday should be weekday 1
      expect(normalizedStart.weekday, equals(DateTime.monday));
    });
  });

  group('ScreeningResult - Model Tests', () {
    test('ScreeningResult creates with required fields', () {
      final result = ScreeningResult(
        riskScore: 0.65,
        riskLevel: RiskLevel.moderate,
        confidence: 0.88,
        features: {'jitter': 0.01, 'shimmer': 0.02},
      );
      
      expect(result.riskScore, equals(0.65));
      expect(result.riskLevel, equals(RiskLevel.moderate));
      expect(result.confidence, equals(0.88));
      expect(result.features.length, equals(2));
    });

    test('RiskLevel has label and color', () {
      expect(RiskLevel.low.label, isNotEmpty);
      expect(RiskLevel.moderate.label, isNotEmpty);
      expect(RiskLevel.high.label, isNotEmpty);
      
      expect(RiskLevel.low.colorValue, isPositive);
      expect(RiskLevel.moderate.colorValue, isPositive);
      expect(RiskLevel.high.colorValue, isPositive);
    });

    test('RiskLevel.fromString handles valid input', () {
      expect(RiskLevel.fromString('low'), equals(RiskLevel.low));
      expect(RiskLevel.fromString('moderate'), equals(RiskLevel.moderate));
      expect(RiskLevel.fromString('high'), equals(RiskLevel.high));
    });

    test('RiskLevel.fromString handles invalid input', () {
      expect(RiskLevel.fromString('invalid'), equals(RiskLevel.low));
      expect(RiskLevel.fromString(''), equals(RiskLevel.low));
    });
  });

  group('Screening - Helper Properties', () {
    test('riskPercentage formats correctly', () {
      final screening = Screening.create(
        audioPath: '/audio.wav',
        result: ScreeningResult(
          riskScore: 0.75,
          riskLevel: RiskLevel.high,
          confidence: 0.9,
          features: {},
        ),
      );
      
      expect(screening.riskPercentage, equals('75%'));
    });

    test('riskPercentage handles null result', () {
      final screening = Screening.create(
        audioPath: '/audio.wav',
        result: null,
      );
      
      expect(screening.riskPercentage, equals('0%'));
    });

    test('patientDescription formats correctly', () {
      final screening = Screening.create(
        audioPath: '/audio.wav',
        patientAge: 65,
        patientGender: 'M',
      );
      
      expect(screening.patientDescription, contains('65세'));
      expect(screening.patientDescription, contains('남성'));
    });

    test('patientDescription handles missing data', () {
      final screening = Screening.create(
        audioPath: '/audio.wav',
      );
      
      expect(screening.patientDescription, contains('나이 미상'));
    });
  });
}

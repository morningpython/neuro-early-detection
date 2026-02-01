import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/screening.dart';

void main() {
  group('RiskLevel', () {
    test('should have correct labels', () {
      expect(RiskLevel.low.label, '낮음');
      expect(RiskLevel.moderate.label, '보통');
      expect(RiskLevel.high.label, '높음');
    });

    test('should have correct color values', () {
      expect(RiskLevel.low.colorValue, 0xFF4CAF50);
      expect(RiskLevel.moderate.colorValue, 0xFFFF9800);
      expect(RiskLevel.high.colorValue, 0xFFF44336);
    });

    test('fromString should parse correctly', () {
      expect(RiskLevel.fromString('low'), RiskLevel.low);
      expect(RiskLevel.fromString('moderate'), RiskLevel.moderate);
      expect(RiskLevel.fromString('high'), RiskLevel.high);
      expect(RiskLevel.fromString('invalid'), RiskLevel.low); // default
    });

    test('fromString should be case insensitive', () {
      expect(RiskLevel.fromString('LOW'), RiskLevel.low);
      expect(RiskLevel.fromString('High'), RiskLevel.high);
    });
  });

  group('ScreeningResult', () {
    test('should create with all fields', () {
      final result = ScreeningResult(
        riskScore: 0.75,
        riskLevel: RiskLevel.high,
        confidence: 0.95,
        features: {'jitter': 0.02, 'shimmer': 0.05},
      );

      expect(result.riskScore, 0.75);
      expect(result.riskLevel, RiskLevel.high);
      expect(result.confidence, 0.95);
      expect(result.features['jitter'], 0.02);
    });
  });

  group('Screening', () {
    test('should create with required fields', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/path/to/audio.wav',
      );

      expect(screening.id, 'test-id');
      expect(screening.audioPath, '/path/to/audio.wav');
      expect(screening.result, isNull);
      expect(screening.deletedAt, isNull);
    });

    test('Screening.create should auto-generate id and timestamp', () {
      final screening = Screening.create(
        audioPath: '/path/to/audio.wav',
        patientAge: 65,
        patientGender: 'M',
      );

      expect(screening.id, isNotEmpty);
      expect(screening.createdAt.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
      expect(screening.patientAge, 65);
      expect(screening.patientGender, 'M');
    });

    test('toMap should convert all fields', () {
      final result = ScreeningResult(
        riskScore: 0.5,
        riskLevel: RiskLevel.moderate,
        confidence: 0.85,
        features: {'jitter': 0.01},
      );
      
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        audioPath: '/path/audio.wav',
        result: result,
        patientAge: 70,
        patientGender: 'F',
        chwId: 'chw-001',
        notes: 'Test note',
      );

      final map = screening.toMap();

      expect(map['id'], 'test-id');
      expect(map['audio_path'], '/path/audio.wav');
      expect(map['risk_score'], 0.5);
      expect(map['risk_level'], 'moderate');
      expect(map['confidence'], 0.85);
      expect(map['patient_age'], 70);
      expect(map['patient_gender'], 'F');
      expect(map['chw_id'], 'chw-001');
      expect(map['notes'], 'Test note');
    });

    test('fromMap should restore all fields', () {
      final map = {
        'id': 'restored-id',
        'created_at': '2024-01-15T10:30:00.000',
        'audio_path': '/restored/audio.wav',
        'risk_score': 0.8,
        'risk_level': 'high',
        'confidence': 0.9,
        'features': '{"jitter":0.02}',
        'patient_age': 68,
        'patient_gender': 'M',
        'chw_id': 'chw-002',
        'notes': 'Restored note',
      };

      final screening = Screening.fromMap(map);

      expect(screening.id, 'restored-id');
      expect(screening.audioPath, '/restored/audio.wav');
      expect(screening.result?.riskScore, 0.8);
      expect(screening.result?.riskLevel, RiskLevel.high);
      expect(screening.result?.features['jitter'], 0.02);
      expect(screening.patientAge, 68);
    });

    test('copyWith should update specified fields', () {
      final original = Screening(
        id: 'orig-id',
        createdAt: DateTime(2024, 1, 1),
        audioPath: '/original.wav',
        patientAge: 60,
      );

      final updated = original.copyWith(
        patientAge: 65,
        notes: 'New note',
      );

      expect(updated.id, 'orig-id'); // unchanged
      expect(updated.audioPath, '/original.wav'); // unchanged
      expect(updated.patientAge, 65); // updated
      expect(updated.notes, 'New note'); // added
    });

    test('fromMap should handle missing optional fields', () {
      final map = {
        'id': 'min-id',
        'created_at': '2024-01-15T10:30:00.000',
        'audio_path': '/audio.wav',
      };

      final screening = Screening.fromMap(map);

      expect(screening.id, 'min-id');
      expect(screening.result, isNull);
      expect(screening.patientAge, isNull);
      expect(screening.notes, isNull);
    });

    test('fromMap should handle soft delete', () {
      final map = {
        'id': 'del-id',
        'created_at': '2024-01-15T10:30:00.000',
        'audio_path': '/audio.wav',
        'deleted_at': '2024-01-20T15:00:00.000',
      };

      final screening = Screening.fromMap(map);

      expect(screening.deletedAt, isNotNull);
      expect(screening.deletedAt?.year, 2024);
      expect(screening.deletedAt?.month, 1);
      expect(screening.deletedAt?.day, 20);
    });

    test('riskPercentage should return formatted percentage', () {
      final result = ScreeningResult(
        riskScore: 0.75,
        riskLevel: RiskLevel.high,
        confidence: 0.95,
        features: {},
      );
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        result: result,
      );

      expect(screening.riskPercentage, '75%');
    });

    test('riskPercentage should return 0% when no result', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
      );

      expect(screening.riskPercentage, '0%');
    });

    test('patientDescription should format age and gender', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        patientAge: 65,
        patientGender: 'M',
      );

      expect(screening.patientDescription, '65세 남성');
    });

    test('patientDescription should handle female gender', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        patientAge: 55,
        patientGender: 'F',
      );

      expect(screening.patientDescription, '55세 여성');
    });

    test('patientDescription should handle other gender', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        patientAge: 60,
        patientGender: 'O',
      );

      expect(screening.patientDescription, '60세 기타');
    });

    test('patientDescription should handle lowercase gender', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        patientAge: 45,
        patientGender: 'm',
      );

      expect(screening.patientDescription, '45세 남성');
    });

    test('patientDescription should handle missing age', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        patientGender: 'F',
      );

      expect(screening.patientDescription, '나이 미상 여성');
    });

    test('patientDescription should handle missing gender', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        patientAge: 70,
      );

      expect(screening.patientDescription, '70세');
    });

    test('patientDescription should handle unknown gender', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        patientAge: 50,
        patientGender: 'X',
      );

      expect(screening.patientDescription, '50세');
    });

    test('isDeleted should return true when deletedAt is set', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        deletedAt: DateTime(2024, 1, 20),
      );

      expect(screening.isDeleted, isTrue);
    });

    test('isDeleted should return false when deletedAt is null', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
      );

      expect(screening.isDeleted, isFalse);
    });

    test('toString should return formatted string', () {
      final result = ScreeningResult(
        riskScore: 0.85,
        riskLevel: RiskLevel.high,
        confidence: 0.95,
        features: {},
      );
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
        result: result,
      );

      expect(screening.toString(), contains('test-id'));
      expect(screening.toString(), contains('높음'));
      expect(screening.toString(), contains('85%'));
    });

    test('toString should handle null result', () {
      final screening = Screening(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
      );

      expect(screening.toString(), contains('N/A'));
    });

    test('equality should be based on id', () {
      final screening1 = Screening(
        id: 'same-id',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio1.wav',
        patientAge: 60,
      );

      final screening2 = Screening(
        id: 'same-id',
        createdAt: DateTime(2024, 2, 20),
        audioPath: '/audio2.wav',
        patientAge: 70,
      );

      expect(screening1 == screening2, isTrue);
      expect(screening1.hashCode, screening2.hashCode);
    });

    test('different ids should not be equal', () {
      final screening1 = Screening(
        id: 'id-1',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
      );

      final screening2 = Screening(
        id: 'id-2',
        createdAt: DateTime(2024, 1, 15),
        audioPath: '/audio.wav',
      );

      expect(screening1 == screening2, isFalse);
    });

    test('fromMap should handle null audio_path', () {
      final map = {
        'id': 'null-path-id',
        'created_at': '2024-01-15T10:30:00.000',
        'audio_path': null,
      };

      final screening = Screening.fromMap(map);

      expect(screening.audioPath, '');
    });

    test('fromMap should handle null risk_level', () {
      final map = {
        'id': 'null-level-id',
        'created_at': '2024-01-15T10:30:00.000',
        'audio_path': '/audio.wav',
        'risk_score': 0.5,
        'risk_level': null,
        'confidence': 0.8,
      };

      final screening = Screening.fromMap(map);

      expect(screening.result?.riskLevel, RiskLevel.low);
    });

    test('fromMap should handle null confidence', () {
      final map = {
        'id': 'null-conf-id',
        'created_at': '2024-01-15T10:30:00.000',
        'audio_path': '/audio.wav',
        'risk_score': 0.5,
        'risk_level': 'moderate',
        'confidence': null,
      };

      final screening = Screening.fromMap(map);

      expect(screening.result?.confidence, 0.0);
    });

    test('copyWith should allow updating all fields', () {
      final originalResult = ScreeningResult(
        riskScore: 0.3,
        riskLevel: RiskLevel.low,
        confidence: 0.7,
        features: {'test': 1.0},
      );
      
      final original = Screening(
        id: 'orig-id',
        createdAt: DateTime(2024, 1, 1),
        audioPath: '/original.wav',
        result: originalResult,
        patientAge: 60,
        patientGender: 'M',
        chwId: 'chw-001',
        notes: 'Original note',
      );

      final newResult = ScreeningResult(
        riskScore: 0.8,
        riskLevel: RiskLevel.high,
        confidence: 0.95,
        features: {'new': 2.0},
      );

      final updated = original.copyWith(
        id: 'new-id',
        createdAt: DateTime(2024, 2, 2),
        audioPath: '/new.wav',
        result: newResult,
        patientAge: 65,
        patientGender: 'F',
        chwId: 'chw-002',
        notes: 'New note',
        deletedAt: DateTime(2024, 3, 3),
      );

      expect(updated.id, 'new-id');
      expect(updated.createdAt.month, 2);
      expect(updated.audioPath, '/new.wav');
      expect(updated.result?.riskScore, 0.8);
      expect(updated.patientAge, 65);
      expect(updated.patientGender, 'F');
      expect(updated.chwId, 'chw-002');
      expect(updated.notes, 'New note');
      expect(updated.deletedAt?.month, 3);
    });
  });

  group('ScreeningResult - Additional Tests', () {
    test('calculateRiskLevel should return low for score < 0.33', () {
      expect(ScreeningResult.calculateRiskLevel(0.0), RiskLevel.low);
      expect(ScreeningResult.calculateRiskLevel(0.1), RiskLevel.low);
      expect(ScreeningResult.calculateRiskLevel(0.32), RiskLevel.low);
    });

    test('calculateRiskLevel should return moderate for score 0.33-0.66', () {
      expect(ScreeningResult.calculateRiskLevel(0.33), RiskLevel.moderate);
      expect(ScreeningResult.calculateRiskLevel(0.5), RiskLevel.moderate);
      expect(ScreeningResult.calculateRiskLevel(0.66), RiskLevel.moderate);
    });

    test('calculateRiskLevel should return high for score >= 0.67', () {
      expect(ScreeningResult.calculateRiskLevel(0.67), RiskLevel.high);
      expect(ScreeningResult.calculateRiskLevel(0.8), RiskLevel.high);
      expect(ScreeningResult.calculateRiskLevel(1.0), RiskLevel.high);
    });

    test('fromInference should create result correctly', () {
      final result = ScreeningResult.fromInference(
        probability: 0.75,
        confidence: 0.9,
        features: {'jitter': 0.02, 'shimmer': 0.05},
      );

      expect(result.riskScore, 0.75);
      expect(result.riskLevel, RiskLevel.high);
      expect(result.confidence, 0.9);
      expect(result.features['jitter'], 0.02);
    });

    test('fromInference should handle null features', () {
      final result = ScreeningResult.fromInference(
        probability: 0.4,
        confidence: 0.85,
        features: null,
      );

      expect(result.features, isEmpty);
    });

    test('toMap should convert all fields', () {
      final result = ScreeningResult(
        riskScore: 0.6,
        riskLevel: RiskLevel.moderate,
        confidence: 0.88,
        features: {'test_feature': 1.5},
      );

      final map = result.toMap();

      expect(map['riskScore'], 0.6);
      expect(map['riskLevel'], 'moderate');
      expect(map['confidence'], 0.88);
      expect(map['features']['test_feature'], 1.5);
    });

    test('fromMap should restore all fields', () {
      final map = {
        'riskScore': 0.45,
        'riskLevel': 'moderate',
        'confidence': 0.92,
        'features': {'restored': 2.5},
      };

      final result = ScreeningResult.fromMap(map);

      expect(result.riskScore, 0.45);
      expect(result.riskLevel, RiskLevel.moderate);
      expect(result.confidence, 0.92);
      expect(result.features['restored'], 2.5);
    });

    test('fromMap should handle null features', () {
      final map = {
        'riskScore': 0.5,
        'riskLevel': 'moderate',
        'confidence': 0.8,
        'features': null,
      };

      final result = ScreeningResult.fromMap(map);

      expect(result.features, isEmpty);
    });

    test('fromMap should handle int values', () {
      final map = {
        'riskScore': 1,
        'riskLevel': 'high',
        'confidence': 1,
        'features': {},
      };

      final result = ScreeningResult.fromMap(map);

      expect(result.riskScore, 1.0);
      expect(result.confidence, 1.0);
    });
  });

  group('RiskLevel - Edge Cases', () {
    test('all values should have unique names', () {
      final names = RiskLevel.values.map((e) => e.name).toSet();
      expect(names.length, RiskLevel.values.length);
    });

    test('all values should have unique labels', () {
      final labels = RiskLevel.values.map((e) => e.label).toSet();
      expect(labels.length, RiskLevel.values.length);
    });

    test('all values should have unique colors', () {
      final colors = RiskLevel.values.map((e) => e.colorValue).toSet();
      expect(colors.length, RiskLevel.values.length);
    });
  });
}

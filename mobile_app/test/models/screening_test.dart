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
  });
}

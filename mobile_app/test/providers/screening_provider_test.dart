import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/providers/screening_provider.dart';
import 'package:neuro_access/ui/screens/patient_info_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScreeningStatus', () {
    test('should have all required states', () {
      expect(ScreeningStatus.values.length, 7);
      expect(ScreeningStatus.values, contains(ScreeningStatus.idle));
      expect(ScreeningStatus.values, contains(ScreeningStatus.recording));
      expect(ScreeningStatus.values, contains(ScreeningStatus.validating));
      expect(ScreeningStatus.values, contains(ScreeningStatus.extractingFeatures));
      expect(ScreeningStatus.values, contains(ScreeningStatus.analyzing));
      expect(ScreeningStatus.values, contains(ScreeningStatus.completed));
      expect(ScreeningStatus.values, contains(ScreeningStatus.error));
    });
  });

  group('ScreeningData', () {
    test('should create with default timestamp', () {
      final data = ScreeningData();
      
      expect(data.audioPath, isNull);
      expect(data.recordingDuration, isNull);
      expect(data.result, isNull);
      expect(data.errorMessage, isNull);
      expect(data.timestamp, isNotNull);
    });

    test('should create with all fields', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final data = ScreeningData(
        audioPath: '/path/to/audio.wav',
        recordingDuration: const Duration(seconds: 30),
        errorMessage: null,
        timestamp: timestamp,
      );

      expect(data.audioPath, '/path/to/audio.wav');
      expect(data.recordingDuration, const Duration(seconds: 30));
      expect(data.timestamp, timestamp);
    });

    test('copyWith should update specified fields', () {
      final original = ScreeningData(
        audioPath: '/original.wav',
      );

      final updated = original.copyWith(
        audioPath: '/updated.wav',
        recordingDuration: const Duration(seconds: 45),
      );

      expect(updated.audioPath, '/updated.wav');
      expect(updated.recordingDuration, const Duration(seconds: 45));
      expect(updated.timestamp, original.timestamp); // unchanged
    });
  });

  group('ScreeningProvider', () {
    late ScreeningProvider provider;

    setUp(() {
      provider = ScreeningProvider();
    });

    test('should start with idle status', () {
      expect(provider.status, ScreeningStatus.idle);
    });

    test('should have default status message', () {
      expect(provider.statusMessage, '검사 준비 완료');
    });

    test('should have zero progress initially', () {
      expect(provider.progress, 0.0);
    });

    test('should have zero recording duration initially', () {
      expect(provider.recordingDuration, Duration.zero);
    });

    test('isRecording should return false initially', () {
      expect(provider.isRecording, false);
    });

    test('isProcessing should return false initially', () {
      expect(provider.isProcessing, false);
    });

    test('isCompleted should return false initially', () {
      expect(provider.isCompleted, false);
    });

    test('patientInfo should be null initially', () {
      expect(provider.patientInfo, isNull);
    });

    test('should allow setting patientInfo', () {
      final info = PatientInfo(
        age: 65,
        gender: 'M',
        hasConsent: true,
      );

      provider.patientInfo = info;

      expect(provider.patientInfo, info);
      expect(provider.patientInfo?.age, 65);
      expect(provider.patientInfo?.gender, 'M');
    });

    test('data should have default values', () {
      expect(provider.data.audioPath, isNull);
      expect(provider.data.result, isNull);
    });
  });

  group('PatientInfo', () {
    test('should create with all fields', () {
      final info = PatientInfo(
        age: 70,
        gender: 'F',
        hasConsent: true,
      );

      expect(info.age, 70);
      expect(info.gender, 'F');
      expect(info.hasConsent, true);
    });

    test('should have default hasConsent as false', () {
      final info = PatientInfo(
        age: 55,
        gender: 'M',
      );

      expect(info.hasConsent, false);
    });

    test('isValid should check all required fields', () {
      final valid = PatientInfo(
        age: 45,
        gender: 'M',
        hasConsent: true,
      );

      final noConsent = PatientInfo(
        age: 45,
        gender: 'M',
        hasConsent: false,
      );

      final noAge = PatientInfo(
        gender: 'M',
        hasConsent: true,
      );

      expect(valid.isValid, true);
      expect(noConsent.isValid, false);
      expect(noAge.isValid, false);
    });

    test('copyWith should update specified fields', () {
      final original = PatientInfo(
        age: 50,
        gender: 'F',
        hasConsent: false,
      );

      final updated = original.copyWith(hasConsent: true);

      expect(updated.age, 50);
      expect(updated.gender, 'F');
      expect(updated.hasConsent, true);
    });
  });
}

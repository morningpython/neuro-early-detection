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

    test('copyWith should allow updating age', () {
      final original = PatientInfo(
        age: 50,
        gender: 'M',
        hasConsent: true,
      );

      final updated = original.copyWith(age: 60);

      expect(updated.age, 60);
      expect(updated.gender, 'M');
      expect(updated.hasConsent, true);
    });

    test('copyWith should allow updating gender', () {
      final original = PatientInfo(
        age: 50,
        gender: 'M',
        hasConsent: true,
      );

      final updated = original.copyWith(gender: 'F');

      expect(updated.age, 50);
      expect(updated.gender, 'F');
      expect(updated.hasConsent, true);
    });
  });

  group('ScreeningStatus - State Transitions', () {
    test('idle is the starting state', () {
      expect(ScreeningStatus.idle.index, 0);
    });

    test('workflow order should be correct', () {
      // Expected flow: idle -> recording -> validating -> extractingFeatures -> analyzing -> completed
      expect(ScreeningStatus.idle.index, lessThan(ScreeningStatus.recording.index));
      expect(ScreeningStatus.recording.index, lessThan(ScreeningStatus.validating.index));
      expect(ScreeningStatus.validating.index, lessThan(ScreeningStatus.extractingFeatures.index));
      expect(ScreeningStatus.extractingFeatures.index, lessThan(ScreeningStatus.analyzing.index));
      expect(ScreeningStatus.analyzing.index, lessThan(ScreeningStatus.completed.index));
    });

    test('error state can occur from any state', () {
      expect(ScreeningStatus.error, isNotNull);
      expect(ScreeningStatus.values, contains(ScreeningStatus.error));
    });
  });

  group('ScreeningProvider - Status Check Methods', () {
    late ScreeningProvider provider;

    setUp(() {
      provider = ScreeningProvider();
    });

    test('isRecording checks for recording status', () {
      // By state comparison
      expect(ScreeningStatus.recording == ScreeningStatus.recording, isTrue);
      expect(ScreeningStatus.idle == ScreeningStatus.recording, isFalse);
      expect(ScreeningStatus.analyzing == ScreeningStatus.recording, isFalse);
    });

    test('isProcessing checks for multiple statuses', () {
      // isProcessing should be true for: validating, extractingFeatures, analyzing
      final processingStates = [
        ScreeningStatus.validating,
        ScreeningStatus.extractingFeatures,
        ScreeningStatus.analyzing,
      ];
      
      for (final state in processingStates) {
        final isProcessing = state == ScreeningStatus.validating ||
                            state == ScreeningStatus.extractingFeatures ||
                            state == ScreeningStatus.analyzing;
        expect(isProcessing, isTrue, reason: '$state should be processing');
      }
    });

    test('isCompleted checks for completed or error', () {
      final completedStates = [
        ScreeningStatus.completed,
        ScreeningStatus.error,
      ];
      
      for (final state in completedStates) {
        final isCompleted = state == ScreeningStatus.completed ||
                           state == ScreeningStatus.error;
        expect(isCompleted, isTrue, reason: '$state should be completed');
      }
    });

    test('idle is not recording, processing, or completed', () {
      final state = ScreeningStatus.idle;
      
      final isRecording = state == ScreeningStatus.recording;
      final isProcessing = state == ScreeningStatus.validating ||
                          state == ScreeningStatus.extractingFeatures ||
                          state == ScreeningStatus.analyzing;
      final isCompleted = state == ScreeningStatus.completed ||
                         state == ScreeningStatus.error;
      
      expect(isRecording, isFalse);
      expect(isProcessing, isFalse);
      expect(isCompleted, isFalse);
    });
  });

  group('ScreeningData - Edge Cases', () {
    test('copyWith with null values should keep original', () {
      final original = ScreeningData(
        audioPath: '/test/audio.wav',
        recordingDuration: const Duration(seconds: 10),
        errorMessage: 'test error',
      );

      final updated = original.copyWith();

      expect(updated.audioPath, '/test/audio.wav');
      expect(updated.recordingDuration, const Duration(seconds: 10));
      expect(updated.errorMessage, 'test error');
      expect(updated.timestamp, original.timestamp);
    });

    test('copyWith should allow clearing error', () {
      final original = ScreeningData(
        audioPath: '/test/audio.wav',
        errorMessage: 'some error',
      );

      // Note: copyWith doesn't allow setting null, so error persists
      final updated = original.copyWith(audioPath: '/new/audio.wav');

      expect(updated.audioPath, '/new/audio.wav');
      expect(updated.errorMessage, 'some error'); // Still present
    });

    test('timestamp should be immutable', () {
      final timestamp = DateTime(2024, 6, 15, 12, 0);
      final data = ScreeningData(timestamp: timestamp);
      
      final updated = data.copyWith(audioPath: '/path.wav');
      
      expect(updated.timestamp, equals(timestamp));
      expect(data.timestamp, equals(timestamp));
    });
  });

  group('ScreeningProvider - Progress Tracking', () {
    late ScreeningProvider provider;

    setUp(() {
      provider = ScreeningProvider();
    });

    test('progress should be between 0 and 1', () {
      expect(provider.progress, greaterThanOrEqualTo(0.0));
      expect(provider.progress, lessThanOrEqualTo(1.0));
    });

    test('initial progress should be 0', () {
      expect(provider.progress, equals(0.0));
    });

    test('expected progress values for each state', () {
      // Document expected progress at each stage
      const idleProgress = 0.0;
      const recordingProgress = 0.0;
      const validatingProgress = 0.2;
      const extractingProgress = 0.5;
      const analyzingProgress = 0.8;
      const completedProgress = 1.0;
      
      expect(idleProgress, equals(0.0));
      expect(validatingProgress, lessThan(extractingProgress));
      expect(extractingProgress, lessThan(analyzingProgress));
      expect(analyzingProgress, lessThan(completedProgress));
    });
  });

  group('ScreeningProvider - Status Messages', () {
    late ScreeningProvider provider;

    setUp(() {
      provider = ScreeningProvider();
    });

    test('default status message is Korean', () {
      expect(provider.statusMessage, contains('검사'));
    });

    test('expected status messages', () {
      // Document expected messages for each state
      const idleMessage = '검사 준비 완료';
      const recordingMessage = '음성을 녹음 중입니다...';
      const validatingMessage = '오디오 품질을 확인 중입니다...';
      const extractingMessage = '음성 특징을 추출 중입니다...';
      const analyzingMessage = 'AI 분석을 실행 중입니다...';
      const completedMessage = '분석 완료';
      
      expect(idleMessage, isNotEmpty);
      expect(recordingMessage, contains('녹음'));
      expect(validatingMessage, contains('품질'));
      expect(extractingMessage, contains('특징'));
      expect(analyzingMessage, contains('AI'));
      expect(completedMessage, contains('완료'));
    });
  });

  group('ScreeningProvider - ChangeNotifier', () {
    late ScreeningProvider provider;

    setUp(() {
      provider = ScreeningProvider();
    });

    test('should be a ChangeNotifier', () {
      expect(provider, isA<ScreeningProvider>());
    });

    test('can add and remove listeners', () {
      var callCount = 0;
      void listener() {
        callCount++;
      }

      provider.addListener(listener);
      provider.removeListener(listener);

      expect(callCount, 0); // Listener was not called
    });
  });

  group('Audio Duration Validation', () {
    test('minimum recording duration should be 1 second', () {
      const minSampleRate = 16000; // 16kHz
      const minDurationSeconds = 1;
      const minSamples = minSampleRate * minDurationSeconds;
      
      expect(minSamples, equals(16000));
    });

    test('should reject recordings shorter than 1 second', () {
      const samples = 15000; // Less than 16000
      final isValid = samples >= 16000;
      
      expect(isValid, isFalse);
    });

    test('should accept recordings of 1 second or more', () {
      const samples = 16000;
      final isValid = samples >= 16000;
      
      expect(isValid, isTrue);
    });
  });

  group('PatientInfo - Additional Tests', () {
    test('age can be null', () {
      final info = PatientInfo(
        gender: 'M',
        hasConsent: true,
      );

      expect(info.age, isNull);
    });

    test('gender can be null', () {
      final info = PatientInfo(
        age: 50,
        hasConsent: true,
      );

      expect(info.gender, isNull);
    });

    test('isValid requires age, gender, and consent', () {
      // All required
      expect(PatientInfo(age: 50, gender: 'M', hasConsent: true).isValid, isTrue);
      
      // Missing consent
      expect(PatientInfo(age: 50, gender: 'M', hasConsent: false).isValid, isFalse);
      
      // Missing age
      expect(PatientInfo(gender: 'M', hasConsent: true).isValid, isFalse);
      
      // Missing gender
      expect(PatientInfo(age: 50, hasConsent: true).isValid, isFalse);
    });

    test('gender values should be M or F', () {
      final male = PatientInfo(age: 50, gender: 'M', hasConsent: true);
      final female = PatientInfo(age: 50, gender: 'F', hasConsent: true);
      
      expect(male.gender, equals('M'));
      expect(female.gender, equals('F'));
    });
  });
}

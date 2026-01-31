import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/services/sms_service.dart';
import 'package:neuro_access/models/screening.dart';

void main() {
  group('SmsResult', () {
    group('factory constructors', () {
      test('success() should create successful result', () {
        final result = SmsResult.success();

        expect(result.success, isTrue);
        expect(result.errorMessage, isNull);
        expect(result.timestamp, isNotNull);
      });

      test('failure() should create failed result with message', () {
        final result = SmsResult.failure('Test error');

        expect(result.success, isFalse);
        expect(result.errorMessage, 'Test error');
        expect(result.timestamp, isNotNull);
      });

      test('timestamp should be close to now', () {
        final before = DateTime.now();
        final result = SmsResult.success();
        final after = DateTime.now();

        expect(result.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(result.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('constructor', () {
      test('should accept all parameters', () {
        final timestamp = DateTime(2024, 1, 1);
        final result = SmsResult(
          success: true,
          errorMessage: null,
          timestamp: timestamp,
        );

        expect(result.success, isTrue);
        expect(result.errorMessage, isNull);
        expect(result.timestamp, timestamp);
      });

      test('should accept error message with success false', () {
        final result = SmsResult(
          success: false,
          errorMessage: 'Custom error',
          timestamp: DateTime.now(),
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, 'Custom error');
      });
    });
  });

  group('SmsService', () {
    late SmsService smsService;

    setUp(() {
      smsService = SmsService();
    });

    group('singleton', () {
      test('should return same instance', () {
        final instance1 = SmsService();
        final instance2 = SmsService();

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('buildReferralMessageFromScreening', () {
      Screening createTestScreening({
        double riskScore = 0.5,
        int? patientAge = 65,
        String? chwId = 'CHW001',
      }) {
        return Screening(
          id: 'test-id',
          audioPath: '/test/audio.wav',
          patientAge: patientAge,
          patientGender: 'male',
          chwId: chwId,
          createdAt: DateTime(2024, 6, 15),
          result: ScreeningResult(
            riskScore: riskScore,
            riskLevel: riskScore >= 0.7 
                ? RiskLevel.high 
                : (riskScore >= 0.4 ? RiskLevel.moderate : RiskLevel.low),
            confidence: 0.9,
            features: {},
          ),
        );
      }

      test('should build English message correctly', () {
        final screening = createTestScreening(riskScore: 0.85);

        final message = smsService.buildReferralMessageFromScreening(
          screening: screening,
          patientName: 'John Doe',
          facilityName: 'Test Hospital',
          locale: 'en',
        );

        expect(message, contains('NEURO ACCESS'));
        expect(message, contains('Screening Referral'));
        expect(message, contains('John Doe'));
        expect(message, contains('Test Hospital'));
        expect(message, contains('높음'));  // High in Korean
        expect(message, contains('85.0%'));
        expect(message, contains('CHW001'));
      });

      test('should build Swahili message correctly', () {
        final screening = createTestScreening(
          riskScore: 0.75,
          chwId: 'CHW002',
        );

        final message = smsService.buildReferralMessageFromScreening(
          screening: screening,
          patientName: 'Juma Ali',
          facilityName: 'Hospitali Kuu',
          locale: 'sw',
        );

        expect(message, contains('NEURO ACCESS'));
        expect(message, contains('Rufaa ya Uchunguzi'));
        expect(message, contains('Juma Ali'));
        expect(message, contains('Hospitali Kuu'));
        expect(message, contains('Juu'));
        expect(message, contains('75.0%'));
        expect(message, contains('CHW002'));
      });

      test('should handle null patient age', () {
        final screening = createTestScreening(
          riskScore: 0.5,
          patientAge: null,
          chwId: 'CHW003',
        );

        final message = smsService.buildReferralMessageFromScreening(
          screening: screening,
          patientName: 'Test Patient',
          facilityName: 'Clinic',
          locale: 'en',
        );

        expect(message, contains('Unknown'));
      });

      test('should handle null chw id', () {
        final screening = createTestScreening(
          riskScore: 0.5,
          patientAge: 60,
          chwId: null,
        );

        final message = smsService.buildReferralMessageFromScreening(
          screening: screening,
          patientName: 'Test Patient',
          facilityName: 'Clinic',
          locale: 'en',
        );

        expect(message, contains('N/A'));
      });

      test('should show high risk level', () {
        final screening = createTestScreening(riskScore: 0.8);

        final message = smsService.buildReferralMessageFromScreening(
          screening: screening,
          patientName: 'Test',
          facilityName: 'Hospital',
          locale: 'en',
        );
        expect(message, contains('높음'));  // High in Korean
      });

      test('should show moderate risk level', () {
        final screening = createTestScreening(riskScore: 0.5);

        final message = smsService.buildReferralMessageFromScreening(
          screening: screening,
          patientName: 'Test',
          facilityName: 'Hospital',
          locale: 'en',
        );
        expect(message, contains('보통'));  // Moderate in Korean
      });

      test('should show low risk level', () {
        final screening = createTestScreening(riskScore: 0.2);

        final message = smsService.buildReferralMessageFromScreening(
          screening: screening,
          patientName: 'Test',
          facilityName: 'Hospital',
          locale: 'en',
        );
        expect(message, contains('낮음'));  // Low in Korean
      });

      test('should handle screening with no result', () {
        final screening = Screening(
          id: 'test-id',
          audioPath: '/test/audio.wav',
          patientAge: 60,
          patientGender: 'male',
          chwId: 'CHW001',
          createdAt: DateTime(2024, 6, 15),
        );

        final message = smsService.buildReferralMessageFromScreening(
          screening: screening,
          patientName: 'Test',
          facilityName: 'Hospital',
          locale: 'en',
        );
        
        expect(message, contains('NEURO ACCESS'));
        expect(message, contains('0.0%'));
      });
    });
  });
}

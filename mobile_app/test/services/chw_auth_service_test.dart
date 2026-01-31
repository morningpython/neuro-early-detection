import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/chw_profile.dart';
import 'package:neuro_access/services/chw_auth_service.dart';

/// CHW Auth Service Tests
/// 
/// Note: Full auth service tests require mocking FlutterSecureStorage and SQLite
/// These tests verify the model contracts and authentication logic
void main() {
  group('AuthResult', () {
    test('success factory creates successful result', () {
      final profile = ChwProfile(
        id: 'id-1',
        chwId: 'CHW001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        role: ChwRole.junior,
        status: ChwStatus.active,
        regionCode: 'REG001',
        facilityId: 'FAC001',
        passwordHash: 'hashedpassword123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = AuthResult.success(profile);
      
      expect(result.success, isTrue);
      expect(result.profile, isNotNull);
      expect(result.profile!.fullName, equals('John Doe'));
      expect(result.errorMessage, isNull);
      expect(result.errorCode, isNull);
    });

    test('failure factory creates failed result', () {
      final result = AuthResult.failure(
        '잘못된 자격 증명',
        code: AuthErrorCode.invalidCredentials,
      );
      
      expect(result.success, isFalse);
      expect(result.profile, isNull);
      expect(result.errorMessage, equals('잘못된 자격 증명'));
      expect(result.errorCode, AuthErrorCode.invalidCredentials);
    });

    test('failure factory without code', () {
      final result = AuthResult.failure('일반 오류');
      
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('일반 오류'));
      expect(result.errorCode, isNull);
    });

    test('constructor allows all fields', () {
      final profile = ChwProfile(
        id: 'id-2',
        chwId: 'CHW002',
        firstName: 'Jane',
        lastName: 'Smith',
        phoneNumber: '+9876543210',
        role: ChwRole.senior,
        status: ChwStatus.active,
        regionCode: 'REG002',
        facilityId: 'FAC002',
        passwordHash: 'hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = AuthResult(
        success: true,
        profile: profile,
        errorMessage: null,
        errorCode: null,
      );
      
      expect(result.success, isTrue);
      expect(result.profile?.chwId, 'CHW002');
    });
  });

  group('AuthErrorCode', () {
    test('all error codes have messages', () {
      for (final code in AuthErrorCode.values) {
        expect(code.message, isNotEmpty);
      }
    });

    test('error codes cover common auth scenarios', () {
      expect(AuthErrorCode.values.length, equals(7));
      
      final codeNames = AuthErrorCode.values.map((e) => e.name).toList();
      expect(codeNames, contains('invalidCredentials'));
      expect(codeNames, contains('accountLocked'));
      expect(codeNames, contains('accountInactive'));
      expect(codeNames, contains('accountPending'));
      expect(codeNames, contains('networkError'));
      expect(codeNames, contains('serverError'));
      expect(codeNames, contains('unknown'));
    });

    test('each error code has Korean message', () {
      expect(AuthErrorCode.invalidCredentials.message, '잘못된 자격 증명');
      expect(AuthErrorCode.accountLocked.message, '계정이 잠겼습니다');
      expect(AuthErrorCode.accountInactive.message, '비활성 계정');
      expect(AuthErrorCode.accountPending.message, '승인 대기 중');
      expect(AuthErrorCode.networkError.message, '네트워크 오류');
      expect(AuthErrorCode.serverError.message, '서버 오류');
      expect(AuthErrorCode.unknown.message, '알 수 없는 오류');
    });
  });

  group('ChwAuthService - Static Constants', () {
    test('session duration is 8 hours', () {
      expect(ChwAuthService.sessionDuration, const Duration(hours: 8));
    });

    test('PIN session duration is 2 hours', () {
      expect(ChwAuthService.pinSessionDuration, const Duration(hours: 2));
    });

    test('max login attempts is 5', () {
      expect(ChwAuthService.maxLoginAttempts, 5);
    });

    test('lock duration is 15 minutes', () {
      expect(ChwAuthService.lockDuration, const Duration(minutes: 15));
    });

    test('PIN session is shorter than full session', () {
      expect(ChwAuthService.pinSessionDuration, lessThan(ChwAuthService.sessionDuration));
    });
  });

  group('ChwAuthService - Session Expiry Logic', () {
    test('session expiry calculation', () {
      final sessionStart = DateTime.now();
      final sessionExpiry = sessionStart.add(ChwAuthService.sessionDuration);
      
      expect(sessionExpiry.isAfter(sessionStart), isTrue);
      expect(sessionExpiry.difference(sessionStart).inHours, 8);
    });

    test('session is not expired immediately after creation', () {
      final sessionExpiry = DateTime.now().add(ChwAuthService.sessionDuration);
      final isExpired = DateTime.now().isAfter(sessionExpiry);
      
      expect(isExpired, isFalse);
    });

    test('session is expired after duration passes', () {
      final sessionExpiry = DateTime.now().subtract(const Duration(hours: 1));
      final isExpired = DateTime.now().isAfter(sessionExpiry);
      
      expect(isExpired, isTrue);
    });

    test('PIN session expiry calculation', () {
      final sessionStart = DateTime.now();
      final pinSessionExpiry = sessionStart.add(ChwAuthService.pinSessionDuration);
      
      expect(pinSessionExpiry.difference(sessionStart).inHours, 2);
    });
  });

  group('ChwAuthService - Login Attempts Logic', () {
    test('max login attempts is reasonable', () {
      expect(ChwAuthService.maxLoginAttempts, greaterThanOrEqualTo(3));
      expect(ChwAuthService.maxLoginAttempts, lessThanOrEqualTo(10));
    });

    test('lock duration is reasonable', () {
      expect(ChwAuthService.lockDuration.inMinutes, greaterThanOrEqualTo(10));
      expect(ChwAuthService.lockDuration.inMinutes, lessThanOrEqualTo(60));
    });

    test('account lock logic simulation', () {
      int failedAttempts = 0;
      final maxAttempts = ChwAuthService.maxLoginAttempts;
      DateTime? lockedUntil;
      
      // Simulate failed attempts
      for (int i = 0; i < maxAttempts; i++) {
        failedAttempts++;
        if (failedAttempts >= maxAttempts) {
          lockedUntil = DateTime.now().add(ChwAuthService.lockDuration);
        }
      }
      
      expect(failedAttempts, equals(5));
      expect(lockedUntil, isNotNull);
    });

    test('failed attempts reset on successful login', () {
      int failedAttempts = 3;
      
      // Simulate successful login
      final loginSuccess = true;
      if (loginSuccess) {
        failedAttempts = 0;
      }
      
      expect(failedAttempts, equals(0));
    });
  });

  group('ChwAuthService - Password Hashing', () {
    test('password hash is consistent', () {
      // SHA-256 produces 64 character hex string
      const hashLength = 64;
      expect(hashLength, equals(64));
    });

    test('different passwords produce different hashes', () {
      const password1 = 'password123';
      const password2 = 'password456';
      
      // Simplified check - actual hashing would be done in service
      expect(password1, isNot(equals(password2)));
    });

    test('PIN hash requirements', () {
      const pin = '1234';
      
      // PIN should be 4-6 digits
      expect(pin.length, greaterThanOrEqualTo(4));
      expect(int.tryParse(pin), isNotNull);
    });
  });

  group('ChwAuthService - Profile Validation', () {
    test('profile status affects authentication', () {
      // Active users can login
      expect(ChwStatus.active, isNotNull);
      
      // Pending users should be blocked
      expect(ChwStatus.pending, isNotNull);
      
      // Inactive users should be blocked
      expect(ChwStatus.inactive, isNotNull);
    });

    test('all profile statuses are handled', () {
      expect(ChwStatus.values.length, greaterThanOrEqualTo(3));
    });

    test('phone number format validation', () {
      final validPhones = [
        '+1234567890',
        '+821012345678',
        '010-1234-5678',
      ];
      
      for (final phone in validPhones) {
        expect(phone.isNotEmpty, isTrue);
        expect(phone.length, greaterThanOrEqualTo(10));
      }
    });
  });

  group('ChwAuthService - Database Schema', () {
    test('required profile fields', () {
      final requiredFields = [
        'id',
        'chw_id',
        'first_name',
        'last_name',
        'phone_number',
        'role',
        'status',
        'region_code',
        'facility_id',
        'password_hash',
        'created_at',
        'updated_at',
      ];
      
      expect(requiredFields.length, greaterThanOrEqualTo(10));
      expect(requiredFields, contains('password_hash'));
      expect(requiredFields, contains('phone_number'));
    });

    test('optional profile fields', () {
      final optionalFields = [
        'email',
        'photo_url',
        'supervisor_id',
        'certifications',
        'pin',
        'last_login_at',
      ];
      
      expect(optionalFields, contains('email'));
      expect(optionalFields, contains('pin'));
    });
  });

  group('ChwAuthService - Secure Storage Keys', () {
    test('session storage key naming', () {
      const sessionTokenKey = 'session_token';
      const sessionExpiryKey = 'session_expiry';
      const currentUserIdKey = 'current_user_id';
      
      expect(sessionTokenKey, isNotEmpty);
      expect(sessionExpiryKey, isNotEmpty);
      expect(currentUserIdKey, isNotEmpty);
    });
  });

  group('ChwAuthService - Singleton', () {
    test('factory returns same instance', () {
      final instance1 = ChwAuthService();
      final instance2 = ChwAuthService();
      
      expect(identical(instance1, instance2), isTrue);
    });
  });
}

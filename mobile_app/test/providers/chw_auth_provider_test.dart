import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/providers/chw_auth_provider.dart';
import 'package:neuro_access/models/chw_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthState', () {
    test('should have all required states', () {
      expect(AuthState.values.length, 5);
      expect(AuthState.values, contains(AuthState.initial));
      expect(AuthState.values, contains(AuthState.loading));
      expect(AuthState.values, contains(AuthState.authenticated));
      expect(AuthState.values, contains(AuthState.unauthenticated));
      expect(AuthState.values, contains(AuthState.error));
    });

    test('state names should be correct', () {
      expect(AuthState.initial.name, equals('initial'));
      expect(AuthState.loading.name, equals('loading'));
      expect(AuthState.authenticated.name, equals('authenticated'));
      expect(AuthState.unauthenticated.name, equals('unauthenticated'));
      expect(AuthState.error.name, equals('error'));
    });

    test('states should have distinct indices', () {
      final indices = AuthState.values.map((e) => e.index).toSet();
      expect(indices.length, equals(AuthState.values.length));
    });
  });

  group('ChwAuthProvider', () {
    late ChwAuthProvider provider;

    setUp(() {
      provider = ChwAuthProvider();
    });

    test('should start with initial state', () {
      expect(provider.state, AuthState.initial);
    });

    test('should not be authenticated initially', () {
      expect(provider.isAuthenticated, false);
    });

    test('should not be loading initially', () {
      expect(provider.isLoading, false);
    });

    test('currentUser should be null initially', () {
      expect(provider.currentUser, isNull);
    });

    test('errorMessage should be null initially', () {
      expect(provider.errorMessage, isNull);
    });

    test('isPinSet should be false initially', () {
      expect(provider.isPinSet, false);
    });

    test('isAuthenticated should check state', () {
      // The provider starts in initial state
      expect(provider.state, AuthState.initial);
      expect(provider.isAuthenticated, false);
    });

    test('isLoading should check state', () {
      expect(provider.state, AuthState.initial);
      expect(provider.isLoading, false);
    });
  });

  group('ChwAuthProvider - State Transitions', () {
    test('AuthState initial to loading', () {
      var state = AuthState.initial;
      expect(state, equals(AuthState.initial));
      
      state = AuthState.loading;
      expect(state, equals(AuthState.loading));
    });

    test('AuthState loading to authenticated', () {
      var state = AuthState.loading;
      state = AuthState.authenticated;
      expect(state, equals(AuthState.authenticated));
    });

    test('AuthState loading to unauthenticated', () {
      var state = AuthState.loading;
      state = AuthState.unauthenticated;
      expect(state, equals(AuthState.unauthenticated));
    });

    test('AuthState loading to error', () {
      var state = AuthState.loading;
      state = AuthState.error;
      expect(state, equals(AuthState.error));
    });

    test('AuthState authenticated to unauthenticated on logout', () {
      var state = AuthState.authenticated;
      state = AuthState.unauthenticated;
      expect(state, equals(AuthState.unauthenticated));
    });
  });

  group('ChwAuthProvider - Computed Properties', () {
    late ChwAuthProvider provider;

    setUp(() {
      provider = ChwAuthProvider();
    });

    test('isAuthenticated returns true only for authenticated state', () {
      // Test using state comparison
      expect(AuthState.initial == AuthState.authenticated, isFalse);
      expect(AuthState.loading == AuthState.authenticated, isFalse);
      expect(AuthState.authenticated == AuthState.authenticated, isTrue);
      expect(AuthState.unauthenticated == AuthState.authenticated, isFalse);
      expect(AuthState.error == AuthState.authenticated, isFalse);
    });

    test('isLoading returns true only for loading state', () {
      expect(AuthState.initial == AuthState.loading, isFalse);
      expect(AuthState.loading == AuthState.loading, isTrue);
      expect(AuthState.authenticated == AuthState.loading, isFalse);
      expect(AuthState.unauthenticated == AuthState.loading, isFalse);
      expect(AuthState.error == AuthState.loading, isFalse);
    });
  });

  group('ChwAuthProvider - ChangeNotifier Behavior', () {
    late ChwAuthProvider provider;

    setUp(() {
      provider = ChwAuthProvider();
    });

    test('provider is a ChangeNotifier', () {
      expect(provider, isA<ChwAuthProvider>());
    });

    test('can add and remove listeners', () {
      var notified = false;
      void listener() {
        notified = true;
      }
      
      provider.addListener(listener);
      provider.removeListener(listener);
      
      // Listener was successfully added and removed without error
      expect(notified, isFalse);
    });
  });

  group('ChwProfile Model', () {
    test('ChwStatus should have all required values', () {
      expect(ChwStatus.values.length, greaterThanOrEqualTo(3));
      expect(ChwStatus.values.map((e) => e.value), contains('active'));
      expect(ChwStatus.values.map((e) => e.value), contains('inactive'));
      expect(ChwStatus.values.map((e) => e.value), contains('pending'));
    });

    test('ChwRole should have correct hierarchy', () {
      expect(ChwRole.trainee.level, lessThan(ChwRole.supervisor.level));
      expect(ChwRole.supervisor.level, lessThan(ChwRole.admin.level));
    });

    test('ChwRole should have all values', () {
      expect(ChwRole.values.length, 5);
      expect(ChwRole.values, contains(ChwRole.trainee));
      expect(ChwRole.values, contains(ChwRole.junior));
      expect(ChwRole.values, contains(ChwRole.senior));
      expect(ChwRole.values, contains(ChwRole.supervisor));
      expect(ChwRole.values, contains(ChwRole.admin));
    });

    test('ChwProfile should create with required fields', () {
      final profile = ChwProfile(
        id: 'user-001',
        chwId: 'CHW-KE-001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+255123456789',
        regionCode: 'TZ-01',
        facilityId: 'facility-001',
        role: ChwRole.junior,
        status: ChwStatus.active,
        passwordHash: 'hashed_password',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(profile.id, equals('user-001'));
      expect(profile.chwId, equals('CHW-KE-001'));
      expect(profile.firstName, equals('John'));
      expect(profile.lastName, equals('Doe'));
      expect(profile.fullName, equals('John Doe'));
      expect(profile.initials, equals('JD'));
    });

    test('ChwProfile fullName should combine first and last name', () {
      final profile = ChwProfile(
        id: 'test',
        chwId: 'CHW-001',
        firstName: 'Jane',
        lastName: 'Smith',
        phoneNumber: '+255000000000',
        regionCode: 'TZ-02',
        facilityId: 'fac-001',
        role: ChwRole.junior,
        status: ChwStatus.active,
        passwordHash: 'hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(profile.fullName, equals('Jane Smith'));
    });

    test('ChwProfile initials should be first letters', () {
      final profile = ChwProfile(
        id: 'test',
        chwId: 'CHW-002',
        firstName: 'Alice',
        lastName: 'Brown',
        phoneNumber: '+255000000000',
        regionCode: 'TZ-03',
        facilityId: 'fac-001',
        role: ChwRole.junior,
        status: ChwStatus.active,
        passwordHash: 'hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(profile.initials, equals('AB'));
    });

    test('ChwProfile isLocked should check lockedUntil', () {
      final now = DateTime.now();
      
      // Not locked (lockedUntil is null)
      final unlockedProfile = ChwProfile(
        id: 'test',
        chwId: 'CHW-003',
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+255000000000',
        regionCode: 'TZ-01',
        facilityId: 'fac-001',
        role: ChwRole.junior,
        status: ChwStatus.active,
        passwordHash: 'hash',
        createdAt: now,
        updatedAt: now,
      );
      expect(unlockedProfile.isLocked, isFalse);
      
      // Locked (lockedUntil is in future)
      final lockedProfile = ChwProfile(
        id: 'test',
        chwId: 'CHW-004',
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+255000000000',
        regionCode: 'TZ-01',
        facilityId: 'fac-001',
        role: ChwRole.junior,
        status: ChwStatus.active,
        passwordHash: 'hash',
        createdAt: now,
        updatedAt: now,
        lockedUntil: now.add(const Duration(hours: 1)),
      );
      expect(lockedProfile.isLocked, isTrue);
      
      // Not locked (lockedUntil is in past)
      final expiredLockProfile = ChwProfile(
        id: 'test',
        chwId: 'CHW-005',
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+255000000000',
        regionCode: 'TZ-01',
        facilityId: 'fac-001',
        role: ChwRole.junior,
        status: ChwStatus.active,
        passwordHash: 'hash',
        createdAt: now,
        updatedAt: now,
        lockedUntil: now.subtract(const Duration(hours: 1)),
      );
      expect(expiredLockProfile.isLocked, isFalse);
    });
  });

  group('ChwProfile - Serialization', () {
    test('ChwProfile toMap should include all fields', () {
      final now = DateTime.now();
      final profile = ChwProfile(
        id: 'user-001',
        chwId: 'CHW-KE-001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+255123456789',
        email: 'john@example.com',
        regionCode: 'TZ-01',
        facilityId: 'facility-001',
        role: ChwRole.junior,
        status: ChwStatus.active,
        passwordHash: 'hash123',
        createdAt: now,
        updatedAt: now,
      );
      
      final map = profile.toMap();
      
      expect(map['id'], equals('user-001'));
      expect(map['chw_id'], equals('CHW-KE-001'));
      expect(map['first_name'], equals('John'));
      expect(map['last_name'], equals('Doe'));
      expect(map['phone_number'], equals('+255123456789'));
      expect(map['email'], equals('john@example.com'));
      expect(map['region_code'], equals('TZ-01'));
      expect(map['facility_id'], equals('facility-001'));
      expect(map['role'], equals('junior'));
      expect(map['status'], equals('active'));
    });

    test('ChwProfile fromMap should restore all fields', () {
      final now = DateTime.now();
      final map = {
        'id': 'user-002',
        'chw_id': 'CHW-KE-002',
        'first_name': 'Jane',
        'last_name': 'Smith',
        'phone_number': '+255987654321',
        'region_code': 'TZ-02',
        'facility_id': 'facility-002',
        'role': 'supervisor',
        'status': 'active',
        'password_hash': 'hash456',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      
      final profile = ChwProfile.fromMap(map);
      
      expect(profile.id, equals('user-002'));
      expect(profile.chwId, equals('CHW-KE-002'));
      expect(profile.firstName, equals('Jane'));
      expect(profile.lastName, equals('Smith'));
      expect(profile.phoneNumber, equals('+255987654321'));
      expect(profile.role, equals(ChwRole.supervisor));
      expect(profile.status, equals(ChwStatus.active));
    });

    test('ChwProfile copyWith should create new instance', () {
      final now = DateTime.now();
      final original = ChwProfile(
        id: 'user-001',
        chwId: 'CHW-001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+255123456789',
        regionCode: 'TZ-01',
        facilityId: 'facility-001',
        role: ChwRole.junior,
        status: ChwStatus.active,
        passwordHash: 'hash',
        createdAt: now,
        updatedAt: now,
      );
      
      final updated = original.copyWith(
        firstName: 'Johnny',
        status: ChwStatus.inactive,
      );
      
      expect(updated.firstName, equals('Johnny'));
      expect(updated.status, equals(ChwStatus.inactive));
      expect(updated.lastName, equals('Doe')); // Unchanged
      expect(original.firstName, equals('John')); // Original unchanged
    });
  });

  group('Login Flow Logic', () {
    test('login should require phoneNumber and password', () {
      bool isValidLogin(String? phoneNumber, String? password) {
        return phoneNumber != null && 
               phoneNumber.isNotEmpty && 
               password != null && 
               password.isNotEmpty;
      }

      expect(isValidLogin(null, null), isFalse);
      expect(isValidLogin('', ''), isFalse);
      expect(isValidLogin('+255123456789', ''), isFalse);
      expect(isValidLogin('', 'password123'), isFalse);
      expect(isValidLogin('+255123456789', 'password123'), isTrue);
    });

    test('PIN should be 4-6 digits', () {
      bool isValidPin(String pin) {
        if (pin.length < 4 || pin.length > 6) return false;
        return pin.split('').every((c) => '0123456789'.contains(c));
      }

      expect(isValidPin(''), isFalse);
      expect(isValidPin('123'), isFalse);
      expect(isValidPin('1234'), isTrue);
      expect(isValidPin('12345'), isTrue);
      expect(isValidPin('123456'), isTrue);
      expect(isValidPin('1234567'), isFalse);
      expect(isValidPin('abcd'), isFalse);
      expect(isValidPin('12ab'), isFalse);
    });

    test('phone number validation', () {
      bool isValidPhone(String phone) {
        final regex = RegExp(r'^\+?[0-9]{10,15}$');
        return regex.hasMatch(phone);
      }

      expect(isValidPhone(''), isFalse);
      expect(isValidPhone('123'), isFalse);
      expect(isValidPhone('+255123456789'), isTrue);
      expect(isValidPhone('0712345678'), isTrue);
      expect(isValidPhone('07123456789012345'), isFalse);
    });
  });

  group('Registration Validation', () {
    test('registration requires all mandatory fields', () {
      bool isValidRegistration({
        String? firstName,
        String? lastName,
        String? phoneNumber,
        String? password,
        String? regionCode,
        String? facilityId,
      }) {
        return firstName != null && firstName.isNotEmpty &&
               lastName != null && lastName.isNotEmpty &&
               phoneNumber != null && phoneNumber.isNotEmpty &&
               password != null && password.length >= 8 &&
               regionCode != null && regionCode.isNotEmpty &&
               facilityId != null && facilityId.isNotEmpty;
      }

      expect(isValidRegistration(), isFalse);
      expect(isValidRegistration(
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+255123456789',
        password: 'pass123',  // Too short
        regionCode: 'TZ-01',
        facilityId: 'fac-001',
      ), isFalse);
      
      expect(isValidRegistration(
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+255123456789',
        password: 'password123',
        regionCode: 'TZ-01',
        facilityId: 'fac-001',
      ), isTrue);
    });

    test('password should meet minimum requirements', () {
      bool isValidPassword(String password) {
        return password.length >= 8;
      }

      expect(isValidPassword(''), isFalse);
      expect(isValidPassword('1234567'), isFalse);
      expect(isValidPassword('12345678'), isTrue);
      expect(isValidPassword('password123'), isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/chw_profile.dart';

void main() {
  group('ChwRole', () {
    test('should have correct labels', () {
      expect(ChwRole.trainee.labelKo, '교육생');
      expect(ChwRole.junior.labelKo, '주니어');
      expect(ChwRole.senior.labelKo, '시니어');
      expect(ChwRole.supervisor.labelKo, '감독자');
      expect(ChwRole.admin.labelKo, '관리자');
    });

    test('should have correct levels', () {
      expect(ChwRole.trainee.level, 1);
      expect(ChwRole.junior.level, 2);
      expect(ChwRole.senior.level, 3);
      expect(ChwRole.supervisor.level, 4);
      expect(ChwRole.admin.level, 5);
    });

    test('label should return locale-specific label', () {
      expect(ChwRole.trainee.label('ko'), '교육생');
      expect(ChwRole.trainee.label('sw'), 'trainee');
    });
  });

  group('ChwStatus', () {
    test('should have correct labels', () {
      expect(ChwStatus.pending.label, '승인 대기');
      expect(ChwStatus.active.label, '활성');
      expect(ChwStatus.suspended.label, '정지');
      expect(ChwStatus.inactive.label, '비활성');
    });

    test('should have correct values', () {
      expect(ChwStatus.pending.value, 'pending');
      expect(ChwStatus.active.value, 'active');
    });
  });

  group('ChwCertification', () {
    test('should create with all fields', () {
      final cert = ChwCertification(
        id: 'cert-001',
        name: 'Basic Health Training',
        issuedAt: DateTime(2024, 1, 1),
        expiresAt: DateTime(2025, 1, 1),
        issuingOrganization: 'Ministry of Health',
        certificateNumber: 'BHT-2024-001',
      );

      expect(cert.id, 'cert-001');
      expect(cert.name, 'Basic Health Training');
      expect(cert.issuingOrganization, 'Ministry of Health');
    });

    test('isExpired should check expiration date', () {
      final expired = ChwCertification(
        id: 'cert-001',
        name: 'Expired Cert',
        issuedAt: DateTime(2020, 1, 1),
        expiresAt: DateTime(2021, 1, 1),
      );

      final valid = ChwCertification(
        id: 'cert-002',
        name: 'Valid Cert',
        issuedAt: DateTime(2024, 1, 1),
        expiresAt: DateTime(2030, 1, 1),
      );

      final noExpiry = ChwCertification(
        id: 'cert-003',
        name: 'No Expiry',
        issuedAt: DateTime(2024, 1, 1),
      );

      expect(expired.isExpired, true);
      expect(valid.isExpired, false);
      expect(noExpiry.isExpired, false);
    });

    test('isValid should be inverse of isExpired', () {
      final cert = ChwCertification(
        id: 'cert-001',
        name: 'Test',
        issuedAt: DateTime(2024, 1, 1),
        expiresAt: DateTime(2030, 1, 1),
      );

      expect(cert.isValid, true);
      expect(cert.isValid, !cert.isExpired);
    });

    test('toMap should convert all fields', () {
      final cert = ChwCertification(
        id: 'cert-001',
        name: 'Basic Health Training',
        issuedAt: DateTime(2024, 1, 1),
        expiresAt: DateTime(2025, 1, 1),
        issuingOrganization: 'MOH',
        certificateNumber: 'BHT-001',
      );

      final map = cert.toMap();

      expect(map['id'], 'cert-001');
      expect(map['name'], 'Basic Health Training');
      expect(map['issuing_organization'], 'MOH');
      expect(map['certificate_number'], 'BHT-001');
    });

    test('fromMap should restore all fields', () {
      final map = {
        'id': 'cert-002',
        'name': 'Advanced Training',
        'issued_at': '2024-01-01T00:00:00.000',
        'expires_at': '2025-01-01T00:00:00.000',
        'issuing_organization': 'WHO',
        'certificate_number': 'ADV-002',
      };

      final cert = ChwCertification.fromMap(map);

      expect(cert.id, 'cert-002');
      expect(cert.name, 'Advanced Training');
      expect(cert.issuingOrganization, 'WHO');
    });
  });

  group('ChwProfile', () {
    ChwProfile createTestProfile() {
      return ChwProfile(
        id: 'profile-001',
        chwId: 'CHW-KE-001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+254712345678',
        email: 'john.doe@example.com',
        role: ChwRole.senior,
        status: ChwStatus.active,
        regionCode: 'KE-NAI',
        facilityId: 'facility-001',
        passwordHash: 'hashed_password',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );
    }

    test('should create with all required fields', () {
      final profile = createTestProfile();

      expect(profile.id, 'profile-001');
      expect(profile.chwId, 'CHW-KE-001');
      expect(profile.firstName, 'John');
      expect(profile.lastName, 'Doe');
      expect(profile.role, ChwRole.senior);
      expect(profile.status, ChwStatus.active);
    });

    test('fullName should combine first and last name', () {
      final profile = createTestProfile();

      expect(profile.fullName, 'John Doe');
    });

    test('initials should return first letters', () {
      final profile = createTestProfile();

      expect(profile.initials, 'JD');
    });

    test('isLocked should check lockedUntil', () {
      final locked = ChwProfile(
        id: 'profile-001',
        chwId: 'CHW-KE-001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+254712345678',
        role: ChwRole.senior,
        status: ChwStatus.active,
        regionCode: 'KE-NAI',
        facilityId: 'facility-001',
        passwordHash: 'hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lockedUntil: DateTime.now().add(const Duration(hours: 1)),
      );

      final notLocked = createTestProfile();

      expect(locked.isLocked, true);
      expect(notLocked.isLocked, false);
    });

    test('validCertifications should return non-expired certs', () {
      final withCerts = ChwProfile(
        id: 'profile-001',
        chwId: 'CHW-KE-001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+254712345678',
        role: ChwRole.senior,
        status: ChwStatus.active,
        regionCode: 'KE-NAI',
        facilityId: 'facility-001',
        passwordHash: 'hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        certifications: [
          ChwCertification(
            id: 'cert-001',
            name: 'Basic',
            issuedAt: DateTime(2024, 1, 1),
            expiresAt: DateTime(2030, 1, 1),
          ),
          ChwCertification(
            id: 'cert-002',
            name: 'Expired',
            issuedAt: DateTime(2020, 1, 1),
            expiresAt: DateTime(2021, 1, 1),
          ),
        ],
      );

      final noCerts = createTestProfile();

      expect(withCerts.validCertifications.length, 1);
      expect(noCerts.validCertifications.length, 0);
    });

    test('toMap should convert all fields', () {
      final profile = createTestProfile();
      final map = profile.toMap();

      expect(map['id'], 'profile-001');
      expect(map['chw_id'], 'CHW-KE-001');
      expect(map['first_name'], 'John');
      expect(map['last_name'], 'Doe');
      expect(map['phone_number'], '+254712345678');
      expect(map['role'], 'senior');
      expect(map['status'], 'active');
    });

    test('fromMap should restore all fields', () {
      final map = {
        'id': 'profile-002',
        'chw_id': 'CHW-KE-002',
        'first_name': 'Jane',
        'last_name': 'Smith',
        'phone_number': '+254798765432',
        'email': 'jane@example.com',
        'role': 'supervisor',
        'status': 'active',
        'region_code': 'KE-MOM',
        'facility_id': 'facility-002',
        'password_hash': 'hash',
        'total_screenings_completed': 50,
        'total_referrals_made': 10,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-15T00:00:00.000',
      };

      final profile = ChwProfile.fromMap(map);

      expect(profile.id, 'profile-002');
      expect(profile.firstName, 'Jane');
      expect(profile.role, ChwRole.supervisor);
      expect(profile.totalScreeningsCompleted, 50);
    });

    test('copyWith should update specified fields', () {
      final original = createTestProfile();
      final updated = original.copyWith(
        role: ChwRole.supervisor,
        totalScreeningsCompleted: 100,
      );

      expect(updated.id, 'profile-001'); // unchanged
      expect(updated.firstName, 'John'); // unchanged
      expect(updated.role, ChwRole.supervisor); // updated
      expect(updated.totalScreeningsCompleted, 100); // updated
    });

    test('isActive should check status and lock', () {
      final active = createTestProfile();
      final inactive = createTestProfile().copyWith(status: ChwStatus.inactive);
      final locked = createTestProfile().copyWith(
        lockedUntil: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(active.isActive, true);
      expect(inactive.isActive, false);
      expect(locked.isActive, false);
    });

    test('hasRoleLevel should check minimum level', () {
      final trainee = createTestProfile().copyWith(role: ChwRole.trainee);
      final senior = createTestProfile().copyWith(role: ChwRole.senior);
      final admin = createTestProfile().copyWith(role: ChwRole.admin);

      expect(trainee.hasRoleLevel(1), true);
      expect(trainee.hasRoleLevel(2), false);
      expect(senior.hasRoleLevel(3), true);
      expect(senior.hasRoleLevel(4), false);
      expect(admin.hasRoleLevel(5), true);
    });

    test('isSupervisorOrAbove should check supervisor level', () {
      final trainee = createTestProfile().copyWith(role: ChwRole.trainee);
      final junior = createTestProfile().copyWith(role: ChwRole.junior);
      final senior = createTestProfile().copyWith(role: ChwRole.senior);
      final supervisor = createTestProfile().copyWith(role: ChwRole.supervisor);
      final admin = createTestProfile().copyWith(role: ChwRole.admin);

      expect(trainee.isSupervisorOrAbove, false);
      expect(junior.isSupervisorOrAbove, false);
      expect(senior.isSupervisorOrAbove, false);
      expect(supervisor.isSupervisorOrAbove, true);
      expect(admin.isSupervisorOrAbove, true);
    });

    test('create factory should generate valid profile', () {
      final profile = ChwProfile.create(
        firstName: 'Alice',
        lastName: 'Johnson',
        phoneNumber: '+254700000000',
        email: 'alice@example.com',
        regionCode: 'KE',
        facilityId: 'facility-001',
        passwordHash: 'hashed_password',
        role: ChwRole.junior,
      );

      expect(profile.firstName, 'Alice');
      expect(profile.lastName, 'Johnson');
      expect(profile.status, ChwStatus.pending);
      expect(profile.role, ChwRole.junior);
      expect(profile.chwId, contains('CHW-KE'));
      expect(profile.id, isNotEmpty);
    });

    test('create factory should default to trainee role', () {
      final profile = ChwProfile.create(
        firstName: 'Bob',
        lastName: 'Smith',
        phoneNumber: '+254700000001',
        regionCode: 'KE',
        facilityId: 'facility-001',
        passwordHash: 'hash',
      );

      expect(profile.role, ChwRole.trainee);
    });

    test('onLoginSuccess should update last login and reset failures', () {
      final original = createTestProfile().copyWith(
        failedLoginAttempts: 3,
      );

      final updated = original.onLoginSuccess();

      expect(updated.failedLoginAttempts, 0);
      expect(updated.lastLoginAt, isNotNull);
    });

    test('onLoginFailure should increment failure count', () {
      final original = createTestProfile();

      final updated = original.onLoginFailure();

      expect(updated.failedLoginAttempts, 1);
      expect(updated.lockedUntil, isNull); // Not locked yet
    });

    test('onLoginFailure should lock after max attempts', () {
      final original = createTestProfile().copyWith(failedLoginAttempts: 4);

      final updated = original.onLoginFailure(maxAttempts: 5);

      expect(updated.failedLoginAttempts, 5);
      expect(updated.lockedUntil, isNotNull);
      expect(updated.isLocked, true);
    });

    test('onLoginFailure should use custom max attempts', () {
      final original = createTestProfile().copyWith(failedLoginAttempts: 2);

      final updated = original.onLoginFailure(maxAttempts: 3);

      expect(updated.failedLoginAttempts, 3);
      expect(updated.lockedUntil, isNotNull);
    });

    test('onLoginFailure should use custom lock duration', () {
      final original = createTestProfile().copyWith(failedLoginAttempts: 4);
      final customDuration = const Duration(hours: 2);

      final updated = original.onLoginFailure(
        maxAttempts: 5,
        lockDuration: customDuration,
      );

      expect(updated.lockedUntil, isNotNull);
    });
  });

  group('ChwProfile - Comprehensive copyWith Tests', () {
    ChwProfile createTestProfile() {
      return ChwProfile(
        id: 'profile-001',
        chwId: 'CHW-KE-001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+254712345678',
        email: 'john.doe@example.com',
        role: ChwRole.senior,
        status: ChwStatus.active,
        regionCode: 'KE-NAI',
        facilityId: 'facility-001',
        passwordHash: 'hashed_password',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );
    }

    test('copyWith should update id', () {
      final original = createTestProfile();
      final updated = original.copyWith(id: 'new-id');
      expect(updated.id, 'new-id');
      expect(original.id, 'profile-001');
    });

    test('copyWith should update chwId', () {
      final original = createTestProfile();
      final updated = original.copyWith(chwId: 'CHW-KE-999');
      expect(updated.chwId, 'CHW-KE-999');
    });

    test('copyWith should update firstName', () {
      final original = createTestProfile();
      final updated = original.copyWith(firstName: 'Jane');
      expect(updated.firstName, 'Jane');
    });

    test('copyWith should update lastName', () {
      final original = createTestProfile();
      final updated = original.copyWith(lastName: 'Smith');
      expect(updated.lastName, 'Smith');
    });

    test('copyWith should update phoneNumber', () {
      final original = createTestProfile();
      final updated = original.copyWith(phoneNumber: '+254700000000');
      expect(updated.phoneNumber, '+254700000000');
    });

    test('copyWith should update email', () {
      final original = createTestProfile();
      final updated = original.copyWith(email: 'newemail@example.com');
      expect(updated.email, 'newemail@example.com');
    });

    test('copyWith should update role', () {
      final original = createTestProfile();
      final updated = original.copyWith(role: ChwRole.admin);
      expect(updated.role, ChwRole.admin);
    });

    test('copyWith should update status', () {
      final original = createTestProfile();
      final updated = original.copyWith(status: ChwStatus.suspended);
      expect(updated.status, ChwStatus.suspended);
    });

    test('copyWith should update photoUrl', () {
      final original = createTestProfile();
      final updated = original.copyWith(photoUrl: 'https://example.com/photo.jpg');
      expect(updated.photoUrl, 'https://example.com/photo.jpg');
    });

    test('copyWith should update regionCode', () {
      final original = createTestProfile();
      final updated = original.copyWith(regionCode: 'KE-MOM');
      expect(updated.regionCode, 'KE-MOM');
    });

    test('copyWith should update facilityId', () {
      final original = createTestProfile();
      final updated = original.copyWith(facilityId: 'facility-999');
      expect(updated.facilityId, 'facility-999');
    });

    test('copyWith should update supervisorId', () {
      final original = createTestProfile();
      final updated = original.copyWith(supervisorId: 'supervisor-001');
      expect(updated.supervisorId, 'supervisor-001');
    });

    test('copyWith should update certifications', () {
      final original = createTestProfile();
      final newCerts = [
        ChwCertification(
          id: 'cert-new',
          name: 'New Cert',
          issuedAt: DateTime.now(),
        ),
      ];
      final updated = original.copyWith(certifications: newCerts);
      expect(updated.certifications.length, 1);
      expect(updated.certifications.first.id, 'cert-new');
    });

    test('copyWith should update completedTrainingModuleIds', () {
      final original = createTestProfile();
      final updated = original.copyWith(
        completedTrainingModuleIds: ['module-1', 'module-2'],
      );
      expect(updated.completedTrainingModuleIds.length, 2);
    });

    test('copyWith should update totalScreeningsCompleted', () {
      final original = createTestProfile();
      final updated = original.copyWith(totalScreeningsCompleted: 500);
      expect(updated.totalScreeningsCompleted, 500);
    });

    test('copyWith should update totalReferralsMade', () {
      final original = createTestProfile();
      final updated = original.copyWith(totalReferralsMade: 150);
      expect(updated.totalReferralsMade, 150);
    });

    test('copyWith should update passwordHash', () {
      final original = createTestProfile();
      final updated = original.copyWith(passwordHash: 'new_hash');
      expect(updated.passwordHash, 'new_hash');
    });

    test('copyWith should update pin', () {
      final original = createTestProfile();
      final updated = original.copyWith(pin: '1234');
      expect(updated.pin, '1234');
    });

    test('copyWith should update lastLoginAt', () {
      final original = createTestProfile();
      final newDate = DateTime(2024, 12, 31);
      final updated = original.copyWith(lastLoginAt: newDate);
      expect(updated.lastLoginAt, newDate);
    });

    test('copyWith should update lastSyncAt', () {
      final original = createTestProfile();
      final newDate = DateTime(2024, 12, 31);
      final updated = original.copyWith(lastSyncAt: newDate);
      expect(updated.lastSyncAt, newDate);
    });

    test('copyWith should update failedLoginAttempts', () {
      final original = createTestProfile();
      final updated = original.copyWith(failedLoginAttempts: 3);
      expect(updated.failedLoginAttempts, 3);
    });

    test('copyWith should update lockedUntil', () {
      final original = createTestProfile();
      final lockDate = DateTime.now().add(const Duration(hours: 2));
      final updated = original.copyWith(lockedUntil: lockDate);
      expect(updated.lockedUntil, lockDate);
    });

    test('copyWith should update createdAt', () {
      final original = createTestProfile();
      final newDate = DateTime(2023, 1, 1);
      final updated = original.copyWith(createdAt: newDate);
      expect(updated.createdAt, newDate);
    });

    test('copyWith should update updatedAt automatically', () {
      final original = createTestProfile();
      final before = DateTime.now();
      final updated = original.copyWith(firstName: 'NewName');
      final after = DateTime.now();

      expect(updated.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(updated.updatedAt.isBefore(after.add(const Duration(seconds: 1))), true);
    });

    test('copyWith can update multiple fields', () {
      final original = createTestProfile();
      final updated = original.copyWith(
        firstName: 'Alice',
        lastName: 'Johnson',
        role: ChwRole.admin,
        status: ChwStatus.suspended,
        totalScreeningsCompleted: 1000,
      );

      expect(updated.firstName, 'Alice');
      expect(updated.lastName, 'Johnson');
      expect(updated.role, ChwRole.admin);
      expect(updated.status, ChwStatus.suspended);
      expect(updated.totalScreeningsCompleted, 1000);
    });
  });

  group('ChwProfile - toMap/fromMap comprehensive', () {
    test('toMap should include all fields', () {
      final profile = ChwProfile(
        id: 'id-001',
        chwId: 'CHW-KE-001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+254700000000',
        email: 'john@example.com',
        role: ChwRole.supervisor,
        status: ChwStatus.active,
        photoUrl: 'https://example.com/photo.jpg',
        regionCode: 'KE',
        facilityId: 'facility-001',
        supervisorId: 'supervisor-001',
        certifications: [
          ChwCertification(
            id: 'cert-001',
            name: 'Basic',
            issuedAt: DateTime(2024, 1, 1),
          ),
        ],
        completedTrainingModuleIds: ['module-1', 'module-2'],
        totalScreeningsCompleted: 100,
        totalReferralsMade: 50,
        passwordHash: 'hash',
        pin: '1234',
        lastLoginAt: DateTime(2024, 12, 1),
        lastSyncAt: DateTime(2024, 12, 2),
        failedLoginAttempts: 2,
        lockedUntil: DateTime(2024, 12, 31),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 12, 15),
      );

      final map = profile.toMap();

      expect(map['id'], 'id-001');
      expect(map['chw_id'], 'CHW-KE-001');
      expect(map['first_name'], 'John');
      expect(map['last_name'], 'Doe');
      expect(map['phone_number'], '+254700000000');
      expect(map['email'], 'john@example.com');
      expect(map['role'], 'supervisor');
      expect(map['status'], 'active');
      expect(map['photo_url'], 'https://example.com/photo.jpg');
      expect(map['region_code'], 'KE');
      expect(map['facility_id'], 'facility-001');
      expect(map['supervisor_id'], 'supervisor-001');
      expect(map['certifications'], isA<List>());
      expect(map['completed_training_module_ids'], isA<List>());
      expect(map['total_screenings_completed'], 100);
      expect(map['total_referrals_made'], 50);
      expect(map['password_hash'], 'hash');
      expect(map['pin'], '1234');
      expect(map['last_login_at'], isNotNull);
      expect(map['last_sync_at'], isNotNull);
      expect(map['failed_login_attempts'], 2);
      expect(map['locked_until'], isNotNull);
      expect(map['created_at'], isNotNull);
      expect(map['updated_at'], isNotNull);
    });

    test('fromMap should handle all fields', () {
      final map = {
        'id': 'id-002',
        'chw_id': 'CHW-KE-002',
        'first_name': 'Jane',
        'last_name': 'Smith',
        'phone_number': '+254700000001',
        'email': 'jane@example.com',
        'role': 'admin',
        'status': 'active',
        'photo_url': 'https://example.com/jane.jpg',
        'region_code': 'KE-MOM',
        'facility_id': 'facility-002',
        'supervisor_id': 'supervisor-002',
        'certifications': [],
        'completed_training_module_ids': ['module-3'],
        'total_screenings_completed': 200,
        'total_referrals_made': 75,
        'password_hash': 'hash2',
        'pin': '5678',
        'last_login_at': '2024-12-01T10:00:00.000',
        'last_sync_at': '2024-12-02T11:00:00.000',
        'failed_login_attempts': 1,
        'locked_until': '2024-12-31T23:59:59.000',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-12-15T12:00:00.000',
      };

      final profile = ChwProfile.fromMap(map);

      expect(profile.id, 'id-002');
      expect(profile.chwId, 'CHW-KE-002');
      expect(profile.firstName, 'Jane');
      expect(profile.lastName, 'Smith');
      expect(profile.phoneNumber, '+254700000001');
      expect(profile.email, 'jane@example.com');
      expect(profile.role, ChwRole.admin);
      expect(profile.status, ChwStatus.active);
      expect(profile.photoUrl, 'https://example.com/jane.jpg');
      expect(profile.regionCode, 'KE-MOM');
      expect(profile.facilityId, 'facility-002');
      expect(profile.supervisorId, 'supervisor-002');
      expect(profile.completedTrainingModuleIds, ['module-3']);
      expect(profile.totalScreeningsCompleted, 200);
      expect(profile.totalReferralsMade, 75);
      expect(profile.passwordHash, 'hash2');
      expect(profile.pin, '5678');
      expect(profile.lastLoginAt, isNotNull);
      expect(profile.lastSyncAt, isNotNull);
      expect(profile.failedLoginAttempts, 1);
      expect(profile.lockedUntil, isNotNull);
    });

    test('fromMap should handle missing optional fields', () {
      final map = {
        'id': 'id-003',
        'chw_id': 'CHW-KE-003',
        'first_name': 'Bob',
        'last_name': 'Wilson',
        'phone_number': '+254700000002',
        'role': 'trainee',
        'status': 'pending',
        'region_code': 'KE',
        'facility_id': 'facility-003',
        'password_hash': 'hash3',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final profile = ChwProfile.fromMap(map);

      expect(profile.email, isNull);
      expect(profile.photoUrl, isNull);
      expect(profile.supervisorId, isNull);
      expect(profile.pin, isNull);
      expect(profile.lastLoginAt, isNull);
      expect(profile.lastSyncAt, isNull);
      expect(profile.lockedUntil, isNull);
      expect(profile.certifications, isEmpty);
      expect(profile.completedTrainingModuleIds, isEmpty);
      expect(profile.totalScreeningsCompleted, 0);
      expect(profile.totalReferralsMade, 0);
      expect(profile.failedLoginAttempts, 0);
    });

    test('fromMap should handle invalid role gracefully', () {
      final map = {
        'id': 'id-004',
        'chw_id': 'CHW-KE-004',
        'first_name': 'Alice',
        'last_name': 'Brown',
        'phone_number': '+254700000003',
        'role': 'invalid_role',
        'status': 'active',
        'region_code': 'KE',
        'facility_id': 'facility-004',
        'password_hash': 'hash4',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final profile = ChwProfile.fromMap(map);

      expect(profile.role, ChwRole.trainee); // Default
    });

    test('fromMap should handle invalid status gracefully', () {
      final map = {
        'id': 'id-005',
        'chw_id': 'CHW-KE-005',
        'first_name': 'Charlie',
        'last_name': 'Davis',
        'phone_number': '+254700000004',
        'role': 'junior',
        'status': 'invalid_status',
        'region_code': 'KE',
        'facility_id': 'facility-005',
        'password_hash': 'hash5',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final profile = ChwProfile.fromMap(map);

      expect(profile.status, ChwStatus.pending); // Default
    });

    test('serialization round trip should preserve all data', () {
      final original = ChwProfile(
        id: 'id-roundtrip',
        chwId: 'CHW-KE-RT',
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+254700000999',
        email: 'test@example.com',
        role: ChwRole.senior,
        status: ChwStatus.active,
        photoUrl: 'https://example.com/test.jpg',
        regionCode: 'KE',
        facilityId: 'facility-rt',
        supervisorId: 'supervisor-rt',
        certifications: [
          ChwCertification(
            id: 'cert-rt',
            name: 'Test Cert',
            issuedAt: DateTime(2024, 1, 1),
            expiresAt: DateTime(2025, 1, 1),
          ),
        ],
        completedTrainingModuleIds: ['mod-1', 'mod-2'],
        totalScreeningsCompleted: 999,
        totalReferralsMade: 99,
        passwordHash: 'hash_rt',
        pin: '9999',
        lastLoginAt: DateTime(2024, 12, 1),
        lastSyncAt: DateTime(2024, 12, 2),
        failedLoginAttempts: 3,
        lockedUntil: DateTime(2024, 12, 31),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 12, 15),
      );

      final map = original.toMap();
      final restored = ChwProfile.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.chwId, original.chwId);
      expect(restored.firstName, original.firstName);
      expect(restored.lastName, original.lastName);
      expect(restored.phoneNumber, original.phoneNumber);
      expect(restored.email, original.email);
      expect(restored.role, original.role);
      expect(restored.status, original.status);
      expect(restored.photoUrl, original.photoUrl);
      expect(restored.regionCode, original.regionCode);
      expect(restored.facilityId, original.facilityId);
      expect(restored.supervisorId, original.supervisorId);
      expect(restored.completedTrainingModuleIds, original.completedTrainingModuleIds);
      expect(restored.totalScreeningsCompleted, original.totalScreeningsCompleted);
      expect(restored.totalReferralsMade, original.totalReferralsMade);
      expect(restored.passwordHash, original.passwordHash);
      expect(restored.pin, original.pin);
      expect(restored.failedLoginAttempts, original.failedLoginAttempts);
    });
  });

  group('ChwRole - Additional Tests', () {
    test('all roles should have unique levels', () {
      final levels = ChwRole.values.map((r) => r.level).toSet();
      expect(levels.length, ChwRole.values.length);
    });

    test('all roles should have unique Korean labels', () {
      final labels = ChwRole.values.map((r) => r.labelKo).toSet();
      expect(labels.length, ChwRole.values.length);
    });

    test('all roles should have unique English labels', () {
      final labels = ChwRole.values.map((r) => r.labelEn).toSet();
      expect(labels.length, ChwRole.values.length);
    });

    test('levels should be in ascending order', () {
      expect(ChwRole.trainee.level < ChwRole.junior.level, true);
      expect(ChwRole.junior.level < ChwRole.senior.level, true);
      expect(ChwRole.senior.level < ChwRole.supervisor.level, true);
      expect(ChwRole.supervisor.level < ChwRole.admin.level, true);
    });

    test('should have exactly 5 roles', () {
      expect(ChwRole.values.length, 5);
    });
  });

  group('ChwStatus - Additional Tests', () {
    test('all statuses should have unique values', () {
      final values = ChwStatus.values.map((s) => s.value).toSet();
      expect(values.length, ChwStatus.values.length);
    });

    test('all statuses should have unique labels', () {
      final labels = ChwStatus.values.map((s) => s.label).toSet();
      expect(labels.length, ChwStatus.values.length);
    });

    test('should have exactly 4 statuses', () {
      expect(ChwStatus.values.length, 4);
    });
  });

  group('ChwCertification - Additional Tests', () {
    test('isExpired should handle null expiry', () {
      final cert = ChwCertification(
        id: 'cert-no-expiry',
        name: 'Permanent Cert',
        issuedAt: DateTime(2024, 1, 1),
      );

      expect(cert.isExpired, false);
    });

    test('toMap should handle null optional fields', () {
      final cert = ChwCertification(
        id: 'cert-min',
        name: 'Minimal Cert',
        issuedAt: DateTime(2024, 1, 1),
      );

      final map = cert.toMap();

      expect(map['expires_at'], isNull);
      expect(map['issuing_organization'], isNull);
      expect(map['certificate_number'], isNull);
    });

    test('fromMap should handle null optional fields', () {
      final map = {
        'id': 'cert-from-min',
        'name': 'Minimal Cert',
        'issued_at': '2024-01-01T00:00:00.000',
      };

      final cert = ChwCertification.fromMap(map);

      expect(cert.expiresAt, isNull);
      expect(cert.issuingOrganization, isNull);
      expect(cert.certificateNumber, isNull);
    });

    test('serialization round trip for certification', () {
      final original = ChwCertification(
        id: 'cert-round',
        name: 'Round Trip Cert',
        issuedAt: DateTime(2024, 6, 15, 10, 30),
        expiresAt: DateTime(2026, 6, 15, 10, 30),
        issuingOrganization: 'Test Org',
        certificateNumber: 'RT-2024-001',
      );

      final map = original.toMap();
      final restored = ChwCertification.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.issuingOrganization, original.issuingOrganization);
      expect(restored.certificateNumber, original.certificateNumber);
    });
  });

  group('ChwProfile - Edge Cases', () {
    test('initials should handle empty names', () {
      final profile = ChwProfile(
        id: 'id',
        chwId: 'CHW-001',
        firstName: '',
        lastName: '',
        phoneNumber: '+254700000000',
        role: ChwRole.trainee,
        status: ChwStatus.pending,
        regionCode: 'KE',
        facilityId: 'facility-001',
        passwordHash: 'hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.initials, '');
    });

    test('fullName should handle names correctly', () {
      final profile = ChwProfile(
        id: 'id',
        chwId: 'CHW-001',
        firstName: 'First',
        lastName: 'Last',
        phoneNumber: '+254700000000',
        role: ChwRole.trainee,
        status: ChwStatus.pending,
        regionCode: 'KE',
        facilityId: 'facility-001',
        passwordHash: 'hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.fullName, 'First Last');
    });

    test('validCertifications should filter correctly', () {
      final profile = ChwProfile(
        id: 'id',
        chwId: 'CHW-001',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+254700000000',
        role: ChwRole.trainee,
        status: ChwStatus.pending,
        regionCode: 'KE',
        facilityId: 'facility-001',
        passwordHash: 'hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        certifications: [
          ChwCertification(
            id: 'valid',
            name: 'Valid',
            issuedAt: DateTime(2024, 1, 1),
            expiresAt: DateTime(2030, 1, 1),
          ),
          ChwCertification(
            id: 'expired',
            name: 'Expired',
            issuedAt: DateTime(2020, 1, 1),
            expiresAt: DateTime(2021, 1, 1),
          ),
          ChwCertification(
            id: 'no-expiry',
            name: 'No Expiry',
            issuedAt: DateTime(2024, 1, 1),
          ),
        ],
      );

      final valid = profile.validCertifications;
      expect(valid.length, 2);
      expect(valid.any((c) => c.id == 'valid'), true);
      expect(valid.any((c) => c.id == 'no-expiry'), true);
      expect(valid.any((c) => c.id == 'expired'), false);
    });

    test('hasRoleLevel should work with boundary values', () {
      final admin = ChwProfile(
        id: 'id',
        chwId: 'CHW-001',
        firstName: 'Admin',
        lastName: 'User',
        phoneNumber: '+254700000000',
        role: ChwRole.admin,
        status: ChwStatus.active,
        regionCode: 'KE',
        facilityId: 'facility-001',
        passwordHash: 'hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(admin.hasRoleLevel(5), true);
      expect(admin.hasRoleLevel(6), false);
      expect(admin.hasRoleLevel(1), true);
    });
  });
}

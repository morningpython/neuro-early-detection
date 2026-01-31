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
  });
}

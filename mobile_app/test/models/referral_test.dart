import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/referral.dart';

void main() {
  group('ReferralStatus', () {
    test('should have correct labels', () {
      expect(ReferralStatus.pending.label, '대기중');
      expect(ReferralStatus.sent.label, '발송됨');
      expect(ReferralStatus.confirmed.label, '확인됨');
      expect(ReferralStatus.completed.label, '완료');
      expect(ReferralStatus.cancelled.label, '취소됨');
    });

    test('fromString should parse correctly', () {
      expect(ReferralStatus.fromString('pending'), ReferralStatus.pending);
      expect(ReferralStatus.fromString('sent'), ReferralStatus.sent);
      expect(ReferralStatus.fromString('confirmed'), ReferralStatus.confirmed);
      expect(ReferralStatus.fromString('completed'), ReferralStatus.completed);
      expect(ReferralStatus.fromString('invalid'), ReferralStatus.pending);
    });
  });

  group('ReferralPriority', () {
    test('should have correct labels', () {
      expect(ReferralPriority.low.label, '낮음');
      expect(ReferralPriority.medium.label, '중간');
      expect(ReferralPriority.high.label, '높음');
      expect(ReferralPriority.urgent.label, '긴급');
    });

    test('fromString should parse correctly', () {
      expect(ReferralPriority.fromString('low'), ReferralPriority.low);
      expect(ReferralPriority.fromString('urgent'), ReferralPriority.urgent);
      expect(ReferralPriority.fromString('invalid'), ReferralPriority.medium);
    });
  });

  group('Referral', () {
    test('should create with all required fields', () {
      final referral = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.high,
        reason: 'High risk score: 0.85',
      );

      expect(referral.id, 'ref-001');
      expect(referral.screeningId, 'scr-001');
      expect(referral.patientName, 'John Doe');
      expect(referral.facilityName, 'Nairobi Hospital');
      expect(referral.status, ReferralStatus.pending);
      expect(referral.priority, ReferralPriority.high);
    });

    test('Referral.create should auto-generate id and set defaults', () {
      final referral = Referral.create(
        screeningId: 'scr-001',
        patientName: 'Jane Doe',
        patientPhone: '+254712345678',
        facilityName: 'Test Hospital',
        facilityPhone: '+254798765432',
        priority: ReferralPriority.urgent,
        reason: 'Urgent case',
      );

      expect(referral.id, isNotEmpty);
      expect(referral.status, ReferralStatus.pending);
      expect(referral.createdAt.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
    });

    test('toMap should convert all fields', () {
      final referral = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.sent,
        priority: ReferralPriority.high,
        reason: 'High risk',
        notes: 'Test notes',
        smsSentAt: DateTime(2024, 1, 15, 10, 35),
      );

      final map = referral.toMap();

      expect(map['id'], 'ref-001');
      expect(map['screening_id'], 'scr-001');
      expect(map['patient_name'], 'John Doe');
      expect(map['patient_phone'], '+254712345678');
      expect(map['facility_name'], 'Nairobi Hospital');
      expect(map['status'], 'sent');
      expect(map['priority'], 'high');
      expect(map['notes'], 'Test notes');
    });

    test('fromMap should restore all fields', () {
      final map = {
        'id': 'ref-002',
        'screening_id': 'scr-002',
        'created_at': '2024-01-15T10:30:00.000',
        'patient_name': 'Jane Doe',
        'patient_phone': '+254712345678',
        'facility_name': 'Test Hospital',
        'facility_phone': '+254798765432',
        'status': 'confirmed',
        'priority': 'medium',
        'reason': 'Medium risk',
        'notes': 'Follow up needed',
        'sms_sent_at': '2024-01-15T10:35:00.000',
        'confirmed_at': '2024-01-15T11:00:00.000',
      };

      final referral = Referral.fromMap(map);

      expect(referral.id, 'ref-002');
      expect(referral.patientName, 'Jane Doe');
      expect(referral.status, ReferralStatus.confirmed);
      expect(referral.priority, ReferralPriority.medium);
      expect(referral.smsSentAt, isNotNull);
      expect(referral.confirmedAt, isNotNull);
    });

    test('copyWith should update specified fields', () {
      final original = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      final updated = original.copyWith(
        status: ReferralStatus.sent,
        smsSentAt: DateTime(2024, 1, 15, 10, 35),
      );

      expect(updated.id, 'ref-001'); // unchanged
      expect(updated.status, ReferralStatus.sent); // updated
      expect(updated.smsSentAt, isNotNull); // added
    });

    test('markAsSent should update status and timestamp', () {
      final referral = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.urgent,
        reason: 'High risk score: 0.85',
      );

      final sent = referral.markAsSent();

      expect(sent.status, ReferralStatus.sent);
      expect(sent.smsSentAt, isNotNull);
    });

    test('markAsConfirmed should update status and timestamp', () {
      final referral = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.sent,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      final confirmed = referral.markAsConfirmed();

      expect(confirmed.status, ReferralStatus.confirmed);
      expect(confirmed.confirmedAt, isNotNull);
    });

    test('markAsCompleted should update status and timestamp', () {
      final referral = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.confirmed,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      final completed = referral.markAsCompleted();

      expect(completed.status, ReferralStatus.completed);
      expect(completed.completedAt, isNotNull);
    });

    test('markAsCancelled should update status', () {
      final referral = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      final cancelled = referral.markAsCancelled();

      expect(cancelled.status, ReferralStatus.cancelled);
    });

    test('toString should return formatted string', () {
      final referral = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      expect(referral.toString(), contains('ref-001'));
      expect(referral.toString(), contains('John Doe'));
      expect(referral.toString(), contains('대기중'));
    });

    test('equality should be based on id', () {
      final referral1 = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      final referral2 = Referral(
        id: 'ref-001',
        screeningId: 'scr-002',
        createdAt: DateTime(2024, 1, 16),
        patientName: 'Jane Doe',
        patientPhone: '+254712345679',
        facilityName: 'Different Hospital',
        facilityPhone: '+254798765433',
        status: ReferralStatus.sent,
        priority: ReferralPriority.low,
        reason: 'Low risk',
      );

      expect(referral1 == referral2, isTrue);
      expect(referral1.hashCode, referral2.hashCode);
    });

    test('different ids should not be equal', () {
      final referral1 = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      final referral2 = Referral(
        id: 'ref-002',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Nairobi Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      expect(referral1 == referral2, isFalse);
    });

    test('fromMap should handle null optional fields', () {
      final map = {
        'id': 'ref-003',
        'screening_id': 'scr-003',
        'created_at': '2024-01-15T10:30:00.000',
        'patient_name': 'Test Patient',
        'patient_phone': '+254712345678',
        'facility_name': 'Test Hospital',
        'facility_phone': '+254798765432',
        'status': null,
        'priority': null,
        'reason': 'Test reason',
      };

      final referral = Referral.fromMap(map);

      expect(referral.status, ReferralStatus.pending);
      expect(referral.priority, ReferralPriority.medium);
      expect(referral.notes, isNull);
      expect(referral.smsSentAt, isNull);
      expect(referral.confirmedAt, isNull);
      expect(referral.completedAt, isNull);
    });

    test('fromMap should handle completedAt', () {
      final map = {
        'id': 'ref-004',
        'screening_id': 'scr-004',
        'created_at': '2024-01-15T10:30:00.000',
        'patient_name': 'Test Patient',
        'patient_phone': '+254712345678',
        'facility_name': 'Test Hospital',
        'facility_phone': '+254798765432',
        'status': 'completed',
        'priority': 'high',
        'reason': 'Test reason',
        'completed_at': '2024-01-16T14:00:00.000',
      };

      final referral = Referral.fromMap(map);

      expect(referral.status, ReferralStatus.completed);
      expect(referral.completedAt, isNotNull);
      expect(referral.completedAt!.day, 16);
    });

    test('copyWith should allow updating all fields', () {
      final original = Referral(
        id: 'ref-001',
        screeningId: 'scr-001',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'John Doe',
        patientPhone: '+254712345678',
        facilityName: 'Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      final updated = original.copyWith(
        id: 'ref-002',
        screeningId: 'scr-002',
        createdAt: DateTime(2024, 2, 20),
        patientName: 'Jane Doe',
        patientPhone: '+254712345679',
        facilityName: 'New Hospital',
        facilityPhone: '+254798765433',
        status: ReferralStatus.completed,
        priority: ReferralPriority.low,
        reason: 'Low risk',
        notes: 'Updated notes',
        confirmedAt: DateTime(2024, 2, 21),
        completedAt: DateTime(2024, 2, 22),
      );

      expect(updated.id, 'ref-002');
      expect(updated.screeningId, 'scr-002');
      expect(updated.patientName, 'Jane Doe');
      expect(updated.patientPhone, '+254712345679');
      expect(updated.facilityName, 'New Hospital');
      expect(updated.facilityPhone, '+254798765433');
      expect(updated.status, ReferralStatus.completed);
      expect(updated.priority, ReferralPriority.low);
      expect(updated.reason, 'Low risk');
      expect(updated.notes, 'Updated notes');
      expect(updated.confirmedAt, isNotNull);
      expect(updated.completedAt, isNotNull);
    });
  });

  group('ReferralStatus - Additional Tests', () {
    test('should have correct color values', () {
      expect(ReferralStatus.pending.colorValue, 0xFFFF9800);
      expect(ReferralStatus.sent.colorValue, 0xFF2196F3);
      expect(ReferralStatus.confirmed.colorValue, 0xFF4CAF50);
      expect(ReferralStatus.completed.colorValue, 0xFF9C27B0);
      expect(ReferralStatus.cancelled.colorValue, 0xFF9E9E9E);
    });

    test('fromString should be case insensitive', () {
      expect(ReferralStatus.fromString('PENDING'), ReferralStatus.pending);
      expect(ReferralStatus.fromString('SENT'), ReferralStatus.sent);
      expect(ReferralStatus.fromString('Confirmed'), ReferralStatus.confirmed);
    });
    
    test('all status values should be unique', () {
      final values = ReferralStatus.values;
      final names = values.map((e) => e.name).toSet();
      expect(names.length, values.length);
    });
  });

  group('ReferralPriority - Additional Tests', () {
    test('should have correct color values', () {
      expect(ReferralPriority.low.colorValue, 0xFF4CAF50);
      expect(ReferralPriority.medium.colorValue, 0xFFFF9800);
      expect(ReferralPriority.high.colorValue, 0xFFF44336);
      expect(ReferralPriority.urgent.colorValue, 0xFF9C27B0);
    });

    test('all priority values should be unique', () {
      final values = ReferralPriority.values;
      final names = values.map((e) => e.name).toSet();
      expect(names.length, values.length);
    });
  });

  group('HealthFacility', () {
    test('should create with all required fields', () {
      const facility = HealthFacility(
        id: 'facility_001',
        name: 'Test Hospital',
        phone: '+254712345678',
        address: 'Test Address',
      );

      expect(facility.id, 'facility_001');
      expect(facility.name, 'Test Hospital');
      expect(facility.phone, '+254712345678');
      expect(facility.address, 'Test Address');
      expect(facility.contactPerson, isNull);
      expect(facility.latitude, isNull);
      expect(facility.longitude, isNull);
    });

    test('should create with optional fields', () {
      const facility = HealthFacility(
        id: 'facility_002',
        name: 'Full Hospital',
        phone: '+254712345679',
        address: 'Full Address',
        contactPerson: 'Dr. Smith',
        latitude: -1.2921,
        longitude: 36.8219,
      );

      expect(facility.contactPerson, 'Dr. Smith');
      expect(facility.latitude, -1.2921);
      expect(facility.longitude, 36.8219);
    });

    test('toMap should convert all fields', () {
      const facility = HealthFacility(
        id: 'facility_003',
        name: 'Map Test Hospital',
        phone: '+254712345680',
        address: 'Map Test Address',
        contactPerson: 'Dr. Jones',
        latitude: -1.3000,
        longitude: 36.8500,
      );

      final map = facility.toMap();

      expect(map['id'], 'facility_003');
      expect(map['name'], 'Map Test Hospital');
      expect(map['phone'], '+254712345680');
      expect(map['address'], 'Map Test Address');
      expect(map['contact_person'], 'Dr. Jones');
      expect(map['latitude'], -1.3000);
      expect(map['longitude'], 36.8500);
    });

    test('toMap should handle null optional fields', () {
      const facility = HealthFacility(
        id: 'facility_004',
        name: 'Minimal Hospital',
        phone: '+254712345681',
        address: 'Minimal Address',
      );

      final map = facility.toMap();

      expect(map['contact_person'], isNull);
      expect(map['latitude'], isNull);
      expect(map['longitude'], isNull);
    });

    test('fromMap should restore all fields', () {
      final map = {
        'id': 'facility_005',
        'name': 'Restored Hospital',
        'phone': '+254712345682',
        'address': 'Restored Address',
        'contact_person': 'Dr. Brown',
        'latitude': -1.3500,
        'longitude': 36.9000,
      };

      final facility = HealthFacility.fromMap(map);

      expect(facility.id, 'facility_005');
      expect(facility.name, 'Restored Hospital');
      expect(facility.phone, '+254712345682');
      expect(facility.address, 'Restored Address');
      expect(facility.contactPerson, 'Dr. Brown');
      expect(facility.latitude, -1.3500);
      expect(facility.longitude, 36.9000);
    });

    test('fromMap should handle null optional fields', () {
      final map = {
        'id': 'facility_006',
        'name': 'Null Test Hospital',
        'phone': '+254712345683',
        'address': 'Null Test Address',
        'contact_person': null,
        'latitude': null,
        'longitude': null,
      };

      final facility = HealthFacility.fromMap(map);

      expect(facility.contactPerson, isNull);
      expect(facility.latitude, isNull);
      expect(facility.longitude, isNull);
    });

    test('fromMap should handle int coordinates', () {
      final map = {
        'id': 'facility_007',
        'name': 'Int Coords Hospital',
        'phone': '+254712345684',
        'address': 'Int Coords Address',
        'latitude': -1,
        'longitude': 37,
      };

      final facility = HealthFacility.fromMap(map);

      expect(facility.latitude, -1.0);
      expect(facility.longitude, 37.0);
    });

    test('getDefaultFacilities should return non-empty list', () {
      final facilities = HealthFacility.getDefaultFacilities();

      expect(facilities, isNotEmpty);
      expect(facilities.length, 5);
    });

    test('getDefaultFacilities should have Kenyatta National Hospital', () {
      final facilities = HealthFacility.getDefaultFacilities();
      final kenyatta = facilities.firstWhere(
        (f) => f.name.contains('Kenyatta'),
        orElse: () => throw StateError('Kenyatta not found'),
      );

      expect(kenyatta.id, 'facility_001');
      expect(kenyatta.name, 'Kenyatta National Hospital');
      expect(kenyatta.contactPerson, 'Dr. Wambui');
    });

    test('getDefaultFacilities should have unique ids', () {
      final facilities = HealthFacility.getDefaultFacilities();
      final ids = facilities.map((f) => f.id).toSet();

      expect(ids.length, facilities.length);
    });

    test('getDefaultFacilities should all have contact persons', () {
      final facilities = HealthFacility.getDefaultFacilities();
      
      for (final facility in facilities) {
        expect(facility.contactPerson, isNotNull);
        expect(facility.contactPerson!.startsWith('Dr.'), isTrue);
      }
    });

    test('getDefaultFacilities should have valid phone numbers', () {
      final facilities = HealthFacility.getDefaultFacilities();
      
      for (final facility in facilities) {
        expect(facility.phone.startsWith('+254'), isTrue);
      }
    });
  });

  group('Referral - Workflow Tests', () {
    test('complete workflow: pending -> sent -> confirmed -> completed', () {
      var referral = Referral(
        id: 'ref-workflow',
        screeningId: 'scr-workflow',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'Workflow Patient',
        patientPhone: '+254712345678',
        facilityName: 'Workflow Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.high,
        reason: 'High risk',
      );

      expect(referral.status, ReferralStatus.pending);
      expect(referral.smsSentAt, isNull);

      referral = referral.markAsSent();
      expect(referral.status, ReferralStatus.sent);
      expect(referral.smsSentAt, isNotNull);

      referral = referral.markAsConfirmed();
      expect(referral.status, ReferralStatus.confirmed);
      expect(referral.confirmedAt, isNotNull);

      referral = referral.markAsCompleted();
      expect(referral.status, ReferralStatus.completed);
      expect(referral.completedAt, isNotNull);
    });

    test('cancelled workflow: pending -> cancelled', () {
      var referral = Referral(
        id: 'ref-cancel',
        screeningId: 'scr-cancel',
        createdAt: DateTime(2024, 1, 15),
        patientName: 'Cancel Patient',
        patientPhone: '+254712345678',
        facilityName: 'Cancel Hospital',
        facilityPhone: '+254798765432',
        status: ReferralStatus.pending,
        priority: ReferralPriority.low,
        reason: 'Test',
      );

      referral = referral.markAsCancelled();
      expect(referral.status, ReferralStatus.cancelled);
    });
  });
}

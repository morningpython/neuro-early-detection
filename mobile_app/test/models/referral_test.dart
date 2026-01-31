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
  });
}

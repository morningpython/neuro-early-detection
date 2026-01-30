/// Referral Model
/// STORY-021: SMS Referral System Integration
///
/// 환자 의뢰 데이터 모델입니다.
/// 고위험 환자를 의료 시설로 의뢰할 때 사용됩니다.
library;

import 'package:uuid/uuid.dart';

/// 의뢰 상태 열거형
enum ReferralStatus {
  pending('대기중', 0xFFFF9800),    // 주황색 - SMS 발송 대기
  sent('발송됨', 0xFF2196F3),       // 파란색 - SMS 발송 완료
  confirmed('확인됨', 0xFF4CAF50),  // 녹색 - 의료진 확인
  completed('완료', 0xFF9C27B0),    // 보라색 - 진료 완료
  cancelled('취소됨', 0xFF9E9E9E);  // 회색 - 취소

  const ReferralStatus(this.label, this.colorValue);
  final String label;
  final int colorValue;

  static ReferralStatus fromString(String value) {
    return ReferralStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ReferralStatus.pending,
    );
  }
}

/// 의뢰 우선순위
enum ReferralPriority {
  low('낮음', 0xFF4CAF50),
  medium('중간', 0xFFFF9800),
  high('높음', 0xFFF44336),
  urgent('긴급', 0xFF9C27B0);

  const ReferralPriority(this.label, this.colorValue);
  final String label;
  final int colorValue;

  static ReferralPriority fromString(String value) {
    return ReferralPriority.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ReferralPriority.medium,
    );
  }
}

/// 의뢰 모델 클래스
class Referral {
  /// 고유 식별자
  final String id;

  /// 관련 스크리닝 ID
  final String screeningId;

  /// 생성 시간
  final DateTime createdAt;

  /// 환자 이름
  final String patientName;

  /// 환자 연락처
  final String patientPhone;

  /// 의료 시설 이름
  final String facilityName;

  /// 의료 시설 연락처
  final String facilityPhone;

  /// 의뢰 상태
  final ReferralStatus status;

  /// 우선순위
  final ReferralPriority priority;

  /// CHW 메모
  final String? notes;

  /// 의뢰 사유 (위험 점수 포함)
  final String reason;

  /// SMS 발송 시간
  final DateTime? smsSentAt;

  /// 확인 시간
  final DateTime? confirmedAt;

  /// 완료 시간
  final DateTime? completedAt;

  const Referral({
    required this.id,
    required this.screeningId,
    required this.createdAt,
    required this.patientName,
    required this.patientPhone,
    required this.facilityName,
    required this.facilityPhone,
    required this.status,
    required this.priority,
    required this.reason,
    this.notes,
    this.smsSentAt,
    this.confirmedAt,
    this.completedAt,
  });

  /// 새 의뢰 생성
  factory Referral.create({
    required String screeningId,
    required String patientName,
    required String patientPhone,
    required String facilityName,
    required String facilityPhone,
    required ReferralPriority priority,
    required String reason,
    String? notes,
  }) {
    return Referral(
      id: const Uuid().v4(),
      screeningId: screeningId,
      createdAt: DateTime.now(),
      patientName: patientName,
      patientPhone: patientPhone,
      facilityName: facilityName,
      facilityPhone: facilityPhone,
      status: ReferralStatus.pending,
      priority: priority,
      reason: reason,
      notes: notes,
    );
  }

  /// SQLite 저장용 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'screening_id': screeningId,
      'created_at': createdAt.toIso8601String(),
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'facility_name': facilityName,
      'facility_phone': facilityPhone,
      'status': status.name,
      'priority': priority.name,
      'reason': reason,
      'notes': notes,
      'sms_sent_at': smsSentAt?.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// SQLite에서 불러오기
  factory Referral.fromMap(Map<String, dynamic> map) {
    return Referral(
      id: map['id'] as String,
      screeningId: map['screening_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      patientName: map['patient_name'] as String,
      patientPhone: map['patient_phone'] as String,
      facilityName: map['facility_name'] as String,
      facilityPhone: map['facility_phone'] as String,
      status: ReferralStatus.fromString(map['status'] as String? ?? 'pending'),
      priority: ReferralPriority.fromString(map['priority'] as String? ?? 'medium'),
      reason: map['reason'] as String,
      notes: map['notes'] as String?,
      smsSentAt: map['sms_sent_at'] != null
          ? DateTime.parse(map['sms_sent_at'] as String)
          : null,
      confirmedAt: map['confirmed_at'] != null
          ? DateTime.parse(map['confirmed_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  /// 상태 업데이트 복사본 생성
  Referral copyWith({
    String? id,
    String? screeningId,
    DateTime? createdAt,
    String? patientName,
    String? patientPhone,
    String? facilityName,
    String? facilityPhone,
    ReferralStatus? status,
    ReferralPriority? priority,
    String? reason,
    String? notes,
    DateTime? smsSentAt,
    DateTime? confirmedAt,
    DateTime? completedAt,
  }) {
    return Referral(
      id: id ?? this.id,
      screeningId: screeningId ?? this.screeningId,
      createdAt: createdAt ?? this.createdAt,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      facilityName: facilityName ?? this.facilityName,
      facilityPhone: facilityPhone ?? this.facilityPhone,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      smsSentAt: smsSentAt ?? this.smsSentAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// SMS 발송 완료 처리
  Referral markAsSent() {
    return copyWith(
      status: ReferralStatus.sent,
      smsSentAt: DateTime.now(),
    );
  }

  /// 확인 처리
  Referral markAsConfirmed() {
    return copyWith(
      status: ReferralStatus.confirmed,
      confirmedAt: DateTime.now(),
    );
  }

  /// 완료 처리
  Referral markAsCompleted() {
    return copyWith(
      status: ReferralStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// 취소 처리
  Referral markAsCancelled() {
    return copyWith(status: ReferralStatus.cancelled);
  }

  @override
  String toString() {
    return 'Referral(id: $id, patient: $patientName, status: ${status.label})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Referral && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 의료 시설 모델
class HealthFacility {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String? contactPerson;
  final double? latitude;
  final double? longitude;

  const HealthFacility({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.contactPerson,
    this.latitude,
    this.longitude,
  });

  /// 기본 시설 목록 (케냐 지역)
  static List<HealthFacility> getDefaultFacilities() {
    return const [
      HealthFacility(
        id: 'facility_001',
        name: 'Kenyatta National Hospital',
        phone: '+254 20 2726300',
        address: 'Hospital Rd, Nairobi',
        contactPerson: 'Dr. Wambui',
      ),
      HealthFacility(
        id: 'facility_002',
        name: 'Moi Teaching & Referral Hospital',
        phone: '+254 53 2033471',
        address: 'Nandi Rd, Eldoret',
        contactPerson: 'Dr. Kiprop',
      ),
      HealthFacility(
        id: 'facility_003',
        name: 'Coast General Hospital',
        phone: '+254 41 2314201',
        address: 'Moi Ave, Mombasa',
        contactPerson: 'Dr. Hassan',
      ),
      HealthFacility(
        id: 'facility_004',
        name: 'Kisumu County Hospital',
        phone: '+254 57 2023597',
        address: 'Jomo Kenyatta Hwy, Kisumu',
        contactPerson: 'Dr. Ochieng',
      ),
      HealthFacility(
        id: 'facility_005',
        name: 'Nakuru Level 5 Hospital',
        phone: '+254 51 2212870',
        address: 'Kenyatta Ave, Nakuru',
        contactPerson: 'Dr. Mutua',
      ),
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'contact_person': contactPerson,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory HealthFacility.fromMap(Map<String, dynamic> map) {
    return HealthFacility(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      contactPerson: map['contact_person'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}

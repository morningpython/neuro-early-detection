/// CHW (Community Health Worker) Model
/// STORY-027: CHW Authentication System
///
/// 지역사회 건강요원 프로필 모델입니다.
library;

import 'package:uuid/uuid.dart';

/// CHW 역할
enum ChwRole {
  trainee('교육생', 'trainee', 1),
  junior('주니어', 'junior', 2),
  senior('시니어', 'senior', 3),
  supervisor('감독자', 'supervisor', 4),
  admin('관리자', 'admin', 5);

  const ChwRole(this.labelKo, this.labelEn, this.level);
  final String labelKo;
  final String labelEn;
  final int level;

  String label(String locale) => locale == 'sw' ? labelEn : labelKo;
}

/// CHW 상태
enum ChwStatus {
  pending('승인 대기', 'pending'),
  active('활성', 'active'),
  suspended('정지', 'suspended'),
  inactive('비활성', 'inactive');

  const ChwStatus(this.label, this.value);
  final String label;
  final String value;
}

/// CHW 자격
class ChwCertification {
  final String id;
  final String name;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final String? issuingOrganization;
  final String? certificateNumber;

  const ChwCertification({
    required this.id,
    required this.name,
    required this.issuedAt,
    this.expiresAt,
    this.issuingOrganization,
    this.certificateNumber,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  
  bool get isValid => !isExpired;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'issued_at': issuedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'issuing_organization': issuingOrganization,
      'certificate_number': certificateNumber,
    };
  }

  factory ChwCertification.fromMap(Map<String, dynamic> map) {
    return ChwCertification(
      id: map['id'] as String,
      name: map['name'] as String,
      issuedAt: DateTime.parse(map['issued_at'] as String),
      expiresAt: map['expires_at'] != null 
          ? DateTime.parse(map['expires_at'] as String) 
          : null,
      issuingOrganization: map['issuing_organization'] as String?,
      certificateNumber: map['certificate_number'] as String?,
    );
  }
}

/// CHW 프로필
class ChwProfile {
  final String id;
  final String chwId; // 고유 CHW 식별자 (예: CHW-KE-001)
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final ChwRole role;
  final ChwStatus status;
  final String? photoUrl;
  
  // 위치 정보
  final String regionCode; // 지역 코드
  final String facilityId; // 소속 시설 ID
  final String? supervisorId; // 감독자 ID
  
  // 자격 및 교육
  final List<ChwCertification> certifications;
  final List<String> completedTrainingModuleIds;
  final int totalScreeningsCompleted;
  final int totalReferralsMade;
  
  // 인증 정보
  final String passwordHash;
  final String? pin; // 빠른 로그인용 PIN
  final DateTime? lastLoginAt;
  final DateTime? lastSyncAt;
  final int failedLoginAttempts;
  final DateTime? lockedUntil;
  
  // 메타데이터
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChwProfile({
    required this.id,
    required this.chwId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.status,
    this.photoUrl,
    required this.regionCode,
    required this.facilityId,
    this.supervisorId,
    this.certifications = const [],
    this.completedTrainingModuleIds = const [],
    this.totalScreeningsCompleted = 0,
    this.totalReferralsMade = 0,
    required this.passwordHash,
    this.pin,
    this.lastLoginAt,
    this.lastSyncAt,
    this.failedLoginAttempts = 0,
    this.lockedUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 전체 이름
  String get fullName => '$firstName $lastName';

  /// 이니셜
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// 계정 잠금 여부
  bool get isLocked {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  /// 활성 계정 여부
  bool get isActive => status == ChwStatus.active && !isLocked;

  /// 유효한 자격증 목록
  List<ChwCertification> get validCertifications {
    return certifications.where((c) => c.isValid).toList();
  }

  /// 역할 레벨 확인
  bool hasRoleLevel(int minLevel) => role.level >= minLevel;

  /// 감독자 이상 권한
  bool get isSupervisorOrAbove => role.level >= ChwRole.supervisor.level;

  /// 새 CHW 프로필 생성
  factory ChwProfile.create({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? email,
    required String regionCode,
    required String facilityId,
    required String passwordHash,
    ChwRole role = ChwRole.trainee,
  }) {
    final now = DateTime.now();
    final uuid = const Uuid();
    
    // CHW ID 생성 (예: CHW-KE-2024-xxxx)
    final shortId = uuid.v4().substring(0, 8).toUpperCase();
    final chwId = 'CHW-$regionCode-${now.year}-$shortId';
    
    return ChwProfile(
      id: uuid.v4(),
      chwId: chwId,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      role: role,
      status: ChwStatus.pending,
      regionCode: regionCode,
      facilityId: facilityId,
      passwordHash: passwordHash,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 로그인 성공 처리
  ChwProfile onLoginSuccess() {
    return copyWith(
      lastLoginAt: DateTime.now(),
      failedLoginAttempts: 0,
      lockedUntil: null,
    );
  }

  /// 로그인 실패 처리
  ChwProfile onLoginFailure({int maxAttempts = 5, Duration lockDuration = const Duration(minutes: 15)}) {
    final newAttempts = failedLoginAttempts + 1;
    
    return copyWith(
      failedLoginAttempts: newAttempts,
      lockedUntil: newAttempts >= maxAttempts 
          ? DateTime.now().add(lockDuration) 
          : null,
    );
  }

  /// 복사본 생성
  ChwProfile copyWith({
    String? id,
    String? chwId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    ChwRole? role,
    ChwStatus? status,
    String? photoUrl,
    String? regionCode,
    String? facilityId,
    String? supervisorId,
    List<ChwCertification>? certifications,
    List<String>? completedTrainingModuleIds,
    int? totalScreeningsCompleted,
    int? totalReferralsMade,
    String? passwordHash,
    String? pin,
    DateTime? lastLoginAt,
    DateTime? lastSyncAt,
    int? failedLoginAttempts,
    DateTime? lockedUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChwProfile(
      id: id ?? this.id,
      chwId: chwId ?? this.chwId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      regionCode: regionCode ?? this.regionCode,
      facilityId: facilityId ?? this.facilityId,
      supervisorId: supervisorId ?? this.supervisorId,
      certifications: certifications ?? this.certifications,
      completedTrainingModuleIds: completedTrainingModuleIds ?? this.completedTrainingModuleIds,
      totalScreeningsCompleted: totalScreeningsCompleted ?? this.totalScreeningsCompleted,
      totalReferralsMade: totalReferralsMade ?? this.totalReferralsMade,
      passwordHash: passwordHash ?? this.passwordHash,
      pin: pin ?? this.pin,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chw_id': chwId,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
      'role': role.name,
      'status': status.value,
      'photo_url': photoUrl,
      'region_code': regionCode,
      'facility_id': facilityId,
      'supervisor_id': supervisorId,
      'certifications': certifications.map((c) => c.toMap()).toList(),
      'completed_training_module_ids': completedTrainingModuleIds,
      'total_screenings_completed': totalScreeningsCompleted,
      'total_referrals_made': totalReferralsMade,
      'password_hash': passwordHash,
      'pin': pin,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'failed_login_attempts': failedLoginAttempts,
      'locked_until': lockedUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map에서 생성
  factory ChwProfile.fromMap(Map<String, dynamic> map) {
    return ChwProfile(
      id: map['id'] as String,
      chwId: map['chw_id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String?,
      role: ChwRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => ChwRole.trainee,
      ),
      status: ChwStatus.values.firstWhere(
        (s) => s.value == map['status'],
        orElse: () => ChwStatus.pending,
      ),
      photoUrl: map['photo_url'] as String?,
      regionCode: map['region_code'] as String,
      facilityId: map['facility_id'] as String,
      supervisorId: map['supervisor_id'] as String?,
      certifications: (map['certifications'] as List<dynamic>?)
          ?.map((c) => ChwCertification.fromMap(c as Map<String, dynamic>))
          .toList() ?? [],
      completedTrainingModuleIds: List<String>.from(
        map['completed_training_module_ids'] as List<dynamic>? ?? [],
      ),
      totalScreeningsCompleted: map['total_screenings_completed'] as int? ?? 0,
      totalReferralsMade: map['total_referrals_made'] as int? ?? 0,
      passwordHash: map['password_hash'] as String,
      pin: map['pin'] as String?,
      lastLoginAt: map['last_login_at'] != null 
          ? DateTime.parse(map['last_login_at'] as String) 
          : null,
      lastSyncAt: map['last_sync_at'] != null 
          ? DateTime.parse(map['last_sync_at'] as String) 
          : null,
      failedLoginAttempts: map['failed_login_attempts'] as int? ?? 0,
      lockedUntil: map['locked_until'] != null 
          ? DateTime.parse(map['locked_until'] as String) 
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

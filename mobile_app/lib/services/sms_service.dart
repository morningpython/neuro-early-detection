/// SMS Service
/// STORY-021: SMS Referral System Integration
///
/// SMS 발송 및 의뢰 관리를 위한 서비스입니다.
/// 고위험 환자를 의료 시설로 의뢰할 때 사용됩니다.
library;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/referral.dart';
import '../models/screening.dart';

/// SMS 발송 결과
class SmsResult {
  final bool success;
  final String? errorMessage;
  final DateTime timestamp;

  const SmsResult({
    required this.success,
    this.errorMessage,
    required this.timestamp,
  });

  factory SmsResult.success() {
    return SmsResult(
      success: true,
      timestamp: DateTime.now(),
    );
  }

  factory SmsResult.failure(String message) {
    return SmsResult(
      success: false,
      errorMessage: message,
      timestamp: DateTime.now(),
    );
  }
}

/// SMS 서비스
class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  /// SMS 발송 (플랫폼 SMS 앱 사용)
  Future<SmsResult> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // 전화번호 정규화
      final normalizedPhone = _normalizePhoneNumber(phoneNumber);
      
      // SMS URI 생성
      final smsUri = Uri(
        scheme: 'sms',
        path: normalizedPhone,
        queryParameters: {'body': message},
      );

      // SMS 앱 실행 가능 여부 확인
      if (await canLaunchUrl(smsUri)) {
        final launched = await launchUrl(smsUri);
        if (launched) {
          debugPrint('✓ SMS app launched for: $normalizedPhone');
          return SmsResult.success();
        } else {
          return SmsResult.failure('SMS 앱을 실행할 수 없습니다');
        }
      } else {
        // Fallback: tel: 스키마로 시도
        final telUri = Uri.parse('sms:$normalizedPhone?body=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
          return SmsResult.success();
        }
        return SmsResult.failure('SMS 기능을 사용할 수 없습니다');
      }
    } catch (e) {
      debugPrint('✗ SMS send failed: $e');
      return SmsResult.failure('SMS 발송 실패: $e');
    }
  }

  /// 의뢰 SMS 발송
  Future<SmsResult> sendReferralSms({
    required Referral referral,
    required String locale,
  }) async {
    final message = _buildReferralMessage(referral, locale);
    return await sendSms(
      phoneNumber: referral.facilityPhone,
      message: message,
    );
  }

  /// 환자에게 알림 SMS 발송
  Future<SmsResult> sendPatientNotificationSms({
    required Referral referral,
    required String locale,
  }) async {
    final message = _buildPatientNotificationMessage(referral, locale);
    return await sendSms(
      phoneNumber: referral.patientPhone,
      message: message,
    );
  }

  /// 스크리닝 결과 기반 의뢰 메시지 생성
  String buildReferralMessageFromScreening({
    required Screening screening,
    required String patientName,
    required String facilityName,
    required String locale,
  }) {
    final riskLevel = screening.result?.riskLevel ?? RiskLevel.low;
    final riskScore = screening.result?.riskScore ?? 0.0;

    if (locale == 'sw') {
      return '''
[NEURO ACCESS - Rufaa ya Uchunguzi]

Habari $facilityName,

Mgonjwa amepitishwa kwa tathmini ya Parkinson's:

Jina: $patientName
Umri: ${screening.patientAge ?? 'Haijulikani'}
Kiwango cha Hatari: ${_getRiskLevelSwahili(riskLevel)}
Alama: ${(riskScore * 100).toStringAsFixed(1)}%
Tarehe: ${_formatDate(screening.createdAt)}

Tafadhali panga miadi kwa tathmini zaidi.

- CHW ID: ${screening.chwId ?? 'N/A'}
''';
    } else {
      return '''
[NEURO ACCESS - Screening Referral]

Hello $facilityName,

A patient has been referred for Parkinson's assessment:

Name: $patientName
Age: ${screening.patientAge ?? 'Unknown'}
Risk Level: ${riskLevel.label}
Score: ${(riskScore * 100).toStringAsFixed(1)}%
Date: ${_formatDate(screening.createdAt)}

Please schedule an appointment for further evaluation.

- CHW ID: ${screening.chwId ?? 'N/A'}
''';
    }
  }

  /// 의뢰 메시지 생성
  String _buildReferralMessage(Referral referral, String locale) {
    if (locale == 'sw') {
      return '''
[NEURO ACCESS - Rufaa]

Mgonjwa: ${referral.patientName}
Simu: ${referral.patientPhone}
Kipaumbele: ${_getPrioritySwahili(referral.priority)}
Sababu: ${referral.reason}

${referral.notes != null ? 'Maelezo: ${referral.notes}' : ''}

Tafadhali wasiliana na mgonjwa kwa miadi.
''';
    } else {
      return '''
[NEURO ACCESS - Referral]

Patient: ${referral.patientName}
Phone: ${referral.patientPhone}
Priority: ${referral.priority.label}
Reason: ${referral.reason}

${referral.notes != null ? 'Notes: ${referral.notes}' : ''}

Please contact the patient to schedule an appointment.
''';
    }
  }

  /// 환자 알림 메시지 생성
  String _buildPatientNotificationMessage(Referral referral, String locale) {
    if (locale == 'sw') {
      return '''
Habari ${referral.patientName},

Umepelekwa kwa ${referral.facilityName} kwa tathmini ya afya.

Tafadhali wasiliana nao kwa: ${referral.facilityPhone}

- Timu ya NeuroAccess
''';
    } else {
      return '''
Hello ${referral.patientName},

You have been referred to ${referral.facilityName} for a health assessment.

Please contact them at: ${referral.facilityPhone}

- NeuroAccess Team
''';
    }
  }

  /// 전화번호 정규화
  String _normalizePhoneNumber(String phone) {
    // 공백, 하이픈, 괄호 제거
    var normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // + 기호가 없으면 추가 (케냐 국제 전화 코드)
    if (!normalized.startsWith('+')) {
      if (normalized.startsWith('0')) {
        normalized = '+254${normalized.substring(1)}';
      } else if (!normalized.startsWith('254')) {
        normalized = '+254$normalized';
      } else {
        normalized = '+$normalized';
      }
    }
    
    return normalized;
  }

  /// 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// 스와힐리어 위험 수준
  String _getRiskLevelSwahili(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Chini';
      case RiskLevel.moderate:
        return 'Wastani';
      case RiskLevel.high:
        return 'Juu';
    }
  }

  /// 스와힐리어 우선순위
  String _getPrioritySwahili(ReferralPriority priority) {
    switch (priority) {
      case ReferralPriority.low:
        return 'Chini';
      case ReferralPriority.medium:
        return 'Wastani';
      case ReferralPriority.high:
        return 'Juu';
      case ReferralPriority.urgent:
        return 'Haraka';
    }
  }
}

/// 의뢰 저장소 (로컬 캐시)
class ReferralRepository {
  final List<Referral> _referrals = [];

  static final ReferralRepository _instance = ReferralRepository._internal();
  factory ReferralRepository() => _instance;
  ReferralRepository._internal();

  /// 의뢰 저장
  Future<Referral> saveReferral(Referral referral) async {
    _referrals.add(referral);
    debugPrint('✅ Referral saved: ${referral.id}');
    return referral;
  }

  /// 의뢰 업데이트
  Future<void> updateReferral(Referral referral) async {
    final index = _referrals.indexWhere((r) => r.id == referral.id);
    if (index != -1) {
      _referrals[index] = referral;
      debugPrint('✅ Referral updated: ${referral.id}');
    }
  }

  /// ID로 의뢰 조회
  Referral? getReferralById(String id) {
    try {
      return _referrals.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 스크리닝 ID로 의뢰 조회
  List<Referral> getReferralsByScreeningId(String screeningId) {
    return _referrals.where((r) => r.screeningId == screeningId).toList();
  }

  /// 상태별 의뢰 조회
  List<Referral> getReferralsByStatus(ReferralStatus status) {
    return _referrals.where((r) => r.status == status).toList();
  }

  /// 모든 의뢰 조회
  List<Referral> getAllReferrals() {
    return List.unmodifiable(_referrals);
  }

  /// 대기 중인 의뢰 개수
  int get pendingCount => _referrals.where((r) => r.status == ReferralStatus.pending).length;

  /// 발송된 의뢰 개수
  int get sentCount => _referrals.where((r) => r.status == ReferralStatus.sent).length;
}

/// Screening Model
/// STORY-016: Screening Data Model & Persistence
///
/// 스크리닝 결과를 저장하는 데이터 모델입니다.
library;

import 'dart:convert';
import 'package:uuid/uuid.dart';

/// 위험 수준 열거형
enum RiskLevel {
  low('낮음', 0xFF4CAF50),      // 녹색 - 정상
  moderate('보통', 0xFFFF9800), // 주황색 - 주의
  high('높음', 0xFFF44336);     // 빨간색 - 의심

  const RiskLevel(this.label, this.colorValue);
  final String label;
  final int colorValue;

  /// 문자열에서 변환 (데이터베이스 저장용)
  static RiskLevel fromString(String value) {
    return RiskLevel.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => RiskLevel.low,
    );
  }
}

/// 스크리닝 모델 클래스
class Screening {
  /// 고유 식별자
  final String id;

  /// 생성 시간
  final DateTime createdAt;

  /// 음성 파일 경로
  final String audioPath;

  /// 스크리닝 결과
  final ScreeningResult? result;

  /// 환자 나이
  final int? patientAge;

  /// 환자 성별 (M/F/O)
  final String? patientGender;

  /// CHW(지역보건요원) 식별자
  final String? chwId;

  /// 메모
  final String? notes;

  /// 소프트 삭제 시간
  final DateTime? deletedAt;

  const Screening({
    required this.id,
    required this.createdAt,
    required this.audioPath,
    this.result,
    this.patientAge,
    this.patientGender,
    this.chwId,
    this.notes,
    this.deletedAt,
  });

  /// 자동 ID 및 타임스탬프 생성
  factory Screening.create({
    required String audioPath,
    ScreeningResult? result,
    int? patientAge,
    String? patientGender,
    String? chwId,
    String? notes,
  }) {
    return Screening(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      audioPath: audioPath,
      result: result,
      patientAge: patientAge,
      patientGender: patientGender,
      chwId: chwId,
      notes: notes,
    );
  }

  /// SQLite 저장용 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'audio_path': audioPath,
      'risk_score': result?.riskScore,
      'risk_level': result?.riskLevel.name,
      'confidence': result?.confidence,
      'features': result?.features != null ? jsonEncode(result!.features) : null,
      'patient_age': patientAge,
      'patient_gender': patientGender,
      'chw_id': chwId,
      'notes': notes,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// SQLite에서 불러오기
  factory Screening.fromMap(Map<String, dynamic> map) {
    ScreeningResult? result;
    if (map['risk_score'] != null) {
      result = ScreeningResult(
        riskScore: (map['risk_score'] as num).toDouble(),
        riskLevel: RiskLevel.fromString(map['risk_level'] as String? ?? 'low'),
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
        features: map['features'] != null
            ? Map<String, double>.from(jsonDecode(map['features'] as String))
            : {},
      );
    }

    return Screening(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      audioPath: map['audio_path'] as String? ?? '',
      result: result,
      patientAge: map['patient_age'] as int?,
      patientGender: map['patient_gender'] as String?,
      chwId: map['chw_id'] as String?,
      notes: map['notes'] as String?,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
    );
  }

  /// 필드 업데이트 복사본 생성
  Screening copyWith({
    String? id,
    DateTime? createdAt,
    String? audioPath,
    ScreeningResult? result,
    int? patientAge,
    String? patientGender,
    String? chwId,
    String? notes,
    DateTime? deletedAt,
  }) {
    return Screening(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      audioPath: audioPath ?? this.audioPath,
      result: result ?? this.result,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      chwId: chwId ?? this.chwId,
      notes: notes ?? this.notes,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// 위험 백분율 표시
  String get riskPercentage => result != null 
      ? '${(result!.riskScore * 100).toInt()}%' 
      : '0%';

  /// 환자 설명
  String get patientDescription {
    final age = patientAge != null ? '$patientAge세' : '나이 미상';
    final gender = _genderLabel;
    return '$age $gender'.trim();
  }

  String get _genderLabel {
    switch (patientGender?.toUpperCase()) {
      case 'M':
        return '남성';
      case 'F':
        return '여성';
      case 'O':
        return '기타';
      default:
        return '';
    }
  }

  /// 소프트 삭제 여부
  bool get isDeleted => deletedAt != null;

  @override
  String toString() {
    return 'Screening(id: $id, risk: ${result?.riskLevel.label ?? "N/A"} $riskPercentage)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Screening && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 스크리닝 결과 클래스
class ScreeningResult {
  /// 위험 점수 (0.0 - 1.0)
  final double riskScore;
  
  /// 위험 수준
  final RiskLevel riskLevel;
  
  /// 신뢰도
  final double confidence;
  
  /// 추출된 특성 값
  final Map<String, double> features;

  const ScreeningResult({
    required this.riskScore,
    required this.riskLevel,
    required this.confidence,
    required this.features,
  });

  /// 위험 점수에서 위험 수준 결정
  static RiskLevel calculateRiskLevel(double score) {
    if (score < 0.33) {
      return RiskLevel.low;
    } else if (score < 0.67) {
      return RiskLevel.moderate;
    } else {
      return RiskLevel.high;
    }
  }

  /// InferenceResult에서 생성
  factory ScreeningResult.fromInference({
    required double probability,
    required double confidence,
    Map<String, double>? features,
  }) {
    return ScreeningResult(
      riskScore: probability,
      riskLevel: calculateRiskLevel(probability),
      confidence: confidence,
      features: features ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'riskScore': riskScore,
      'riskLevel': riskLevel.name,
      'confidence': confidence,
      'features': features,
    };
  }

  factory ScreeningResult.fromMap(Map<String, dynamic> map) {
    return ScreeningResult(
      riskScore: (map['riskScore'] as num).toDouble(),
      riskLevel: RiskLevel.fromString(map['riskLevel'] as String),
      confidence: (map['confidence'] as num).toDouble(),
      features: Map<String, double>.from(map['features'] ?? {}),
    );
  }
}

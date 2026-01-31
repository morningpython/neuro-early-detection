/// Data Export Service
/// STORY-029: Data Export Functionality
///
/// 데이터 내보내기 서비스입니다.
/// CSV, JSON 형식으로 스크리닝 데이터를 내보냅니다.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/screening.dart';
import '../models/referral.dart';

/// 내보내기 형식
enum ExportFormat {
  csv('CSV', '.csv', 'text/csv'),
  json('JSON', '.json', 'application/json');

  const ExportFormat(this.label, this.extension, this.mimeType);
  final String label;
  final String extension;
  final String mimeType;
}

/// 내보내기 옵션
class ExportOptions {
  final ExportFormat format;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool includePatientInfo;
  final bool includeAudioPath;
  final bool anonymize;
  final String? customFilename;

  const ExportOptions({
    this.format = ExportFormat.csv,
    this.startDate,
    this.endDate,
    this.includePatientInfo = true,
    this.includeAudioPath = false,
    this.anonymize = false,
    this.customFilename,
  });

  ExportOptions copyWith({
    ExportFormat? format,
    DateTime? startDate,
    DateTime? endDate,
    bool? includePatientInfo,
    bool? includeAudioPath,
    bool? anonymize,
    String? customFilename,
  }) {
    return ExportOptions(
      format: format ?? this.format,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includePatientInfo: includePatientInfo ?? this.includePatientInfo,
      includeAudioPath: includeAudioPath ?? this.includeAudioPath,
      anonymize: anonymize ?? this.anonymize,
      customFilename: customFilename ?? this.customFilename,
    );
  }
}

/// 내보내기 결과
class ExportResult {
  final bool success;
  final String? filePath;
  final int recordCount;
  final String? errorMessage;

  const ExportResult({
    required this.success,
    this.filePath,
    required this.recordCount,
    this.errorMessage,
  });

  factory ExportResult.failure(String message) {
    return ExportResult(
      success: false,
      recordCount: 0,
      errorMessage: message,
    );
  }
}

/// 데이터 내보내기 서비스
class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd_HHmmss');
  final DateFormat _displayDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// 스크리닝 데이터 내보내기
  Future<ExportResult> exportScreenings(
    List<Screening> screenings, {
    ExportOptions options = const ExportOptions(),
  }) async {
    try {
      // 날짜 필터링
      var filteredData = screenings;
      if (options.startDate != null) {
        filteredData = filteredData
            .where((s) => s.createdAt.isAfter(options.startDate!))
            .toList();
      }
      if (options.endDate != null) {
        filteredData = filteredData
            .where((s) => s.createdAt.isBefore(options.endDate!))
            .toList();
      }

      if (filteredData.isEmpty) {
        return ExportResult.failure('내보낼 데이터가 없습니다');
      }

      // 파일 생성
      final content = options.format == ExportFormat.csv
          ? _screeningsToCsv(filteredData, options)
          : _screeningsToJson(filteredData, options);

      final filePath = await _saveFile(
        content,
        'screenings',
        options.format,
        options.customFilename,
      );

      debugPrint('✓ Exported ${filteredData.length} screenings to $filePath');

      return ExportResult(
        success: true,
        filePath: filePath,
        recordCount: filteredData.length,
      );
    } catch (e) {
      debugPrint('✗ Export error: $e');
      return ExportResult.failure('내보내기 중 오류 발생: $e');
    }
  }

  /// 의뢰 데이터 내보내기
  Future<ExportResult> exportReferrals(
    List<Referral> referrals, {
    ExportOptions options = const ExportOptions(),
  }) async {
    try {
      var filteredData = referrals;
      if (options.startDate != null) {
        filteredData = filteredData
            .where((r) => r.createdAt.isAfter(options.startDate!))
            .toList();
      }
      if (options.endDate != null) {
        filteredData = filteredData
            .where((r) => r.createdAt.isBefore(options.endDate!))
            .toList();
      }

      if (filteredData.isEmpty) {
        return ExportResult.failure('내보낼 데이터가 없습니다');
      }

      final content = options.format == ExportFormat.csv
          ? _referralsToCsv(filteredData, options)
          : _referralsToJson(filteredData, options);

      final filePath = await _saveFile(
        content,
        'referrals',
        options.format,
        options.customFilename,
      );

      debugPrint('✓ Exported ${filteredData.length} referrals to $filePath');

      return ExportResult(
        success: true,
        filePath: filePath,
        recordCount: filteredData.length,
      );
    } catch (e) {
      debugPrint('✗ Export error: $e');
      return ExportResult.failure('내보내기 중 오류 발생: $e');
    }
  }

  /// 스크리닝 CSV 변환
  String _screeningsToCsv(List<Screening> screenings, ExportOptions options) {
    final buffer = StringBuffer();

    // 헤더
    final headers = <String>[
      'id',
      'created_at',
      if (options.includePatientInfo) ...[
        'patient_age',
        'patient_gender',
      ],
      'risk_score',
      'risk_level',
      'confidence',
      'notes',
      if (options.includeAudioPath) 'audio_path',
      'chw_id',
    ];
    buffer.writeln(headers.join(','));

    // 데이터
    for (final screening in screenings) {
      final riskScore = screening.result?.riskScore ?? 0.0;
      final row = <String>[
        options.anonymize ? _anonymizeId(screening.id) : screening.id,
        _displayDateFormat.format(screening.createdAt),
        if (options.includePatientInfo) ...[
          screening.patientAge?.toString() ?? '',
          screening.patientGender ?? '',
        ],
        riskScore.toStringAsFixed(3),
        _getRiskLevel(riskScore),
        (screening.result?.confidence ?? 0.0).toStringAsFixed(3),
        _escapeCsv(screening.notes ?? ''),
        if (options.includeAudioPath) _escapeCsv(screening.audioPath),
        screening.chwId ?? '',
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  /// 스크리닝 JSON 변환
  String _screeningsToJson(List<Screening> screenings, ExportOptions options) {
    final data = screenings.map((s) {
      final riskScore = s.result?.riskScore ?? 0.0;
      final map = <String, dynamic>{
        'id': options.anonymize ? _anonymizeId(s.id) : s.id,
        'created_at': s.createdAt.toIso8601String(),
        'risk_score': riskScore,
        'risk_level': _getRiskLevel(riskScore),
        'confidence': s.result?.confidence,
        'notes': s.notes,
        'chw_id': s.chwId,
      };

      if (options.includePatientInfo) {
        map['patient'] = {
          'age': s.patientAge,
          'gender': s.patientGender,
        };
      }

      if (options.includeAudioPath) {
        map['audio_path'] = s.audioPath;
      }

      return map;
    }).toList();

    return const JsonEncoder.withIndent('  ').convert({
      'export_date': DateTime.now().toIso8601String(),
      'record_count': data.length,
      'data': data,
    });
  }

  /// 의뢰 CSV 변환
  String _referralsToCsv(List<Referral> referrals, ExportOptions options) {
    final buffer = StringBuffer();

    final headers = <String>[
      'id',
      'created_at',
      'screening_id',
      if (options.includePatientInfo) 'patient_name',
      'facility_name',
      'facility_phone',
      'priority',
      'status',
      'notes',
    ];
    buffer.writeln(headers.join(','));

    for (final referral in referrals) {
      final row = <String>[
        options.anonymize ? _anonymizeId(referral.id) : referral.id,
        _displayDateFormat.format(referral.createdAt),
        options.anonymize 
            ? _anonymizeId(referral.screeningId) 
            : referral.screeningId,
        if (options.includePatientInfo) 
          options.anonymize 
              ? _anonymizeName(referral.patientName)
              : _escapeCsv(referral.patientName),
        _escapeCsv(referral.facilityName),
        referral.facilityPhone,
        referral.priority.name,
        referral.status.name,
        _escapeCsv(referral.notes ?? ''),
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  /// 의뢰 JSON 변환
  String _referralsToJson(List<Referral> referrals, ExportOptions options) {
    final data = referrals.map((r) {
      final map = <String, dynamic>{
        'id': options.anonymize ? _anonymizeId(r.id) : r.id,
        'created_at': r.createdAt.toIso8601String(),
        'screening_id': options.anonymize 
            ? _anonymizeId(r.screeningId) 
            : r.screeningId,
        'facility': {
          'name': r.facilityName,
          'phone': r.facilityPhone,
        },
        'priority': r.priority.name,
        'status': r.status.name,
        'notes': r.notes,
      };

      if (options.includePatientInfo) {
        map['patient_name'] = options.anonymize 
            ? _anonymizeName(r.patientName)
            : r.patientName;
      }

      return map;
    }).toList();

    return const JsonEncoder.withIndent('  ').convert({
      'export_date': DateTime.now().toIso8601String(),
      'record_count': data.length,
      'data': data,
    });
  }

  /// 파일 저장
  Future<String> _saveFile(
    String content,
    String prefix,
    ExportFormat format,
    String? customFilename,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final filename = customFilename ?? 
        '${prefix}_${_dateFormat.format(DateTime.now())}';
    final filePath = '${exportDir.path}/$filename${format.extension}';

    final file = File(filePath);
    await file.writeAsString(content, encoding: utf8);

    return filePath;
  }

  /// CSV 이스케이프
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// ID 익명화
  String _anonymizeId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 4)}****${id.substring(id.length - 4)}';
  }

  /// 이름 익명화
  String _anonymizeName(String name) {
    if (name.isEmpty) return '';
    return '${name[0]}***';
  }

  /// 위험 수준 문자열
  String _getRiskLevel(double score) {
    if (score >= 0.7) return 'HIGH';
    if (score >= 0.4) return 'MEDIUM';
    if (score >= 0.1) return 'LOW';
    return 'NONE';
  }

  /// 내보낸 파일 목록 조회
  Future<List<ExportedFile>> getExportedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exports');
      
      if (!await exportDir.exists()) {
        return [];
      }

      final files = await exportDir.list().toList();
      final exportedFiles = <ExportedFile>[];

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          exportedFiles.add(ExportedFile(
            path: entity.path,
            name: entity.path.split('/').last,
            size: stat.size,
            createdAt: stat.modified,
          ));
        }
      }

      exportedFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return exportedFiles;
    } catch (e) {
      debugPrint('✗ Error getting exported files: $e');
      return [];
    }
  }

  /// 내보낸 파일 삭제
  Future<bool> deleteExportedFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('✗ Error deleting file: $e');
      return false;
    }
  }
}

/// 내보낸 파일 정보
class ExportedFile {
  final String path;
  final String name;
  final int size;
  final DateTime createdAt;

  const ExportedFile({
    required this.path,
    required this.name,
    required this.size,
    required this.createdAt,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  ExportFormat? get format {
    if (name.endsWith('.csv')) return ExportFormat.csv;
    if (name.endsWith('.json')) return ExportFormat.json;
    return null;
  }
}

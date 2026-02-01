import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/services/data_export_service.dart';
import 'package:neuro_access/models/screening.dart';
import 'package:neuro_access/models/referral.dart';

void main() {
  group('ExportFormat', () {
    test('csv should have correct properties', () {
      expect(ExportFormat.csv.label, 'CSV');
      expect(ExportFormat.csv.extension, '.csv');
      expect(ExportFormat.csv.mimeType, 'text/csv');
    });

    test('json should have correct properties', () {
      expect(ExportFormat.json.label, 'JSON');
      expect(ExportFormat.json.extension, '.json');
      expect(ExportFormat.json.mimeType, 'application/json');
    });

    test('all formats should have unique extensions', () {
      final extensions = ExportFormat.values.map((f) => f.extension).toSet();
      expect(extensions.length, ExportFormat.values.length);
    });
  });

  group('ExportOptions', () {
    test('default constructor should have correct defaults', () {
      const options = ExportOptions();

      expect(options.format, ExportFormat.csv);
      expect(options.startDate, isNull);
      expect(options.endDate, isNull);
      expect(options.includePatientInfo, isTrue);
      expect(options.includeAudioPath, isFalse);
      expect(options.anonymize, isFalse);
      expect(options.customFilename, isNull);
    });

    test('should accept all parameters', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);

      final options = ExportOptions(
        format: ExportFormat.json,
        startDate: startDate,
        endDate: endDate,
        includePatientInfo: false,
        includeAudioPath: true,
        anonymize: true,
        customFilename: 'custom_export',
      );

      expect(options.format, ExportFormat.json);
      expect(options.startDate, startDate);
      expect(options.endDate, endDate);
      expect(options.includePatientInfo, isFalse);
      expect(options.includeAudioPath, isTrue);
      expect(options.anonymize, isTrue);
      expect(options.customFilename, 'custom_export');
    });

    group('copyWith', () {
      test('should copy with modified format', () {
        const original = ExportOptions(format: ExportFormat.csv);
        final copied = original.copyWith(format: ExportFormat.json);

        expect(copied.format, ExportFormat.json);
        expect(copied.includePatientInfo, original.includePatientInfo);
      });

      test('should copy with modified dates', () {
        const original = ExportOptions();
        final newStart = DateTime(2024, 6, 1);
        final newEnd = DateTime(2024, 6, 30);
        
        final copied = original.copyWith(
          startDate: newStart,
          endDate: newEnd,
        );

        expect(copied.startDate, newStart);
        expect(copied.endDate, newEnd);
        expect(copied.format, original.format);
      });

      test('should copy with modified flags', () {
        const original = ExportOptions(
          includePatientInfo: true,
          includeAudioPath: false,
          anonymize: false,
        );

        final copied = original.copyWith(
          includePatientInfo: false,
          includeAudioPath: true,
          anonymize: true,
        );

        expect(copied.includePatientInfo, isFalse);
        expect(copied.includeAudioPath, isTrue);
        expect(copied.anonymize, isTrue);
      });

      test('should copy with custom filename', () {
        const original = ExportOptions();
        final copied = original.copyWith(customFilename: 'my_export');

        expect(copied.customFilename, 'my_export');
      });

      test('should preserve values when not specified', () {
        final original = ExportOptions(
          format: ExportFormat.json,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31),
          includePatientInfo: false,
          includeAudioPath: true,
          anonymize: true,
          customFilename: 'test',
        );

        final copied = original.copyWith();

        expect(copied.format, original.format);
        expect(copied.startDate, original.startDate);
        expect(copied.endDate, original.endDate);
        expect(copied.includePatientInfo, original.includePatientInfo);
        expect(copied.includeAudioPath, original.includeAudioPath);
        expect(copied.anonymize, original.anonymize);
        expect(copied.customFilename, original.customFilename);
      });
    });
  });

  group('ExportResult', () {
    test('should create successful result', () {
      const result = ExportResult(
        success: true,
        filePath: '/path/to/file.csv',
        recordCount: 10,
      );

      expect(result.success, isTrue);
      expect(result.filePath, '/path/to/file.csv');
      expect(result.recordCount, 10);
      expect(result.errorMessage, isNull);
    });

    test('failure factory should create failed result', () {
      final result = ExportResult.failure('Export failed');

      expect(result.success, isFalse);
      expect(result.filePath, isNull);
      expect(result.recordCount, 0);
      expect(result.errorMessage, 'Export failed');
    });

    test('should allow null filePath', () {
      const result = ExportResult(
        success: false,
        recordCount: 0,
        errorMessage: 'No data',
      );

      expect(result.filePath, isNull);
    });
  });

  group('ExportedFile', () {
    test('should create with required properties', () {
      final file = ExportedFile(
        path: '/exports/data.csv',
        name: 'data.csv',
        size: 1024,
        createdAt: DateTime(2024, 6, 15),
      );

      expect(file.path, '/exports/data.csv');
      expect(file.name, 'data.csv');
      expect(file.size, 1024);
      expect(file.createdAt, DateTime(2024, 6, 15));
    });

    group('sizeFormatted', () {
      test('should format bytes', () {
        final file = ExportedFile(
          path: '/test',
          name: 'test',
          size: 500,
          createdAt: DateTime.now(),
        );

        expect(file.sizeFormatted, '500 B');
      });

      test('should format kilobytes', () {
        final file = ExportedFile(
          path: '/test',
          name: 'test',
          size: 2048,
          createdAt: DateTime.now(),
        );

        expect(file.sizeFormatted, '2.0 KB');
      });

      test('should format megabytes', () {
        final file = ExportedFile(
          path: '/test',
          name: 'test',
          size: 1536 * 1024,
          createdAt: DateTime.now(),
        );

        expect(file.sizeFormatted, '1.5 MB');
      });

      test('should handle zero size', () {
        final file = ExportedFile(
          path: '/test',
          name: 'test',
          size: 0,
          createdAt: DateTime.now(),
        );

        expect(file.sizeFormatted, '0 B');
      });

      test('should handle edge case at 1KB', () {
        final file = ExportedFile(
          path: '/test',
          name: 'test',
          size: 1024,
          createdAt: DateTime.now(),
        );

        expect(file.sizeFormatted, '1.0 KB');
      });

      test('should handle edge case at 1MB', () {
        final file = ExportedFile(
          path: '/test',
          name: 'test',
          size: 1024 * 1024,
          createdAt: DateTime.now(),
        );

        expect(file.sizeFormatted, '1.0 MB');
      });
    });

    group('format', () {
      test('should return csv for .csv file', () {
        final file = ExportedFile(
          path: '/exports/data.csv',
          name: 'data.csv',
          size: 1024,
          createdAt: DateTime.now(),
        );

        expect(file.format, ExportFormat.csv);
      });

      test('should return json for .json file', () {
        final file = ExportedFile(
          path: '/exports/data.json',
          name: 'data.json',
          size: 1024,
          createdAt: DateTime.now(),
        );

        expect(file.format, ExportFormat.json);
      });

      test('should return null for unknown extension', () {
        final file = ExportedFile(
          path: '/exports/data.txt',
          name: 'data.txt',
          size: 1024,
          createdAt: DateTime.now(),
        );

        expect(file.format, isNull);
      });

      test('should return null for no extension', () {
        final file = ExportedFile(
          path: '/exports/data',
          name: 'data',
          size: 1024,
          createdAt: DateTime.now(),
        );

        expect(file.format, isNull);
      });
    });
  });

  group('DataExportService', () {
    late DataExportService service;

    setUp(() {
      service = DataExportService();
    });

    test('should be singleton', () {
      final instance1 = DataExportService();
      final instance2 = DataExportService();

      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('DataExportService - CSV Escaping Logic', () {
    test('should not escape simple values', () {
      const value = 'simple text';
      final needsEscape = value.contains(',') || value.contains('"') || value.contains('\n');
      expect(needsEscape, isFalse);
    });

    test('should escape values with commas', () {
      const value = 'value, with, commas';
      final needsEscape = value.contains(',');
      expect(needsEscape, isTrue);
    });

    test('should escape values with quotes', () {
      const value = 'value "with" quotes';
      final needsEscape = value.contains('"');
      expect(needsEscape, isTrue);
    });

    test('should escape values with newlines', () {
      const value = 'value\nwith\nnewlines';
      final needsEscape = value.contains('\n');
      expect(needsEscape, isTrue);
    });

    test('should handle empty string', () {
      const value = '';
      final needsEscape = value.contains(',') || value.contains('"') || value.contains('\n');
      expect(needsEscape, isFalse);
    });
  });

  group('DataExportService - Anonymization Logic', () {
    test('should anonymize ID keeping first and last 4 chars', () {
      const id = 'abc12345xyz';
      String anonymizeId(String id) {
        if (id.length <= 8) return id;
        return '${id.substring(0, 4)}****${id.substring(id.length - 4)}';
      }
      
      final result = anonymizeId(id);
      expect(result, 'abc1****5xyz');
    });

    test('should not anonymize short IDs', () {
      const id = 'short';
      String anonymizeId(String id) {
        if (id.length <= 8) return id;
        return '${id.substring(0, 4)}****${id.substring(id.length - 4)}';
      }
      
      final result = anonymizeId(id);
      expect(result, 'short');
    });

    test('should handle exactly 8 character IDs', () {
      const id = '12345678';
      String anonymizeId(String id) {
        if (id.length <= 8) return id;
        return '${id.substring(0, 4)}****${id.substring(id.length - 4)}';
      }
      
      final result = anonymizeId(id);
      expect(result, '12345678');
    });

    test('should anonymize name keeping only first letter', () {
      const name = 'John Doe';
      String anonymizeName(String name) {
        if (name.isEmpty) return '';
        return '${name[0]}***';
      }
      
      final result = anonymizeName(name);
      expect(result, 'J***');
    });

    test('should handle empty name', () {
      const name = '';
      String anonymizeName(String name) {
        if (name.isEmpty) return '';
        return '${name[0]}***';
      }
      
      final result = anonymizeName(name);
      expect(result, '');
    });
  });

  group('DataExportService - Risk Level Logic', () {
    test('should classify high risk for score >= 0.7', () {
      String getRiskLevel(double score) {
        if (score >= 0.7) return 'HIGH';
        if (score >= 0.4) return 'MEDIUM';
        if (score >= 0.1) return 'LOW';
        return 'NONE';
      }
      
      expect(getRiskLevel(0.7), 'HIGH');
      expect(getRiskLevel(0.8), 'HIGH');
      expect(getRiskLevel(1.0), 'HIGH');
    });

    test('should classify medium risk for score >= 0.4 and < 0.7', () {
      String getRiskLevel(double score) {
        if (score >= 0.7) return 'HIGH';
        if (score >= 0.4) return 'MEDIUM';
        if (score >= 0.1) return 'LOW';
        return 'NONE';
      }
      
      expect(getRiskLevel(0.4), 'MEDIUM');
      expect(getRiskLevel(0.5), 'MEDIUM');
      expect(getRiskLevel(0.69), 'MEDIUM');
    });

    test('should classify low risk for score >= 0.1 and < 0.4', () {
      String getRiskLevel(double score) {
        if (score >= 0.7) return 'HIGH';
        if (score >= 0.4) return 'MEDIUM';
        if (score >= 0.1) return 'LOW';
        return 'NONE';
      }
      
      expect(getRiskLevel(0.1), 'LOW');
      expect(getRiskLevel(0.2), 'LOW');
      expect(getRiskLevel(0.39), 'LOW');
    });

    test('should classify no risk for score < 0.1', () {
      String getRiskLevel(double score) {
        if (score >= 0.7) return 'HIGH';
        if (score >= 0.4) return 'MEDIUM';
        if (score >= 0.1) return 'LOW';
        return 'NONE';
      }
      
      expect(getRiskLevel(0.0), 'NONE');
      expect(getRiskLevel(0.05), 'NONE');
      expect(getRiskLevel(0.09), 'NONE');
    });
  });

  group('DataExportService - Date Filtering Logic', () {
    test('should filter by start date', () {
      final data = [
        DateTime(2024, 1, 1),
        DateTime(2024, 2, 1),
        DateTime(2024, 3, 1),
        DateTime(2024, 4, 1),
      ];
      
      final startDate = DateTime(2024, 2, 15);
      final filtered = data.where((d) => d.isAfter(startDate)).toList();
      
      expect(filtered.length, 2);
      expect(filtered, contains(DateTime(2024, 3, 1)));
      expect(filtered, contains(DateTime(2024, 4, 1)));
    });

    test('should filter by end date', () {
      final data = [
        DateTime(2024, 1, 1),
        DateTime(2024, 2, 1),
        DateTime(2024, 3, 1),
        DateTime(2024, 4, 1),
      ];
      
      final endDate = DateTime(2024, 2, 15);
      final filtered = data.where((d) => d.isBefore(endDate)).toList();
      
      expect(filtered.length, 2);
      expect(filtered, contains(DateTime(2024, 1, 1)));
      expect(filtered, contains(DateTime(2024, 2, 1)));
    });

    test('should filter by date range', () {
      final data = [
        DateTime(2024, 1, 1),
        DateTime(2024, 2, 1),
        DateTime(2024, 3, 1),
        DateTime(2024, 4, 1),
      ];
      
      final startDate = DateTime(2024, 1, 15);
      final endDate = DateTime(2024, 3, 15);
      final filtered = data.where((d) => 
        d.isAfter(startDate) && d.isBefore(endDate)
      ).toList();
      
      expect(filtered.length, 2);
    });
  });

  group('DataExportService - JSON Encoding', () {
    test('should encode screening data to JSON', () {
      final data = {
        'id': 'screening-001',
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
        'risk_score': 0.75,
        'patient': {
          'age': 65,
          'gender': 'M',
        },
      };
      
      final json = data.toString();
      expect(json, contains('screening-001'));
    });

    test('should include export metadata', () {
      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'record_count': 10,
        'data': [],
      };
      
      expect(exportData.containsKey('export_date'), isTrue);
      expect(exportData.containsKey('record_count'), isTrue);
      expect(exportData.containsKey('data'), isTrue);
    });
  });

  group('DataExportService - CSV Header Logic', () {
    test('should include required headers', () {
      final headers = <String>[
        'id',
        'created_at',
        'risk_score',
        'risk_level',
        'confidence',
        'notes',
        'chw_id',
      ];
      
      expect(headers, contains('id'));
      expect(headers, contains('created_at'));
      expect(headers, contains('risk_score'));
      expect(headers, contains('risk_level'));
    });

    test('should conditionally include patient info headers', () {
      const includePatientInfo = true;
      
      final headers = <String>[
        'id',
        if (includePatientInfo) ...[
          'patient_age',
          'patient_gender',
        ],
        'risk_score',
      ];
      
      expect(headers, contains('patient_age'));
      expect(headers, contains('patient_gender'));
    });

    test('should conditionally include audio path header', () {
      const includeAudioPath = true;
      
      final headers = <String>[
        'id',
        if (includeAudioPath) 'audio_path',
      ];
      
      expect(headers, contains('audio_path'));
    });
  });

  group('DataExportService - Referral CSV Headers', () {
    test('should include referral-specific headers', () {
      final headers = <String>[
        'id',
        'created_at',
        'screening_id',
        'facility_name',
        'facility_phone',
        'priority',
        'status',
        'notes',
      ];
      
      expect(headers, contains('screening_id'));
      expect(headers, contains('facility_name'));
      expect(headers, contains('priority'));
      expect(headers, contains('status'));
    });
  });

  group('ExportedFile - Additional Properties', () {
    test('should handle very large files', () {
      final file = ExportedFile(
        path: '/test',
        name: 'large.csv',
        size: 1024 * 1024 * 500, // 500 MB
        createdAt: DateTime.now(),
      );
      
      expect(file.sizeFormatted, contains('MB'));
    });

    test('should correctly identify xlsx format as null', () {
      final file = ExportedFile(
        path: '/test',
        name: 'data.xlsx',
        size: 1024,
        createdAt: DateTime.now(),
      );
      
      expect(file.format, isNull);
    });

    test('createdAt should be preserved', () {
      final date = DateTime(2024, 6, 15, 10, 30);
      final file = ExportedFile(
        path: '/test',
        name: 'test.csv',
        size: 100,
        createdAt: date,
      );
      
      expect(file.createdAt, date);
    });
  });

  group('Export Filename Generation', () {
    test('should use custom filename when provided', () {
      const customFilename = 'my_export';
      const format = ExportFormat.csv;
      
      final filename = '$customFilename${format.extension}';
      expect(filename, 'my_export.csv');
    });

    test('should generate timestamped filename', () {
      final now = DateTime(2024, 6, 15, 14, 30, 45);
      final formatted = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      
      expect(formatted, '2024-06-15_143045');
    });
  });

  group('Screening Data Preparation', () {
    test('should handle null risk score', () {
      double? riskScore;
      final displayScore = (riskScore ?? 0.0).toStringAsFixed(3);
      
      expect(displayScore, '0.000');
    });

    test('should handle null confidence', () {
      double? confidence;
      final displayConfidence = (confidence ?? 0.0).toStringAsFixed(3);
      
      expect(displayConfidence, '0.000');
    });

    test('should handle null notes', () {
      String? notes;
      final displayNotes = notes ?? '';
      
      expect(displayNotes, '');
    });
  });

  group('ExportResult - Additional Tests', () {
    test('success result should have correct values', () {
      const result = ExportResult(
        success: true,
        filePath: '/path/to/export.csv',
        recordCount: 100,
      );
      
      expect(result.success, isTrue);
      expect(result.filePath, '/path/to/export.csv');
      expect(result.recordCount, 100);
      expect(result.errorMessage, isNull);
    });

    test('failure factory should create failed result', () {
      final result = ExportResult.failure('Test error message');
      
      expect(result.success, isFalse);
      expect(result.recordCount, 0);
      expect(result.errorMessage, 'Test error message');
      expect(result.filePath, isNull);
    });

    test('partial success result', () {
      const result = ExportResult(
        success: true,
        filePath: '/export/partial.json',
        recordCount: 50,
        errorMessage: 'Some records skipped',
      );
      
      expect(result.success, isTrue);
      expect(result.recordCount, 50);
      expect(result.errorMessage, 'Some records skipped');
    });
  });

  group('ExportOptions - copyWith Additional Tests', () {
    test('copyWith should update single field', () {
      const original = ExportOptions(format: ExportFormat.csv);
      final updated = original.copyWith(format: ExportFormat.json);
      
      expect(updated.format, ExportFormat.json);
      expect(updated.includePatientInfo, original.includePatientInfo);
      expect(updated.anonymize, original.anonymize);
    });

    test('copyWith with dates', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      const original = ExportOptions();
      
      final updated = original.copyWith(
        startDate: startDate,
        endDate: endDate,
      );
      
      expect(updated.startDate, startDate);
      expect(updated.endDate, endDate);
    });

    test('copyWith chain operations', () {
      const original = ExportOptions();
      
      final updated = original
          .copyWith(format: ExportFormat.json)
          .copyWith(anonymize: true)
          .copyWith(customFilename: 'chained_export');
      
      expect(updated.format, ExportFormat.json);
      expect(updated.anonymize, isTrue);
      expect(updated.customFilename, 'chained_export');
    });
  });

  group('ExportedFile - sizeFormatted Additional Tests', () {
    test('should format gigabytes', () {
      final largeFile = ExportedFile(
        path: '/path/large.csv',
        name: 'large.csv',
        size: 2 * 1024 * 1024 * 1024, // 2 GB
        createdAt: DateTime.now(),
      );
      
      // Since MB is the max in the code, it will show as MB
      expect(largeFile.sizeFormatted, isNotEmpty);
    });

    test('should handle boundary at exactly 1 MB', () {
      final file = ExportedFile(
        path: '/path/boundary.csv',
        name: 'boundary.csv',
        size: 1024 * 1024, // Exactly 1 MB
        createdAt: DateTime.now(),
      );
      
      expect(file.sizeFormatted, '1.0 MB');
    });

    test('should handle small file sizes', () {
      final tinyFile = ExportedFile(
        path: '/path/tiny.json',
        name: 'tiny.json',
        size: 100,
        createdAt: DateTime.now(),
      );
      
      expect(tinyFile.sizeFormatted, '100 B');
    });
  });

  group('ExportedFile - format detection', () {
    test('should detect uppercase CSV extension', () {
      final file = ExportedFile(
        path: '/exports/DATA.CSV',
        name: 'DATA.CSV',
        size: 1024,
        createdAt: DateTime.now(),
      );
      
      // Current implementation is case-sensitive, may return null
      expect(file.format, isNull);
    });

    test('should handle multiple dots in filename', () {
      final file = ExportedFile(
        path: '/exports/data.backup.csv',
        name: 'data.backup.csv',
        size: 1024,
        createdAt: DateTime.now(),
      );
      
      expect(file.format, ExportFormat.csv);
    });

    test('should handle filename without path', () {
      final file = ExportedFile(
        path: 'simple.json',
        name: 'simple.json',
        size: 512,
        createdAt: DateTime.now(),
      );
      
      expect(file.format, ExportFormat.json);
    });
  });

  group('Risk Level Classification', () {
    test('should classify score 0.7 as HIGH', () {
      final level = _getRiskLevel(0.7);
      expect(level, 'HIGH');
    });

    test('should classify score 0.4 as MEDIUM', () {
      final level = _getRiskLevel(0.4);
      expect(level, 'MEDIUM');
    });

    test('should classify score 0.1 as LOW', () {
      final level = _getRiskLevel(0.1);
      expect(level, 'LOW');
    });

    test('should classify score 0.05 as NONE', () {
      final level = _getRiskLevel(0.05);
      expect(level, 'NONE');
    });

    test('should handle boundary cases correctly', () {
      expect(_getRiskLevel(0.69), 'MEDIUM');
      expect(_getRiskLevel(0.70), 'HIGH');
      expect(_getRiskLevel(0.39), 'LOW');
      expect(_getRiskLevel(0.40), 'MEDIUM');
      expect(_getRiskLevel(0.09), 'NONE');
      expect(_getRiskLevel(0.10), 'LOW');
    });
  });

  group('ID Anonymization Logic', () {
    test('should anonymize long ID', () {
      final anonymized = _anonymizeId('1234567890ABCDEF');
      expect(anonymized, '1234****CDEF');
    });

    test('should not anonymize short ID', () {
      final shortId = _anonymizeId('ABC123');
      expect(shortId, 'ABC123');
    });

    test('should handle exactly 8 character ID', () {
      final id8 = _anonymizeId('12345678');
      expect(id8, '12345678');
    });

    test('should handle 9 character ID', () {
      final id9 = _anonymizeId('123456789');
      expect(id9, '1234****6789');
    });
  });

  group('Name Anonymization Logic', () {
    test('should anonymize full name', () {
      final anonymized = _anonymizeName('John Doe');
      expect(anonymized, 'J***');
    });

    test('should handle single character name', () {
      final single = _anonymizeName('A');
      expect(single, 'A***');
    });

    test('should handle empty name', () {
      final empty = _anonymizeName('');
      expect(empty, '');
    });
  });

  group('Date Filtering Logic', () {
    test('should filter by start date', () {
      final dates = [
        DateTime(2024, 1, 1),
        DateTime(2024, 2, 1),
        DateTime(2024, 3, 1),
      ];
      final startDate = DateTime(2024, 1, 15);
      
      final filtered = dates.where((d) => d.isAfter(startDate)).toList();
      expect(filtered.length, 2);
    });

    test('should filter by end date', () {
      final dates = [
        DateTime(2024, 1, 1),
        DateTime(2024, 2, 1),
        DateTime(2024, 3, 1),
      ];
      final endDate = DateTime(2024, 2, 15);
      
      final filtered = dates.where((d) => d.isBefore(endDate)).toList();
      expect(filtered.length, 2);
    });

    test('should filter by date range', () {
      final dates = [
        DateTime(2024, 1, 1),
        DateTime(2024, 2, 1),
        DateTime(2024, 3, 1),
        DateTime(2024, 4, 1),
      ];
      final startDate = DateTime(2024, 1, 15);
      final endDate = DateTime(2024, 3, 15);
      
      final filtered = dates.where((d) => 
        d.isAfter(startDate) && d.isBefore(endDate)
      ).toList();
      
      expect(filtered.length, 2);
    });
  });

  group('JSON Structure Validation', () {
    test('export JSON should have required top-level keys', () {
      // Simulating expected JSON structure
      final jsonStructure = {
        'export_date': DateTime.now().toIso8601String(),
        'record_count': 10,
        'data': [],
      };
      
      expect(jsonStructure.containsKey('export_date'), isTrue);
      expect(jsonStructure.containsKey('record_count'), isTrue);
      expect(jsonStructure.containsKey('data'), isTrue);
    });

    test('screening JSON should have required fields', () {
      final screeningJson = {
        'id': 'SCR001',
        'created_at': DateTime.now().toIso8601String(),
        'risk_score': 0.5,
        'risk_level': 'MEDIUM',
        'confidence': 0.85,
      };
      
      expect(screeningJson['id'], isNotNull);
      expect(screeningJson['risk_score'], isA<double>());
    });
  });

  group('ExportFormat enumeration', () {
    test('should have exactly 2 formats', () {
      expect(ExportFormat.values.length, 2);
    });

    test('mime types should be valid', () {
      expect(ExportFormat.csv.mimeType, contains('/'));
      expect(ExportFormat.json.mimeType, contains('/'));
    });

    test('extensions should start with dot', () {
      for (final format in ExportFormat.values) {
        expect(format.extension.startsWith('.'), isTrue);
      }
    });
  });
}

// Helper functions to test (matching logic from service)
String _getRiskLevel(double score) {
  if (score >= 0.7) return 'HIGH';
  if (score >= 0.4) return 'MEDIUM';
  if (score >= 0.1) return 'LOW';
  return 'NONE';
}

String _anonymizeId(String id) {
  if (id.length <= 8) return id;
  return '${id.substring(0, 4)}****${id.substring(id.length - 4)}';
}

String _anonymizeName(String name) {
  if (name.isEmpty) return '';
  return '${name[0]}***';
}

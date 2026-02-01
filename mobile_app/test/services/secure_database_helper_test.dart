import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/screening.dart';
import 'package:neuro_access/services/secure_database_helper.dart';
import 'package:neuro_access/services/encryption_service.dart';

void main() {
  group('EncryptionValidator.isEncrypted', () {
    test('returns false for null or empty', () {
      expect(EncryptionValidator.isEncrypted(null), isFalse);
      expect(EncryptionValidator.isEncrypted(''), isFalse);
    });

    test('returns false for too short strings', () {
      expect(EncryptionValidator.isEncrypted('short'), isFalse);
      expect(EncryptionValidator.isEncrypted('12345678901234567890123'), isFalse); // 23 chars
    });

    test('returns false for non-base64 strings', () {
      const invalid = 'this-is-not-base64!!@@';
      expect(EncryptionValidator.isEncrypted(invalid), isFalse);
    });

    test('returns true for base64 strings with sufficient length', () {
      final bytes = List<int>.filled(18, 0); // base64 length 24
      final base64 = base64Encode(bytes);
      expect(base64.length, 24);
      expect(EncryptionValidator.isEncrypted(base64), isTrue);
    });

    test('accepts base64 padding', () {
      final bytes = List<int>.filled(19, 1); // base64 length 28 with padding
      final base64 = base64Encode(bytes);
      expect(base64.length >= 24, isTrue);
      expect(EncryptionValidator.isEncrypted(base64), isTrue);
    });
  });

  group('EncryptionValidator.generateIntegrityHash', () {
    test('generates deterministic hash from screening fields', () {
      final screening = Screening(
        id: 'screening_123',
        createdAt: DateTime(2026, 1, 31, 10, 0, 0),
        audioPath: '/path/to/audio.wav',
      );

      final expected = EncryptionService().generateHash(
        'screening_123|2026-01-31T10:00:00.000|/path/to/audio.wav',
      );

      final actual = EncryptionValidator.generateIntegrityHash(screening);

      expect(actual, expected);
      expect(actual.length, 64);
    });
  });
}

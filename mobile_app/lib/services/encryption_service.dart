/// Encryption Service
/// STORY-022: Data Encryption - AES-256
///
/// Provides AES-256-GCM encryption for sensitive health data.
/// Follows DEVELOPMENT_PLAN_SRS.md security requirements.
library;

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256 암호화 서비스
/// 
/// HIPAA/GDPR 준수를 위한 데이터 암호화 제공
/// - AES-256-GCM 알고리즘 사용
/// - 키는 Flutter Secure Storage에 안전하게 저장
/// - IV(Initialization Vector)는 매 암호화마다 랜덤 생성
class EncryptionService {
  static const String _keyStorageKey = 'neuro_access_encryption_key';
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits for GCM
  
  final FlutterSecureStorage _secureStorage;
  encrypt.Key? _encryptionKey;
  bool _isInitialized = false;
  
  /// 싱글톤 인스턴스
  static final EncryptionService _instance = EncryptionService._internal();
  
  factory EncryptionService() => _instance;
  
  EncryptionService._internal() : _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  /// 서비스 초기화
  /// 
  /// 저장된 키를 로드하거나 새 키를 생성합니다.
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 저장된 키 로드 시도
      final storedKey = await _secureStorage.read(key: _keyStorageKey);
      
      if (storedKey != null) {
        _encryptionKey = encrypt.Key(base64Decode(storedKey));
        debugPrint('✓ Encryption key loaded from secure storage');
      } else {
        // 새 키 생성
        await _generateAndStoreKey();
        debugPrint('✓ New encryption key generated');
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('✗ Encryption service initialization failed: $e');
      rethrow;
    }
  }
  
  /// 새 암호화 키 생성 및 저장
  Future<void> _generateAndStoreKey() async {
    final random = Random.secure();
    final keyBytes = List<int>.generate(_keyLength, (_) => random.nextInt(256));
    
    _encryptionKey = encrypt.Key(Uint8List.fromList(keyBytes));
    
    // Secure Storage에 키 저장
    await _secureStorage.write(
      key: _keyStorageKey,
      value: base64Encode(keyBytes),
    );
  }
  
  /// 문자열 암호화 (AES-256-GCM)
  /// 
  /// [plainText] 암호화할 평문
  /// Returns Base64 인코딩된 암호문 (IV + encrypted data + auth tag)
  String encryptString(String plainText) {
    _ensureInitialized();
    
    // 랜덤 IV 생성
    final iv = encrypt.IV.fromSecureRandom(_ivLength);
    
    // 암호화
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.gcm),
    );
    
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    
    // IV + 암호문을 결합하여 반환
    final combined = Uint8List.fromList([
      ...iv.bytes,
      ...encrypted.bytes,
    ]);
    
    return base64Encode(combined);
  }
  
  /// 문자열 복호화 (AES-256-GCM)
  /// 
  /// [encryptedData] Base64 인코딩된 암호문
  /// Returns 복호화된 평문
  String decryptString(String encryptedData) {
    _ensureInitialized();
    
    final combined = base64Decode(encryptedData);
    
    // IV와 암호문 분리
    final iv = encrypt.IV(Uint8List.fromList(combined.sublist(0, _ivLength)));
    final encryptedBytes = combined.sublist(_ivLength);
    
    // 복호화
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.gcm),
    );
    
    final encrypted = encrypt.Encrypted(Uint8List.fromList(encryptedBytes));
    return encrypter.decrypt(encrypted, iv: iv);
  }
  
  /// Map 데이터 암호화
  /// 
  /// [data] 암호화할 Map 데이터
  /// Returns Base64 인코딩된 암호문
  String encryptMap(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return encryptString(jsonString);
  }
  
  /// Map 데이터 복호화
  /// 
  /// [encryptedData] Base64 인코딩된 암호문
  /// Returns 복호화된 Map 데이터
  Map<String, dynamic> decryptMap(String encryptedData) {
    final jsonString = decryptString(encryptedData);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
  
  /// 바이트 데이터 암호화 (오디오 파일 등)
  /// 
  /// [data] 암호화할 바이트 데이터
  /// Returns 암호화된 바이트 데이터 (IV + encrypted data)
  Uint8List encryptBytes(Uint8List data) {
    _ensureInitialized();
    
    final iv = encrypt.IV.fromSecureRandom(_ivLength);
    
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.gcm),
    );
    
    final encrypted = encrypter.encryptBytes(data, iv: iv);
    
    return Uint8List.fromList([
      ...iv.bytes,
      ...encrypted.bytes,
    ]);
  }
  
  /// 바이트 데이터 복호화
  /// 
  /// [encryptedData] 암호화된 바이트 데이터
  /// Returns 복호화된 바이트 데이터
  Uint8List decryptBytes(Uint8List encryptedData) {
    _ensureInitialized();
    
    final iv = encrypt.IV(Uint8List.fromList(encryptedData.sublist(0, _ivLength)));
    final encryptedBytes = encryptedData.sublist(_ivLength);
    
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.gcm),
    );
    
    final encrypted = encrypt.Encrypted(Uint8List.fromList(encryptedBytes));
    return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
  }
  
  /// 데이터 해시 생성 (SHA-256)
  /// 
  /// [data] 해시할 문자열
  /// Returns SHA-256 해시 (hex string)
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// 초기화 확인
  void _ensureInitialized() {
    if (!_isInitialized || _encryptionKey == null) {
      throw StateError('EncryptionService is not initialized. Call initialize() first.');
    }
  }
  
  /// 서비스 상태 확인
  bool get isInitialized => _isInitialized;
  
  /// 암호화 키 재생성 (보안 이벤트 시)
  /// 
  /// 주의: 기존 암호화된 데이터는 복호화할 수 없게 됩니다.
  Future<void> regenerateKey() async {
    await _generateAndStoreKey();
    debugPrint('✓ Encryption key regenerated');
  }
  
  /// 키 삭제 (앱 데이터 완전 삭제 시)
  Future<void> deleteKey() async {
    await _secureStorage.delete(key: _keyStorageKey);
    _encryptionKey = null;
    _isInitialized = false;
    debugPrint('✓ Encryption key deleted');
  }
}

/// 민감 데이터 필드 암호화 헬퍼
extension EncryptedField on String? {
  /// 필드 암호화
  String? encrypt() {
    if (this == null || this!.isEmpty) return null;
    try {
      return EncryptionService().encryptString(this!);
    } catch (e) {
      debugPrint('Encryption failed: $e');
      return null;
    }
  }
  
  /// 필드 복호화
  String? decrypt() {
    if (this == null || this!.isEmpty) return null;
    try {
      return EncryptionService().decryptString(this!);
    } catch (e) {
      debugPrint('Decryption failed: $e');
      return null;
    }
  }
}

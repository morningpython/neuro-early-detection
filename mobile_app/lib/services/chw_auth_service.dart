/// CHW Authentication Service
/// STORY-027: CHW Authentication System
///
/// 지역사회 건강요원 인증 서비스입니다.
/// PIN 기반 빠른 로그인, 오프라인 인증 지원
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chw_profile.dart';

/// 인증 결과
class AuthResult {
  final bool success;
  final ChwProfile? profile;
  final String? errorMessage;
  final AuthErrorCode? errorCode;

  const AuthResult({
    required this.success,
    this.profile,
    this.errorMessage,
    this.errorCode,
  });

  factory AuthResult.success(ChwProfile profile) {
    return AuthResult(success: true, profile: profile);
  }

  factory AuthResult.failure(String message, {AuthErrorCode? code}) {
    return AuthResult(
      success: false,
      errorMessage: message,
      errorCode: code,
    );
  }
}

/// 인증 오류 코드
enum AuthErrorCode {
  invalidCredentials('잘못된 자격 증명'),
  accountLocked('계정이 잠겼습니다'),
  accountInactive('비활성 계정'),
  accountPending('승인 대기 중'),
  networkError('네트워크 오류'),
  serverError('서버 오류'),
  unknown('알 수 없는 오류');

  const AuthErrorCode(this.message);
  final String message;
}

/// CHW 인증 서비스
class ChwAuthService {
  static final ChwAuthService _instance = ChwAuthService._internal();
  factory ChwAuthService() => _instance;
  ChwAuthService._internal();

  Database? _database;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // 현재 세션
  ChwProfile? _currentUser;
  String? _sessionToken;
  DateTime? _sessionExpiry;
  
  // 세션 설정
  static const Duration sessionDuration = Duration(hours: 8);
  static const Duration pinSessionDuration = Duration(hours: 2);
  static const int maxLoginAttempts = 5;
  static const Duration lockDuration = Duration(minutes: 15);

  ChwProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && !isSessionExpired;
  bool get isSessionExpired {
    if (_sessionExpiry == null) return true;
    return DateTime.now().isAfter(_sessionExpiry!);
  }

  /// 초기화
  Future<void> initialize() async {
    await _initDatabase();
    await _restoreSession();
    debugPrint('✓ ChwAuthService initialized');
  }

  /// 데이터베이스 초기화
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chw_auth.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chw_profiles (
            id TEXT PRIMARY KEY,
            chw_id TEXT UNIQUE NOT NULL,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            phone_number TEXT NOT NULL,
            email TEXT,
            role TEXT NOT NULL,
            status TEXT NOT NULL,
            photo_url TEXT,
            region_code TEXT NOT NULL,
            facility_id TEXT NOT NULL,
            supervisor_id TEXT,
            certifications TEXT,
            completed_training_module_ids TEXT,
            total_screenings_completed INTEGER DEFAULT 0,
            total_referrals_made INTEGER DEFAULT 0,
            password_hash TEXT NOT NULL,
            pin TEXT,
            last_login_at TEXT,
            last_sync_at TEXT,
            failed_login_attempts INTEGER DEFAULT 0,
            locked_until TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_chw_phone ON chw_profiles(phone_number)
        ''');
      },
    );
  }

  /// 세션 복원
  Future<void> _restoreSession() async {
    try {
      final token = await _secureStorage.read(key: 'session_token');
      final expiryStr = await _secureStorage.read(key: 'session_expiry');
      final userId = await _secureStorage.read(key: 'current_user_id');

      if (token != null && expiryStr != null && userId != null) {
        final expiry = DateTime.parse(expiryStr);
        
        if (DateTime.now().isBefore(expiry)) {
          final profile = await _getProfileById(userId);
          
          if (profile != null && profile.isActive) {
            _sessionToken = token;
            _sessionExpiry = expiry;
            _currentUser = profile;
            debugPrint('✓ Session restored for ${profile.fullName}');
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Session restore failed: $e');
    }
  }

  /// 비밀번호 해시 생성
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// PIN 해시 생성
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// 전화번호 + 비밀번호로 로그인
  Future<AuthResult> loginWithPassword(String phoneNumber, String password) async {
    try {
      final profile = await _getProfileByPhone(phoneNumber);
      
      if (profile == null) {
        return AuthResult.failure(
          '등록되지 않은 전화번호입니다',
          code: AuthErrorCode.invalidCredentials,
        );
      }

      // 계정 잠금 확인
      if (profile.isLocked) {
        final remaining = profile.lockedUntil!.difference(DateTime.now());
        return AuthResult.failure(
          '계정이 잠겼습니다. ${remaining.inMinutes}분 후 다시 시도하세요',
          code: AuthErrorCode.accountLocked,
        );
      }

      // 계정 상태 확인
      if (profile.status == ChwStatus.pending) {
        return AuthResult.failure(
          '계정이 아직 승인되지 않았습니다',
          code: AuthErrorCode.accountPending,
        );
      }

      if (profile.status != ChwStatus.active) {
        return AuthResult.failure(
          '계정이 비활성화되었습니다',
          code: AuthErrorCode.accountInactive,
        );
      }

      // 비밀번호 검증
      final passwordHash = hashPassword(password);
      if (passwordHash != profile.passwordHash) {
        final updatedProfile = profile.onLoginFailure(
          maxAttempts: maxLoginAttempts,
          lockDuration: lockDuration,
        );
        await _updateProfile(updatedProfile);
        
        final remaining = maxLoginAttempts - updatedProfile.failedLoginAttempts;
        return AuthResult.failure(
          '비밀번호가 올바르지 않습니다. $remaining회 시도 남음',
          code: AuthErrorCode.invalidCredentials,
        );
      }

      // 로그인 성공
      final updatedProfile = profile.onLoginSuccess();
      await _updateProfile(updatedProfile);
      await _createSession(updatedProfile, sessionDuration);
      
      debugPrint('✓ Login successful: ${updatedProfile.fullName}');
      return AuthResult.success(updatedProfile);
    } catch (e) {
      debugPrint('✗ Login error: $e');
      return AuthResult.failure('로그인 중 오류가 발생했습니다', code: AuthErrorCode.unknown);
    }
  }

  /// PIN으로 빠른 로그인
  Future<AuthResult> loginWithPin(String pin) async {
    try {
      if (_currentUser == null) {
        return AuthResult.failure(
          '먼저 비밀번호로 로그인하세요',
          code: AuthErrorCode.invalidCredentials,
        );
      }

      final profile = await _getProfileById(_currentUser!.id);
      if (profile == null || profile.pin == null) {
        return AuthResult.failure(
          'PIN이 설정되지 않았습니다',
          code: AuthErrorCode.invalidCredentials,
        );
      }

      final pinHash = hashPin(pin);
      if (pinHash != profile.pin) {
        return AuthResult.failure(
          'PIN이 올바르지 않습니다',
          code: AuthErrorCode.invalidCredentials,
        );
      }

      // PIN 로그인 성공
      final updatedProfile = profile.onLoginSuccess();
      await _updateProfile(updatedProfile);
      await _createSession(updatedProfile, pinSessionDuration);
      
      debugPrint('✓ PIN login successful');
      return AuthResult.success(updatedProfile);
    } catch (e) {
      debugPrint('✗ PIN login error: $e');
      return AuthResult.failure('PIN 로그인 중 오류가 발생했습니다', code: AuthErrorCode.unknown);
    }
  }

  /// PIN 설정
  Future<bool> setPin(String pin) async {
    if (_currentUser == null) return false;
    
    try {
      final pinHash = hashPin(pin);
      final updatedProfile = _currentUser!.copyWith(pin: pinHash);
      await _updateProfile(updatedProfile);
      _currentUser = updatedProfile;
      debugPrint('✓ PIN set successfully');
      return true;
    } catch (e) {
      debugPrint('✗ Set PIN error: $e');
      return false;
    }
  }

  /// 세션 생성
  Future<void> _createSession(ChwProfile profile, Duration duration) async {
    _currentUser = profile;
    _sessionToken = _generateSessionToken();
    _sessionExpiry = DateTime.now().add(duration);

    await _secureStorage.write(key: 'session_token', value: _sessionToken);
    await _secureStorage.write(key: 'session_expiry', value: _sessionExpiry!.toIso8601String());
    await _secureStorage.write(key: 'current_user_id', value: profile.id);
  }

  /// 세션 토큰 생성
  String _generateSessionToken() {
    final bytes = utf8.encode('${DateTime.now().millisecondsSinceEpoch}');
    return sha256.convert(bytes).toString();
  }

  /// 로그아웃
  Future<void> logout() async {
    _currentUser = null;
    _sessionToken = null;
    _sessionExpiry = null;

    await _secureStorage.delete(key: 'session_token');
    await _secureStorage.delete(key: 'session_expiry');
    await _secureStorage.delete(key: 'current_user_id');
    
    debugPrint('✓ Logged out');
  }

  /// CHW 등록
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    String? email,
    required String regionCode,
    required String facilityId,
  }) async {
    try {
      // 중복 확인
      final existing = await _getProfileByPhone(phoneNumber);
      if (existing != null) {
        return AuthResult.failure('이미 등록된 전화번호입니다');
      }

      // 프로필 생성
      final profile = ChwProfile.create(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
        regionCode: regionCode,
        facilityId: facilityId,
        passwordHash: hashPassword(password),
      );

      await _insertProfile(profile);
      debugPrint('✓ Registration successful: ${profile.chwId}');
      
      return AuthResult.success(profile);
    } catch (e) {
      debugPrint('✗ Registration error: $e');
      return AuthResult.failure('등록 중 오류가 발생했습니다');
    }
  }

  /// 비밀번호 변경
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;

    final currentHash = hashPassword(currentPassword);
    if (currentHash != _currentUser!.passwordHash) {
      return false;
    }

    try {
      final newHash = hashPassword(newPassword);
      final updatedProfile = _currentUser!.copyWith(passwordHash: newHash);
      await _updateProfile(updatedProfile);
      _currentUser = updatedProfile;
      debugPrint('✓ Password changed');
      return true;
    } catch (e) {
      debugPrint('✗ Change password error: $e');
      return false;
    }
  }

  // Database operations
  Future<ChwProfile?> _getProfileById(String id) async {
    final db = _database;
    if (db == null) return null;

    final maps = await db.query(
      'chw_profiles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _profileFromDbMap(maps.first);
  }

  Future<ChwProfile?> _getProfileByPhone(String phoneNumber) async {
    final db = _database;
    if (db == null) return null;

    final maps = await db.query(
      'chw_profiles',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _profileFromDbMap(maps.first);
  }

  Future<void> _insertProfile(ChwProfile profile) async {
    await _database?.insert('chw_profiles', _profileToDbMap(profile));
  }

  Future<void> _updateProfile(ChwProfile profile) async {
    await _database?.update(
      'chw_profiles',
      _profileToDbMap(profile),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Map<String, dynamic> _profileToDbMap(ChwProfile profile) {
    final map = profile.toMap();
    // JSON encode list fields
    map['certifications'] = jsonEncode(map['certifications']);
    map['completed_training_module_ids'] = jsonEncode(map['completed_training_module_ids']);
    return map;
  }

  ChwProfile _profileFromDbMap(Map<String, dynamic> map) {
    final mutableMap = Map<String, dynamic>.from(map);
    // JSON decode list fields
    mutableMap['certifications'] = jsonDecode(mutableMap['certifications'] as String? ?? '[]');
    mutableMap['completed_training_module_ids'] = jsonDecode(
      mutableMap['completed_training_module_ids'] as String? ?? '[]',
    );
    return ChwProfile.fromMap(mutableMap);
  }

  /// 리소스 정리
  void dispose() {
    _database?.close();
  }
}

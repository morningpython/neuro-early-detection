/// CHW Auth Provider
/// STORY-027: CHW Authentication System
///
/// CHW 인증 상태 관리 프로바이더입니다.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chw_profile.dart';
import '../services/chw_auth_service.dart';

/// 인증 상태
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// CHW 인증 프로바이더
class ChwAuthProvider extends ChangeNotifier {
  final ChwAuthService _authService = ChwAuthService();
  
  AuthState _state = AuthState.initial;
  ChwProfile? _currentUser;
  String? _errorMessage;
  bool _isPinSet = false;

  // Getters
  AuthState get state => _state;
  ChwProfile? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isPinSet => _isPinSet;

  /// 초기화
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      await _authService.initialize();
      
      if (_authService.isAuthenticated) {
        _currentUser = _authService.currentUser;
        _state = AuthState.authenticated;
        _isPinSet = _currentUser?.pin != null;
        debugPrint('✓ Already authenticated: ${_currentUser?.fullName}');
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      debugPrint('✗ Auth initialization error: $e');
    }

    notifyListeners();
  }

  /// 전화번호 + 비밀번호로 로그인
  Future<bool> login(String phoneNumber, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.loginWithPassword(phoneNumber, password);
    
    if (result.success && result.profile != null) {
      _currentUser = result.profile;
      _state = AuthState.authenticated;
      _isPinSet = _currentUser?.pin != null;
    } else {
      _state = AuthState.unauthenticated;
      _errorMessage = result.errorMessage ?? '로그인 실패';
    }

    notifyListeners();
    return result.success;
  }

  /// PIN으로 빠른 로그인
  Future<bool> loginWithPin(String pin) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.loginWithPin(pin);
    
    if (result.success && result.profile != null) {
      _currentUser = result.profile;
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
      _errorMessage = result.errorMessage ?? 'PIN 로그인 실패';
    }

    notifyListeners();
    return result.success;
  }

  /// PIN 설정
  Future<bool> setPin(String pin) async {
    final success = await _authService.setPin(pin);
    
    if (success) {
      _isPinSet = true;
      notifyListeners();
    }
    
    return success;
  }

  /// 로그아웃
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _state = AuthState.unauthenticated;
    _isPinSet = false;
    notifyListeners();
  }

  /// CHW 등록
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    String? email,
    required String regionCode,
    required String facilityId,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      password: password,
      email: email,
      regionCode: regionCode,
      facilityId: facilityId,
    );

    if (result.success) {
      // 등록 성공 시 로그인은 하지 않음 (승인 대기)
      _state = AuthState.unauthenticated;
    } else {
      _state = AuthState.error;
      _errorMessage = result.errorMessage;
    }

    notifyListeners();
    return result.success;
  }

  /// 비밀번호 변경
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final success = await _authService.changePassword(currentPassword, newPassword);
    
    if (!success) {
      _errorMessage = '현재 비밀번호가 올바르지 않습니다';
      notifyListeners();
    }
    
    return success;
  }

  /// 오류 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}

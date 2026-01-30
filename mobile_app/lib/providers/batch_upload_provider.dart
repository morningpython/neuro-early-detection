/// Batch Upload Provider
/// STORY-025: Batch Data Upload
///
/// 배치 업로드 상태 관리 프로바이더입니다.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/batch_upload_service.dart';
import '../models/screening.dart';
import '../models/referral.dart';

/// 배치 업로드 상태 관리 프로바이더
class BatchUploadProvider extends ChangeNotifier {
  final BatchUploadService _service = BatchUploadService();
  
  BatchUploadProgress? _currentProgress;
  BatchUploadResult? _lastResult;
  bool _isUploading = false;
  String? _lastError;
  StreamSubscription<BatchUploadProgress>? _progressSubscription;

  // Getters
  BatchUploadProgress? get currentProgress => _currentProgress;
  BatchUploadResult? get lastResult => _lastResult;
  bool get isUploading => _isUploading;
  String? get lastError => _lastError;

  /// 초기화
  void initialize() {
    _progressSubscription = _service.progressStream.listen((progress) {
      _currentProgress = progress;
      notifyListeners();
    });
    debugPrint('✓ BatchUploadProvider initialized');
  }

  /// 설정 업데이트 (네트워크 상태에 따라)
  void updateConfigForNetwork({required bool isLowBandwidth}) {
    _service.updateConfig(
      isLowBandwidth 
          ? BatchUploadConfig.lowBandwidth 
          : BatchUploadConfig.highSpeed,
    );
  }

  /// 스크리닝 일괄 업로드
  Future<BatchUploadResult> uploadScreenings(List<Screening> screenings) async {
    return _performUpload(() => _service.uploadScreenings(screenings));
  }

  /// 의뢰 일괄 업로드
  Future<BatchUploadResult> uploadReferrals(List<Referral> referrals) async {
    return _performUpload(() => _service.uploadReferrals(referrals));
  }

  /// 혼합 업로드
  Future<BatchUploadResult> uploadMixed(List<UploadItem> items) async {
    return _performUpload(() => _service.uploadBatch(items));
  }

  /// 업로드 실행
  Future<BatchUploadResult> _performUpload(
    Future<BatchUploadResult> Function() uploadFn,
  ) async {
    if (_isUploading) {
      _lastError = '이미 업로드가 진행 중입니다';
      notifyListeners();
      return BatchUploadResult.empty();
    }

    _isUploading = true;
    _lastError = null;
    _currentProgress = null;
    notifyListeners();

    try {
      final result = await uploadFn();
      _lastResult = result;
      
      if (result.failedCount > 0) {
        _lastError = '${result.failedCount}개 항목 업로드 실패';
      }
      
      return result;
    } catch (e) {
      _lastError = '업로드 중 오류 발생: $e';
      return BatchUploadResult.empty();
    } finally {
      _isUploading = false;
      _currentProgress = null;
      notifyListeners();
    }
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progress => _currentProgress?.progress ?? 0;

  /// 상태 텍스트
  String get statusText {
    if (_isUploading && _currentProgress != null) {
      return _currentProgress!.description;
    }
    
    if (_lastResult != null) {
      if (_lastResult!.isSuccess) {
        return '${_lastResult!.totalItems}개 항목 업로드 완료';
      } else {
        return '${_lastResult!.successCount}/${_lastResult!.totalItems} 성공, ${_lastResult!.failedCount} 실패';
      }
    }
    
    return '대기 중';
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}

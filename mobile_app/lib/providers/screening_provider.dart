/// Screening Provider
/// STORY-012: End-to-End Inference Pipeline Integration
///
/// This provider orchestrates the complete screening workflow:
/// Recording → Feature Extraction → ML Inference → Risk Stratification
library;

import 'package:flutter/foundation.dart';

import '../services/audio_recording_service.dart';
import '../services/feature_extraction_service.dart';
import '../services/ml_inference_service.dart';
import '../ui/screens/patient_info_screen.dart';

/// Screening workflow states
enum ScreeningStatus {
  /// Initial state, ready to start
  idle,
  
  /// Recording audio from microphone
  recording,
  
  /// Validating audio quality
  validating,
  
  /// Extracting voice features
  extractingFeatures,
  
  /// Running ML inference
  analyzing,
  
  /// Completed successfully
  completed,
  
  /// An error occurred
  error,
}

/// Screening result data
class ScreeningData {
  final String? audioPath;
  final Duration? recordingDuration;
  final InferenceResult? result;
  final String? errorMessage;
  final DateTime timestamp;
  
  ScreeningData({
    this.audioPath,
    this.recordingDuration,
    this.result,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  ScreeningData copyWith({
    String? audioPath,
    Duration? recordingDuration,
    InferenceResult? result,
    String? errorMessage,
  }) {
    return ScreeningData(
      audioPath: audioPath ?? this.audioPath,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp,
    );
  }
}

/// Provider for managing the screening workflow
class ScreeningProvider extends ChangeNotifier {
  final AudioRecordingService _audioService = AudioRecordingService();
  final FeatureExtractionService _featureService = FeatureExtractionService();
  final MLInferenceService _mlService = MLInferenceService();
  
  ScreeningStatus _status = ScreeningStatus.idle;
  ScreeningData _data = ScreeningData();
  String _statusMessage = '검사 준비 완료';
  double _progress = 0.0;
  Duration _recordingDuration = Duration.zero;
  
  /// Patient information (optional)
  PatientInfo? patientInfo;
  
  /// Current screening status
  ScreeningStatus get status => _status;
  
  /// Current screening data
  ScreeningData get data => _data;
  
  /// Human-readable status message
  String get statusMessage => _statusMessage;
  
  /// Progress (0.0 - 1.0)
  double get progress => _progress;
  
  /// Current recording duration
  Duration get recordingDuration => _recordingDuration;
  
  /// Whether currently recording
  bool get isRecording => _status == ScreeningStatus.recording;
  
  /// Whether processing (feature extraction or ML inference)
  bool get isProcessing => 
      _status == ScreeningStatus.validating ||
      _status == ScreeningStatus.extractingFeatures ||
      _status == ScreeningStatus.analyzing;
  
  /// Whether completed (success or error)
  bool get isCompleted => 
      _status == ScreeningStatus.completed ||
      _status == ScreeningStatus.error;
  
  /// Initialize the provider
  Future<void> initialize() async {
    try {
      await _audioService.initialize();
      
      // Listen to recording duration updates
      _audioService.durationStream.listen((duration) {
        _recordingDuration = duration;
        notifyListeners();
      });
      
      // Ensure ML model is loaded
      if (!_mlService.isModelLoaded) {
        await _mlService.initialize();
      }
      
      debugPrint('✓ ScreeningProvider initialized');
    } catch (e) {
      debugPrint('✗ ScreeningProvider initialization failed: $e');
    }
  }
  
  /// Start recording audio
  Future<void> startRecording() async {
    if (_status == ScreeningStatus.recording) return;
    
    try {
      _status = ScreeningStatus.recording;
      _statusMessage = '음성을 녹음 중입니다...';
      _progress = 0.0;
      _recordingDuration = Duration.zero;
      _data = ScreeningData();
      notifyListeners();
      
      await _audioService.startRecording();
      
    } catch (e) {
      _handleError('녹음을 시작할 수 없습니다: $e');
    }
  }
  
  /// Stop recording and start analysis
  Future<void> stopRecordingAndAnalyze() async {
    if (_status != ScreeningStatus.recording) return;
    
    try {
      // Stop recording
      final audioPath = await _audioService.stopRecording();
      
      if (audioPath == null) {
        throw Exception('녹음 파일을 찾을 수 없습니다');
      }
      
      _data = _data.copyWith(
        audioPath: audioPath,
        recordingDuration: _audioService.recordedDuration,
      );
      
      // Run analysis pipeline
      await _runAnalysisPipeline();
      
    } catch (e) {
      _handleError('분석 중 오류가 발생했습니다: $e');
    }
  }
  
  /// Run the complete analysis pipeline
  Future<void> _runAnalysisPipeline() async {
    try {
      // Step 1: Validate audio
      _status = ScreeningStatus.validating;
      _statusMessage = '오디오 품질을 확인 중입니다...';
      _progress = 0.2;
      notifyListeners();
      
      final samples = await _audioService.getAudioSamples();
      if (samples == null || samples.isEmpty) {
        throw Exception('오디오 샘플을 읽을 수 없습니다');
      }
      
      // Basic validation
      if (samples.length < 16000) { // Less than 1 second
        throw Exception('녹음이 너무 짧습니다. 다시 시도해 주세요.');
      }
      
      // Step 2: Extract features
      _status = ScreeningStatus.extractingFeatures;
      _statusMessage = '음성 특징을 추출 중입니다...';
      _progress = 0.5;
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 500)); // UX delay
      
      final features = await _featureService.extractFeatures(samples);
      debugPrint('✓ Features extracted: ${features.length} features');
      
      // Step 3: Run ML inference
      _status = ScreeningStatus.analyzing;
      _statusMessage = 'AI 분석을 실행 중입니다...';
      _progress = 0.8;
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 500)); // UX delay
      
      final result = await _mlService.predictWithDetails(features);
      debugPrint('✓ Inference complete: $result');
      
      // Step 4: Complete
      _status = ScreeningStatus.completed;
      _statusMessage = '분석 완료';
      _progress = 1.0;
      _data = _data.copyWith(result: result);
      notifyListeners();
      
    } catch (e) {
      rethrow;
    }
  }
  
  /// Cancel current recording
  Future<void> cancelRecording() async {
    if (_status != ScreeningStatus.recording) return;
    
    await _audioService.cancelRecording();
    _reset();
  }
  
  /// Reset to initial state
  void reset() {
    _reset();
  }
  
  void _reset() {
    _status = ScreeningStatus.idle;
    _statusMessage = '검사 준비 완료';
    _progress = 0.0;
    _recordingDuration = Duration.zero;
    _data = ScreeningData();
    notifyListeners();
  }
  
  void _handleError(String message) {
    _status = ScreeningStatus.error;
    _statusMessage = message;
    _data = _data.copyWith(errorMessage: message);
    notifyListeners();
    debugPrint('✗ Screening error: $message');
  }
  
  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

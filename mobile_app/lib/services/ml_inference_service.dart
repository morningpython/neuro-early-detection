/// ML Inference Service for Parkinson's Detection
/// STORY-010: TensorFlow Lite Inference Service
///
/// This service loads the TFLite model and runs inference on extracted features
/// to generate a Parkinson's disease risk score.
library;

import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Service for running ML inference on voice features
class MLInferenceService {
  static const String _modelPath = 'assets/models/parkinson_model_v1.0.tflite';
  
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  
  /// Singleton instance
  static final MLInferenceService _instance = MLInferenceService._internal();
  factory MLInferenceService() => _instance;
  MLInferenceService._internal();
  
  /// Whether the model is loaded and ready for inference
  bool get isModelLoaded => _isModelLoaded;
  
  /// Initialize the ML model
  /// Should be called once at app startup
  Future<void> initialize() async {
    if (_isModelLoaded) return;
    
    try {
      // Load model from assets
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isModelLoaded = true;
      debugPrint('✓ ML Model loaded successfully');
      debugPrint('  Input shape: ${_interpreter!.getInputTensor(0).shape}');
      debugPrint('  Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      debugPrint('✗ Failed to load ML model: $e');
      _isModelLoaded = false;
      rethrow;
    }
  }
  
  /// Run inference on feature vector
  /// 
  /// [features] - 22-dimensional feature vector from UCI Parkinson's dataset format
  /// Returns risk probability between 0.0 and 1.0
  Future<double> predict(List<double> features) async {
    if (!_isModelLoaded || _interpreter == null) {
      throw StateError('ML model not loaded. Call initialize() first.');
    }
    
    // Validate input dimensions
    // UCI Parkinson's dataset has 22 features
    if (features.length != 22) {
      throw ArgumentError(
        'Expected 22 features, but got ${features.length}. '
        'Features must match UCI Parkinson\'s dataset format.'
      );
    }
    
    // Prepare input tensor
    final input = Float32List.fromList(features);
    final inputBuffer = input.buffer.asFloat32List().reshape([1, 22]);
    
    // Prepare output tensor
    final output = List.filled(1, List.filled(1, 0.0));
    
    try {
      // Run inference
      _interpreter!.run(inputBuffer, output);
      
      // Extract probability from output
      final probability = output[0][0];
      
      // Clamp to valid range
      return probability.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('✗ Inference failed: $e');
      rethrow;
    }
  }
  
  /// Run inference and return detailed result
  Future<InferenceResult> predictWithDetails(List<double> features) async {
    final probability = await predict(features);
    return InferenceResult(
      probability: probability,
      riskLevel: _getRiskLevel(probability),
      confidence: _calculateConfidence(probability),
    );
  }
  
  /// Convert probability to risk level
  RiskLevel _getRiskLevel(double probability) {
    if (probability < 0.33) {
      return RiskLevel.low;
    } else if (probability < 0.67) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.high;
    }
  }
  
  /// Calculate confidence based on distance from decision boundary
  double _calculateConfidence(double probability) {
    // Confidence is higher when probability is farther from 0.5
    final distanceFromBoundary = (probability - 0.5).abs();
    return (distanceFromBoundary * 2).clamp(0.0, 1.0);
  }
  
  /// Dispose the interpreter
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }
}

/// Result of ML inference
class InferenceResult {
  /// Raw probability from model (0.0 - 1.0)
  final double probability;
  
  /// Categorical risk level
  final RiskLevel riskLevel;
  
  /// Confidence score (0.0 - 1.0)
  final double confidence;
  
  const InferenceResult({
    required this.probability,
    required this.riskLevel,
    required this.confidence,
  });
  
  /// Probability as percentage string
  String get probabilityPercent => '${(probability * 100).toStringAsFixed(1)}%';
  
  /// Confidence as percentage string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';
  
  @override
  String toString() => 'InferenceResult('
      'probability: $probabilityPercent, '
      'risk: ${riskLevel.name}, '
      'confidence: $confidencePercent)';
}

/// Risk level categories
/// STORY-011: Risk Stratification Logic
enum RiskLevel {
  /// 0.0 - 0.33: No immediate concern
  low,
  
  /// 0.34 - 0.66: Possible early signs
  medium,
  
  /// 0.67 - 1.0: Recommend consultation
  high,
}

/// Extension methods for RiskLevel
extension RiskLevelExtension on RiskLevel {
  /// Get display color hex code
  int get colorValue {
    switch (this) {
      case RiskLevel.low:
        return 0xFF4CAF50; // Green
      case RiskLevel.medium:
        return 0xFFFFC107; // Yellow/Amber
      case RiskLevel.high:
        return 0xFFF44336; // Red
    }
  }
  
  /// Get localized title
  String get title {
    switch (this) {
      case RiskLevel.low:
        return '낮은 위험';
      case RiskLevel.medium:
        return '중간 위험';
      case RiskLevel.high:
        return '높은 위험';
    }
  }
  
  /// Get recommended action
  String get recommendation {
    switch (this) {
      case RiskLevel.low:
        return '즉각적인 우려 사항이 없습니다. 정기적인 건강 모니터링을 권장합니다.';
      case RiskLevel.medium:
        return '초기 증상의 가능성이 있습니다. 6개월 후 재검사를 권장합니다.';
      case RiskLevel.high:
        return '신경과 전문의 상담을 즉시 권장합니다.';
    }
  }
  
  /// Get urgency level
  String get urgency {
    switch (this) {
      case RiskLevel.low:
        return 'routine';
      case RiskLevel.medium:
        return 'monitor';
      case RiskLevel.high:
        return 'urgent';
    }
  }
}

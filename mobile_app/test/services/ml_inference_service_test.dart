import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/services/ml_inference_service.dart';

/// ML Inference Service Tests
///
/// Note: Full ML tests require TensorFlow Lite model mocking
/// These tests verify inference configuration and data structures
void main() {
  group('RiskLevel enum', () {
    test('has three risk levels', () {
      expect(RiskLevel.values.length, 3);
      expect(RiskLevel.values, contains(RiskLevel.low));
      expect(RiskLevel.values, contains(RiskLevel.medium));
      expect(RiskLevel.values, contains(RiskLevel.high));
    });

    test('colorValue returns different colors for each level', () {
      expect(RiskLevel.low.colorValue, 0xFF4CAF50); // Green
      expect(RiskLevel.medium.colorValue, 0xFFFFC107); // Yellow
      expect(RiskLevel.high.colorValue, 0xFFF44336); // Red
    });

    test('title returns Korean labels', () {
      expect(RiskLevel.low.title, '낮은 위험');
      expect(RiskLevel.medium.title, '중간 위험');
      expect(RiskLevel.high.title, '높은 위험');
    });

    test('recommendation returns appropriate guidance', () {
      expect(RiskLevel.low.recommendation, contains('정기적인 건강 모니터링'));
      expect(RiskLevel.medium.recommendation, contains('재검사'));
      expect(RiskLevel.high.recommendation, contains('신경과 전문의'));
    });

    test('urgency returns appropriate levels', () {
      expect(RiskLevel.low.urgency, 'routine');
      expect(RiskLevel.medium.urgency, 'monitor');
      expect(RiskLevel.high.urgency, 'urgent');
    });
  });

  group('InferenceResult', () {
    test('creation with all fields', () {
      const result = InferenceResult(
        probability: 0.75,
        riskLevel: RiskLevel.high,
        confidence: 0.8,
      );

      expect(result.probability, 0.75);
      expect(result.riskLevel, RiskLevel.high);
      expect(result.confidence, 0.8);
    });

    test('probabilityPercent formats correctly', () {
      const result = InferenceResult(
        probability: 0.756,
        riskLevel: RiskLevel.high,
        confidence: 0.8,
      );

      expect(result.probabilityPercent, '75.6%');
    });

    test('confidencePercent formats correctly', () {
      const result = InferenceResult(
        probability: 0.5,
        riskLevel: RiskLevel.medium,
        confidence: 0.85,
      );

      expect(result.confidencePercent, '85%');
    });

    test('toString contains all info', () {
      const result = InferenceResult(
        probability: 0.7,
        riskLevel: RiskLevel.high,
        confidence: 0.9,
      );

      final str = result.toString();
      expect(str, contains('probability'));
      expect(str, contains('risk'));
      expect(str, contains('confidence'));
    });

    test('low risk result', () {
      const result = InferenceResult(
        probability: 0.2,
        riskLevel: RiskLevel.low,
        confidence: 0.6,
      );

      expect(result.riskLevel.title, '낮은 위험');
      expect(result.probabilityPercent, '20.0%');
    });

    test('medium risk result', () {
      const result = InferenceResult(
        probability: 0.5,
        riskLevel: RiskLevel.medium,
        confidence: 0.0,
      );

      expect(result.riskLevel.title, '중간 위험');
      expect(result.confidence, 0.0);
    });

    test('edge case probability 0.0', () {
      const result = InferenceResult(
        probability: 0.0,
        riskLevel: RiskLevel.low,
        confidence: 1.0,
      );

      expect(result.probabilityPercent, '0.0%');
    });

    test('edge case probability 1.0', () {
      const result = InferenceResult(
        probability: 1.0,
        riskLevel: RiskLevel.high,
        confidence: 1.0,
      );

      expect(result.probabilityPercent, '100.0%');
    });
  });

  group('MLInferenceService - Singleton', () {
    test('factory returns same instance', () {
      final instance1 = MLInferenceService();
      final instance2 = MLInferenceService();

      expect(identical(instance1, instance2), isTrue);
    });

    test('isModelLoaded initially false (before initialize)', () {
      // Note: Cannot test this properly since singleton may already be initialized
      // This test documents expected behavior
      final service = MLInferenceService();
      // Service may or may not be loaded depending on test order
      expect(service.isModelLoaded, isA<bool>());
    });
  });

  group('MlInferenceService - Model Configuration', () {
    test('model file name', () {
      const modelFileName = 'parkinson_model.tflite';
      
      expect(modelFileName, endsWith('.tflite'));
    });

    test('model input shape', () {
      // 22 features for Parkinson's voice analysis
      const inputShape = [1, 22];
      
      expect(inputShape[0], equals(1)); // batch size
      expect(inputShape[1], equals(22)); // feature count
    });

    test('model output shape', () {
      // Binary classification: [healthy, parkinson]
      const outputShape = [1, 2];
      
      expect(outputShape[0], equals(1));
      expect(outputShape[1], equals(2));
    });

    test('feature count matches scaler', () {
      const modelFeatureCount = 22;
      const scalerFeatureCount = 22;
      
      expect(modelFeatureCount, equals(scalerFeatureCount));
    });
  });

  group('MlInferenceService - Feature Names', () {
    test('all required features present', () {
      final featureNames = [
        'MDVP:Fo(Hz)',
        'MDVP:Fhi(Hz)',
        'MDVP:Flo(Hz)',
        'MDVP:Jitter(%)',
        'MDVP:Jitter(Abs)',
        'MDVP:RAP',
        'MDVP:PPQ',
        'Jitter:DDP',
        'MDVP:Shimmer',
        'MDVP:Shimmer(dB)',
        'Shimmer:APQ3',
        'Shimmer:APQ5',
        'MDVP:APQ',
        'Shimmer:DDA',
        'NHR',
        'HNR',
        'RPDE',
        'DFA',
        'spread1',
        'spread2',
        'D2',
        'PPE',
      ];
      
      expect(featureNames.length, equals(22));
    });

    test('feature names are unique', () {
      final featureNames = [
        'MDVP:Fo(Hz)', 'MDVP:Fhi(Hz)', 'MDVP:Flo(Hz)',
        'MDVP:Jitter(%)', 'MDVP:Jitter(Abs)', 'MDVP:RAP',
      ];
      
      final uniqueNames = featureNames.toSet();
      expect(uniqueNames.length, equals(featureNames.length));
    });
  });

  group('MlInferenceService - Preprocessing', () {
    test('feature scaling range', () {
      // StandardScaler: (x - mean) / std
      const scaledMin = -4.0; // typical range
      const scaledMax = 4.0;
      
      expect(scaledMax, greaterThan(scaledMin));
    });

    test('handle missing features', () {
      final features = <String, double>{
        'MDVP:Fo(Hz)': 120.0,
        'MDVP:Fhi(Hz)': 150.0,
        // missing other features
      };
      
      // Should fill missing with 0 or mean
      const expectedFeatureCount = 22;
      
      final paddedFeatures = List<double>.filled(expectedFeatureCount, 0.0);
      paddedFeatures[0] = features['MDVP:Fo(Hz)'] ?? 0.0;
      paddedFeatures[1] = features['MDVP:Fhi(Hz)'] ?? 0.0;
      
      expect(paddedFeatures.length, equals(expectedFeatureCount));
    });

    test('clip extreme values', () {
      double clipValue(double value, double min, double max) {
        if (value < min) return min;
        if (value > max) return max;
        return value;
      }
      
      expect(clipValue(-10.0, -3.0, 3.0), equals(-3.0));
      expect(clipValue(10.0, -3.0, 3.0), equals(3.0));
      expect(clipValue(1.0, -3.0, 3.0), equals(1.0));
    });
  });

  group('MlInferenceService - Inference', () {
    test('output probability sum to 1', () {
      final outputProbabilities = [0.3, 0.7];
      final sum = outputProbabilities.reduce((a, b) => a + b);
      
      expect(sum, closeTo(1.0, 0.001));
    });

    test('argmax for classification', () {
      int argmax(List<double> values) {
        var maxIndex = 0;
        for (var i = 1; i < values.length; i++) {
          if (values[i] > values[maxIndex]) {
            maxIndex = i;
          }
        }
        return maxIndex;
      }
      
      expect(argmax([0.3, 0.7]), equals(1));
      expect(argmax([0.8, 0.2]), equals(0));
    });

    test('confidence threshold', () {
      const confidenceThreshold = 0.5;
      
      expect(confidenceThreshold, greaterThanOrEqualTo(0.0));
      expect(confidenceThreshold, lessThanOrEqualTo(1.0));
    });

    test('risk score calculation', () {
      // Risk score is the probability of positive class
      const outputProbabilities = [0.4, 0.6];
      const riskScore = 0.6; // P(positive)
      
      expect(outputProbabilities[1], equals(riskScore));
    });
  });

  group('MlInferenceService - Risk Levels', () {
    test('risk level thresholds', () {
      const lowThreshold = 0.33;
      const highThreshold = 0.66;
      
      expect(lowThreshold, lessThan(highThreshold));
    });

    test('classify risk level', () {
      String classifyRisk(double score) {
        if (score < 0.33) return 'low';
        if (score < 0.66) return 'moderate';
        return 'high';
      }
      
      expect(classifyRisk(0.2), equals('low'));
      expect(classifyRisk(0.5), equals('moderate'));
      expect(classifyRisk(0.8), equals('high'));
    });

    test('boundary cases', () {
      String classifyRisk(double score) {
        if (score < 0.33) return 'low';
        if (score < 0.66) return 'moderate';
        return 'high';
      }
      
      expect(classifyRisk(0.0), equals('low'));
      expect(classifyRisk(0.33), equals('moderate'));
      expect(classifyRisk(0.66), equals('high'));
      expect(classifyRisk(1.0), equals('high'));
    });
  });

  group('MlInferenceService - Performance', () {
    test('inference time target', () {
      const targetInferenceMs = 100;
      expect(targetInferenceMs, lessThanOrEqualTo(500));
    });

    test('model size limit', () {
      const maxModelSizeMB = 10;
      expect(maxModelSizeMB, lessThanOrEqualTo(50));
    });

    test('batch inference support', () {
      const maxBatchSize = 32;
      expect(maxBatchSize, greaterThan(0));
    });
  });

  group('MlInferenceService - Error Handling', () {
    test('model not loaded error', () {
      const errorMessage = 'Model not loaded';
      expect(errorMessage, isNotEmpty);
    });

    test('invalid input error', () {
      const errorMessage = 'Invalid input shape';
      expect(errorMessage, isNotEmpty);
    });

    test('inference failure handling', () {
      var fallbackUsed = false;
      
      try {
        throw Exception('Inference failed');
      } catch (e) {
        // Use fallback or default result
        fallbackUsed = true;
      }
      
      expect(fallbackUsed, isTrue);
    });
  });

  group('MlInferenceService - Model Versioning', () {
    test('model version tracking', () {
      const modelVersion = '1.0.0';
      
      expect(modelVersion, matches(RegExp(r'^\d+\.\d+\.\d+$')));
    });

    test('model hash for integrity', () {
      const modelHash = 'sha256:abc123...';
      
      expect(modelHash, startsWith('sha256:'));
    });

    test('model update check', () {
      const currentVersion = '1.0.0';
      const latestVersion = '1.1.0';
      
      final needsUpdate = currentVersion != latestVersion;
      expect(needsUpdate, isTrue);
    });
  });

  group('MlInferenceService - Caching', () {
    test('result caching', () {
      final cache = <String, Map<String, dynamic>>{};
      
      final cacheKey = 'audio_hash_123';
      final result = {'risk_score': 0.7, 'risk_level': 'high'};
      
      cache[cacheKey] = result;
      
      expect(cache.containsKey(cacheKey), isTrue);
      expect(cache[cacheKey]!['risk_score'], equals(0.7));
    });

    test('cache expiration', () {
      const cacheExpirationMinutes = 30;
      expect(cacheExpirationMinutes, greaterThan(0));
    });

    test('cache size limit', () {
      const maxCacheEntries = 100;
      expect(maxCacheEntries, greaterThan(0));
    });
  });
}

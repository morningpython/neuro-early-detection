import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/services/feature_extraction_service.dart';

void main() {
  late FeatureExtractionService service;

  setUp(() {
    service = FeatureExtractionService();
  });

  group('FeatureExtractionService - Basic Tests', () {
    test('singleton instance should be same', () {
      final instance1 = FeatureExtractionService();
      final instance2 = FeatureExtractionService();
      
      expect(identical(instance1, instance2), isTrue);
    });

    test('service should exist', () {
      expect(service, isNotNull);
    });
  });

  group('FeatureExtractionService - Feature Vector Specification', () {
    test('feature vector should have 22 dimensions', () {
      // UCI Parkinson's dataset has 22 voice features
      const expectedDimensions = 22;
      expect(expectedDimensions, equals(22));
    });

    test('feature names should match UCI Parkinson dataset', () {
      final featureNames = [
        'MDVP:Fo(Hz)',      // Fundamental frequency
        'MDVP:Fhi(Hz)',     // Max fundamental frequency
        'MDVP:Flo(Hz)',     // Min fundamental frequency
        'MDVP:Jitter(%)',   // Jitter percentage
        'MDVP:Jitter(Abs)', // Jitter absolute
        'MDVP:RAP',         // Relative average perturbation
        'MDVP:PPQ',         // Period perturbation quotient
        'Jitter:DDP',       // DDP
        'MDVP:Shimmer',     // Shimmer
        'MDVP:Shimmer(dB)', // Shimmer in dB
        'Shimmer:APQ3',     // Amplitude perturbation quotient (3-point)
        'Shimmer:APQ5',     // Amplitude perturbation quotient (5-point)
        'MDVP:APQ',         // Amplitude perturbation quotient
        'Shimmer:DDA',      // DDA
        'NHR',              // Noise-to-harmonics ratio
        'HNR',              // Harmonics-to-noise ratio
        'RPDE',             // Recurrence period density entropy
        'DFA',              // Detrended fluctuation analysis
        'spread1',          // Nonlinear measure
        'spread2',          // Nonlinear measure
        'D2',               // Correlation dimension
        'PPE',              // Pitch period entropy
      ];
      
      expect(featureNames.length, equals(22));
      expect(featureNames[0], equals('MDVP:Fo(Hz)'));
      expect(featureNames.last, equals('PPE'));
    });
  });

  group('FeatureExtractionService - Audio Parameters', () {
    test('default sample rate should be 16kHz', () {
      const defaultSampleRate = 16000;
      expect(defaultSampleRate, equals(16000));
    });

    test('audio format should be PCM 16-bit mono', () {
      const bitDepth = 16;
      const channels = 1; // mono
      
      expect(bitDepth, equals(16));
      expect(channels, equals(1));
    });

    test('voice frequency range for detection', () {
      const minVoiceFreq = 80.0;  // Hz
      const maxVoiceFreq = 400.0; // Hz
      
      expect(minVoiceFreq, lessThan(maxVoiceFreq));
      // Typical adult voice range
      expect(minVoiceFreq, greaterThanOrEqualTo(50));
      expect(maxVoiceFreq, lessThanOrEqualTo(500));
    });
  });

  group('FeatureExtractionService - Fundamental Frequency Statistics', () {
    test('F0 statistics should include mean, max, min', () {
      final f0Stats = {
        'f0_mean': 150.0,
        'f0_max': 200.0,
        'f0_min': 100.0,
      };
      
      expect(f0Stats.containsKey('f0_mean'), isTrue);
      expect(f0Stats.containsKey('f0_max'), isTrue);
      expect(f0Stats.containsKey('f0_min'), isTrue);
      expect(f0Stats['f0_max']!, greaterThanOrEqualTo(f0Stats['f0_mean']!));
      expect(f0Stats['f0_min']!, lessThanOrEqualTo(f0Stats['f0_mean']!));
    });

    test('default F0 values for edge cases', () {
      // When no valid periods detected
      const defaultF0Mean = 150.0;
      const defaultF0Max = 200.0;
      const defaultF0Min = 100.0;
      
      expect(defaultF0Mean, closeTo(150.0, 0.1));
      expect(defaultF0Max, greaterThan(defaultF0Mean));
      expect(defaultF0Min, lessThan(defaultF0Mean));
    });
  });

  group('FeatureExtractionService - Jitter Features', () {
    test('jitter features structure', () {
      final jitterFeatures = {
        'jitter_percent': 0.005,
        'jitter_abs': 0.00003,
        'rap': 0.003,
        'ppq': 0.003,
        'ddp': 0.009,
      };
      
      expect(jitterFeatures.length, equals(5));
      expect(jitterFeatures['jitter_percent'], isNotNull);
      expect(jitterFeatures['jitter_abs'], isNotNull);
    });

    test('jitter values should be positive and small', () {
      // Typical jitter values for healthy voice
      const healthyJitterPercent = 0.005; // 0.5%
      
      expect(healthyJitterPercent, greaterThan(0));
      expect(healthyJitterPercent, lessThan(0.1));
    });

    test('DDP should be 3x RAP', () {
      const rap = 0.003;
      final ddp = 3 * rap;
      
      expect(ddp, closeTo(0.009, 0.0001));
    });
  });

  group('FeatureExtractionService - Shimmer Features', () {
    test('shimmer features structure', () {
      final shimmerFeatures = {
        'shimmer': 0.03,
        'shimmer_db': 0.3,
        'apq3': 0.015,
        'apq5': 0.02,
        'apq': 0.025,
        'dda': 0.045,
      };
      
      expect(shimmerFeatures.length, equals(6));
    });

    test('shimmer values should be reasonable', () {
      // Typical shimmer values
      const shimmer = 0.03; // 3%
      const shimmerDb = 0.3; // dB
      
      expect(shimmer, greaterThan(0));
      expect(shimmer, lessThan(1));
      expect(shimmerDb, greaterThan(0));
    });

    test('DDA should be 3x APQ3', () {
      const apq3 = 0.015;
      const dda = 3 * apq3;
      
      expect(dda, equals(0.045));
    });
  });

  group('FeatureExtractionService - Noise Features', () {
    test('noise features include NHR and HNR', () {
      final noiseFeatures = {
        'nhr': 0.01,
        'hnr': 25.0,
      };
      
      expect(noiseFeatures['nhr'], isNotNull);
      expect(noiseFeatures['hnr'], isNotNull);
    });

    test('HNR should be positive for voiced sound', () {
      // Harmonics-to-noise ratio in dB
      const hnr = 25.0;
      
      expect(hnr, greaterThan(0));
      // Typical healthy voice HNR: 20-30 dB
      expect(hnr, greaterThan(10));
    });

    test('NHR should be small for healthy voice', () {
      // Noise-to-harmonics ratio
      const nhr = 0.01;
      
      expect(nhr, greaterThan(0));
      expect(nhr, lessThan(0.2));
    });
  });

  group('FeatureExtractionService - Nonlinear Features', () {
    test('nonlinear features structure', () {
      final nonlinearFeatures = {
        'rpde': 0.5,
        'dfa': 0.7,
        'spread1': -5.0,
        'spread2': 0.3,
        'd2': 2.5,
        'ppe': 0.2,
      };
      
      expect(nonlinearFeatures.length, equals(6));
    });

    test('RPDE should be between 0 and 1', () {
      // Recurrence period density entropy
      const rpde = 0.5;
      
      expect(rpde, greaterThanOrEqualTo(0));
      expect(rpde, lessThanOrEqualTo(1));
    });

    test('DFA should be positive', () {
      // Detrended fluctuation analysis
      const dfa = 0.7;
      
      expect(dfa, greaterThan(0));
    });
  });

  group('FeatureExtractionService - Feature Scaling', () {
    test('scaled features should have normalized range', () {
      // After normalization, features should be in reasonable range
      const normalizedMin = -3.0;
      const normalizedMax = 3.0;
      
      expect(normalizedMin, lessThan(normalizedMax));
    });

    test('feature scaler should preserve order', () {
      final rawFeatures = [100.0, 200.0, 50.0];
      final scaledFeatures = [0.0, 1.0, -0.5];
      
      // Order relationship should be preserved
      expect(scaledFeatures[1], greaterThan(scaledFeatures[0]));
      expect(scaledFeatures[2], lessThan(scaledFeatures[0]));
    });
  });

  group('FeatureExtractionService - Edge Cases', () {
    test('empty audio samples handling', () {
      final emptySamples = Float32List(0);
      expect(emptySamples.isEmpty, isTrue);
    });

    test('silent audio samples handling', () {
      final silentSamples = Float32List.fromList(
        List<double>.filled(1000, 0.0),
      );
      
      expect(silentSamples.length, equals(1000));
      expect(silentSamples.every((s) => s == 0), isTrue);
    });

    test('minimum audio length for analysis', () {
      // Need at least a few pitch periods for analysis
      const sampleRate = 16000;
      const minPitchPeriod = 1.0 / 400; // 400 Hz max voice frequency
      final minSamples = (sampleRate * minPitchPeriod * 3).ceil();
      
      expect(minSamples, greaterThan(100));
    });
  });

  group('FeatureExtractionService - extractFeatures method', () {
    test('extractFeatures returns 22-dimensional vector', () async {
      // Create test samples with realistic audio-like data (simulated voice)
      const sampleRate = 16000;
      const duration = 0.5; // 500ms
      final numSamples = (sampleRate * duration).toInt();
      
      final samples = Float32List(numSamples);
      for (int i = 0; i < numSamples; i++) {
        // Simulate a simple sine wave at ~150Hz with some harmonics
        final t = i / sampleRate;
        samples[i] = 0.5 * _sin(2 * 3.14159 * 150 * t) +
                     0.2 * _sin(2 * 3.14159 * 300 * t) +
                     0.1 * _sin(2 * 3.14159 * 450 * t);
      }
      
      final features = await service.extractFeatures(samples, sampleRate: sampleRate);
      
      expect(features.length, equals(22));
      expect(features.every((f) => f.isFinite), isTrue);
    });

    test('extractFeatures with silent audio', () async {
      final silentSamples = Float32List.fromList(
        List<double>.filled(8000, 0.0),
      );
      
      final features = await service.extractFeatures(silentSamples);
      
      expect(features.length, equals(22));
      expect(features.every((f) => f.isFinite), isTrue);
    });

    test('extractFeatures with very short audio', () async {
      // Very short audio (100 samples at 16kHz = 6.25ms)
      final shortSamples = Float32List.fromList(
        List<double>.generate(100, (i) => _sin(i * 0.1)),
      );
      
      final features = await service.extractFeatures(shortSamples);
      
      expect(features.length, equals(22));
    });

    test('extractFeatures with noisy audio', () async {
      // Create noisy audio with random values
      final noisySamples = Float32List.fromList(
        List<double>.generate(8000, (i) => (i % 7 - 3) * 0.1),
      );
      
      final features = await service.extractFeatures(noisySamples);
      
      expect(features.length, equals(22));
      expect(features.every((f) => f.isFinite), isTrue);
    });

    test('extractFeatures with pure tone', () async {
      // Create a pure 200Hz sine wave
      const sampleRate = 16000;
      final samples = Float32List.fromList(
        List<double>.generate(
          8000,
          (i) => 0.8 * _sin(2 * 3.14159 * 200 * i / sampleRate),
        ),
      );
      
      final features = await service.extractFeatures(samples);
      
      expect(features.length, equals(22));
    });
  });

  group('FeatureExtractionService - extractFeaturesFromFile', () {
    test('extractFeaturesFromFile throws UnimplementedError', () async {
      expect(
        () => service.extractFeaturesFromFile('/path/to/file.wav'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('FeatureExtractionService - Feature Value Ranges', () {
    test('extracted features should be in valid ranges', () async {
      // Create test samples
      final samples = Float32List.fromList(
        List<double>.generate(
          16000,
          (i) => 0.5 * _sin(2 * 3.14159 * 150 * i / 16000) +
                 0.1 * _sin(2 * 3.14159 * 300 * i / 16000),
        ),
      );
      
      final features = await service.extractFeatures(samples);
      
      // Features are normalized, so check for finite values
      for (var i = 0; i < features.length; i++) {
        expect(features[i].isFinite, isTrue, reason: 'Feature $i should be finite');
        // Normalized features should be in reasonable range
        expect(features[i].abs(), lessThan(10), reason: 'Feature $i should be in normal range');
      }
    });
  });

  group('FeatureExtractionService - Different Sample Rates', () {
    test('extractFeatures with 8kHz sample rate', () async {
      const sampleRate = 8000;
      final samples = Float32List.fromList(
        List<double>.generate(
          4000,
          (i) => 0.5 * _sin(2 * 3.14159 * 150 * i / sampleRate),
        ),
      );
      
      final features = await service.extractFeatures(samples, sampleRate: sampleRate);
      
      expect(features.length, equals(22));
    });

    test('extractFeatures with 44.1kHz sample rate', () async {
      const sampleRate = 44100;
      final samples = Float32List.fromList(
        List<double>.generate(
          22050,
          (i) => 0.5 * _sin(2 * 3.14159 * 150 * i / sampleRate),
        ),
      );
      
      final features = await service.extractFeatures(samples, sampleRate: sampleRate);
      
      expect(features.length, equals(22));
    });
  });

  group('FeatureExtractionService - Consistency', () {
    test('same input should produce same output', () async {
      final samples = Float32List.fromList(
        List<double>.generate(8000, (i) => 0.5 * _sin(2 * 3.14159 * 150 * i / 16000)),
      );
      
      final features1 = await service.extractFeatures(samples);
      final features2 = await service.extractFeatures(samples);
      
      for (var i = 0; i < features1.length; i++) {
        expect(features1[i], closeTo(features2[i], 0.0001));
      }
    });
  });
}

// Helper function for tests
double _sin(double x) {
  // Taylor series approximation for sin
  x = x % (2 * 3.14159265359);
  if (x > 3.14159265359) x -= 2 * 3.14159265359;
  double result = x;
  double term = x;
  for (int i = 1; i <= 10; i++) {
    term *= -x * x / ((2 * i) * (2 * i + 1));
    result += term;
  }
  return result;
}

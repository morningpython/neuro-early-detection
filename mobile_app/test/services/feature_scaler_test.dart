import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/services/feature_scaler.dart';

void main() {
  group('FeatureScaler', () {
    group('featureCount', () {
      test('should return 22 features', () {
        expect(FeatureScaler.featureCount, 22);
      });

      test('featureNames should have 22 entries', () {
        expect(FeatureScaler.featureNames.length, 22);
      });
    });

    group('transform', () {
      test('should normalize features correctly', () {
        // Use mean values - should normalize to zeros
        final features = List<double>.generate(22, (i) => FeatureScaler.getMean(i));
        final normalized = FeatureScaler.transform(features);

        // All values should be close to 0
        for (int i = 0; i < normalized.length; i++) {
          expect(normalized[i], closeTo(0.0, 1e-10));
        }
      });

      test('should throw if wrong number of features', () {
        final wrongFeatures = [1.0, 2.0, 3.0]; // Only 3 features

        expect(
          () => FeatureScaler.transform(wrongFeatures),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle zero features', () {
        expect(
          () => FeatureScaler.transform([]),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should normalize correctly for known values', () {
        // Test with mean + 1 scale should give 1.0
        final features = List<double>.generate(
          22, 
          (i) => FeatureScaler.getMean(i) + FeatureScaler.getScale(i),
        );
        final normalized = FeatureScaler.transform(features);

        for (int i = 0; i < normalized.length; i++) {
          expect(normalized[i], closeTo(1.0, 1e-10));
        }
      });

      test('should normalize correctly for negative deviation', () {
        // Test with mean - 1 scale should give -1.0
        final features = List<double>.generate(
          22, 
          (i) => FeatureScaler.getMean(i) - FeatureScaler.getScale(i),
        );
        final normalized = FeatureScaler.transform(features);

        for (int i = 0; i < normalized.length; i++) {
          expect(normalized[i], closeTo(-1.0, 1e-10));
        }
      });
    });

    group('inverseTransform', () {
      test('should denormalize zeros to means', () {
        final normalized = List<double>.filled(22, 0.0);
        final features = FeatureScaler.inverseTransform(normalized);

        for (int i = 0; i < features.length; i++) {
          expect(features[i], closeTo(FeatureScaler.getMean(i), 1e-10));
        }
      });

      test('should be inverse of transform', () {
        final original = List<double>.generate(
          22, 
          (i) => FeatureScaler.getMean(i) + (i * 0.5),
        );
        final normalized = FeatureScaler.transform(original);
        final recovered = FeatureScaler.inverseTransform(normalized);

        for (int i = 0; i < original.length; i++) {
          expect(recovered[i], closeTo(original[i], 1e-10));
        }
      });

      test('should throw if wrong number of features', () {
        final wrongFeatures = [1.0, 2.0, 3.0];

        expect(
          () => FeatureScaler.inverseTransform(wrongFeatures),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should denormalize 1.0 to mean + scale', () {
        final normalized = List<double>.filled(22, 1.0);
        final features = FeatureScaler.inverseTransform(normalized);

        for (int i = 0; i < features.length; i++) {
          final expected = FeatureScaler.getMean(i) + FeatureScaler.getScale(i);
          expect(features[i], closeTo(expected, 1e-10));
        }
      });
    });

    group('getMean', () {
      test('should return valid mean values', () {
        // First feature: MDVP:Fo(Hz)
        expect(FeatureScaler.getMean(0), closeTo(152.797, 0.001));
        
        // HNR (index 15)
        expect(FeatureScaler.getMean(15), closeTo(21.416, 0.001));
      });

      test('should return different values for different indices', () {
        expect(FeatureScaler.getMean(0), isNot(equals(FeatureScaler.getMean(1))));
      });
    });

    group('getScale', () {
      test('should return valid scale values', () {
        // First feature: MDVP:Fo(Hz)
        expect(FeatureScaler.getScale(0), closeTo(41.221, 0.001));
        
        // HNR (index 15)
        expect(FeatureScaler.getScale(15), closeTo(4.658, 0.001));
      });

      test('should return positive values', () {
        for (int i = 0; i < 22; i++) {
          expect(FeatureScaler.getScale(i), greaterThan(0));
        }
      });
    });

    group('featureNames', () {
      test('should contain expected feature names', () {
        expect(FeatureScaler.featureNames[0], 'MDVP:Fo(Hz)');
        expect(FeatureScaler.featureNames[15], 'HNR');
        expect(FeatureScaler.featureNames[21], 'PPE');
      });

      test('should have unique names', () {
        final uniqueNames = FeatureScaler.featureNames.toSet();
        expect(uniqueNames.length, FeatureScaler.featureNames.length);
      });
    });

    group('edge cases', () {
      test('should handle very large values', () {
        final features = List<double>.generate(22, (i) => 1e6);
        final normalized = FeatureScaler.transform(features);
        
        // Should not throw and should return valid numbers
        for (final value in normalized) {
          expect(value.isFinite, isTrue);
        }
      });

      test('should handle very small values', () {
        final features = List<double>.generate(22, (i) => 1e-10);
        final normalized = FeatureScaler.transform(features);
        
        for (final value in normalized) {
          expect(value.isFinite, isTrue);
        }
      });

      test('should handle negative values', () {
        final features = List<double>.generate(22, (i) => -100.0);
        final normalized = FeatureScaler.transform(features);
        
        for (final value in normalized) {
          expect(value.isFinite, isTrue);
        }
      });
    });
  });
}

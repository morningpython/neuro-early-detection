/// Feature Scaler for UCI Parkinson's Dataset Features
/// 
/// This class replicates the StandardScaler normalization used during
/// model training. The mean and scale values are from the trained scaler.
library;

/// StandardScaler implementation for Dart
/// Normalizes features using: (x - mean) / scale
class FeatureScaler {
  /// Mean values from training data (per feature)
  static const List<double> _mean = [
    152.79699264705883,  // MDVP:Fo(Hz)
    196.1368602941177,   // MDVP:Fhi(Hz)
    114.83619117647059,  // MDVP:Flo(Hz)
    0.006712279411764703, // MDVP:Jitter(%)
    4.7301470588235284e-05, // MDVP:Jitter(Abs)
    0.0036007352941176468, // MDVP:RAP
    0.0037174999999999995, // MDVP:PPQ
    0.010802867647058826,  // Jitter:DDP
    0.03202573529411765,   // MDVP:Shimmer
    0.30683823529411763,   // MDVP:Shimmer(dB)
    0.016878161764705895,  // Shimmer:APQ3
    0.019254852941176466,  // Shimmer:APQ5
    0.026191691176470588,  // MDVP:APQ
    0.05063433823529412,   // Shimmer:DDA
    0.028354191176470575,  // NHR
    21.416375000000006,    // HNR
    0.5061492647058824,    // RPDE
    0.7206074632352941,    // DFA
    -5.63956205882353,     // spread1
    0.230600080882353,     // spread2
    2.415795602941177,     // D2
    0.21295754411764703,   // PPE
  ];

  /// Scale (std) values from training data (per feature)
  static const List<double> _scale = [
    41.220780031310085,    // MDVP:Fo(Hz)
    91.22686871082418,     // MDVP:Fhi(Hz)
    42.8074640128734,      // MDVP:Flo(Hz)
    0.005410903747351779,  // MDVP:Jitter(%)
    3.7883591018085996e-05, // MDVP:Jitter(Abs)
    0.003330424286773503,  // MDVP:RAP
    0.00307705377373724,   // MDVP:PPQ
    0.009991781763329908,  // Jitter:DDP
    0.020543152273730915,  // MDVP:Shimmer
    0.21460590490574863,   // MDVP:Shimmer(dB)
    0.011013474447920994,  // Shimmer:APQ3
    0.013064072758416393,  // Shimmer:APQ5
    0.018870559452535768,  // MDVP:APQ
    0.03303995076601796,   // Shimmer:DDA
    0.04590662662909845,   // NHR
    4.65812577327718,      // HNR
    0.10148281541032651,   // RPDE
    0.056084314557992274,  // DFA
    1.0971853687410789,    // spread1
    0.07939240892517363,   // spread2
    0.40821516948256664,   // D2
    0.09242203091389008,   // PPE
  ];

  /// Feature names in order
  static const List<String> featureNames = [
    'MDVP:Fo(Hz)',      // Fundamental frequency
    'MDVP:Fhi(Hz)',     // Maximum vocal fundamental frequency
    'MDVP:Flo(Hz)',     // Minimum vocal fundamental frequency
    'MDVP:Jitter(%)',   // Jitter percentage
    'MDVP:Jitter(Abs)', // Absolute jitter
    'MDVP:RAP',         // Relative average perturbation
    'MDVP:PPQ',         // Pitch perturbation quotient
    'Jitter:DDP',       // Differential of period perturbation
    'MDVP:Shimmer',     // Local shimmer
    'MDVP:Shimmer(dB)', // Shimmer in dB
    'Shimmer:APQ3',     // 3-point amplitude perturbation
    'Shimmer:APQ5',     // 5-point amplitude perturbation
    'MDVP:APQ',         // Amplitude perturbation quotient
    'Shimmer:DDA',      // Average difference of amplitude
    'NHR',              // Noise-to-harmonics ratio
    'HNR',              // Harmonics-to-noise ratio
    'RPDE',             // Recurrence period density entropy
    'DFA',              // Detrended fluctuation analysis
    'spread1',          // Nonlinear measure 1
    'spread2',          // Nonlinear measure 2
    'D2',               // Correlation dimension
    'PPE',              // Pitch period entropy
  ];

  /// Number of features
  static int get featureCount => _mean.length;

  /// Transform a single feature vector using StandardScaler
  /// 
  /// [features] - Raw feature values (must be length 22)
  /// Returns normalized feature vector
  static List<double> transform(List<double> features) {
    if (features.length != featureCount) {
      throw ArgumentError(
        'Expected $featureCount features, got ${features.length}'
      );
    }

    final normalized = <double>[];
    for (int i = 0; i < features.length; i++) {
      normalized.add((features[i] - _mean[i]) / _scale[i]);
    }
    return normalized;
  }

  /// Inverse transform (denormalize) a feature vector
  static List<double> inverseTransform(List<double> normalized) {
    if (normalized.length != featureCount) {
      throw ArgumentError(
        'Expected $featureCount features, got ${normalized.length}'
      );
    }

    final features = <double>[];
    for (int i = 0; i < normalized.length; i++) {
      features.add(normalized[i] * _scale[i] + _mean[i]);
    }
    return features;
  }

  /// Get the mean value for a specific feature
  static double getMean(int index) => _mean[index];

  /// Get the scale value for a specific feature
  static double getScale(int index) => _scale[index];
}

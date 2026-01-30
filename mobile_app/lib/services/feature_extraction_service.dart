/// Audio Feature Extraction Service
/// STORY-009: Audio Feature Extraction Service
///
/// This service extracts voice features from recorded audio for ML inference.
/// Features extracted match the UCI Parkinson's dataset format.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'feature_scaler.dart';

/// Service for extracting voice features from audio recordings
class FeatureExtractionService {
  /// Singleton instance
  static final FeatureExtractionService _instance = 
      FeatureExtractionService._internal();
  factory FeatureExtractionService() => _instance;
  FeatureExtractionService._internal();

  /// Extract features from raw audio samples
  /// 
  /// [samples] - Raw PCM audio samples (16-bit, 16kHz, mono)
  /// [sampleRate] - Sample rate in Hz (default 16000)
  /// 
  /// Returns a 22-dimensional feature vector matching UCI Parkinson's format
  Future<List<double>> extractFeatures(
    Float32List samples, {
    int sampleRate = 16000,
  }) async {
    // Calculate fundamental frequency and related features
    final f0Stats = _calculateF0Statistics(samples, sampleRate);
    
    // Calculate jitter features (frequency perturbation)
    final jitterFeatures = _calculateJitterFeatures(samples, sampleRate);
    
    // Calculate shimmer features (amplitude perturbation)
    final shimmerFeatures = _calculateShimmerFeatures(samples, sampleRate);
    
    // Calculate harmonics-to-noise ratio
    final noiseFeatures = _calculateNoiseFeatures(samples, sampleRate);
    
    // Calculate nonlinear dynamics features
    final nonlinearFeatures = _calculateNonlinearFeatures(samples, sampleRate);
    
    // Combine all features in UCI Parkinson's dataset order
    final features = <double>[
      f0Stats['f0_mean']!,      // MDVP:Fo(Hz)
      f0Stats['f0_max']!,       // MDVP:Fhi(Hz)
      f0Stats['f0_min']!,       // MDVP:Flo(Hz)
      jitterFeatures['jitter_percent']!,  // MDVP:Jitter(%)
      jitterFeatures['jitter_abs']!,      // MDVP:Jitter(Abs)
      jitterFeatures['rap']!,             // MDVP:RAP
      jitterFeatures['ppq']!,             // MDVP:PPQ
      jitterFeatures['ddp']!,             // Jitter:DDP
      shimmerFeatures['shimmer']!,        // MDVP:Shimmer
      shimmerFeatures['shimmer_db']!,     // MDVP:Shimmer(dB)
      shimmerFeatures['apq3']!,           // Shimmer:APQ3
      shimmerFeatures['apq5']!,           // Shimmer:APQ5
      shimmerFeatures['apq']!,            // MDVP:APQ
      shimmerFeatures['dda']!,            // Shimmer:DDA
      noiseFeatures['nhr']!,              // NHR
      noiseFeatures['hnr']!,              // HNR
      nonlinearFeatures['rpde']!,         // RPDE
      nonlinearFeatures['dfa']!,          // DFA
      nonlinearFeatures['spread1']!,      // spread1
      nonlinearFeatures['spread2']!,      // spread2
      nonlinearFeatures['d2']!,           // D2
      nonlinearFeatures['ppe']!,          // PPE
    ];
    
    // Normalize using the trained scaler
    return FeatureScaler.transform(features);
  }

  /// Extract features from a WAV file path
  /// Note: Requires audio decoding (use flutter_sound or similar)
  Future<List<double>> extractFeaturesFromFile(String filePath) async {
    // TODO: Implement WAV file reading
    // For now, this is a placeholder
    throw UnimplementedError('WAV file reading not yet implemented');
  }

  /// Calculate fundamental frequency (F0) statistics
  Map<String, double> _calculateF0Statistics(Float32List samples, int sampleRate) {
    final periods = _detectPeriods(samples, sampleRate);
    
    if (periods.isEmpty) {
      // Default values if no periods detected
      return {
        'f0_mean': 150.0,
        'f0_max': 200.0,
        'f0_min': 100.0,
      };
    }
    
    // Convert periods to frequencies
    final frequencies = periods.map((p) => sampleRate / p).toList();
    
    // Filter out outliers (typical voice range: 80-400 Hz)
    final validFreqs = frequencies
        .where((f) => f >= 80 && f <= 400)
        .toList();
    
    if (validFreqs.isEmpty) {
      return {
        'f0_mean': 150.0,
        'f0_max': 200.0,
        'f0_min': 100.0,
      };
    }
    
    return {
      'f0_mean': _mean(validFreqs),
      'f0_max': validFreqs.reduce(math.max),
      'f0_min': validFreqs.reduce(math.min),
    };
  }

  /// Calculate jitter features (pitch perturbation)
  Map<String, double> _calculateJitterFeatures(Float32List samples, int sampleRate) {
    final periods = _detectPeriods(samples, sampleRate);
    
    if (periods.length < 3) {
      return {
        'jitter_percent': 0.005,
        'jitter_abs': 0.00003,
        'rap': 0.003,
        'ppq': 0.003,
        'ddp': 0.009,
      };
    }
    
    // Calculate period differences
    final diffs = <double>[];
    for (int i = 1; i < periods.length; i++) {
      diffs.add((periods[i] - periods[i - 1]).abs().toDouble());
    }
    
    final meanPeriod = _mean(periods.map((p) => p.toDouble()).toList());
    final meanDiff = _mean(diffs);
    
    // Jitter (%) - average absolute difference divided by mean period
    final jitterPercent = meanDiff / meanPeriod;
    
    // Jitter (Abs) - average absolute difference in seconds
    final jitterAbs = meanDiff / sampleRate;
    
    // RAP - Relative Average Perturbation (3-point average)
    double rapSum = 0;
    for (int i = 1; i < periods.length - 1; i++) {
      final avg3 = (periods[i - 1] + periods[i] + periods[i + 1]) / 3;
      rapSum += (periods[i] - avg3).abs();
    }
    final rap = rapSum / ((periods.length - 2) * meanPeriod);
    
    // PPQ - 5-point Pitch Perturbation Quotient
    double ppqSum = 0;
    for (int i = 2; i < periods.length - 2; i++) {
      final avg5 = (periods[i - 2] + periods[i - 1] + periods[i] + 
                   periods[i + 1] + periods[i + 2]) / 5;
      ppqSum += (periods[i] - avg5).abs();
    }
    final ppq = periods.length > 4 
        ? ppqSum / ((periods.length - 4) * meanPeriod)
        : rap;
    
    // DDP - average absolute difference of differences
    final ddp = rap * 3;
    
    return {
      'jitter_percent': jitterPercent.clamp(0.001, 0.05),
      'jitter_abs': jitterAbs.clamp(0.00001, 0.0003),
      'rap': rap.clamp(0.001, 0.03),
      'ppq': ppq.clamp(0.001, 0.03),
      'ddp': ddp.clamp(0.003, 0.09),
    };
  }

  /// Calculate shimmer features (amplitude perturbation)
  Map<String, double> _calculateShimmerFeatures(Float32List samples, int sampleRate) {
    final amplitudes = _detectPeakAmplitudes(samples, sampleRate);
    
    if (amplitudes.length < 3) {
      return {
        'shimmer': 0.025,
        'shimmer_db': 0.25,
        'apq3': 0.015,
        'apq5': 0.018,
        'apq': 0.024,
        'dda': 0.045,
      };
    }
    
    final meanAmp = _mean(amplitudes);
    
    // Calculate amplitude differences
    final diffs = <double>[];
    for (int i = 1; i < amplitudes.length; i++) {
      diffs.add((amplitudes[i] - amplitudes[i - 1]).abs());
    }
    
    // Shimmer - average absolute difference divided by mean amplitude
    final shimmer = _mean(diffs) / meanAmp;
    
    // Shimmer (dB) - 20 * log10 of adjacent amplitude ratios
    double dbSum = 0;
    for (int i = 1; i < amplitudes.length; i++) {
      if (amplitudes[i] > 0 && amplitudes[i - 1] > 0) {
        dbSum += 20 * _log10(amplitudes[i] / amplitudes[i - 1]).abs();
      }
    }
    final shimmerDb = dbSum / (amplitudes.length - 1);
    
    // APQ3 - 3-point amplitude perturbation quotient
    double apq3Sum = 0;
    for (int i = 1; i < amplitudes.length - 1; i++) {
      final avg3 = (amplitudes[i - 1] + amplitudes[i] + amplitudes[i + 1]) / 3;
      apq3Sum += (amplitudes[i] - avg3).abs();
    }
    final apq3 = apq3Sum / ((amplitudes.length - 2) * meanAmp);
    
    // APQ5 - 5-point amplitude perturbation quotient
    double apq5Sum = 0;
    for (int i = 2; i < amplitudes.length - 2; i++) {
      final avg5 = (amplitudes[i - 2] + amplitudes[i - 1] + amplitudes[i] + 
                   amplitudes[i + 1] + amplitudes[i + 2]) / 5;
      apq5Sum += (amplitudes[i] - avg5).abs();
    }
    final apq5 = amplitudes.length > 4 
        ? apq5Sum / ((amplitudes.length - 4) * meanAmp)
        : apq3;
    
    // MDVP:APQ - 11-point APQ (simplified as 5-point here)
    final apq = apq5;
    
    // DDA - average absolute difference of differences of amplitudes
    final dda = apq3 * 3;
    
    return {
      'shimmer': shimmer.clamp(0.01, 0.15),
      'shimmer_db': shimmerDb.clamp(0.1, 1.5),
      'apq3': apq3.clamp(0.005, 0.06),
      'apq5': apq5.clamp(0.005, 0.08),
      'apq': apq.clamp(0.005, 0.15),
      'dda': dda.clamp(0.015, 0.18),
    };
  }

  /// Calculate noise-related features (HNR, NHR)
  Map<String, double> _calculateNoiseFeatures(Float32List samples, int sampleRate) {
    // Simplified HNR calculation using autocorrelation
    final autocorr = _autocorrelation(samples);
    
    // Find the first peak in autocorrelation (fundamental period)
    double maxCorr = 0;
    final minLag = sampleRate ~/ 400; // Max F0 ~ 400Hz
    final maxLag = sampleRate ~/ 80;  // Min F0 ~ 80Hz
    
    for (int lag = minLag; lag < math.min(maxLag, autocorr.length); lag++) {
      if (autocorr[lag] > maxCorr) {
        maxCorr = autocorr[lag];
      }
    }
    
    // HNR = 10 * log10(r1 / (1 - r1)) where r1 is max autocorrelation
    maxCorr = maxCorr.clamp(0.01, 0.99);
    final hnr = 10 * _log10(maxCorr / (1 - maxCorr));
    
    // NHR = 1 / HNR (noise-to-harmonics ratio)
    final nhr = 1 / (hnr.abs() + 0.001);
    
    return {
      'nhr': nhr.clamp(0.001, 0.4),
      'hnr': hnr.clamp(10.0, 35.0),
    };
  }

  /// Calculate nonlinear dynamics features
  Map<String, double> _calculateNonlinearFeatures(Float32List samples, int sampleRate) {
    // RPDE - Recurrence Period Density Entropy
    // Simplified estimation based on signal complexity
    final rpde = _calculateRPDE(samples);
    
    // DFA - Detrended Fluctuation Analysis
    final dfa = _calculateDFA(samples);
    
    // Spread measures (nonlinear fundamental frequency variation)
    final f0Stats = _calculateF0Statistics(samples, sampleRate);
    final spread1 = -5.0 - _log10(f0Stats['f0_max']! - f0Stats['f0_min']! + 1);
    final spread2 = 0.2 + 0.1 * (f0Stats['f0_max']! - f0Stats['f0_min']!) / f0Stats['f0_mean']!;
    
    // D2 - Correlation dimension
    final d2 = _calculateCorrelationDimension(samples);
    
    // PPE - Pitch Period Entropy
    final ppe = _calculatePPE(samples, sampleRate);
    
    return {
      'rpde': rpde.clamp(0.3, 0.7),
      'dfa': dfa.clamp(0.6, 0.85),
      'spread1': spread1.clamp(-7.0, -2.5),
      'spread2': spread2.clamp(0.1, 0.5),
      'd2': d2.clamp(1.5, 4.0),
      'ppe': ppe.clamp(0.05, 0.55),
    };
  }

  /// Detect periods using zero-crossing or autocorrelation
  List<int> _detectPeriods(Float32List samples, int sampleRate) {
    final periods = <int>[];
    final minPeriod = sampleRate ~/ 400; // Max 400 Hz
    final maxPeriod = sampleRate ~/ 80;  // Min 80 Hz
    
    // Use autocorrelation to detect periods
    final autocorr = _autocorrelation(samples);
    
    // Find peaks in autocorrelation
    for (int i = minPeriod; i < math.min(maxPeriod, autocorr.length - 1); i++) {
      if (autocorr[i] > autocorr[i - 1] && autocorr[i] > autocorr[i + 1]) {
        if (autocorr[i] > 0.3) { // Threshold
          periods.add(i);
        }
      }
    }
    
    return periods;
  }

  /// Detect peak amplitudes for each period
  List<double> _detectPeakAmplitudes(Float32List samples, int sampleRate) {
    final amplitudes = <double>[];
    final frameSize = sampleRate ~/ 100; // 10ms frames
    
    for (int i = 0; i < samples.length - frameSize; i += frameSize) {
      double maxAmp = 0;
      for (int j = i; j < i + frameSize; j++) {
        final amp = samples[j].abs();
        if (amp > maxAmp) maxAmp = amp;
      }
      if (maxAmp > 0.01) { // Ignore silent frames
        amplitudes.add(maxAmp);
      }
    }
    
    return amplitudes;
  }

  /// Calculate autocorrelation of signal
  List<double> _autocorrelation(Float32List samples) {
    final maxLag = math.min(samples.length ~/ 4, 2000);
    final result = List<double>.filled(maxLag, 0);
    
    // Normalize by removing mean
    final mean = _mean(samples.toList().map((e) => e.toDouble()).toList());
    
    for (int lag = 0; lag < maxLag; lag++) {
      double sum = 0;
      for (int i = 0; i < samples.length - lag; i++) {
        sum += (samples[i] - mean) * (samples[i + lag] - mean);
      }
      result[lag] = sum / (samples.length - lag);
    }
    
    // Normalize
    if (result[0] > 0) {
      for (int i = 0; i < result.length; i++) {
        result[i] /= result[0];
      }
    }
    
    return result;
  }

  /// Calculate RPDE (Recurrence Period Density Entropy)
  double _calculateRPDE(Float32List samples) {
    // Simplified RPDE calculation
    // Based on histogram of period differences
    final frameSize = 160; // 10ms at 16kHz
    final energies = <double>[];
    
    for (int i = 0; i < samples.length - frameSize; i += frameSize) {
      double energy = 0;
      for (int j = i; j < i + frameSize; j++) {
        energy += samples[j] * samples[j];
      }
      energies.add(energy / frameSize);
    }
    
    if (energies.isEmpty) return 0.5;
    
    // Calculate entropy of energy distribution
    final maxEnergy = energies.reduce(math.max);
    if (maxEnergy == 0) return 0.5;
    
    // Normalize and bin
    const nBins = 20;
    final histogram = List<int>.filled(nBins, 0);
    for (final e in energies) {
      final bin = ((e / maxEnergy) * (nBins - 1)).round().clamp(0, nBins - 1);
      histogram[bin]++;
    }
    
    // Calculate entropy
    double entropy = 0;
    for (final count in histogram) {
      if (count > 0) {
        final p = count / energies.length;
        entropy -= p * _log2(p);
      }
    }
    
    // Normalize by max entropy
    return entropy / _log2(nBins.toDouble());
  }

  /// Calculate DFA (Detrended Fluctuation Analysis)
  double _calculateDFA(Float32List samples) {
    // Simplified DFA calculation
    final n = samples.length;
    if (n < 100) return 0.72; // Default value
    
    // Integrate the signal
    final integrated = List<double>.filled(n, 0);
    double sum = 0;
    final mean = _mean(samples.toList().map((e) => e.toDouble()).toList());
    for (int i = 0; i < n; i++) {
      sum += samples[i] - mean;
      integrated[i] = sum;
    }
    
    // Calculate fluctuation for different window sizes
    final windowSizes = [16, 32, 64, 128, 256];
    final logN = <double>[];
    final logF = <double>[];
    
    for (final ws in windowSizes) {
      if (ws >= n ~/ 4) continue;
      
      final numWindows = n ~/ ws;
      double fluctuation = 0;
      
      for (int w = 0; w < numWindows; w++) {
        final start = w * ws;
        final end = start + ws;
        
        // Linear fit within window
        final xMean = (ws - 1) / 2.0;
        double yMean = 0;
        for (int i = start; i < end; i++) {
          yMean += integrated[i];
        }
        yMean /= ws;
        
        double ssXY = 0, ssXX = 0;
        for (int i = 0; i < ws; i++) {
          ssXY += (i - xMean) * (integrated[start + i] - yMean);
          ssXX += (i - xMean) * (i - xMean);
        }
        
        final slope = ssXX > 0 ? ssXY / ssXX : 0;
        final intercept = yMean - slope * xMean;
        
        // Calculate RMS error from trend
        for (int i = 0; i < ws; i++) {
          final trend = slope * i + intercept;
          final diff = integrated[start + i] - trend;
          fluctuation += diff * diff;
        }
      }
      
      if (numWindows > 0) {
        fluctuation = math.sqrt(fluctuation / (numWindows * ws));
        logN.add(_log10(ws.toDouble()));
        logF.add(_log10(fluctuation + 0.0001));
      }
    }
    
    // Calculate DFA exponent from slope
    if (logN.length < 2) return 0.72;
    
    final slope = _linearSlope(logN, logF);
    return slope.clamp(0.5, 1.0);
  }

  /// Calculate correlation dimension D2
  double _calculateCorrelationDimension(Float32List samples) {
    // Simplified D2 calculation
    // Typical values for voice: 2.0 - 3.5
    
    // Using zero crossing rate as a proxy for signal complexity
    final zeroCrossings = _zeroCrossingRate(samples);
    
    // Empirical formula based on signal complexity
    return 2.0 + (zeroCrossings * 2.0).clamp(0.0, 1.5);
  }

  /// Calculate PPE (Pitch Period Entropy)
  double _calculatePPE(Float32List samples, int sampleRate) {
    final periods = _detectPeriods(samples, sampleRate);
    if (periods.length < 10) return 0.2;
    
    // Calculate entropy of period distribution
    final minPeriod = periods.reduce(math.min);
    final maxPeriod = periods.reduce(math.max);
    final range = maxPeriod - minPeriod;
    
    if (range == 0) return 0.1;
    
    // Bin periods
    const nBins = 10;
    final histogram = List<int>.filled(nBins, 0);
    for (final p in periods) {
      final bin = ((p - minPeriod) / range * (nBins - 1)).round().clamp(0, nBins - 1);
      histogram[bin]++;
    }
    
    // Calculate entropy
    double entropy = 0;
    for (final count in histogram) {
      if (count > 0) {
        final prob = count / periods.length;
        entropy -= prob * _log2(prob);
      }
    }
    
    return entropy / _log2(nBins.toDouble());
  }

  // Helper functions
  
  double _mean(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  double _zeroCrossingRate(Float32List samples) {
    if (samples.length < 2) return 0;
    int crossings = 0;
    for (int i = 1; i < samples.length; i++) {
      if ((samples[i] >= 0 && samples[i - 1] < 0) ||
          (samples[i] < 0 && samples[i - 1] >= 0)) {
        crossings++;
      }
    }
    return crossings / samples.length;
  }
  
  double _log10(double x) => math.log(x) / math.ln10;
  double _log2(double x) => math.log(x) / math.ln2;
  
  double _linearSlope(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) return 0;
    
    final xMean = _mean(x);
    final yMean = _mean(y);
    
    double ssXY = 0, ssXX = 0;
    for (int i = 0; i < x.length; i++) {
      ssXY += (x[i] - xMean) * (y[i] - yMean);
      ssXX += (x[i] - xMean) * (x[i] - xMean);
    }
    
    return ssXX > 0 ? ssXY / ssXX : 0;
  }
}

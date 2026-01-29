/// Audio Recording Service
/// STORY-004: Voice Recording Service Implementation
///
/// This service handles audio recording using flutter_sound package.
/// Records 16kHz, 16-bit PCM, mono audio for voice analysis.
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

/// Recording state enumeration
enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}

/// Audio recording service for voice capture
class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  
  bool _isInitialized = false;
  RecordingState _state = RecordingState.idle;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  
  // Stream controllers
  final StreamController<RecordingState> _stateController = 
      StreamController<RecordingState>.broadcast();
  final StreamController<double> _amplitudeController = 
      StreamController<double>.broadcast();
  final StreamController<Duration> _durationController = 
      StreamController<Duration>.broadcast();
  
  Timer? _durationTimer;
  Duration _recordedDuration = Duration.zero;
  
  // Recording configuration
  static const int sampleRate = 16000;
  static const int numChannels = 1;
  static const int bitRate = 16;
  static const Duration maxDuration = Duration(seconds: 30);
  
  /// Current recording state
  RecordingState get state => _state;
  
  /// Whether recorder is initialized
  bool get isInitialized => _isInitialized;
  
  /// Current recording file path
  String? get currentRecordingPath => _currentRecordingPath;
  
  /// Stream of recording state changes
  Stream<RecordingState> get stateStream => _stateController.stream;
  
  /// Stream of amplitude levels (0.0 - 1.0)
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  
  /// Stream of recording duration
  Stream<Duration> get durationStream => _durationController.stream;
  
  /// Initialize the recorder
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _recorder.openRecorder();
      _isInitialized = true;
      debugPrint('✓ AudioRecordingService initialized');
    } catch (e) {
      debugPrint('✗ Failed to initialize recorder: $e');
      rethrow;
    }
  }
  
  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    
    if (status.isGranted) {
      debugPrint('✓ Microphone permission granted');
      return true;
    } else if (status.isPermanentlyDenied) {
      debugPrint('✗ Microphone permission permanently denied');
      await openAppSettings();
      return false;
    } else {
      debugPrint('✗ Microphone permission denied');
      return false;
    }
  }
  
  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    return await Permission.microphone.isGranted;
  }
  
  /// Start recording audio
  Future<String?> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_state == RecordingState.recording) {
      debugPrint('Already recording');
      return _currentRecordingPath;
    }
    
    // Check permission
    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) {
        throw RecordingException('Microphone permission denied');
      }
    }
    
    try {
      // Generate unique file path
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      
      final uuid = const Uuid().v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${audioDir.path}/recording_${uuid}_$timestamp.wav';
      
      // Start recording
      await _recorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.pcm16WAV,
        sampleRate: sampleRate,
        numChannels: numChannels,
      );
      
      _state = RecordingState.recording;
      _recordingStartTime = DateTime.now();
      _recordedDuration = Duration.zero;
      _stateController.add(_state);
      
      // Start duration timer
      _startDurationTimer();
      
      // Start amplitude monitoring
      _startAmplitudeMonitoring();
      
      debugPrint('✓ Recording started: $_currentRecordingPath');
      return _currentRecordingPath;
      
    } catch (e) {
      debugPrint('✗ Failed to start recording: $e');
      _state = RecordingState.idle;
      _stateController.add(_state);
      rethrow;
    }
  }
  
  /// Stop recording and return file path
  Future<String?> stopRecording() async {
    if (_state != RecordingState.recording) {
      debugPrint('Not recording');
      return null;
    }
    
    try {
      await _recorder.stopRecorder();
      
      _stopDurationTimer();
      
      _state = RecordingState.stopped;
      _stateController.add(_state);
      
      debugPrint('✓ Recording stopped: $_currentRecordingPath');
      debugPrint('  Duration: ${_recordedDuration.inSeconds}s');
      
      return _currentRecordingPath;
      
    } catch (e) {
      debugPrint('✗ Failed to stop recording: $e');
      rethrow;
    }
  }
  
  /// Cancel recording and delete file
  Future<void> cancelRecording() async {
    if (_state != RecordingState.recording) return;
    
    try {
      await _recorder.stopRecorder();
      _stopDurationTimer();
      
      // Delete the recording file
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('✓ Recording cancelled and deleted');
        }
      }
      
      _currentRecordingPath = null;
      _state = RecordingState.idle;
      _stateController.add(_state);
      
    } catch (e) {
      debugPrint('✗ Failed to cancel recording: $e');
    }
  }
  
  /// Read recorded audio as Float32List for feature extraction
  Future<Float32List?> getAudioSamples() async {
    if (_currentRecordingPath == null) return null;
    
    try {
      final file = File(_currentRecordingPath!);
      if (!await file.exists()) {
        debugPrint('✗ Recording file not found');
        return null;
      }
      
      final bytes = await file.readAsBytes();
      
      // Skip WAV header (44 bytes)
      const wavHeaderSize = 44;
      if (bytes.length <= wavHeaderSize) {
        debugPrint('✗ Recording file too small');
        return null;
      }
      
      // Convert 16-bit PCM to Float32
      final pcmData = bytes.sublist(wavHeaderSize);
      final int16Data = Int16List.view(pcmData.buffer);
      final samples = Float32List(int16Data.length);
      
      for (int i = 0; i < int16Data.length; i++) {
        samples[i] = int16Data[i] / 32768.0; // Normalize to -1.0 to 1.0
      }
      
      debugPrint('✓ Audio samples loaded: ${samples.length} samples');
      return samples;
      
    } catch (e) {
      debugPrint('✗ Failed to read audio samples: $e');
      return null;
    }
  }
  
  /// Get recording duration
  Duration get recordedDuration => _recordedDuration;
  
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_recordingStartTime != null) {
        _recordedDuration = DateTime.now().difference(_recordingStartTime!);
        _durationController.add(_recordedDuration);
        
        // Auto-stop at max duration
        if (_recordedDuration >= maxDuration) {
          stopRecording();
        }
      }
    });
  }
  
  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }
  
  void _startAmplitudeMonitoring() {
    // Subscribe to recorder decibels stream
    _recorder.onProgress?.listen((event) {
      if (event.decibels != null) {
        // Convert decibels to 0-1 range (roughly)
        // -60dB = silence, 0dB = max
        final normalized = ((event.decibels! + 60) / 60).clamp(0.0, 1.0);
        _amplitudeController.add(normalized);
      }
    });
  }
  
  /// Delete a recording file
  Future<void> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✓ Recording deleted: $path');
      }
    } catch (e) {
      debugPrint('✗ Failed to delete recording: $e');
    }
  }
  
  /// Dispose the service
  Future<void> dispose() async {
    _stopDurationTimer();
    await _stateController.close();
    await _amplitudeController.close();
    await _durationController.close();
    
    if (_isInitialized) {
      await _recorder.closeRecorder();
      _isInitialized = false;
    }
  }
}

/// Exception thrown when recording fails
class RecordingException implements Exception {
  final String message;
  RecordingException(this.message);
  
  @override
  String toString() => 'RecordingException: $message';
}

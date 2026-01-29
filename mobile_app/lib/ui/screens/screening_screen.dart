import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:neuro_access/config/theme.dart';
import 'package:neuro_access/l10n/generated/app_localizations.dart';
import 'package:neuro_access/providers/screening_provider.dart';
import 'package:neuro_access/ui/screens/patient_info_screen.dart';

/// 스크리닝 (음성 녹음) 화면
class ScreeningScreen extends StatefulWidget {
  final PatientInfo? patientInfo;
  
  const ScreeningScreen({super.key, this.patientInfo});

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen>
    with SingleTickerProviderStateMixin {
  late ScreeningProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ScreeningProvider();
    _provider.patientInfo = widget.patientInfo;
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _provider.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<ScreeningProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.voiceRecording),
              actions: [
                if (provider.status != ScreeningStatus.idle)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: provider.reset,
                    tooltip: AppLocalizations.of(context)!.tryAgain,
                  ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 안내 텍스트
                    _buildInstructions(context),
                    const Spacer(),
                    
                    // 상태 메시지
                    if (provider.isProcessing) ...[
                      _buildProcessingIndicator(context, provider),
                      const SizedBox(height: 24),
                    ],
                    
                    // 녹음 버튼
                    _buildRecordButton(context, provider),
                    const SizedBox(height: 24),
                    
                    // 타이머
                    _buildTimer(context, provider),
                    const Spacer(),
                    
                    // 파형 시각화
                    _buildWaveform(context, provider),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.record_voice_over,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.voiceRecording,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.holdPhoneInstruction}\n${l10n.sayAhInstruction}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator(BuildContext context, ScreeningProvider provider) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: provider.progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 12),
        Text(
          provider.statusMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordButton(BuildContext context, ScreeningProvider provider) {
    final Color buttonColor = _getButtonColor(provider);
    final String buttonText = _getButtonText(provider);
    final IconData buttonIcon = _getButtonIcon(provider);
    final bool isEnabled = _isButtonEnabled(provider);

    return GestureDetector(
      onTap: isEnabled ? () => _handleRecordTap(provider) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: isEnabled ? buttonColor : buttonColor.withAlpha(128),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: buttonColor.withAlpha(100),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              buttonIcon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer(BuildContext context, ScreeningProvider provider) {
    final seconds = provider.isRecording
        ? 30 - provider.recordingDuration.inSeconds
        : 30;
    
    return Text(
      '${seconds.clamp(0, 30)}초',
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: provider.isRecording
            ? AppTheme.recordingColor
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildWaveform(BuildContext context, ScreeningProvider provider) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: provider.isRecording
            ? const _AnimatedWaveform()
            : Text(
                AppLocalizations.of(context)!.tapToStart,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
      ),
    );
  }

  Color _getButtonColor(ScreeningProvider provider) {
    switch (provider.status) {
      case ScreeningStatus.idle:
        return AppTheme.readyColor;
      case ScreeningStatus.recording:
        return AppTheme.recordingColor;
      case ScreeningStatus.validating:
      case ScreeningStatus.extractingFeatures:
      case ScreeningStatus.analyzing:
        return AppTheme.processingColor;
      case ScreeningStatus.completed:
        return AppTheme.readyColor;
      case ScreeningStatus.error:
        return Colors.red;
    }
  }

  String _getButtonText(ScreeningProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (provider.status) {
      case ScreeningStatus.idle:
        return l10n.tapToStart;
      case ScreeningStatus.recording:
        return l10n.recording;
      case ScreeningStatus.validating:
      case ScreeningStatus.extractingFeatures:
      case ScreeningStatus.analyzing:
        return l10n.processing;
      case ScreeningStatus.completed:
        return l10n.screeningComplete;
      case ScreeningStatus.error:
        return l10n.tryAgain;
    }
  }

  IconData _getButtonIcon(ScreeningProvider provider) {
    switch (provider.status) {
      case ScreeningStatus.idle:
        return Icons.mic;
      case ScreeningStatus.recording:
        return Icons.stop;
      case ScreeningStatus.validating:
      case ScreeningStatus.extractingFeatures:
      case ScreeningStatus.analyzing:
        return Icons.hourglass_empty;
      case ScreeningStatus.completed:
        return Icons.check;
      case ScreeningStatus.error:
        return Icons.refresh;
    }
  }

  bool _isButtonEnabled(ScreeningProvider provider) {
    return provider.status == ScreeningStatus.idle ||
           provider.status == ScreeningStatus.recording ||
           provider.status == ScreeningStatus.error;
  }

  void _handleRecordTap(ScreeningProvider provider) {
    switch (provider.status) {
      case ScreeningStatus.idle:
      case ScreeningStatus.error:
        _startRecording(provider);
        break;
      case ScreeningStatus.recording:
        _stopRecording(provider);
        break;
      default:
        break;
    }
  }

  Future<void> _startRecording(ScreeningProvider provider) async {
    await provider.startRecording();
  }

  Future<void> _stopRecording(ScreeningProvider provider) async {
    await provider.stopRecordingAndAnalyze();
    
    // Navigate to results when completed
    provider.addListener(_onProviderStateChange);
  }
  
  void _onProviderStateChange() {
    if (_provider.status == ScreeningStatus.completed && _provider.data.result != null) {
      _provider.removeListener(_onProviderStateChange);
      
      // Navigate to results screen
      if (mounted) {
        context.push('/results', extra: _provider.data.result);
      }
    } else if (_provider.status == ScreeningStatus.error) {
      _provider.removeListener(_onProviderStateChange);
      
      // Show error dialog
      if (mounted) {
        _showErrorDialog(_provider.data.errorMessage ?? '알 수 없는 오류가 발생했습니다');
      }
    }
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('오류'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _provider.reset();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// Animated waveform visualization
class _AnimatedWaveform extends StatefulWidget {
  const _AnimatedWaveform();

  @override
  State<_AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<_AnimatedWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (index) {
            final height = 20.0 + 
                (_controller.value * 30 * (0.5 + 0.5 * 
                    ((index % 5) / 5) * 
                    (1 + 0.5 * (index.isEven ? 1 : -1) * _controller.value)));
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 4,
              height: height.clamp(10.0, 60.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

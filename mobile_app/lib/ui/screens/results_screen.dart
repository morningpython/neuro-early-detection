/// Analysis Results Screen
/// 
/// Displays the results of voice analysis including risk level,
/// probability, and recommendations for next steps.
library;

import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/referral.dart';
import '../../models/screening.dart' hide RiskLevel;
import '../../services/ml_inference_service.dart';
import '../../services/screening_repository.dart';
import '../../services/sms_service.dart';

class ResultsScreen extends StatefulWidget {
  final InferenceResult result;
  final String? audioPath;
  
  const ResultsScreen({
    super.key,
    required this.result,
    this.audioPath,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ScreeningRepository _repository = ScreeningRepository();
  final SmsService _smsService = SmsService();
  final ReferralRepository _referralRepository = ReferralRepository();
  bool _isSaving = false;
  bool _isSaved = false;
  Screening? _savedScreening;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final riskColor = Color(widget.result.riskLevel.colorValue);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.results),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Risk Level Card
              _RiskLevelCard(
                riskLevel: widget.result.riskLevel,
                color: riskColor,
              ),
              
              const SizedBox(height: 24),
              
              // Probability Score
              _ProbabilityCard(
                probability: widget.result.probability,
                confidence: widget.result.confidence,
                color: riskColor,
              ),
              
              const SizedBox(height: 24),
              
              // Recommendation
              _RecommendationCard(
                riskLevel: widget.result.riskLevel,
                color: riskColor,
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              FilledButton.icon(
                onPressed: () {
                  // Navigate to screening for new test
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.recordAgain),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              
              const SizedBox(height: 12),
              
              OutlinedButton.icon(
                onPressed: _isSaved ? null : () => _saveResult(context),
                icon: _isSaving 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isSaved ? Icons.check : Icons.save_alt),
                label: Text(_isSaved ? l10n.screeningSaved : l10n.saveAndFinish),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              
              if (widget.result.riskLevel == RiskLevel.high) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    _showReferralDialog(context);
                  },
                  icon: const Icon(Icons.local_hospital),
                  label: Text(l10n.referToHospital),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '이 검사 결과는 참고용이며, 정확한 진단을 위해서는 반드시 전문의 상담이 필요합니다.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _saveResult(BuildContext context) async {
    setState(() => _isSaving = true);
    
    try {
      // InferenceResult를 ScreeningResult로 변환
      final screeningResult = ScreeningResult.fromInference(
        probability: widget.result.probability,
        confidence: widget.result.confidence,
      );
      
      // 데이터베이스에 저장
      _savedScreening = await _repository.createAndSaveScreening(
        audioPath: widget.audioPath ?? '',
        result: screeningResult,
      );
      
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('검사 결과가 저장되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showReferralDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final facilities = HealthFacility.getDefaultFacilities();
    final patientNameController = TextEditingController();
    final patientPhoneController = TextEditingController();
    final notesController = TextEditingController();
    HealthFacility? selectedFacility;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.referToHospital,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SMS를 통해 환자를 의료 시설에 의뢰합니다.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // 환자 정보
                TextField(
                  controller: patientNameController,
                  decoration: const InputDecoration(
                    labelText: '환자 이름',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: patientPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '환자 연락처',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    hintText: '+254...',
                  ),
                ),
                const SizedBox(height: 24),

                // 시설 선택
                Text(
                  '의료 시설 선택',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: facilities.map((facility) {
                      return RadioListTile<HealthFacility>(
                        title: Text(facility.name),
                        subtitle: Text(facility.address),
                        value: facility,
                        groupValue: selectedFacility,
                        onChanged: (value) {
                          setModalState(() => selectedFacility = value);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // 메모
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '추가 메모 (선택)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // 발송 버튼
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: selectedFacility == null
                        ? null
                        : () async {
                            await _sendReferralSms(
                              context,
                              patientName: patientNameController.text.isNotEmpty
                                  ? patientNameController.text
                                  : '환자',
                              patientPhone: patientPhoneController.text,
                              facility: selectedFacility!,
                              notes: notesController.text.isNotEmpty
                                  ? notesController.text
                                  : null,
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                    icon: const Icon(Icons.send),
                    label: const Text('SMS 의뢰 발송'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendReferralSms(
    BuildContext context, {
    required String patientName,
    required String patientPhone,
    required HealthFacility facility,
    String? notes,
  }) async {
    final locale = Localizations.localeOf(context).languageCode;

    // 스크리닝이 저장되지 않았으면 먼저 저장
    if (_savedScreening == null && !_isSaved) {
      await _saveResult(context);
    }

    // 의뢰 생성
    final referral = Referral.create(
      screeningId: _savedScreening?.id ?? 'unknown',
      patientName: patientName,
      patientPhone: patientPhone,
      facilityName: facility.name,
      facilityPhone: facility.phone,
      priority: ReferralPriority.high,
      reason:
          'Parkinson\'s screening - Risk: ${widget.result.riskLevel.title}, Score: ${(widget.result.probability * 100).toStringAsFixed(1)}%',
      notes: notes,
    );

    // 의뢰 저장
    await _referralRepository.saveReferral(referral);

    // SMS 발송
    final result = await _smsService.sendReferralSms(
      referral: referral,
      locale: locale,
    );

    if (context.mounted) {
      if (result.success) {
        // 의뢰 상태 업데이트
        await _referralRepository.updateReferral(referral.markAsSent());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${facility.name}(으)로 의뢰 SMS가 준비되었습니다.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS 발송 실패: ${result.errorMessage}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _RiskLevelCard extends StatelessWidget {
  final RiskLevel riskLevel;
  final Color color;
  
  const _RiskLevelCard({
    required this.riskLevel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha(25),
              color.withAlpha(12),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(50),
                border: Border.all(color: color, width: 4),
              ),
              child: Icon(
                _getIcon(),
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              riskLevel.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getDescription(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIcon() {
    return switch (riskLevel) {
      RiskLevel.low => Icons.check_circle,
      RiskLevel.medium => Icons.warning,
      RiskLevel.high => Icons.error,
    };
  }
  
  String _getDescription() {
    return switch (riskLevel) {
      RiskLevel.low => '음성 분석 결과 특이사항이 발견되지 않았습니다.',
      RiskLevel.medium => '일부 지표에서 주의가 필요한 패턴이 감지되었습니다.',
      RiskLevel.high => '추가 검사가 필요한 패턴이 감지되었습니다.',
    };
  }
}

class _ProbabilityCard extends StatelessWidget {
  final double probability;
  final double confidence;
  final Color color;
  
  const _ProbabilityCard({
    required this.probability,
    required this.confidence,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '분석 상세',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _MetricRow(
              label: '위험 점수',
              value: '${(probability * 100).toStringAsFixed(1)}%',
              color: color,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: probability,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 20),
            _MetricRow(
              label: '신뢰도',
              value: '${(confidence * 100).toStringAsFixed(0)}%',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RiskLevel riskLevel;
  final Color color;
  
  const _RecommendationCard({
    required this.riskLevel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: color),
                const SizedBox(width: 8),
                Text(
                  '권장 사항',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              riskLevel.recommendation,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getUrgencyLabel(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getUrgencyLabel() {
    switch (riskLevel.urgency) {
      case 'routine':
        return '일반 모니터링';
      case 'monitor':
        return '주의 관찰 필요';
      case 'urgent':
        return '즉시 상담 권장';
      default:
        return '';
    }
  }
}

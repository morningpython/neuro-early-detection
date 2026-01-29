/// Patient Information Screen
/// STORY-019: Patient Demographics Input Screen
///
/// 스크리닝 전 환자 정보(나이, 성별, 동의)를 입력받는 화면
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';

/// 환자 정보 데이터 클래스
class PatientInfo {
  final int? age;
  final String? gender;
  final bool hasConsent;

  const PatientInfo({
    this.age,
    this.gender,
    this.hasConsent = false,
  });

  bool get isValid => 
      age != null && 
      age! >= 18 && 
      age! <= 120 && 
      gender != null && 
      hasConsent;

  PatientInfo copyWith({
    int? age,
    String? gender,
    bool? hasConsent,
  }) {
    return PatientInfo(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      hasConsent: hasConsent ?? this.hasConsent,
    );
  }
}

/// 환자 정보 입력 화면
class PatientInfoScreen extends StatefulWidget {
  const PatientInfoScreen({super.key});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  
  String? _selectedGender;
  bool _hasConsent = false;
  
  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final age = int.tryParse(_ageController.text);
    return age != null && 
           age >= 18 && 
           age <= 120 && 
           _selectedGender != null && 
           _hasConsent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patientInformation),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 안내 텍스트
                Card(
                  color: theme.colorScheme.primaryContainer.withAlpha(50),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.welcomeMessage,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 나이 입력
                _buildAgeInput(theme),
                
                const SizedBox(height: 24),
                
                // 성별 선택
                _buildGenderSelection(theme),
                
                const SizedBox(height: 32),
                
                // 동의 체크박스
                _buildConsentCheckbox(theme),
                
                const SizedBox(height: 40),
                
                // 다음 버튼
                FilledButton(
                  onPressed: _isFormValid ? _onNext : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.startScreening,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 건너뛰기 버튼
                TextButton(
                  onPressed: () => _onSkip(),
                  child: Text(
                    l10n.next,
                    style: TextStyle(
                      color: theme.colorScheme.outline,
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

  Widget _buildAgeInput(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.patientAge,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.pleaseEnterValidAge,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: InputDecoration(
            hintText: l10n.patientAge,
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '나이를 입력해주세요';
            }
            final age = int.tryParse(value);
            if (age == null || age < 18 || age > 120) {
              return '18세에서 120세 사이의 나이를 입력해주세요';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildGenderSelection(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.patientGender,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.pleaseSelectGender,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _GenderOption(
                label: l10n.male,
                icon: Icons.male,
                isSelected: _selectedGender == 'M',
                onTap: () => setState(() => _selectedGender = 'M'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderOption(
                label: l10n.female,
                icon: Icons.female,
                isSelected: _selectedGender == 'F',
                onTap: () => setState(() => _selectedGender = 'F'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderOption(
                label: l10n.other,
                icon: Icons.transgender,
                isSelected: _selectedGender == 'O',
                onTap: () => setState(() => _selectedGender = 'O'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsentCheckbox(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _hasConsent 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline.withAlpha(100),
          width: _hasConsent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: _hasConsent 
            ? theme.colorScheme.primaryContainer.withAlpha(30)
            : null,
      ),
      child: CheckboxListTile(
        value: _hasConsent,
        onChanged: (value) => setState(() => _hasConsent = value ?? false),
        title: Text(
          l10n.consent,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          l10n.consentMessage,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {
      final patientInfo = PatientInfo(
        age: int.tryParse(_ageController.text),
        gender: _selectedGender,
        hasConsent: _hasConsent,
      );
      
      // 스크리닝 화면으로 이동 (환자 정보 전달)
      context.push('/screening', extra: patientInfo);
    }
  }

  void _onSkip() {
    // 환자 정보 없이 스크리닝 화면으로 이동
    context.push('/screening');
  }
}

/// 성별 선택 옵션 위젯
class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer 
              : theme.colorScheme.surfaceContainerHighest.withAlpha(50),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withAlpha(100),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

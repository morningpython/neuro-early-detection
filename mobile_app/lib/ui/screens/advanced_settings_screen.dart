/// Advanced Settings Screen
/// STORY-030: Settings Screen Implementation
///
/// 고급 설정 화면입니다.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';

/// 고급 설정 화면
class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고급 설정'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = provider.settings;
          
          return ListView(
            children: [
              _buildSectionHeader('스크리닝 설정'),
              
              // 오디오 품질
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('오디오 품질'),
                subtitle: Text(settings.audioQuality.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAudioQualityDialog(context, provider),
              ),
              
              // 녹음 시간
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('녹음 시간'),
                subtitle: Text('${settings.recordingDuration}초'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showRecordingDurationDialog(context, provider),
              ),
              
              // 자동 품질 검증
              SwitchListTile(
                secondary: const Icon(Icons.check_circle),
                title: const Text('자동 품질 검증'),
                subtitle: const Text('녹음 후 자동으로 오디오 품질 확인'),
                value: settings.autoValidateAudio,
                onChanged: (value) => provider.updateSettings(
                  settings.copyWith(autoValidateAudio: value),
                ),
              ),
              
              // 신뢰도 점수 표시
              SwitchListTile(
                secondary: const Icon(Icons.analytics),
                title: const Text('신뢰도 점수 표시'),
                subtitle: const Text('결과 화면에 ML 신뢰도 표시'),
                value: settings.showConfidenceScore,
                onChanged: (value) => provider.updateSettings(
                  settings.copyWith(showConfidenceScore: value),
                ),
              ),
              
              const Divider(),
              _buildSectionHeader('동기화 설정'),
              
              // 동기화 빈도
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('동기화 빈도'),
                subtitle: Text(settings.syncFrequency.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSyncFrequencyDialog(context, provider),
              ),
              
              // Wi-Fi에서만 동기화
              SwitchListTile(
                secondary: const Icon(Icons.wifi),
                title: const Text('Wi-Fi에서만 동기화'),
                subtitle: const Text('모바일 데이터 사용 안 함'),
                value: settings.syncOnWifiOnly,
                onChanged: (value) => provider.updateSettings(
                  settings.copyWith(syncOnWifiOnly: value),
                ),
              ),
              
              // 자동 업로드
              SwitchListTile(
                secondary: const Icon(Icons.cloud_upload),
                title: const Text('자동 업로드'),
                subtitle: const Text('스크리닝 완료 시 자동 업로드'),
                value: settings.autoUpload,
                onChanged: (value) => provider.updateSettings(
                  settings.copyWith(autoUpload: value),
                ),
              ),
              
              const Divider(),
              _buildSectionHeader('보안 설정'),
              
              // 앱 재개 시 PIN 요구
              SwitchListTile(
                secondary: const Icon(Icons.pin),
                title: const Text('앱 재개 시 PIN 요구'),
                subtitle: Text('${settings.pinTimeout}분 후 잠금'),
                value: settings.requirePinOnResume,
                onChanged: (value) => provider.setRequirePinOnResume(value),
              ),
              
              // 생체 인증
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('생체 인증'),
                subtitle: const Text('지문 또는 Face ID 사용'),
                value: settings.enableBiometric,
                onChanged: (value) => provider.setEnableBiometric(value),
              ),
              
              // 로컬 데이터 암호화
              SwitchListTile(
                secondary: const Icon(Icons.lock),
                title: const Text('로컬 데이터 암호화'),
                subtitle: const Text('저장된 데이터 AES-256 암호화'),
                value: settings.encryptLocalData,
                onChanged: (value) => provider.setEncryptLocalData(value),
              ),
              
              const Divider(),
              _buildSectionHeader('데이터 관리'),
              
              // 저장 공간
              _buildStorageInfo(context, provider),
              
              // 자동 삭제
              ListTile(
                leading: const Icon(Icons.auto_delete),
                title: const Text('자동 삭제'),
                subtitle: Text(
                  settings.autoDeleteDays > 0 
                      ? '${settings.autoDeleteDays}일 이상 된 데이터 자동 삭제'
                      : '비활성화됨',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAutoDeleteDialog(context, provider),
              ),
              
              // 캐시 삭제
              ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: const Text('캐시 삭제'),
                subtitle: const Text('임시 파일 삭제'),
                onTap: () => _confirmClearCache(context, provider),
              ),
              
              // 모든 데이터 삭제
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('모든 데이터 삭제', style: TextStyle(color: Colors.red)),
                subtitle: const Text('스크리닝 및 설정 데이터 전체 삭제'),
                onTap: () => _confirmClearAllData(context, provider),
              ),
              
              const Divider(),
              _buildSectionHeader('설정 초기화'),
              
              // 설정 초기화
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('기본값으로 복원'),
                subtitle: const Text('모든 설정을 기본값으로 초기화'),
                onTap: () => _confirmResetSettings(context, provider),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStorageInfo(BuildContext context, SettingsProvider provider) {
    final storageInfo = provider.storageInfo;
    
    return ListTile(
      leading: const Icon(Icons.storage),
      title: const Text('저장 공간'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${storageInfo.usedFormatted} / ${storageInfo.totalFormatted} 사용 중'),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: storageInfo.usagePercent / 100,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 4),
          Text(
            '스크리닝: ${storageInfo.screeningCount}건, 오디오: ${storageInfo.audioFileCount}개',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  void _showAudioQualityDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오디오 품질'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AudioQuality.values.map((quality) {
            return RadioListTile<AudioQuality>(
              title: Text(quality.label),
              value: quality,
              groupValue: provider.settings.audioQuality,
              onChanged: (value) {
                if (value != null) {
                  provider.setAudioQuality(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRecordingDurationDialog(BuildContext context, SettingsProvider provider) {
    final durations = [15, 20, 30, 45, 60];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('녹음 시간'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations.map((seconds) {
            return RadioListTile<int>(
              title: Text('$seconds초'),
              value: seconds,
              groupValue: provider.settings.recordingDuration,
              onChanged: (value) {
                if (value != null) {
                  provider.setRecordingDuration(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSyncFrequencyDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('동기화 빈도'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SyncFrequency.values.map((freq) {
            return RadioListTile<SyncFrequency>(
              title: Text(freq.label),
              value: freq,
              groupValue: provider.settings.syncFrequency,
              onChanged: (value) {
                if (value != null) {
                  provider.setSyncFrequency(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAutoDeleteDialog(BuildContext context, SettingsProvider provider) {
    final options = [0, 7, 14, 30, 60, 90];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('자동 삭제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((days) {
            return RadioListTile<int>(
              title: Text(days == 0 ? '비활성화' : '$days일'),
              value: days,
              groupValue: provider.settings.autoDeleteDays,
              onChanged: (value) {
                if (value != null) {
                  provider.setAutoDeleteDays(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _confirmClearCache(BuildContext context, SettingsProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: const Text('임시 파일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await provider.clearCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('캐시가 삭제되었습니다')),
        );
      }
    }
  }

  Future<void> _confirmClearAllData(BuildContext context, SettingsProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 데이터 삭제'),
        content: const Text(
          '모든 스크리닝 데이터와 설정이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await provider.clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 데이터가 삭제되었습니다')),
        );
      }
    }
  }

  Future<void> _confirmResetSettings(BuildContext context, SettingsProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('모든 설정을 기본값으로 복원하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await provider.resetToDefaults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 초기화되었습니다')),
        );
      }
    }
  }
}

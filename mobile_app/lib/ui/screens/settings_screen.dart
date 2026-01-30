import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_provider.dart';
import 'advanced_settings_screen.dart';
import 'training_screen.dart';

/// 설정 화면
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;
          
          return ListView(
            children: [
              // 일반 설정
              _buildSectionHeader(context, l10n.language),
              Consumer<LocaleProvider>(
                builder: (context, localeProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.selectLanguage),
                    subtitle: Text(localeProvider.currentLocaleName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(context),
                  );
                },
              ),
              
              // 테마 설정
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: Text(settings.themeMode.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, settingsProvider),
              ),
              
              // 알림 설정
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                subtitle: const Text('Enable push notifications'),
                value: settings.enableNotifications,
                onChanged: (value) => settingsProvider.setEnableNotifications(value),
              ),
              const Divider(),
              
              // 앱 정보 섹션
              _buildSectionHeader(context, l10n.about),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.version),
                subtitle: const Text('1.0.0'),
              ),
              const Divider(),
              
              // CHW 설정
              _buildSectionHeader(context, l10n.communityHealthWorker),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('CHW Profile'),
                subtitle: const Text('Configure profile information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: CHW 프로필 화면
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('Training Module'),
                subtitle: const Text('CHW training materials'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrainingScreen()),
                  );
                },
              ),
              const Divider(),
              
              // 고급 설정
              _buildSectionHeader(context, 'Advanced'),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Advanced Settings'),
                subtitle: const Text('Screening, sync, security settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdvancedSettingsScreen()),
                  );
                },
              ),
              const Divider(),
              
              // 데이터 관리
              _buildSectionHeader(context, 'Data'),
              _buildStorageInfo(context, settingsProvider),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.delete),
                subtitle: const Text('Delete all screening records'),
                onTap: () {
                  _showDeleteConfirmation(context, settingsProvider);
                },
              ),
              const Divider(),
              
              // 정보
              _buildSectionHeader(context, 'Legal'),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.privacyPolicy),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 개인정보 처리방침
                },
              ),
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: Text(l10n.termsOfService),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 이용약관
                },
              ),
              ListTile(
                leading: const Icon(Icons.medical_information_outlined),
                title: const Text('IRB Approval'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: IRB 정보
                },
              ),
              const SizedBox(height: 24),
              
              // 푸터
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'NeuroAccess',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'University of Michigan\nGlobal Health & Neuroscience Initiative',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStorageInfo(BuildContext context, SettingsProvider provider) {
    final storageInfo = provider.storageInfo;
    
    return ListTile(
      leading: const Icon(Icons.storage_outlined),
      title: const Text('Local Data'),
      subtitle: Text('${storageInfo.usedFormatted} in use (${storageInfo.screeningCount} screenings)'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdvancedSettingsScreen()),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(mode.label),
              value: mode,
              groupValue: provider.settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocaleProvider.supportedLocales.map((locale) {
            final isSelected = locale == localeProvider.locale;
            final name = LocaleProvider.localeNames[locale.languageCode] ?? locale.languageCode;
            
            return ListTile(
              title: Text(name),
              leading: Radio<Locale>(
                value: locale,
                groupValue: localeProvider.locale,
                onChanged: (value) {
                  if (value != null) {
                    localeProvider.setLocale(value);
                    Navigator.pop(context);
                  }
                },
              ),
              selected: isSelected,
              onTap: () {
                localeProvider.setLocale(locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SettingsProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data deleted')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocaleProvider.supportedLocales.map((locale) {
            final isSelected = locale == localeProvider.locale;
            final name = LocaleProvider.localeNames[locale.languageCode] ?? locale.languageCode;
            
            return ListTile(
              title: Text(name),
              leading: Radio<Locale>(
                value: locale,
                groupValue: localeProvider.locale,
                onChanged: (value) {
                  if (value != null) {
                    localeProvider.setLocale(value);
                    Navigator.pop(context);
                  }
                },
              ),
              selected: isSelected,
              onTap: () {
                localeProvider.setLocale(locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

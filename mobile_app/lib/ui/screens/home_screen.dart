import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/screening.dart';
import '../../services/screening_repository.dart';

/// 홈 화면 (대시보드)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScreeningRepository _repository = ScreeningRepository();
  List<Screening> _recentScreenings = [];
  Map<RiskLevel, int> _riskStats = {};
  int _totalCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final screenings = await _repository.getRecentScreenings(limit: 5);
      final stats = await _repository.getRiskStats();
      final count = await _repository.getScreeningCount();
      
      setState(() {
        _recentScreenings = screenings;
        _riskStats = stats;
        _totalCount = count;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // TODO: 도움말 화면으로 이동
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 환영 메시지
              _buildWelcomeCard(context),
              const SizedBox(height: 24),
              
              // 빠른 시작 버튼
              _buildQuickStartButton(context),
              const SizedBox(height: 16),
              
              // 빠른 액션 버튼들
              _buildQuickActions(context),
              const SizedBox(height: 24),
              
              // 최근 스크리닝
              _buildRecentScreenings(context),
              const SizedBox(height: 24),
              
              // 통계 카드
              _buildStatsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.waving_hand,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcomeGreeting,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.communityHealthWorker,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.welcomeMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: () => context.push('/patient-info'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mic, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.startScreening,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.secondsRemaining(30),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.school,
            label: l10n.training,
            color: Colors.orange,
            onTap: () => context.push('/training'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.history,
            label: l10n.recentScreenings,
            color: Colors.blue,
            onTap: () {
              // TODO: 기록 화면으로 이동
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.settings,
            label: l10n.settings,
            color: Colors.grey,
            onTap: () => context.push('/settings'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentScreenings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.recentScreenings,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_recentScreenings.isNotEmpty)
              TextButton(
                onPressed: () {
                  // TODO: 전체 기록 화면으로 이동
                },
                child: Text(AppLocalizations.of(context)!.viewDetails),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (_recentScreenings.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.noScreeningsYet,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: _recentScreenings.map((screening) => 
              _ScreeningCard(
                screening: screening,
                onTap: () {
                  // TODO: 상세 화면으로 이동
                },
                onDelete: () => _confirmDelete(screening),
              ),
            ).toList(),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(Screening screening) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text(AppLocalizations.of(context)!.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _repository.deleteScreening(screening.id);
      _loadData();
    }
  }

  Widget _buildStatsCard(BuildContext context) {
    final lowCount = _riskStats[RiskLevel.low] ?? 0;
    final moderateCount = _riskStats[RiskLevel.moderate] ?? 0;
    final highCount = _riskStats[RiskLevel.high] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.statistics,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.people_outline,
                label: AppLocalizations.of(context)!.totalScreenings,
                value: '$_totalCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.check_circle_outline,
                label: AppLocalizations.of(context)!.lowRisk,
                value: '$lowCount',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.warning_amber_outlined,
                label: AppLocalizations.of(context)!.highRisk,
                value: '${moderateCount + highCount}',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 스크리닝 카드 위젯
class _ScreeningCard extends StatelessWidget {
  final Screening screening;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _ScreeningCard({
    required this.screening,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final riskLevel = screening.result?.riskLevel ?? RiskLevel.low;
    final riskColor = Color(riskLevel.colorValue);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 위험 수준 표시
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: riskColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getRiskIcon(riskLevel),
                    color: riskColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          screening.patientDescription.isNotEmpty 
                              ? screening.patientDescription 
                              : '환자 정보 없음',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: riskColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            riskLevel.label,
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(screening.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 위험 점수
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    screening.riskPercentage,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      color: Colors.grey,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.moderate:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('MM/dd HH:mm').format(date);
    }
  }
}

/// 빠른 액션 버튼 위젯
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withAlpha(200),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

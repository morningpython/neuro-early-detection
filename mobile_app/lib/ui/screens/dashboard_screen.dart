/// Dashboard Screen
/// STORY-028: Screening Statistics Dashboard
///
/// 스크리닝 통계 대시보드 화면입니다.
library;

import 'package:flutter/material.dart';
import '../../models/dashboard_stats.dart';
import '../../services/dashboard_service.dart';

/// 대시보드 화면
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  
  DashboardStats _stats = DashboardStats.empty();
  RiskDistribution _riskDistribution = RiskDistribution.empty();
  ChartData? _dailyTrend;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _dashboardService.initialize();
      
      final results = await Future.wait([
        _dashboardService.getOverallStats(),
        _dashboardService.getRiskDistribution(),
        _dashboardService.getDailyScreeningTrend(days: 7),
      ]);

      setState(() {
        _stats = results[0] as DashboardStats;
        _riskDistribution = results[1] as RiskDistribution;
        _dailyTrend = results[2] as ChartData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null 
              ? Center(child: Text('오류: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        _buildTrendSection(),
                        const SizedBox(height: 24),
                        _buildRiskDistributionSection(),
                        const SizedBox(height: 24),
                        _buildReferralSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '스크리닝 현황',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: '오늘',
                value: _stats.screeningsToday.toString(),
                icon: Icons.today,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: '이번 주',
                value: _stats.screeningsThisWeek.toString(),
                icon: Icons.date_range,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: '이번 달',
                value: _stats.screeningsThisMonth.toString(),
                icon: Icons.calendar_month,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: '전체',
                value: _stats.totalScreenings.toString(),
                icon: Icons.assessment,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendSection() {
    final trend = _dailyTrend;
    if (trend == null || trend.dataPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주간 트렌드',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '평균: ${trend.avgValue.toStringAsFixed(1)}건/일',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '최대: ${trend.maxValue.toInt()}건',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSimpleBarChart(trend),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleBarChart(ChartData data) {
    final maxValue = data.maxValue > 0 ? data.maxValue : 1;
    
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.dataPoints.map((point) {
          final height = (point.value / maxValue) * 100;
          final dayName = _getDayName(point.date.weekday);
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    point.value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: height.clamp(4, 100),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }

  Widget _buildRiskDistributionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '위험 수준 분포',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RiskBar(
                  label: '고위험',
                  count: _riskDistribution.highRisk,
                  percent: _riskDistribution.highRiskPercent,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                _RiskBar(
                  label: '중위험',
                  count: _riskDistribution.mediumRisk,
                  percent: _riskDistribution.mediumRiskPercent,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _RiskBar(
                  label: '저위험',
                  count: _riskDistribution.lowRisk,
                  percent: _riskDistribution.lowRiskPercent,
                  color: Colors.yellow.shade700,
                ),
                const SizedBox(height: 12),
                _RiskBar(
                  label: '정상',
                  count: _riskDistribution.noRisk,
                  percent: _riskDistribution.noRiskPercent,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '의뢰 현황',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: '전체 의뢰',
                value: _stats.totalReferrals.toString(),
                icon: Icons.send,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: '대기 중',
                value: _stats.pendingReferrals.toString(),
                icon: Icons.pending_actions,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: '완료',
                value: _stats.completedReferrals.toString(),
                icon: Icons.check_circle,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        if (_stats.totalReferrals > 0) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withAlpha(30),
                child: Text(
                  '${(_stats.referralCompletionRate * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              title: const Text('의뢰 완료율'),
              subtitle: LinearProgressIndicator(
                value: _stats.referralCompletionRate,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 통계 카드 위젯
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 위험 수준 막대 위젯
class _RiskBar extends StatelessWidget {
  final String label;
  final int count;
  final double percent;
  final Color color;

  const _RiskBar({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent / 100,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            '$count건',
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '${percent.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

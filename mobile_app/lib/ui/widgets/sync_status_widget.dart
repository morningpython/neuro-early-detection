/// Sync Status Widget
/// STORY-024: Offline Sync Queue
/// STORY-026: Connection Status Monitoring
///
/// 동기화 상태를 표시하는 위젯들입니다.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sync_provider.dart';
import '../../models/sync_queue.dart';

/// 연결 상태 표시 위젯 (앱바용)
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, provider, child) {
        final color = Color(provider.connectionColorCode);
        
        return Tooltip(
          message: provider.connectionStatus.label,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withAlpha(100)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                if (provider.hasPendingItems) ...[
                  Text(
                    '${provider.stats.totalPending}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.sync,
                    size: 12,
                    color: color,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 동기화 상태 배너
class SyncStatusBanner extends StatelessWidget {
  final VoidCallback? onSyncPressed;

  const SyncStatusBanner({super.key, this.onSyncPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const SizedBox.shrink();
        }

        // 동기화 중일 때
        if (provider.isSyncing && provider.currentProgress != null) {
          return _buildSyncingBanner(context, provider);
        }

        // 오프라인일 때
        if (!provider.isOnline) {
          return _buildOfflineBanner(context, provider);
        }

        // 대기 중인 항목이 있을 때
        if (provider.hasPendingItems) {
          return _buildPendingBanner(context, provider);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSyncingBanner(BuildContext context, SyncProvider provider) {
    final progress = provider.currentProgress!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  progress.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.progress,
            backgroundColor: Colors.blue.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context, SyncProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 20, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오프라인 모드',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (provider.stats.totalPending > 0)
                  Text(
                    '${provider.stats.totalPending}개 항목이 연결 시 동기화됩니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBanner(BuildContext context, SyncProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.sync, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${provider.stats.totalPending}개 항목 동기화 대기 중',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: onSyncPressed ?? () => provider.syncNow(),
            child: const Text('지금 동기화'),
          ),
        ],
      ),
    );
  }
}

/// 동기화 큐 화면
class SyncQueueScreen extends StatefulWidget {
  const SyncQueueScreen({super.key});

  @override
  State<SyncQueueScreen> createState() => _SyncQueueScreenState();
}

class _SyncQueueScreenState extends State<SyncQueueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('동기화 큐'),
        actions: const [
          ConnectionStatusIndicator(),
          SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '대기 중', icon: Icon(Icons.pending_actions)),
            Tab(text: '실패', icon: Icon(Icons.error_outline)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PendingItemsList(),
                _FailedItemsList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<SyncProvider>(
        builder: (context, provider, child) {
          if (provider.isSyncing) {
            return FloatingActionButton(
              onPressed: null,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            );
          }

          return FloatingActionButton.extended(
            onPressed: provider.isOnline ? () => provider.syncNow() : null,
            icon: const Icon(Icons.sync),
            label: const Text('지금 동기화'),
            backgroundColor: provider.isOnline ? null : Colors.grey,
          );
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<SyncProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '대기',
                  stats.pendingCount.toString(),
                  Colors.orange,
                  Icons.pending_actions,
                ),
                _buildStatItem(
                  '진행 중',
                  stats.inProgressCount.toString(),
                  Colors.blue,
                  Icons.sync,
                ),
                _buildStatItem(
                  '완료',
                  stats.completedCount.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatItem(
                  '실패',
                  stats.failedCount.toString(),
                  Colors.red,
                  Icons.error,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _PendingItemsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<SyncQueueItem>>(
          future: provider.getPendingItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data ?? [];
            
            if (items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text('대기 중인 항목이 없습니다'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => _SyncQueueItemTile(item: items[index]),
            );
          },
        );
      },
    );
  }
}

class _FailedItemsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<SyncQueueItem>>(
          future: provider.getFailedItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data ?? [];
            
            if (items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text('실패한 항목이 없습니다'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    onPressed: () => provider.retryFailed(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('모두 재시도'),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) => _SyncQueueItemTile(
                      item: items[index],
                      showError: true,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SyncQueueItemTile extends StatelessWidget {
  final SyncQueueItem item;
  final bool showError;

  const _SyncQueueItemTile({
    required this.item,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withAlpha(30),
          child: Icon(
            _getEntityIcon(),
            color: _getStatusColor(),
          ),
        ),
        title: Text(item.entityType.label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.operationType.label} • ${_formatTime(item.createdAt)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (showError && item.errorMessage != null)
              Text(
                item.errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: item.status == SyncStatus.failed
            ? Text(
                '${item.retryCount}/${item.maxRetries}',
                style: const TextStyle(color: Colors.red),
              )
            : Icon(
                Icons.priority_high,
                color: item.priority <= 5 ? Colors.red : Colors.grey,
                size: 16,
              ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (item.status) {
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.inProgress:
        return Colors.blue;
      case SyncStatus.completed:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
    }
  }

  IconData _getEntityIcon() {
    switch (item.entityType) {
      case SyncEntityType.screening:
        return Icons.assignment;
      case SyncEntityType.referral:
        return Icons.medical_services;
      case SyncEntityType.trainingProgress:
        return Icons.school;
      case SyncEntityType.chwProfile:
        return Icons.person;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

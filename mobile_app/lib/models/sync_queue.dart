/// Sync Queue Model
/// STORY-024: Offline Sync Queue
///
/// 오프라인 데이터 동기화 큐 모델입니다.
/// 인터넷 연결이 없을 때 데이터를 저장하고 연결 시 동기화합니다.
library;

import 'package:uuid/uuid.dart';

/// 동기화 작업 유형
enum SyncOperationType {
  create('생성'),
  update('수정'),
  delete('삭제');

  const SyncOperationType(this.label);
  final String label;

  static SyncOperationType fromString(String value) {
    return SyncOperationType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SyncOperationType.create,
    );
  }
}

/// 동기화 상태
enum SyncStatus {
  pending('대기중', 0xFFFF9800),
  inProgress('진행중', 0xFF2196F3),
  completed('완료', 0xFF4CAF50),
  failed('실패', 0xFFF44336),
  cancelled('취소됨', 0xFF9E9E9E);

  const SyncStatus(this.label, this.colorValue);
  final String label;
  final int colorValue;

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SyncStatus.pending,
    );
  }
}

/// 동기화 항목 유형
enum SyncEntityType {
  screening('스크리닝'),
  referral('의뢰'),
  trainingProgress('교육 진행'),
  chwProfile('CHW 프로필');

  const SyncEntityType(this.label);
  final String label;

  static SyncEntityType fromString(String value) {
    return SyncEntityType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SyncEntityType.screening,
    );
  }
}

/// 동기화 큐 항목
class SyncQueueItem {
  /// 고유 식별자
  final String id;

  /// 생성 시간
  final DateTime createdAt;

  /// 엔티티 유형
  final SyncEntityType entityType;

  /// 엔티티 ID
  final String entityId;

  /// 작업 유형
  final SyncOperationType operationType;

  /// 동기화 상태
  final SyncStatus status;

  /// 데이터 페이로드 (JSON)
  final String payload;

  /// 재시도 횟수
  final int retryCount;

  /// 최대 재시도 횟수
  final int maxRetries;

  /// 마지막 시도 시간
  final DateTime? lastAttemptAt;

  /// 오류 메시지
  final String? errorMessage;

  /// 우선순위 (낮을수록 높은 우선순위)
  final int priority;

  const SyncQueueItem({
    required this.id,
    required this.createdAt,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.status,
    required this.payload,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.lastAttemptAt,
    this.errorMessage,
    this.priority = 10,
  });

  /// 새 동기화 항목 생성
  factory SyncQueueItem.create({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required String payload,
    int priority = 10,
  }) {
    return SyncQueueItem(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      status: SyncStatus.pending,
      payload: payload,
      priority: priority,
    );
  }

  /// Map 변환 (SQLite 저장용)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'entity_type': entityType.name,
      'entity_id': entityId,
      'operation_type': operationType.name,
      'status': status.name,
      'payload': payload,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
      'error_message': errorMessage,
      'priority': priority,
    };
  }

  /// Map에서 생성
  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      entityType: SyncEntityType.fromString(map['entity_type'] as String),
      entityId: map['entity_id'] as String,
      operationType: SyncOperationType.fromString(map['operation_type'] as String),
      status: SyncStatus.fromString(map['status'] as String),
      payload: map['payload'] as String,
      retryCount: map['retry_count'] as int? ?? 0,
      maxRetries: map['max_retries'] as int? ?? 3,
      lastAttemptAt: map['last_attempt_at'] != null
          ? DateTime.parse(map['last_attempt_at'] as String)
          : null,
      errorMessage: map['error_message'] as String?,
      priority: map['priority'] as int? ?? 10,
    );
  }

  /// 상태 업데이트 복사본 생성
  SyncQueueItem copyWith({
    SyncStatus? status,
    int? retryCount,
    DateTime? lastAttemptAt,
    String? errorMessage,
  }) {
    return SyncQueueItem(
      id: id,
      createdAt: createdAt,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      status: status ?? this.status,
      payload: payload,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
      priority: priority,
    );
  }

  /// 재시도 가능 여부
  bool get canRetry => retryCount < maxRetries && status == SyncStatus.failed;

  /// 진행 중으로 표시
  SyncQueueItem markInProgress() {
    return copyWith(
      status: SyncStatus.inProgress,
      lastAttemptAt: DateTime.now(),
    );
  }

  /// 완료로 표시
  SyncQueueItem markCompleted() {
    return copyWith(status: SyncStatus.completed);
  }

  /// 실패로 표시
  SyncQueueItem markFailed(String error) {
    return copyWith(
      status: SyncStatus.failed,
      retryCount: retryCount + 1,
      errorMessage: error,
    );
  }

  /// 대기로 재설정 (재시도용)
  SyncQueueItem resetToPending() {
    return copyWith(
      status: SyncStatus.pending,
      errorMessage: null,
    );
  }

  @override
  String toString() {
    return 'SyncQueueItem(id: $id, type: ${entityType.label}, status: ${status.label})';
  }
}

/// 동기화 결과
class SyncResult {
  final int totalItems;
  final int successCount;
  final int failedCount;
  final List<String> errors;
  final DateTime completedAt;

  const SyncResult({
    required this.totalItems,
    required this.successCount,
    required this.failedCount,
    required this.errors,
    required this.completedAt,
  });

  factory SyncResult.empty() {
    return SyncResult(
      totalItems: 0,
      successCount: 0,
      failedCount: 0,
      errors: [],
      completedAt: DateTime.now(),
    );
  }

  bool get isSuccess => failedCount == 0;
  double get successRate => totalItems > 0 ? successCount / totalItems : 0;
}

/// 동기화 통계
class SyncStats {
  final int pendingCount;
  final int inProgressCount;
  final int completedCount;
  final int failedCount;
  final DateTime? lastSyncAt;

  const SyncStats({
    required this.pendingCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.failedCount,
    this.lastSyncAt,
  });

  int get totalCount => pendingCount + inProgressCount + completedCount + failedCount;
  bool get hasPending => pendingCount > 0;
}

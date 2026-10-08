enum SyncStatus { idle, running, success, partial, failed }

class SyncResult {
  const SyncResult({required this.status, this.pushed = 0, this.pulled = 0, this.conflicts = 0, this.failed = 0, this.error, this.duration});
  final SyncStatus status;
  final int pushed;
  final int pulled;
  final int conflicts;
  final int failed;
  final String? error;
  final Duration? duration;
  bool get isSuccess => status == SyncStatus.success;
  bool get hasChanges => pushed > 0 || pulled > 0;
}

class PushResult {
  const PushResult({required this.processed, required this.failed, required this.conflicts});
  final int processed;
  final int failed;
  final int conflicts;
  factory PushResult.empty() => const PushResult(processed: 0, failed: 0, conflicts: 0);
}

class PullResult {
  const PullResult({required this.applied, required this.conflicts, this.newCursor, this.error});
  final int applied;
  final int conflicts;
  final String? newCursor;
  final String? error;
  factory PullResult.empty() => const PullResult(applied: 0, conflicts: 0);
}

class PushCommandResult {
  const PushCommandResult({required this.opId, required this.status, this.serverVersion, this.serverEntityId, this.message, this.retryable = true});
  final String opId;
  final String status;
  final int? serverVersion;
  final String? serverEntityId;
  final String? message;
  final bool retryable;
}

class PushBatchResponse {
  const PushBatchResponse({required this.ok, required this.results, this.message, this.statusCode, this.retryable});
  final bool ok;
  final List<PushCommandResult> results;
  final String? message;
  final int? statusCode;
  final bool? retryable;
}

class PullBatchResponse {
  const PullBatchResponse({required this.ok, required this.changes, this.nextCursor, this.message, this.statusCode});
  final bool ok;
  final List<Map<String, dynamic>> changes;
  final String? nextCursor;
  final String? message;
  final int? statusCode;
}

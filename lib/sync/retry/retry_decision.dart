import 'retry_policy.dart';
import 'sync_failure_type.dart';

bool shouldRetryOperation(
  SyncFailureType type,
  int retryCount,
  RetryPolicy policy,
) {
  if (type == SyncFailureType.conflict) return false;

  return retryCount < policy.maxRetries;
}

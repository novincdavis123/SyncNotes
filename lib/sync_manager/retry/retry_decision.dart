import 'retry_policy.dart';
import 'sync_failure_type.dart';

bool shouldRetryOperation(
  SyncFailureType type,
  int retryCount,
  RetryPolicy policy,
) {
  // ❌ Never retry conflicts (user resolves manually)
  if (type == SyncFailureType.conflict) {
    return false;
  }

  // ❌ Hard stop: global retry limit
  if (retryCount >= policy.maxRetries) {
    return false;
  }

  switch (type) {
    case SyncFailureType.network:
      return true;

    case SyncFailureType.server:
      return retryCount < 3;

    case SyncFailureType.timeout:
      return retryCount < policy.maxRetries;

    case SyncFailureType.validation:
      // ❌ validation errors are permanent (bad data)
      return false;

    case SyncFailureType.unknown:
      return retryCount < 2;

    case SyncFailureType.conflict:
      return false;
  }
}

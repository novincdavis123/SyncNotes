/// ------------------------------------------------------------
/// SyncNotificationType (Step 9)
/// ------------------------------------------------------------
/// Central enum used across Sync UI, Notification Service,
/// Event mapping, and Debug tools.
/// ------------------------------------------------------------

enum SyncNotificationType {
  started,
  completed,
  empty,
  error,
  success,
  retryScheduled,
  permanentFailure,
  conflictDetected,
  operationSuccess,
  operationStarted,
}

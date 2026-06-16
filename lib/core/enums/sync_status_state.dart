/// Represents the current runtime state of the sync engine.
///
/// Used by:
/// - SyncEngine
/// - SyncStatusService
/// - Presentation layer
/// - Sync status indicator widget
enum SyncStatusState {
  /// No sync activity.
  idle,

  /// Sync queue is currently being processed.
  syncing,

  /// Device has no network connection.
  offline,

  /// Sync completed successfully.
  success,

  /// Sync encountered an unexpected error.
  error,
}

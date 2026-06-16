/// ------------------------------------------------------------
/// SyncNotificationModel (Step 9)
/// ------------------------------------------------------------
/// Lightweight UI-friendly model for representing sync events
/// in notifications, banners, or debug overlays.
/// ------------------------------------------------------------

enum SyncNotificationType {
  started,
  completed,
  empty,
  error,
  success,
  retry,
  failure,
  conflict,
}

class SyncNotificationModel {
  /// Unique id for tracking notification
  final String id;

  /// Type of notification
  final SyncNotificationType type;

  /// Human-readable message
  final String message;

  /// Optional metadata (debug / UI enhancements)
  final Map<String, dynamic>? meta;

  /// Timestamp of event
  final DateTime timestamp;

  const SyncNotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.meta,
  });

  /// ------------------------------------------------------------
  /// FACTORY HELPERS
  /// ------------------------------------------------------------

  factory SyncNotificationModel.started() {
    return SyncNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: SyncNotificationType.started,
      message: "Sync started",
      timestamp: DateTime.now().toUtc(),
    );
  }

  factory SyncNotificationModel.completed() {
    return SyncNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: SyncNotificationType.completed,
      message: "Sync completed successfully",
      timestamp: DateTime.now().toUtc(),
    );
  }

  factory SyncNotificationModel.empty() {
    return SyncNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: SyncNotificationType.empty,
      message: "Nothing to sync",
      timestamp: DateTime.now().toUtc(),
    );
  }

  factory SyncNotificationModel.error(String message) {
    return SyncNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: SyncNotificationType.error,
      message: message,
      timestamp: DateTime.now().toUtc(),
    );
  }

  factory SyncNotificationModel.success(String message) {
    return SyncNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: SyncNotificationType.success,
      message: message,
      timestamp: DateTime.now().toUtc(),
    );
  }

  factory SyncNotificationModel.retry({
    required int attempt,
    required Duration delay,
  }) {
    return SyncNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: SyncNotificationType.retry,
      message: "Retry attempt $attempt in ${delay.inSeconds}s",
      timestamp: DateTime.now().toUtc(),
      meta: {"attempt": attempt, "delay": delay.inSeconds},
    );
  }

  factory SyncNotificationModel.failure(String message) {
    return SyncNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: SyncNotificationType.failure,
      message: message,
      timestamp: DateTime.now().toUtc(),
    );
  }

  factory SyncNotificationModel.conflict(String noteId) {
    return SyncNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: SyncNotificationType.conflict,
      message: "Conflict detected for note $noteId",
      timestamp: DateTime.now().toUtc(),
      meta: {"noteId": noteId},
    );
  }

  /// ------------------------------------------------------------
  /// COPY WITH
  /// ------------------------------------------------------------

  SyncNotificationModel copyWith({
    String? id,
    SyncNotificationType? type,
    String? message,
    DateTime? timestamp,
    Map<String, dynamic>? meta,
  }) {
    return SyncNotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      meta: meta ?? this.meta,
    );
  }

  /// ------------------------------------------------------------
  /// TO STRING
  /// ------------------------------------------------------------

  @override
  String toString() {
    return "SyncNotificationModel(type: $type, message: $message)";
  }
}

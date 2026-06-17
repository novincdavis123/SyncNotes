import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/features/conflict/data/models/conflict_model.dart';

class ConflictDetector {
  const ConflictDetector();

  ConflictModel? detect({
    required String noteId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) {
    AppLogger.log("🟡 Conflict check started for: $noteId");

    final localDeleted = localData['isDeleted'] as bool? ?? false;
    final remoteDeleted = remoteData['isDeleted'] as bool? ?? false;

    // ❌ NEVER conflict deleted notes
    if (localDeleted || remoteDeleted) {
      AppLogger.log("🗑️ Skipping conflict (deleted state)");
      return null;
    }

    final localUpdatedAt = _parseDate(localData['updatedAt']);
    final remoteUpdatedAt = _parseDate(remoteData['updatedAt']);

    if (localUpdatedAt == null || remoteUpdatedAt == null) {
      AppLogger.log("⚠️ Missing timestamps → skip conflict");
      return null;
    }

    AppLogger.log("📍 Local updatedAt: $localUpdatedAt");
    AppLogger.log("📍 Remote updatedAt: $remoteUpdatedAt");

    // ❌ If same timestamp → no conflict
    if (localUpdatedAt.isAtSameMomentAs(remoteUpdatedAt)) {
      AppLogger.log("🟢 Same timestamp → no conflict");
      return null;
    }

    final localTitle = (localData['title'] ?? '').toString();
    final remoteTitle = (remoteData['title'] ?? '').toString();

    final localBody = (localData['body'] ?? '').toString();
    final remoteBody = (remoteData['body'] ?? '').toString();

    final contentChanged = localTitle != remoteTitle || localBody != remoteBody;

    if (!contentChanged) {
      AppLogger.log("🟢 No real content change → skip conflict");
      return null;
    }

    AppLogger.log("🔴 CONFLICT DETECTED: $noteId");

    return ConflictModel(
      noteId: noteId,
      localData: localData,
      remoteData: remoteData,
      detectedAt: DateTime.now(),
    );
  }

  bool hasConflict({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) {
    final localDeleted = localData['isDeleted'] as bool? ?? false;
    final remoteDeleted = remoteData['isDeleted'] as bool? ?? false;

    if (localDeleted || remoteDeleted) {
      return false;
    }

    final localUpdatedAt = _parseDate(localData['updatedAt']);
    final remoteUpdatedAt = _parseDate(remoteData['updatedAt']);

    if (localUpdatedAt == null || remoteUpdatedAt == null) {
      return false;
    }

    final sameTime = localUpdatedAt.isAtSameMomentAs(remoteUpdatedAt);

    final contentChanged =
        (localData['title'] ?? '') != (remoteData['title'] ?? '') ||
        (localData['body'] ?? '') != (remoteData['body'] ?? '');

    return !sameTime && contentChanged;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

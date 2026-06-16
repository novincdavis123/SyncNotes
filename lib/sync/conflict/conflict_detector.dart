import 'package:syncnotes/sync/conflict/conflict_model.dart';

/// ============================================================
/// STEP 7 - CONFLICT DETECTOR
///
/// Determines whether a local note and a remote note
/// have been modified independently and therefore
/// require conflict resolution.
/// ============================================================

class ConflictDetector {
  const ConflictDetector();

  /// Returns a [ConflictModel] if a conflict exists.
  /// Returns null if there is no conflict.
  ConflictModel? detect({
    required String noteId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) {
    final localUpdatedAt = _parseDate(localData['updatedAt']);
    final remoteUpdatedAt = _parseDate(remoteData['updatedAt']);

    if (localUpdatedAt == null || remoteUpdatedAt == null) {
      return null;
    }

    final localModified = localData['isModified'] as bool? ?? true;

    final remoteModified = remoteData['isModified'] as bool? ?? true;

    final hasConflict =
        localModified && remoteModified && localUpdatedAt != remoteUpdatedAt;

    if (!hasConflict) {
      return null;
    }

    return ConflictModel(
      noteId: noteId,
      localData: localData,
      remoteData: remoteData,
      detectedAt: DateTime.now(),
    );
  }

  /// Simple boolean helper.
  bool hasConflict({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) {
    final localUpdatedAt = _parseDate(localData['updatedAt']);
    final remoteUpdatedAt = _parseDate(remoteData['updatedAt']);

    if (localUpdatedAt == null || remoteUpdatedAt == null) {
      return false;
    }

    final localModified = localData['isModified'] as bool? ?? true;

    final remoteModified = remoteData['isModified'] as bool? ?? true;

    return localModified && remoteModified && localUpdatedAt != remoteUpdatedAt;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}

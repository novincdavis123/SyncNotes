import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/features/notes/data/models/note_model.dart';

enum ConflictResolutionType { none, localWins, serverWins, merged }

class ConflictModel {
  /// Unique note id
  final String noteId;

  /// Local version
  final Map<String, dynamic> localData;

  /// Server version
  final Map<String, dynamic> remoteData;

  /// Detection time
  final DateTime detectedAt;

  /// Whether conflict is resolved
  final bool resolved;

  /// 🔥 NEW: resolution type (IMPORTANT FIX)
  final ConflictResolutionType resolutionType;

  const ConflictModel({
    required this.noteId,
    required this.localData,
    required this.remoteData,
    required this.detectedAt,
    this.resolved = false,
    this.resolutionType = ConflictResolutionType.none,
  });

  // ==========================================================
  // LOCAL NOTE
  // ==========================================================

  NoteModel get localNote {
    return NoteModel(
      id: noteId,
      title: localData["title"]?.toString() ?? "",
      body: localData["body"]?.toString() ?? "",
      createdAt:
          DateTime.tryParse(localData["createdAt"]?.toString() ?? "") ??
          detectedAt,
      lastModifiedAt:
          DateTime.tryParse(localData["updatedAt"]?.toString() ?? "") ??
          detectedAt,
      syncStatus: SyncStatus.conflict.name,
      isDeleted: false,
    );
  }

  // ==========================================================
  // SERVER NOTE
  // ==========================================================

  NoteModel get serverNote {
    return NoteModel(
      id: noteId,
      title: remoteData["title"]?.toString() ?? "",
      body: remoteData["body"]?.toString() ?? "",
      createdAt:
          DateTime.tryParse(remoteData["createdAt"]?.toString() ?? "") ??
          detectedAt,
      lastModifiedAt:
          DateTime.tryParse(remoteData["updatedAt"]?.toString() ?? "") ??
          detectedAt,
      syncStatus: SyncStatus.conflict.name,
      isDeleted: false,
    );
  }

  // ==========================================================
  // HELPERS (IMPORTANT FOR SYNC ENGINE)
  // ==========================================================

  bool get isResolved =>
      resolved || resolutionType != ConflictResolutionType.none;

  bool get isLocalWinner => resolutionType == ConflictResolutionType.localWins;

  bool get isServerWinner =>
      resolutionType == ConflictResolutionType.serverWins;

  // ==========================================================
  // COPY WITH
  // ==========================================================

  ConflictModel copyWith({
    String? noteId,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    DateTime? detectedAt,
    bool? resolved,
    ConflictResolutionType? resolutionType,
  }) {
    return ConflictModel(
      noteId: noteId ?? this.noteId,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      detectedAt: detectedAt ?? this.detectedAt,
      resolved: resolved ?? this.resolved,
      resolutionType: resolutionType ?? this.resolutionType,
    );
  }

  // ==========================================================
  // SERIALIZATION (🔥 FIXED FOR ENUM SAFETY)
  // ==========================================================

  Map<String, dynamic> toJson() {
    return {
      "noteId": noteId,
      "localData": localData,
      "remoteData": remoteData,
      "detectedAt": detectedAt.toIso8601String(),
      "resolved": resolved,
      "resolutionType": resolutionType.name,
    };
  }

  factory ConflictModel.fromJson(Map<String, dynamic> json) {
    return ConflictModel(
      noteId: json["noteId"] as String,
      localData: Map<String, dynamic>.from(json["localData"] as Map),
      remoteData: Map<String, dynamic>.from(json["remoteData"] as Map),
      detectedAt: DateTime.parse(json["detectedAt"] as String),
      resolved: json["resolved"] as bool? ?? false,
      resolutionType: ConflictResolutionType.values.firstWhere(
        (e) => e.name == (json["resolutionType"] ?? "none"),
        orElse: () => ConflictResolutionType.none,
      ),
    );
  }

  // ==========================================================
  // DEBUG
  // ==========================================================

  @override
  String toString() {
    return '''
ConflictModel(
  noteId: $noteId,
  resolved: $resolved,
  resolutionType: $resolutionType,
  detectedAt: $detectedAt
)
''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConflictModel &&
          noteId == other.noteId &&
          detectedAt == other.detectedAt;

  @override
  int get hashCode => noteId.hashCode ^ detectedAt.hashCode;
}

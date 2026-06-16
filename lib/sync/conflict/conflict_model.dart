import 'package:syncnotes/core/enums/sync_status.dart';
import 'package:syncnotes/features/notes/data/models/note_model.dart';

class ConflictModel {
  /// Unique note id
  final String noteId;

  /// Local version
  final Map<String, dynamic> localData;

  /// Server version
  final Map<String, dynamic> remoteData;

  /// Detection time
  final DateTime detectedAt;

  /// Resolution state
  final bool resolved;

  const ConflictModel({
    required this.noteId,
    required this.localData,
    required this.remoteData,
    required this.detectedAt,
    this.resolved = false,
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

  ConflictModel copyWith({
    String? noteId,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    DateTime? detectedAt,
    bool? resolved,
  }) {
    return ConflictModel(
      noteId: noteId ?? this.noteId,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      detectedAt: detectedAt ?? this.detectedAt,
      resolved: resolved ?? this.resolved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "noteId": noteId,
      "localData": localData,
      "remoteData": remoteData,
      "detectedAt": detectedAt.toIso8601String(),
      "resolved": resolved,
    };
  }

  factory ConflictModel.fromJson(Map<String, dynamic> json) {
    return ConflictModel(
      noteId: json["noteId"] as String,
      localData: Map<String, dynamic>.from(json["localData"] as Map),
      remoteData: Map<String, dynamic>.from(json["remoteData"] as Map),
      detectedAt: DateTime.parse(json["detectedAt"] as String),
      resolved: json["resolved"] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConflictModel &&
          noteId == other.noteId &&
          detectedAt == other.detectedAt;

  @override
  int get hashCode => noteId.hashCode ^ detectedAt.hashCode;

  @override
  String toString() {
    return '''
ConflictModel(
  noteId: $noteId,
  resolved: $resolved,
  detectedAt: $detectedAt
)
''';
  }
}

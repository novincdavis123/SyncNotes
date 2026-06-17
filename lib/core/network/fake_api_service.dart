import 'dart:async';

import 'package:syncnotes/app/app_logger.dart';
import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

class FakeApiService {
  FakeApiService();

  /// ==========================================================
  /// FAKE SERVER DB
  /// ==========================================================

  final Map<String, Map<String, dynamic>> _serverNotes = {};

  /// ==========================================================
  /// PUSH TO SERVER (SYNC OPERATION)
  /// ==========================================================

  Future<bool> pushToServer(SyncOperationModel operation) async {
    await Future.delayed(const Duration(milliseconds: 500));

    AppLogger.log("🌐 PUSH → server: ${operation.noteId}");

    _serverNotes[operation.noteId] = {
      "id": operation.noteId,
      "title": operation.title ?? "",
      "body": operation.body ?? "",
      "updatedAt": DateTime.now().toUtc().toIso8601String(),
    };

    AppLogger.success("✅ Server updated: ${operation.noteId}");

    return true;
  }

  /// ==========================================================
  /// MANUAL SERVER UPDATE (FOR CONFLICT SIMULATION)
  /// ==========================================================

  void updateServerNote(String id, String title, String body) {
    AppLogger.log("🛠 SERVER MANUAL UPDATE: $id");

    _serverNotes[id] = {
      "id": id,
      "title": title,
      "body": body,
      "updatedAt": DateTime.now().toUtc().toIso8601String(),
    };

    AppLogger.success("🔵 Server forced change applied");
  }

  /// ==========================================================
  /// FETCH SINGLE NOTE
  /// ==========================================================

  Future<Map<String, dynamic>?> fetchNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final data = _serverNotes[noteId];

    if (data == null) {
      AppLogger.log("⚠️ Server note not found: $noteId");
      return null;
    }

    return Map<String, dynamic>.from(data);
  }

  /// ==========================================================
  /// FETCH ALL NOTES
  /// ==========================================================

  Future<List<Map<String, dynamic>>> fetchAllNotes() async {
    await Future.delayed(const Duration(milliseconds: 300));

    AppLogger.log("⬇️ Fetching all server notes: ${_serverNotes.length}");

    return _serverNotes.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// ==========================================================
  /// DELETE NOTE
  /// ==========================================================

  Future<bool> deleteNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final removed = _serverNotes.remove(noteId);

    if (removed != null) {
      AppLogger.log("🗑️ Server deleted: $noteId");
    }

    return true;
  }

  /// ==========================================================
  /// UPSERT SERVER NOTE (USED BY CONFLICT RESOLUTION)
  /// ==========================================================

  Future<void> saveServerNote({
    required String noteId,
    required String title,
    required String body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _serverNotes[noteId] = {
      "id": noteId,
      "title": title,
      "body": body,
      "updatedAt": DateTime.now().toUtc().toIso8601String(),
    };

    AppLogger.success("💾 Conflict resolved → server updated: $noteId");
  }

  /// ==========================================================
  /// TOUCH NOTE (ONLY TIMESTAMP CHANGE → GREAT FOR CONFLICT TEST)
  /// ==========================================================

  Future<void> touchServerNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_serverNotes.containsKey(noteId)) {
      _serverNotes[noteId]!["updatedAt"] = DateTime.now()
          .toUtc()
          .toIso8601String();

      AppLogger.log("⏱️ Server timestamp updated: $noteId");
    }
  }

  /// ==========================================================
  /// SEED DATA
  /// ==========================================================

  Future<void> seedNote({
    required String noteId,
    required String title,
    required String body,
    DateTime? updatedAt,
  }) async {
    _serverNotes[noteId] = {
      "id": noteId,
      "title": title,
      "body": body,
      "updatedAt": (updatedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };

    AppLogger.log("🌱 Seeded server note: $noteId");
  }

  /// ==========================================================
  /// CHECK EXISTENCE
  /// ==========================================================

  bool exists(String noteId) => _serverNotes.containsKey(noteId);

  /// ==========================================================
  /// CLEAR SERVER
  /// ==========================================================

  Future<void> clearServer() async {
    _serverNotes.clear();
    AppLogger.log("🧹 Server cleared");
  }

  /// ==========================================================
  /// DEBUG PRINT
  /// ==========================================================

  void printServerDatabase() {
    AppLogger.log("========== SERVER DB ==========");

    for (final entry in _serverNotes.entries) {
      AppLogger.log(entry.value.toString());
    }

    AppLogger.log("===============================");
  }
}

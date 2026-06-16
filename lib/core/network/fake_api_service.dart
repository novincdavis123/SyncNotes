import 'dart:async';

import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

class FakeApiService {
  FakeApiService();

  /// ==========================================================
  /// Fake Remote Database
  /// ==========================================================

  final Map<String, Map<String, dynamic>> _serverNotes = {};

  /// ==========================================================
  /// PUSH TO SERVER
  /// ==========================================================

  Future<bool> pushToServer(SyncOperationModel operation) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final existing = _serverNotes[operation.noteId];

    _serverNotes[operation.noteId] = {
      "id": operation.noteId,
      "title": existing?["title"] ?? "Note ${operation.noteId}",
      "body": existing?["body"] ?? "",
      "updatedAt": DateTime.now().toUtc().toIso8601String(),
    };

    return true;
  }

  /// ==========================================================
  /// FETCH SINGLE NOTE
  /// ==========================================================

  Future<Map<String, dynamic>?> fetchNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_serverNotes.containsKey(noteId)) {
      return null;
    }

    return Map<String, dynamic>.from(_serverNotes[noteId]!);
  }

  /// ==========================================================
  /// FETCH ALL NOTES
  /// ==========================================================

  Future<List<Map<String, dynamic>>> fetchAllNotes() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _serverNotes.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// ==========================================================
  /// DELETE NOTE
  /// ==========================================================

  Future<bool> deleteNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _serverNotes.remove(noteId);

    return true;
  }

  /// ==========================================================
  /// UPSERT SERVER NOTE
  /// Used by ConflictResolutionService
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
  }

  /// ==========================================================
  /// UPDATE SERVER NOTE TIMESTAMP
  /// Used to simulate conflicts
  /// ==========================================================

  Future<void> touchServerNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_serverNotes.containsKey(noteId)) {
      _serverNotes[noteId]!["updatedAt"] = DateTime.now()
          .toUtc()
          .toIso8601String();
    }
  }

  /// ==========================================================
  /// SEED TEST DATA
  /// Useful during development
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
  }

  /// ==========================================================
  /// CHECK EXISTENCE
  /// ==========================================================

  bool exists(String noteId) {
    return _serverNotes.containsKey(noteId);
  }

  /// ==========================================================
  /// CLEAR SERVER
  /// Useful for testing
  /// ==========================================================

  Future<void> clearServer() async {
    _serverNotes.clear();
  }

  /// ==========================================================
  /// DEBUG PRINT
  /// ==========================================================

  void printServerDatabase() {
    print("========== SERVER ==========");

    for (final entry in _serverNotes.entries) {
      print(entry.value);
    }

    print("============================");
  }
}

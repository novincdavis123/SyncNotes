import 'dart:math';

import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

class FakeApiService {
  final Random _random = Random();

  /// Simulated remote database
  final Map<String, Map<String, dynamic>> _serverNotes = {};

  // ==========================================================
  // PUSH TO SERVER
  // ==========================================================

  Future<bool> pushToServer(SyncOperationModel operation) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Simulate 80% success rate
    final success = _random.nextInt(10) < 8;

    if (!success) {
      return false;
    }

    _serverNotes[operation.noteId] = {
      'id': operation.noteId,
      'title': operation.title,
      'body': operation.body,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };

    return true;
  }

  // ==========================================================
  // FETCH SINGLE NOTE
  // ==========================================================

  Future<Map<String, dynamic>?> fetchNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _serverNotes[noteId];
  }

  // ==========================================================
  // SAVE / UPDATE SERVER NOTE
  // (Used by ConflictResolutionService)
  // ==========================================================

  Future<void> saveServerNote({
    required String noteId,
    required String title,
    required String body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _serverNotes[noteId] = {
      'id': noteId,
      'title': title,
      'body': body,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  // ==========================================================
  // SAVE NOTE USING MAP
  // ==========================================================

  Future<void> saveNote(String noteId, Map<String, dynamic> note) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _serverNotes[noteId] = {
      ...note,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  // ==========================================================
  // DELETE NOTE
  // ==========================================================

  Future<void> deleteNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _serverNotes.remove(noteId);
  }

  // ==========================================================
  // FETCH ALL NOTES
  // ==========================================================

  Future<List<Map<String, dynamic>>> fetchAllNotes() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _serverNotes.values.toList();
  }

  // ==========================================================
  // CHECK EXISTENCE
  // ==========================================================

  bool exists(String noteId) {
    return _serverNotes.containsKey(noteId);
  }

  // ==========================================================
  // CLEAR SERVER
  // ==========================================================

  void clear() {
    _serverNotes.clear();
  }
}

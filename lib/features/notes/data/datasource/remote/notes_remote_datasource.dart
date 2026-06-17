abstract class NotesRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchNotes();

  Future<Map<String, dynamic>?> fetchNote(String id);

  Future<void> createNote(Map<String, dynamic> note);

  Future<void> updateNote(String id, Map<String, dynamic> note);

  Future<void> deleteNote(String id);
}

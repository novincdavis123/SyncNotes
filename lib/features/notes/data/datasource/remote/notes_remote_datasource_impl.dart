import 'package:syncnotes/core/network/fake_api_service.dart';
import 'package:syncnotes/features/notes/data/datasource/remote/notes_remote_datasource.dart';

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final FakeApiService api;

  NotesRemoteDataSourceImpl(this.api);

  @override
  Future<List<Map<String, dynamic>>> fetchNotes() {
    return api.fetchAllNotes();
  }

  @override
  Future<Map<String, dynamic>?> fetchNote(String id) {
    return api.fetchNote(id);
  }

  @override
  Future<void> createNote(Map<String, dynamic> note) async {
    await api.saveServerNote(
      noteId: note['id'],
      title: note['title'] ?? '',
      body: note['body'] ?? '',
    );
  }

  @override
  Future<void> updateNote(String id, Map<String, dynamic> note) async {
    await api.saveServerNote(
      noteId: id,
      title: note['title'] ?? '',
      body: note['body'] ?? '',
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    await api.deleteNote(id);
  }
}

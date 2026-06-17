import '../repositories/notes_repository.dart';

class DeleteNoteUseCase {
  final NotesRepository repository;

  const DeleteNoteUseCase(this.repository);

  Future<void> call(String id) async {
    // 1. Delete note locally
    await repository.deleteNote(id);

    // 2. IMPORTANT: remove pending sync operations
    await repository.removePendingOperationsForNote(id);

    // 3. Mark as dirty so sync engine can re-evaluate state safely
    await repository.markSyncDirty();
  }
}

import '../repositories/notes_repository.dart';

class DeleteNoteUseCase {
  final NotesRepository repository;

  const DeleteNoteUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteNote(id);
  }
}

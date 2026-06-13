import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class SaveNoteUseCase {
  final NotesRepository repository;

  const SaveNoteUseCase(this.repository);

  Future<void> call(NoteEntity note) {
    return repository.saveNote(note);
  }
}

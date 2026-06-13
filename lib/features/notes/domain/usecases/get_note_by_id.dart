import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class GetNoteByIdUseCase {
  final NotesRepository repository;

  const GetNoteByIdUseCase(this.repository);

  Future<NoteEntity?> call(String id) {
    return repository.getNoteById(id);
  }
}

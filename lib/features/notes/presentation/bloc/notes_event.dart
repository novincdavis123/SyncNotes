import 'package:equatable/equatable.dart';
import '../../domain/entities/note_entity.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

// =========================================================
// LOAD
// =========================================================
final class LoadNotesEvent extends NotesEvent {
  const LoadNotesEvent();
}

// =========================================================
// REFRESH
// =========================================================
final class RefreshNotesEvent extends NotesEvent {
  const RefreshNotesEvent();
}

// =========================================================
// CREATE NOTE
// =========================================================
final class CreateNoteEvent extends NotesEvent {
  final NoteEntity note;

  const CreateNoteEvent({required this.note});

  @override
  List<Object?> get props => [note];
}

// =========================================================
// UPDATE NOTE
// =========================================================
final class UpdateNoteEvent extends NotesEvent {
  final NoteEntity note;

  const UpdateNoteEvent({required this.note});

  @override
  List<Object?> get props => [note];
}

// =========================================================
// DELETE NOTE
// =========================================================
final class DeleteNoteEvent extends NotesEvent {
  final String id;

  const DeleteNoteEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

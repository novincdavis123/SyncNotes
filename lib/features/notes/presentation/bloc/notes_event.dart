import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadNotesEvent extends NotesEvent {
  const LoadNotesEvent();
}

final class RefreshNotesEvent extends NotesEvent {
  const RefreshNotesEvent();
}

final class SaveNoteEvent extends NotesEvent {
  final NoteEntity note;

  const SaveNoteEvent({required this.note});

  @override
  List<Object?> get props => [note];
}

final class DeleteNoteEvent extends NotesEvent {
  final String id;

  const DeleteNoteEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

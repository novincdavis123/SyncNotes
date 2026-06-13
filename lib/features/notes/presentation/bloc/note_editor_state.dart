import 'package:equatable/equatable.dart';

sealed class NoteEditorState extends Equatable {
  const NoteEditorState();

  @override
  List<Object?> get props => [];
}

final class NoteEditorInitial extends NoteEditorState {
  const NoteEditorInitial();
}

final class NoteEditorSaving extends NoteEditorState {
  const NoteEditorSaving();
}

final class NoteEditorSaved extends NoteEditorState {
  const NoteEditorSaved();
}

final class NoteEditorError extends NoteEditorState {
  final String message;

  const NoteEditorError({required this.message});

  @override
  List<Object?> get props => [message];
}

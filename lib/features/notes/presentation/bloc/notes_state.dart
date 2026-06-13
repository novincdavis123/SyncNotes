import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

final class NotesInitial extends NotesState {
  const NotesInitial();
}

final class NotesLoading extends NotesState {
  const NotesLoading();
}

final class NotesLoaded extends NotesState {
  final List<NoteEntity> notes;

  final bool isRefreshing;

  const NotesLoaded({required this.notes, this.isRefreshing = false});

  NotesLoaded copyWith({List<NoteEntity>? notes, bool? isRefreshing}) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [notes, isRefreshing];
}

final class NotesError extends NotesState {
  final String message;

  final List<NoteEntity> previousNotes;

  const NotesError({required this.message, this.previousNotes = const []});

  @override
  List<Object?> get props => [message, previousNotes];
}

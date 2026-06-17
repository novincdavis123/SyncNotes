import 'package:equatable/equatable.dart';
import '../../domain/entities/note_entity.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

// =========================================================
// INITIAL
// =========================================================
final class NotesInitial extends NotesState {
  const NotesInitial();
}

// =========================================================
// LOADING
// =========================================================
final class NotesLoading extends NotesState {
  const NotesLoading();
}

// =========================================================
// LOADED (MAIN STATE)
// =========================================================
final class NotesLoaded extends NotesState {
  final List<NoteEntity> notes;

  // UI flags
  final bool isRefreshing;
  final bool isSaving;
  final bool isDeleting;

  // 🔥 NEW: prevents stale UI after sync/conflict resolution
  final bool isSyncing;

  const NotesLoaded({
    required this.notes,
    this.isRefreshing = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.isSyncing = false,
  });

  NotesLoaded copyWith({
    List<NoteEntity>? notes,
    bool? isRefreshing,
    bool? isSaving,
    bool? isDeleting,
    bool? isSyncing,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [
    notes,
    isRefreshing,
    isSaving,
    isDeleting,
    isSyncing,
  ];
}

// =========================================================
// ERROR
// =========================================================
final class NotesError extends NotesState {
  final String message;
  final List<NoteEntity> previousNotes;

  const NotesError({required this.message, this.previousNotes = const []});

  @override
  List<Object?> get props => [message, previousNotes];
}

// =========================================================
// CONFLICT STATE
// =========================================================
final class NotesConflict extends NotesState {
  final NoteEntity local;
  final NoteEntity remote;

  const NotesConflict({required this.local, required this.remote});

  @override
  List<Object?> get props => [local, remote];
}

// =========================================================
// 🔥 SYNC SUCCESS STATE (IMPORTANT ADDITION)
// =========================================================
final class NotesSyncSuccess extends NotesState {
  final List<NoteEntity> notes;

  const NotesSyncSuccess({required this.notes});

  @override
  List<Object?> get props => [notes];
}

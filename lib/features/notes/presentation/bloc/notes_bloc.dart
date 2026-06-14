import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncnotes/app/app_logger.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/save_note.dart';

import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUseCase getNotesUseCase;

  final SaveNoteUseCase saveNoteUseCase;

  final DeleteNoteUseCase deleteNoteUseCase;

  NotesBloc({
    required this.getNotesUseCase,
    required this.saveNoteUseCase,
    required this.deleteNoteUseCase,
  }) : super(const NotesInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);

    on<RefreshNotesEvent>(_onRefreshNotes);

    on<SaveNoteEvent>(_onSaveNote);

    on<DeleteNoteEvent>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());

    await _loadNotes(emit);
  }

  Future<void> _onRefreshNotes(
    RefreshNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    final previousNotes = switch (state) {
      NotesLoaded(:final notes) => notes,
      NotesError(:final previousNotes) => previousNotes,
      _ => <NoteEntity>[],
    };

    emit(NotesLoaded(notes: previousNotes, isRefreshing: true));

    await _loadNotes(emit);
  }

  Future<void> _onSaveNote(
    SaveNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      AppLogger.log("Save event triggered: ${event.note.id}");
      await saveNoteUseCase(event.note);
      AppLogger.success("Save usecase completed");
      await _loadNotes(emit);
    } catch (e) {
      emit(NotesError(message: e.toString(), previousNotes: _currentNotes));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await deleteNoteUseCase(event.id);

      await _loadNotes(emit);
    } catch (e) {
      emit(NotesError(message: e.toString(), previousNotes: _currentNotes));
    }
  }

  Future<void> _loadNotes(Emitter<NotesState> emit) async {
    try {
      final notes = await getNotesUseCase();

      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: e.toString(), previousNotes: _currentNotes));
    }
  }

  List<NoteEntity> get _currentNotes {
    return switch (state) {
      NotesLoaded(:final notes) => notes,
      NotesError(:final previousNotes) => previousNotes,
      _ => [],
    };
  }
}

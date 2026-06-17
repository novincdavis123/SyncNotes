import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/save_note.dart';

import 'notes_event.dart';
import 'notes_state.dart';

import 'package:syncnotes/features/sync/events/sync_event_bus.dart';
import 'package:syncnotes/features/sync/events/sync_event.dart';
import 'package:syncnotes/di/injection.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final SaveNoteUseCase saveNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  late final StreamSubscription _syncSubscription;

  NotesBloc({
    required this.getNotesUseCase,
    required this.saveNoteUseCase,
    required this.deleteNoteUseCase,
  }) : super(const NotesInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<RefreshNotesEvent>(_onRefreshNotes);

    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);

    // ======================================================
    // 🔥 AUTO SYNC LISTENER (IMPORTANT FIX)
    // ======================================================
    final eventBus = sl<SyncEventBus>();

    _syncSubscription = eventBus.stream.listen((event) {
      if (event.type == SyncEventType.syncRefresh ||
          event.type == SyncEventType.operationSuccess ||
          event.type == SyncEventType.completed) {
        add(const RefreshNotesEvent());
      }
    });
  }

  // =========================================================
  // LOAD
  // =========================================================

  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());
    await _loadNotes(emit);
  }

  // =========================================================
  // REFRESH
  // =========================================================

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

  // =========================================================
  // CREATE
  // =========================================================

  Future<void> _onCreateNote(
    CreateNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await saveNoteUseCase(event.note);
      await _loadNotes(emit);
    } catch (e) {
      emit(NotesError(message: e.toString(), previousNotes: _currentNotes));
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await saveNoteUseCase(event.note);
      await _loadNotes(emit);
    } catch (e) {
      emit(NotesError(message: e.toString(), previousNotes: _currentNotes));
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

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

  // =========================================================
  // CORE LOADER
  // =========================================================

  Future<void> _loadNotes(Emitter<NotesState> emit) async {
    final notes = await getNotesUseCase();
    emit(NotesLoaded(notes: notes));
  }

  List<NoteEntity> get _currentNotes {
    return switch (state) {
      NotesLoaded(:final notes) => notes,
      NotesError(:final previousNotes) => previousNotes,
      _ => [],
    };
  }

  @override
  Future<void> close() {
    _syncSubscription.cancel();
    return super.close();
  }
}

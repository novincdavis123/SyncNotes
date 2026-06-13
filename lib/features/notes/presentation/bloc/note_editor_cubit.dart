import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncnotes/features/notes/domain/entities/note_entity.dart';
import 'package:syncnotes/features/notes/domain/usecases/save_note.dart';

import 'note_editor_state.dart';

class NoteEditorCubit extends Cubit<NoteEditorState> {
  final SaveNoteUseCase saveNoteUseCase;

  NoteEditorCubit({required this.saveNoteUseCase})
    : super(const NoteEditorInitial());

  Future<void> save(NoteEntity note) async {
    emit(const NoteEditorSaving());

    try {
      await saveNoteUseCase(note);

      emit(const NoteEditorSaved());
    } catch (e) {
      emit(NoteEditorError(message: e.toString()));
    }
  }
}

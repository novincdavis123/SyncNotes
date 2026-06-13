import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncnotes/features/notes/domain/usecases/delete_note.dart';

import 'delete_note_state.dart';

class DeleteNoteCubit extends Cubit<DeleteNoteState> {
  final DeleteNoteUseCase deleteNoteUseCase;

  DeleteNoteCubit({required this.deleteNoteUseCase})
    : super(const DeleteNoteInitial());

  Future<void> delete(String id) async {
    emit(const DeleteNoteLoading());

    try {
      await deleteNoteUseCase(id);

      emit(const DeleteNoteSuccess());
    } catch (e) {
      emit(DeleteNoteError(message: e.toString()));
    }
  }
}

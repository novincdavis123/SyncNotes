import 'package:equatable/equatable.dart';

sealed class DeleteNoteState extends Equatable {
  const DeleteNoteState();

  @override
  List<Object?> get props => [];
}

final class DeleteNoteInitial extends DeleteNoteState {
  const DeleteNoteInitial();
}

final class DeleteNoteLoading extends DeleteNoteState {
  const DeleteNoteLoading();
}

final class DeleteNoteSuccess extends DeleteNoteState {
  const DeleteNoteSuccess();
}

final class DeleteNoteError extends DeleteNoteState {
  final String message;

  const DeleteNoteError({required this.message});

  @override
  List<Object?> get props => [message];
}

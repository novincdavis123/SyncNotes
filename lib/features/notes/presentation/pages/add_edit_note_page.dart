import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums/sync_status.dart';
import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';

class AddEditNotePage extends StatefulWidget {
  final NoteEntity? note;

  const AddEditNotePage({super.key, this.note});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final note = widget.note;

    if (note != null) {
      _titleController.text = note.title;
      _bodyController.text = note.body;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final now = DateTime.now().toUtc();

    final note =
        widget.note?.copyWith(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          lastModifiedAt: now,
          syncStatus: SyncStatus.pending,
        ) ??
        NoteEntity(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          createdAt: now,
          lastModifiedAt: now,
          lastSyncedAt: null,
          isDeleted: false,
          syncStatus: SyncStatus.pending,
        );

    context.read<NotesBloc>().add(SaveNoteEvent(note: note));

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Note" : "New Note"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Text(
                isEdit ? "Update your note" : "Create a new note",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // TITLE FIELD
                    _buildField(
                      controller: _titleController,
                      label: "Title",
                      hint: "Enter note title",
                      maxLines: 1,
                    ),

                    const SizedBox(height: 16),

                    // BODY FIELD
                    _buildField(
                      controller: _bodyController,
                      label: "Content",
                      hint: "Write your note here...",
                      maxLines: 8,
                    ),

                    const SizedBox(height: 28),

                    // SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: FilledButton(
                          onPressed: _isSaving ? null : _save,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isEdit ? "Update Note" : "Save Note",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label is required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
    );
  }
}

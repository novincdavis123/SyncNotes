import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:syncnotes/features/notes/presentation/widgets/empty_notes.dart';
import 'package:syncnotes/sync/presentation/widgets/sync_status_indicator.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';

import '../widgets/note_card.dart';
import 'add_edit_note_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  void _openEditor(BuildContext context, note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditNotePage(note: note)),
    );
  }

  void _deleteNote(BuildContext context, String id) {
    context.read<NotesBloc>().add(DeleteNoteEvent(id: id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync Notes"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NotesBloc>().add(const RefreshNotesEvent());
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditNotePage()),
          );
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SyncStatusIndicator(),
            ),

            const Divider(height: 1),

            Expanded(
              child: BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  if (state is NotesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NotesLoaded) {
                    if (state.notes.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<NotesBloc>().add(
                            const RefreshNotesEvent(),
                          );
                        },
                        child: const SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 600,
                            child: EmptyNotesWidget(),
                          ),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            context.read<NotesBloc>().add(
                              const RefreshNotesEvent(),
                            );
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: state.notes.length,
                            itemBuilder: (_, index) {
                              final note = state.notes[index];

                              return Dismissible(
                                key: ValueKey(note.id),

                                direction: DismissDirection.endToStart,

                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),

                                onDismissed: (_) {
                                  _deleteNote(context, note.id);
                                },

                                child: NoteCard(
                                  note: note,
                                  onEdit: () => _openEditor(context, note),
                                ),
                              );
                            },
                          ),
                        ),

                        if (state.isRefreshing)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(),
                          ),
                      ],
                    );
                  }

                  if (state is NotesError) {
                    if (state.previousNotes.isNotEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<NotesBloc>().add(
                            const RefreshNotesEvent(),
                          );
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.previousNotes.length,
                          itemBuilder: (_, index) {
                            final note = state.previousNotes[index];

                            return NoteCard(
                              note: note,
                              onEdit: () => _openEditor(context, note),
                              onDelete: () => _deleteNote(context, note.id),
                            );
                          },
                        ),
                      );
                    }

                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64),
                            const SizedBox(height: 16),
                            Text(state.message, textAlign: TextAlign.center),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text("Retry"),
                              onPressed: () {
                                context.read<NotesBloc>().add(
                                  const RefreshNotesEvent(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

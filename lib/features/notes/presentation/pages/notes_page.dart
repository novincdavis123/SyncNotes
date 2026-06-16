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
            // ======================================================
            // Sync Status
            // ======================================================
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SyncStatusIndicator(),
            ),

            const Divider(height: 1),

            // ======================================================
            // Notes
            // ======================================================
            Expanded(
              child: BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  switch (state) {
                    case NotesLoading():
                      return const Center(child: CircularProgressIndicator());

                    case NotesLoaded(:final notes, :final isRefreshing):
                      if (notes.isEmpty) {
                        return const EmptyNotesWidget();
                      }

                      return Stack(
                        children: [
                          RefreshIndicator(
                            onRefresh: () async {
                              context.read<NotesBloc>().add(
                                const RefreshNotesEvent(),
                              );
                            },
                            child: AnimatedListView(notes: notes),
                          ),

                          if (isRefreshing)
                            const Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: LinearProgressIndicator(),
                            ),
                        ],
                      );

                    case NotesError(:final message, :final previousNotes):
                      if (previousNotes.isNotEmpty) {
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: previousNotes.length,
                          itemBuilder: (_, index) {
                            return NoteCard(note: previousNotes[index]);
                          },
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

                              Text(message, textAlign: TextAlign.center),

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

                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedListView extends StatelessWidget {
  final List notes;

  const AnimatedListView({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: notes.length,
      itemBuilder: (_, index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: NoteCard(note: notes[index]),
        );
      },
    );
  }
}

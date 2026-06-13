import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncnotes/features/notes/presentation/widgets/empty_notes.dart';

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
      appBar: AppBar(title: const Text("Sync Notes")),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          switch (state) {
            case NotesLoading():
              return const Center(child: CircularProgressIndicator());

            case NotesLoaded(:final notes, :final isRefreshing):
              if (notes.isEmpty) {
                return const EmptyNotesWidget();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotesBloc>().add(const RefreshNotesEvent());
                },
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (_, index) {
                        return NoteCard(note: notes[index]);
                      },
                    ),
                    if (isRefreshing) const LinearProgressIndicator(),
                  ],
                ),
              );

            case NotesError(:final message, :final previousNotes):
              if (previousNotes.isNotEmpty) {
                return ListView.builder(
                  itemCount: previousNotes.length,
                  itemBuilder: (_, index) {
                    return NoteCard(note: previousNotes[index]);
                  },
                );
              }

              return Center(child: Text(message));

            default:
              return const SizedBox();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditNotePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Screens/Encadrant/add_note.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';

import 'package:pfa/Utils/snackbar.dart';

class EncadrantNotesPage extends StatefulWidget {
  const EncadrantNotesPage({super.key});

  @override
  State<EncadrantNotesPage> createState() => _EncadrantNotesPageState();
}

class _EncadrantNotesPageState extends State<EncadrantNotesPage> {
  int? _expandedInternshipId;
  // Removed _currentInternshipNotes as NotesLoaded state now carries specific internshipId
  // The _buildNotesSection will directly react to NotesLoaded for the correct ID.

  @override
  void initState() {
    super.initState();
    context.read<EncadrantCubit>().fetchAssignedInternships();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'validé':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'refusé':
        return Colors.red;
      case 'proposé':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _onExpansionChanged(bool expanded, int internshipId) {
    setState(() {
      if (expanded) {
        _expandedInternshipId = internshipId;
        context.read<EncadrantCubit>().fetchNotesForInternship(internshipId);
      } else {
        _expandedInternshipId = null; // Collapse the tile
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Internships Assigned to You',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            BlocConsumer<EncadrantCubit, EncadrantState>(
              listener: (context, state) {
                if (state is EncadrantActionSuccess) {
                  showSuccessSnackBar(context, state.message);
                } else if (state is EncadrantError) {
                  showFailureSnackBar(context, 'Error: ${state.message}');
                }
                // NotesLoaded is now handled within _buildNotesSection's BlocBuilder
              },
              // The main builder should only react to initial loading or loaded states
              buildWhen: (previous, current) =>
                  current is EncadrantLoading ||
                  current is EncadrantLoaded ||
                  current is EncadrantError,
              builder: (context, state) {
                if (state is EncadrantLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is EncadrantLoaded) {
                  if (state.internships.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text(
                          'No internships currently assigned to you.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.internships.length,
                      itemBuilder: (context, index) {
                        final internship = state.internships[index];
                        final bool isCurrentlyExpanded =
                            _expandedInternshipId == internship.stageID;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            key: ValueKey(
                              internship.stageID,
                            ), // Important for ExpansionTile state
                            initiallyExpanded: isCurrentlyExpanded,
                            onExpansionChanged: (expanded) {
                              _onExpansionChanged(expanded, internship.stageID);
                            },
                            title: Text(
                              '${internship.studentFirstName} ${internship.studentLastName}  - ${internship.subjectTitle ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type: ${internship.typeStage}'),

                                Text(
                                  'Status: ${internship.statut}',
                                  style: TextStyle(
                                    color: _getStatusColor(internship.statut),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Show loading indicator specifically for this action
                                BlocBuilder<EncadrantCubit, EncadrantState>(
                                  buildWhen: (previous, current) =>
                                      (current is NoteActionLoading &&
                                          current.targetInternshipId ==
                                              internship.stageID) ||
                                      (previous is NoteActionLoading &&
                                          previous.targetInternshipId ==
                                              internship.stageID &&
                                          current is! NoteActionLoading),
                                  builder: (context, state) {
                                    if (state is NoteActionLoading &&
                                        state.targetInternshipId ==
                                            internship.stageID) {
                                      return const SizedBox(
                                        width:
                                            24, // Allocate space for indicator
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                    return IconButton(
                                      icon: const Icon(
                                        Icons.note_add,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Add Note',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) {
                                            return BlocProvider.value(
                                              value: context
                                                  .read<EncadrantCubit>(),
                                              child: AddNoteDialog(
                                                internshipId:
                                                    internship.stageID,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                // The default ExpansionTile arrow is displayed here.
                                // We keep it for consistency.
                              ],
                            ),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _buildNotesSection(internship.stageID),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is EncadrantError) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'Failed to load internships: ${state.message}',
                      ),
                    ),
                  );
                }
                return const Expanded(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(int internshipId) {
    return BlocBuilder<EncadrantCubit, EncadrantState>(
      // Only rebuild if it's a state related to notes and for this specific internship
      buildWhen: (previous, current) =>
          (current is NotesLoaded && current.internshipId == internshipId) ||
          (current is NoteActionLoading &&
              current.targetInternshipId ==
                  internshipId) || // For loading indicator for notes
          (current is EncadrantError &&
              _expandedInternshipId == internshipId &&
              !(previous
                  is NotesLoaded)), // Show error if it's related to note fetching
      builder: (context, state) {
        if (state is NoteActionLoading &&
            state.targetInternshipId == internshipId) {
          // Show loading indicator only for the specific notes section being loaded/acted upon
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is NotesLoaded && state.internshipId == internshipId) {
          if (state.notes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No notes added for this internship yet.'),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 10),
              ...state.notes.map(
                (note) => Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.contenuNote,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'by ${note.encadrantName ?? 'Unknown'} on ${note.dateNote}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else if (state is EncadrantError &&
            _expandedInternshipId == internshipId) {
          // If the error occurred while trying to fetch notes for this specific expanded internship
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading notes: ${state.message}'),
            ),
          );
        }
        // If it's not the currently expanded internship, or the state is not relevant
        return const SizedBox.shrink();
      },
    );
  }
}

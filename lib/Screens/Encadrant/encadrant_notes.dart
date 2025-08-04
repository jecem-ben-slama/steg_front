import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Screens/Encadrant/add_note.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';
import 'package:pfa/Utils/snackbar.dart'; // Assuming this provides showSuccessSnackBar and showFailureSnackBar
import 'package:pfa/Utils/Consts/style.dart'; // Assuming MyColors is defined here

class EncadrantNotesPage extends StatefulWidget {
  const EncadrantNotesPage({super.key});

  @override
  State<EncadrantNotesPage> createState() => _EncadrantNotesPageState();
}

class _EncadrantNotesPageState extends State<EncadrantNotesPage> {
  int? _expandedInternshipId;

  @override
  void initState() {
    super.initState();
    context.read<EncadrantCubit>().fetchAssignedInternships();
  }

  // Helper function to get status color
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'in progress':
        return Colors.blue.shade700;
      case 'proposed':
        return Colors.orange.shade700;
      case 'refused':
        return Colors.red.shade700;
      case 'finished':
        return Colors.grey.shade700;
      case 'validated':
        return Colors.green.shade700;
      case 'accepted': // Assuming 'accepted' is equivalent to 'validated' for color
        return Colors.green.shade700;
      default:
        return Colors.grey.shade500;
    }
  }

  // Helper function to get status background color for badges
  Color _getStatusBackgroundColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'in progress':
        return Colors.blue.shade100;
      case 'proposed':
        return Colors.orange.shade100;
      case 'refused':
        return Colors.red.shade100;
      case 'finished':
        return Colors.grey.shade200;
      case 'validated':
        return Colors.green.shade100;
      case 'accepted': // Assuming 'accepted' is equivalent to 'validated' for background
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
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
      backgroundColor: MyColors.lightBlue, // Consistent background
      appBar: AppBar(
        backgroundColor: MyColors.lightBlue, // Consistent AppBar color
        foregroundColor: Colors.white,
        elevation: 0, // Flat AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocConsumer<EncadrantCubit, EncadrantState>(
              listener: (context, state) {
                if (state is EncadrantActionSuccess) {
                  showSuccessSnackBar(context, state.message);
                } else if (state is EncadrantError) {
                  showFailureSnackBar(context, 'Error: ${state.message}');
                }
              },
              buildWhen: (previous, current) =>
                  current is EncadrantLoading ||
                  current is EncadrantLoaded ||
                  current is EncadrantError,
              builder: (context, state) {
                if (state is EncadrantLoading) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: MyColors.darkBlue,
                      ), // Use consistent color
                    ),
                  );
                } else if (state is EncadrantLoaded) {
                  if (state.internships.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No internships currently assigned to you.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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

                        // Corrected condition to add notes
                        final bool canAddNotes =
                            internship.statut?.toLowerCase() == 'in progress' ||
                            internship.statut?.toLowerCase() == 'proposed';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 4, // Increased elevation for better depth
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              15,
                            ), // Rounded corners
                          ),
                          child: ExpansionTile(
                            key: ValueKey(internship.stageID),
                            initiallyExpanded: isCurrentlyExpanded,
                            onExpansionChanged: (expanded) {
                              _onExpansionChanged(expanded, internship.stageID);
                            },
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              '${internship.studentFirstName} ${internship.studentLastName}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.darkBlue,
                                  ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Type: ${internship.typeStage}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subject: ${internship.subjectTitle ?? 'Not Assigned'}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontStyle:
                                            internship.subjectTitle == null
                                            ? FontStyle.italic
                                            : null,
                                        color: internship.subjectTitle == null
                                            ? Colors.grey.shade600
                                            : null,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dates: ${internship.dateDebut.year}-${internship.dateDebut.month}-${internship.dateDebut.day} to ${internship.dateFin.year}-${internship.dateFin.month}-${internship.dateFin.day}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusBackgroundColor(
                                        internship.statut,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      internship.statut,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: _getStatusColor(
                                              internship.statut,
                                            ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: BlocBuilder<EncadrantCubit, EncadrantState>(
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
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: MyColors.darkBlue,
                                    ),
                                  );
                                }
                                return IconButton(
                                  icon: Icon(
                                    Icons.note_add,
                                    color: canAddNotes
                                        ? MyColors.darkBlue
                                        : Colors
                                              .grey, // Grey out if notes can't be added
                                  ),
                                  tooltip: canAddNotes
                                      ? 'Add Note'
                                      : 'Notes can only be added for In Progress internships',
                                  onPressed: canAddNotes
                                      ? () {
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
                                        }
                                      : null, // Disable button if notes can't be added
                                );
                              },
                            ),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  0.0,
                                  16.0,
                                  16.0,
                                ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Error loading internships: ${state.message}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<EncadrantCubit>()
                                  .fetchAssignedInternships(),
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Retry',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.darkBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const Expanded(
                  child: Center(
                    child: Text(
                      'No internships to display.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(int internshipId) {
    return BlocBuilder<EncadrantCubit, EncadrantState>(
      buildWhen: (previous, current) =>
          (current is NotesLoaded && current.internshipId == internshipId) ||
          (current is NoteActionLoading &&
              current.targetInternshipId == internshipId) ||
          (current is EncadrantError &&
              _expandedInternshipId == internshipId &&
              !(previous is NotesLoaded)),
      builder: (context, state) {
        if (state is NoteActionLoading &&
            state.targetInternshipId == internshipId) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: MyColors.darkBlue),
            ),
          );
        } else if (state is NotesLoaded && state.internshipId == internshipId) {
          if (state.notes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No notes added for this internship yet.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
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
                  fontSize: 18,
                  color: MyColors.darkBlue,
                ),
              ),
              const SizedBox(height: 10),
              ...state.notes.map((note) {
                // Remove time part from dateNote
                final String displayNoteDate = note.dateNote.split(' ')[0];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.contenuNote,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'by ${note.encadrantName ?? 'Unknown'} on $displayNoteDate',
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
                );
              }),
            ],
          );
        } else if (state is EncadrantError &&
            _expandedInternshipId == internshipId) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading notes: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

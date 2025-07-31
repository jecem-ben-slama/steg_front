import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Screens/Encadrant/evaluate_internship_popup.dart';
import 'package:pfa/Utils/snackbar.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';

class EncadrantFinishedInternshipsScreen extends StatefulWidget {
  const EncadrantFinishedInternshipsScreen({super.key});

  @override
  State<EncadrantFinishedInternshipsScreen> createState() =>
      _EncadrantFinishedInternshipsScreenState();
}

class _EncadrantFinishedInternshipsScreenState
    extends State<EncadrantFinishedInternshipsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EncadrantCubit>().fetchFinishedInternships();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'Validated':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Refused':
        return Colors.red;
      case 'Proposed':
        return Colors.blue;
     
      case 'Finiched':
        return Colors.grey.shade700;
      case 'Accepted':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  void _showUnvalidateConfirmationDialog(
    BuildContext context,
    int internshipId, // This is internshipID from the model
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Unvalidation'),
          content: const Text(
            'Are you sure you want to mark this internship as "Refused"? This will set its status to "Refusé" and clear your evaluation.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<EncadrantCubit>().evaluateInternship(
                  stageID:
                      internshipId, // Pass internshipId (which is stageID in cubit method)
                  actionType: 'unvalidate',
                  note: null,
                  commentaires: null,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Internships Awaiting Your Final Evaluation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
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
              },
              buildWhen: (previous, current) =>
                  current is FinishedInternshipsLoading ||
                  current is FinishedInternshipsLoaded ||
                  current is EncadrantError ||
                  (current is EvaluationActionLoading &&
                      previous is FinishedInternshipsLoaded) ||
                  (previous is EvaluationActionLoading &&
                      current is FinishedInternshipsLoaded),
              builder: (context, state) {
                if (state is FinishedInternshipsLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is FinishedInternshipsLoaded) {
                  if (state.finishedInternships.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text(
                          'No finished internships currently assigned to you.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.finishedInternships.length,
                      itemBuilder: (context, index) {
                        final internship = state.finishedInternships[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Student: ${internship.studentName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subject: ${internship.subjectTitle ?? 'N/A'}', // Use null-aware operator
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text('Type: ${internship.typeStage}'),
                                Text(
                                  'End Date: ${internship.dateFin.toString().split(' ')[0]}',
                                ), // Format date
                                const SizedBox(height: 8),
                                Text(
                                  'Current Status: ${internship.statut}',
                                  style: TextStyle(
                                    color: _getStatusColor(internship.statut),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (internship.estRemunere)
                                  Text(
                                    'Remuneration: ${internship.montantRemuneration?.toStringAsFixed(2) ?? '0.00'} TND', // Use null-aware operator
                                  ),
                                const SizedBox(height: 10),
                                // Display Encadrant's evaluation if it exists
                                if (internship.encadrantEvaluation != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Your Evaluation:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        'Note: ${internship.encadrantEvaluation!.note?.toStringAsFixed(1) ?? 'N/A'}',
                                      ),
                                      Text(
                                        'Comments: ${internship.encadrantEvaluation!.commentaires?.isNotEmpty == true ? internship.encadrantEvaluation!.commentaires : 'No comments'}',
                                      ),

                                      // Corrected to show actual validation status
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      'No evaluation from you yet.',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                // Action Buttons
                                BlocBuilder<EncadrantCubit, EncadrantState>(
                                  buildWhen: (previous, current) =>
                                      (current is EvaluationActionLoading &&
                                          current.targetStageId ==
                                              internship.internshipID) ||
                                      (previous is EvaluationActionLoading &&
                                          previous.targetStageId ==
                                              internship.internshipID &&
                                          !(current
                                              is EvaluationActionLoading)),
                                  builder: (context, state) {
                                    final bool isLoadingForThisInternship =
                                        (state is EvaluationActionLoading &&
                                        state.targetStageId ==
                                            internship.internshipID);

                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (isLoadingForThisInternship)
                                          const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        if (!isLoadingForThisInternship) ...[
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (dialogContext) {
                                                  return BlocProvider.value(
                                                    value: context
                                                        .read<EncadrantCubit>(),
                                                    child: EvaluateInternshipPopup(
                                                      internshipId: internship
                                                          .internshipID, // Use internshipID
                                                      currentNote: internship
                                                          .encadrantEvaluation
                                                          ?.note,
                                                      currentComments: internship
                                                          .encadrantEvaluation
                                                          ?.commentaires,
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons.check),
                                            label: Text(
                                              internship.encadrantEvaluation !=
                                                      null
                                                  ? 'Edit Evaluation'
                                                  : 'Evaluate',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              _showUnvalidateConfirmationDialog(
                                                context,
                                                internship
                                                    .internshipID, // Use internshipID
                                              );
                                            },
                                            icon: const Icon(Icons.close),
                                            label: const Text('Refuse'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              side: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
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
                        textAlign: TextAlign.center,
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
}

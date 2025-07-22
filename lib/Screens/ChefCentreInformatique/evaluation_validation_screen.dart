import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Utils/snackbar.dart';
import 'package:pfa/cubit/chef_cubit.dart'; // Ensure this path is correct (assuming snackbar_utils.dart is now snackbar.dart)

class EvaluationValidationScreen extends StatefulWidget {
  const EvaluationValidationScreen({super.key});

  @override
  State<EvaluationValidationScreen> createState() =>
      _EvaluationValidationScreenState();
}

class _EvaluationValidationScreenState
    extends State<EvaluationValidationScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger fetching evaluations when the screen initializes
    context.read<ChefCentreCubit>().fetchEvaluationsToValidate();
  }

  // Helper function to determine status color (for internship status)
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'validé':
        return Colors.green;
      case 'refusé': // Status set by Encadrant if unvalidated
        return Colors.red;
      case 'rejeté': // Status set by Chef Centre if rejected
        return Colors.red.shade700;
      case 'en attente':
        return Colors.orange;
      case 'en cours':
        return Colors.purple;
      case 'terminé': // If an internship is simply "Terminé" but evaluation pending
        return Colors.blueGrey;
      case 'proposé':
        return Colors.blue;
      case 'accepté':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  // Dialog to get rejection reason
  void _showRejectReasonDialog(BuildContext context, int evaluationID) {
    final TextEditingController _reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Evaluation'),
          content: TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for Rejection (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                context.read<ChefCentreCubit>().validateOrRejectEvaluation(
                  evaluationID: evaluationID,
                  actionType: 'reject',
                  rejectionReason: _reasonController.text.trim().isEmpty
                      ? null
                      : _reasonController.text.trim(),
                );
              },
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluations for Validation'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evaluations Pending Your Approval',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            BlocConsumer<ChefCentreCubit, ChefCentreState>(
              listener: (context, state) {
                if (state is EvaluationActionSuccess) {
                  showSuccessSnackBar(context, state.message);
                } else if (state is ChefCentreError) {
                  showFailureSnackBar(context, 'Error: ${state.message}');
                }
              },
              // buildWhen ensures the main list only rebuilds on relevant state changes
              buildWhen: (previous, current) =>
                  current is EvaluationsLoading ||
                  current is EvaluationsLoaded ||
                  current is ChefCentreError ||
                  // Also rebuild if an action loading state starts/ends on the evaluations list
                  (current is EvaluationActionLoading &&
                      previous is EvaluationsLoaded) ||
                  (previous is EvaluationActionLoading &&
                      current is EvaluationsLoaded),
              builder: (context, state) {
                if (state is EvaluationsLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is EvaluationsLoaded) {
                  if (state.evaluations.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text(
                          'No evaluations currently require your validation.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.evaluations.length,
                      itemBuilder: (context, index) {
                        final evaluation = state.evaluations[index];
                        // Check if this specific evaluation is currently being processed
                        final isLoadingForThisEvaluation =
                            (state is EvaluationActionLoading);

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
                                  'Internship Subject: ${evaluation.internshipDetails.subjectTitle ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Student: ${evaluation.studentDetails.studentName ?? 'N/A'} (${evaluation.studentDetails.studentEmail ?? 'N/A'})',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Encadrant: ${evaluation.encadrantDetails.encadrantUsername ?? 'N/A'} (${evaluation.encadrantDetails.encadrantEmail ?? 'N/A'})',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Type: ${evaluation.internshipDetails.typeStage ?? 'N/A'}',
                                ),
                                Text(
                                  'End Date: ${evaluation.internshipDetails.dateFin ?? 'N/A'}',
                                ),
                                Text(
                                  'Internship Status: ${evaluation.internshipDetails.statut ?? 'N/A'}',
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      evaluation.internshipDetails.statut,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(height: 20, thickness: 1),
                                const Text(
                                  'Encadrant\'s Evaluation:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Evaluation Date: ${evaluation.dateEvaluation}',
                                ),
                                Text(
                                  'Note: ${evaluation.note?.toStringAsFixed(1) ?? 'N/A'} / 10',
                                ),
                                Text(
                                  'Comments: ${evaluation.commentaires?.isNotEmpty == true ? evaluation.commentaires : 'No comments provided'}',
                                ),

                                const SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: isLoadingForThisEvaluation
                                      ? const SizedBox(
                                          width:
                                              24, // Allocate space for indicator
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                context
                                                    .read<ChefCentreCubit>()
                                                    .validateOrRejectEvaluation(
                                                      evaluationID: evaluation
                                                          .evaluationID,
                                                      actionType: 'validate',
                                                    );
                                              },
                                              icon: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'Validate',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            OutlinedButton.icon(
                                              onPressed: () =>
                                                  _showRejectReasonDialog(
                                                    context,
                                                    evaluation.evaluationID,
                                                  ),
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              label: const Text(
                                                'Reject',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is ChefCentreError) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'Failed to load evaluations: ${state.message}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const Expanded(
                  child: SizedBox.shrink(),
                ); // Default empty state
              },
            ),
          ],
        ),
      ),
    );
  }
}

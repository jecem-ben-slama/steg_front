// lib/Screens/ChefCentreInformatique/chef_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/internship_cubit.dart'; // Import your main InternshipCubit
import 'package:pfa/Model/internship_model.dart'; // Import your Internship model

class ChefDashboardScreen extends StatelessWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the InternshipCubit and immediately trigger fetching pending internships
    return BlocProvider(
      create: (context) =>
          InternshipCubit(
            RepositoryProvider.of(
              context,
            ), // Ensure InternshipRepository is provided higher up
          )..fetchInternshipsByStatus(
            'Proposé',
          ), // Fetch only PENDING internships for the dashboard

      child: BlocConsumer<InternshipCubit, InternshipState>(
        listener: (context, state) {
          if (state is InternshipError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          } else if (state is InternshipActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          List<Internship> internshipsToDisplay = [];
          bool isLoading = false;
          int? updatingId;

          if (state is InternshipLoading || state is InternshipInitial) {
            isLoading = true;
          } else if (state is InternshipLoaded) {
            internshipsToDisplay = state.internships;
          } else if (state is InternshipUpdatingSingle) {
            // When a single item is updating, show the original list content but with a spinner on the item
            internshipsToDisplay = state.currentInternships;
            updatingId = state.updatingInternshipId;
          } else if (state is InternshipError) {
            // In case of an error after a list was loaded, display the last known good list
            internshipsToDisplay = state.lastLoadedInternships ?? [];
          }

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (internshipsToDisplay.isEmpty) {
            return const Center(
              child: Text('No pending internships to review.'),
            );
          }

          return ListView.builder(
            itemCount: internshipsToDisplay.length,
            itemBuilder: (context, index) {
              final internship = internshipsToDisplay[index];
              final bool canUpdate = internship.internshipID != null;
              final bool isUpdatingThisItem =
                  updatingId == internship.internshipID;

              return GestureDetector(
                onTap: () {
                  debugPrint("***************************************");
                },
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          internship.subjectTitle ?? 'No Subject Title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Student: ${internship.studentName ?? 'N/A'}'),
                        Text(
                          'Supervisor: ${internship.supervisorName ?? 'N/A'}',
                        ),
                        Text('Type: ${internship.typeStage ?? 'N/A'}'),
                        Text('Status: ${internship.statut ?? 'N/A'}'),
                        Text(
                          'From: ${internship.dateDebut ?? 'N/A'} To: ${internship.dateFin ?? 'N/A'}',
                        ),
                        if (internship.estRemunere == true)
                          Text(
                            'Remuneration: ${internship.montantRemuneration ?? 'N/A'} TND',
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isUpdatingThisItem)
                              const Padding(
                                padding: EdgeInsets.only(right: 16.0),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: canUpdate
                                        ? () {
                                            context
                                                .read<InternshipCubit>()
                                                .updateInternshipStatus(
                                                  internship.internshipID,
                                                  'ACCEPTED',
                                                );
                                          }
                                        : null,
                                    icon: const Icon(Icons.check),
                                    label: const Text('Accept'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: canUpdate
                                        ? () {
                                            context
                                                .read<InternshipCubit>()
                                                .updateInternshipStatus(
                                                  internship.internshipID,
                                                  'REJECTED',
                                                );
                                          }
                                        : null,
                                    icon: const Icon(Icons.close),
                                    label: const Text('Reject'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

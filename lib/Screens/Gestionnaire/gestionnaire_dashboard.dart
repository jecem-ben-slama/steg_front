// lib/Gestionnaire/gestionnaire_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/internship_cubit.dart';
import 'package:pfa/Model/internship_model.dart'; // Ensure this import is correct
import 'package:pfa/Utils/Widgets/deptcard.dart';
import 'package:pfa/Utils/Widgets/statcard.dart';
import 'package:pfa/Utils/snackbar.dart'; // Ensure this import is correct

class GestionnaireDashboard extends StatelessWidget {
  const GestionnaireDashboard({super.key});

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'validé':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'refusé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this internship? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<InternshipCubit, InternshipState>(
      listener: (context, state) {
        if (state is InternshipActionSuccess) {
          showSuccessSnackBar(context, "yess!!");
        } else if (state is InternshipError) {
          // This listener always shows a SnackBar for any error.
          showFailureSnackBar(context, 'Error: ${state.message}');
        }
      },
      child: Column(
        children: [
          //? Search Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 200),
              SizedBox(
                width: screenWidth * 0.4,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search here",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://randomuser.me/api/portraits/men/1.jpg",
                ),
                radius: 24,
              ),
            ],
          ),
          const SizedBox(height: 24),
          //? Stats sneak peek
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatCard(title: "Active Employee", value: "1081"),
              StatCard(title: "Total Employee", value: "2,300"),
              StatCard(title: "Total Task", value: "34"),
              StatCard(title: "Attendance", value: "+91"),
            ],
          ),
          const SizedBox(height: 24),
          //? Department Cards
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DeptCard(title: "Manage Internships"),
              DeptCard(title: "Manage Student"),
              DeptCard(title: "Manage Subject"),
              DeptCard(title: "Manage Supervisor"),
            ],
          ),
          const SizedBox(height: 24),
          //? Internships Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Internships",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<InternshipCubit, InternshipState>(
                    builder: (context, state) {
                      List<Internship>? internshipsToDisplay;

                      // Determine what list of internships to display
                      if (state is InternshipLoaded) {
                        internshipsToDisplay = state.internships;
                      } else if (state is InternshipError) {
                        // If the error state carries previous data, display that data
                        internshipsToDisplay = state.lastLoadedInternships;
                      } else if (context.read<InternshipCubit>().state
                          is InternshipLoaded) {
                        // If currently loading but previous state was loaded, show previous data
                        internshipsToDisplay =
                            (context.read<InternshipCubit>().state
                                    as InternshipLoaded)
                                .internships;
                      } else if (context.read<InternshipCubit>().state
                              is InternshipError &&
                          (context.read<InternshipCubit>().state
                                      as InternshipError)
                                  .lastLoadedInternships !=
                              null) {
                        // If currently in error but previous state (or error state itself) has data, show it
                        internshipsToDisplay =
                            (context.read<InternshipCubit>().state
                                    as InternshipError)
                                .lastLoadedInternships;
                      }

                      // Handle different display scenarios
                      if (internshipsToDisplay == null ||
                          internshipsToDisplay.isEmpty) {
                        if (state is InternshipLoading) {
                          // Show loading only if no data has ever been loaded
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is InternshipError) {
                          // Show full error message only if no data could ever be loaded
                          return Center(
                            child: Text(
                              'Error loading internships: ${state.message}',
                            ),
                          );
                        } else {
                          // No internships found after load, or initial state
                          return const Center(
                            child: Text('No internships found.'),
                          );
                        }
                      }

                      // If we have data, display the table
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Student Name")),
                            DataColumn(label: Text("Subject")),
                            DataColumn(
                              label: Text("Supervisor"),
                            ), // Assuming supervisorName
                            DataColumn(label: Text("Type")),
                            DataColumn(label: Text("Start Date")),
                            DataColumn(label: Text("End Date")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: internshipsToDisplay.map((internship) {
                            return DataRow(
                              cells: [
                                DataCell(Text(internship.studentName ?? 'N/A')),
                                DataCell(
                                  Text(internship.subjectTitle ?? 'N/A'),
                                ),
                                DataCell(
                                  Text(internship.supervisorName ?? 'N/A'),
                                ), // Use correct field here
                                DataCell(Text(internship.typeStage ?? 'N/A')),
                                DataCell(Text(internship.dateDebut ?? 'N/A')),
                                DataCell(Text(internship.dateFin ?? 'N/A')),
                                DataCell(
                                  Text(
                                    internship.statut ?? 'N/A',
                                    style: TextStyle(
                                      color: _getStatusColor(internship.statut),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () {
                                          print(
                                            'Edit ${internship.internshipID}',
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final confirmed =
                                              await _showDeleteConfirmationDialog(
                                                context,
                                              );
                                          if (confirmed == true) {
                                            if (internship.internshipID !=
                                                null) {
                                              context
                                                  .read<InternshipCubit>()
                                                  .deleteInternship(
                                                    internship.internshipID!,
                                                  );
                                            } else {
                                              showFailureSnackBar(
                                                context,
                                                "zebi, internship ID is null",
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/internship_cubit.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_details_page.dart';

// This is the original main content. We'll rename it slightly
// and make it one of the views.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        //? Search Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 200), // Adjust as needed
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
            // These will eventually be buttons or navigation, but for now they are just cards
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
                const SizedBox(height: 16), // Add some spacing
                // --- BlocBuilder for Internship List ---
                BlocBuilder<InternshipCubit, InternshipState>(
                  builder: (context, state) {
                    if (state is InternshipLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is InternshipError) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else if (state is InternshipLoaded) {
                      if (state.internships.isEmpty) {
                        return const Center(
                          child: Text('No internships found.'),
                        );
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis
                            .horizontal, // Allows horizontal scrolling if columns are too wide
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Student Name")),
                            DataColumn(label: Text("Subject")),
                            DataColumn(label: Text("Supervisor")),
                            DataColumn(label: Text("Type")),
                            DataColumn(label: Text("Start Date")),
                            DataColumn(label: Text("End Date")),
                            DataColumn(label: Text("Status")),
                            DataColumn(
                              label: Text("Actions"),
                            ), // For edit/delete buttons
                          ],
                          rows: state.internships.map((internship) {
                            return DataRow(
                              cells: [
                                DataCell(Text(internship.studentName ?? 'N/A')),
                                DataCell(
                                  Text(internship.subjectTitle ?? 'N/A'),
                                ),
                                DataCell(
                                  Text(internship.supervisorName ?? 'N/A'),
                                ),
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
                                          // TODO: Implement edit functionality
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
                                        onPressed: () {
                                          // TODO: Implement delete functionality
                                          print(
                                            'Delete ${internship.internshipID}',
                                          );
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
                    }
                    return const SizedBox.shrink(); // Initial or unexpected state
                  },
                ),
                // --- End BlocBuilder ---
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper function for status color (moved here as it's specific to this view)
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
}

class PapersView extends StatelessWidget {
  const PapersView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Papers Management Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AccountingFinanceView extends StatelessWidget {
  const AccountingFinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Accounting and Finance Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SupervisorsView extends StatelessWidget {
  const SupervisorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Supervisors Management Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Attendance Records Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class LogoutView extends StatelessWidget {
  const LogoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Logging Out...',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

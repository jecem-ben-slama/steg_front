import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/internship_cubit.dart'; // Import your cubit
// Import your model

class GestionnaireHome extends StatelessWidget {
  const GestionnaireHome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            //* Sidebar
            Container(
              width: screenWidth * 0.2,
              height: screenHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF0A2847),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    //* Logo
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.dashboard,
                        color: Color(0xFF0A2847),
                        size: 40,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      "Micon Protocol",
                      style: TextStyle(
                        fontSize: screenWidth * 0.02,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    //* Navigation Items
                    const SidebarItem(
                      icon: Icons.dashboard,
                      label: "Dashboard",
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.015),
                    const SidebarItem(icon: Icons.business, label: "Papers"),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.015),
                    const SidebarItem(
                      icon: Icons.account_balance_wallet,
                      label: "Accounting and Finance",
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.015),
                    const SidebarItem(icon: Icons.people, label: "Supervisors"),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.015),
                    const SidebarItem(
                      icon: Icons.access_time,
                      label: "Attendance",
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.06),
                    const SidebarItem(icon: Icons.logout, label: "Log Out"),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            //* Main Content
            Expanded(
              child: Column(
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DeptCard(title: "Manage Subjects"),
                      DeptCard(title: "Manage Student"),
                      DeptCard(title: "Manage Supervisor"),
                      //DeptCard(title: "Manage Internships"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  //? Internships Table (Attendance Table renamed)
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 16), // Add some spacing
                          // --- BlocBuilder for Internship List ---
                          BlocBuilder<InternshipCubit, InternshipState>(
                            builder: (context, state) {
                              if (state is InternshipLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is InternshipError) {
                                return Center(
                                  child: Text('Error: ${state.message}'),
                                );
                              } else if (state is InternshipLoaded) {
                                if (state.internships.isEmpty) {
                                  return const Center(
                                    child: Text('No internships found.'),
                                  );
                                }
                                return SingleChildScrollView(
                                  // Use SingleChildScrollView for DataTable
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
                                          DataCell(
                                            Text(
                                              internship.studentName ?? 'N/A',
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              internship.subjectTitle ?? 'N/A',
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              internship.supervisorName ??
                                                  'N/A',
                                            ),
                                          ),
                                          DataCell(
                                            Text(internship.typeStage ?? 'N/A'),
                                          ),
                                          DataCell(
                                            Text(internship.dateDebut ?? 'N/A'),
                                          ),
                                          DataCell(
                                            Text(internship.dateFin ?? 'N/A'),
                                          ),
                                          DataCell(
                                            Text(
                                              internship.statut ?? 'N/A',
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                  internship.statut,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    size: 20,
                                                  ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for status color
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

//! Sidebar item widget (No changes needed)
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const SidebarItem({super.key, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: MediaQuery.of(context).size.width * 0.02,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.width * 0.01,
        ),
      ),
      onTap: () {
        // Implement navigation here
      },
    );
  }
}

//! Stat card widget (No changes needed)
class StatCard extends StatelessWidget {
  final String title, value;
  const StatCard({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.13,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const Text("See More", style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}

//! Department card widget (No changes needed)
class DeptCard extends StatelessWidget {
  final String title;
  const DeptCard({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.11,
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

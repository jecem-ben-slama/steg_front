// lib/Gestionnaire/gestionnaire_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/internship_cubit.dart';
import 'package:pfa/Model/internship_model.dart'; // Ensure this import is correct
import 'package:pfa/Utils/Widgets/deptcard.dart';
import 'package:pfa/Utils/Widgets/edit_internship.dart';
import 'package:pfa/Utils/Widgets/statcard.dart';
import 'package:pfa/Utils/snackbar.dart'; // Ensure this import is correct

class GestionnaireDashboard extends StatefulWidget {
  const GestionnaireDashboard({super.key});

  @override
  State<GestionnaireDashboard> createState() => _GestionnaireDashboardState();
}

class _GestionnaireDashboardState extends State<GestionnaireDashboard> {
  String _searchQuery = '';
  String? _selectedStatusFilter;
  String? _selectedTypeFilter;

  final List<String> _statusOptions = [
    'All',
    'Validé',
    'En attente',
    'Refusé',
    'Proposé',
  ];

  final List<String> _typeOptions = ['All', 'PFA', 'PFE', 'Stage Ouvrier'];

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

  //* --- Filter ---
  List<Internship> _applyFilters(List<Internship> internships) {
    List<Internship> filteredList = List.from(internships);

    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((internship) {
        final query = _searchQuery.toLowerCase();
        return (internship.studentName?.toLowerCase().contains(query) ??
                false) ||
            (internship.subjectTitle?.toLowerCase().contains(query) ?? false) ||
            (internship.supervisorName?.toLowerCase().contains(query) ??
                false) ||
            (internship.typeStage?.toLowerCase().contains(query) ?? false) ||
            (internship.statut?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_selectedStatusFilter != null && _selectedStatusFilter != 'All') {
      filteredList = filteredList.where((internship) {
        return internship.statut?.toLowerCase() ==
            _selectedStatusFilter!.toLowerCase();
      }).toList();
    }

    if (_selectedTypeFilter != null && _selectedTypeFilter != 'All') {
      filteredList = filteredList.where((internship) {
        return internship.typeStage?.toLowerCase() ==
            _selectedTypeFilter!.toLowerCase();
      }).toList();
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<InternshipCubit, InternshipState>(
      listener: (context, state) {
        if (state is InternshipActionSuccess) {
          showSuccessSnackBar(context, state.message);
        } else if (state is InternshipError) {
          showFailureSnackBar(context, 'Error: ${state.message}');
        }
      },
      child: Column(
        children: [
          //? Search Bar and Filters
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.3, // Adjust width as needed
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          "Search by student, subject, supervisor, status...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: screenWidth * 0.1, // Adjust width as needed
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    value: _selectedStatusFilter ?? 'All', // Default to 'All'
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatusFilter = newValue == 'All'
                            ? null
                            : newValue;
                      });
                    },
                    items: _statusOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                // Type Filter Dropdown
                SizedBox(
                  width: screenWidth * 0.2, // Adjust width as needed
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    value: _selectedTypeFilter ?? 'All', // Default to 'All'
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTypeFilter = newValue == 'All'
                            ? null
                            : newValue;
                      });
                    },
                    items: _typeOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    "https://randomuser.me/api/portraits/men/1.jpg",
                  ),
                  radius: 24,
                ),
              ],
            ),
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
                      List<Internship>?
                      internshipsRaw; // This will hold the unfiltered data

                      // Determine the raw list of internships
                      if (state is InternshipLoaded) {
                        internshipsRaw = state.internships;
                      } else if (state is InternshipError) {
                        internshipsRaw = state.lastLoadedInternships;
                      } else if (state is InternshipLoading &&
                          context.read<InternshipCubit>().state
                              is InternshipLoaded) {
                        internshipsRaw =
                            (context.read<InternshipCubit>().state
                                    as InternshipLoaded)
                                .internships;
                      } else if (state is InternshipLoading &&
                          context.read<InternshipCubit>().state
                              is InternshipError &&
                          (context.read<InternshipCubit>().state
                                      as InternshipError)
                                  .lastLoadedInternships !=
                              null) {
                        internshipsRaw =
                            (context.read<InternshipCubit>().state
                                    as InternshipError)
                                .lastLoadedInternships;
                      }

                      // Apply filters to the raw list if it exists
                      List<Internship>? internshipsToDisplay;
                      if (internshipsRaw != null) {
                        internshipsToDisplay = _applyFilters(internshipsRaw);
                      }

                      // Handle different display scenarios
                      if (internshipsToDisplay == null ||
                          internshipsToDisplay.isEmpty) {
                        if (state is InternshipLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is InternshipError) {
                          return Center(
                            child: Text(
                              'Error loading internships: ${state.message}',
                            ),
                          );
                        } else {
                          // No internships found after load, or initial state, or no results after filter
                          return Center(
                            child: Text(
                              _searchQuery.isNotEmpty ||
                                      _selectedStatusFilter != null ||
                                      _selectedTypeFilter != null
                                  ? 'No matching internships found for current filters.'
                                  : 'No internships found.',
                            ),
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
                            DataColumn(label: Text("Supervisor")),
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
                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              return BlocProvider.value(
                                                value: context
                                                    .read<InternshipCubit>(),
                                                child: InternshipEditDialog(
                                                  internship: internship,
                                                ),
                                              );
                                            },
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
                                                "Internship ID is missing for deletion.",
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

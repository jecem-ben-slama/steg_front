import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/encadrant_internships_model.dart';
import 'package:pfa/Screens/Encadrant/assign_subject.dart';
import 'package:pfa/Utils/Consts/style.dart'; // Assuming MyColors and other styles are here
import 'package:pfa/cubit/encadrant_cubit.dart';
import 'package:pfa/cubit/subject_cubit.dart';

class EncadrantDashboardScreen extends StatefulWidget {
  const EncadrantDashboardScreen({super.key});

  @override
  State<EncadrantDashboardScreen> createState() =>
      _EncadrantDashboardScreenState();
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
    case 'accepted':
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
      return Colors
          .grey
          .shade200; // Changed to shade200 for better contrast with grey text
    case 'validated':
      return Colors.green.shade100;
    case 'accepted':
      return Colors.green.shade100;
    default:
      return Colors.grey.shade100;
  }
}

class _EncadrantDashboardScreenState extends State<EncadrantDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<EncadrantCubit>().fetchAssignedInternships();
    context.read<SubjectCubit>().fetchSubjects(); // Pre-fetch subjects

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Function to show the assign subject dialog
  void _showAssignSubjectDialog(
    BuildContext context,
    AssignedInternship internship,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context
              .read<SubjectCubit>(), // Provide the existing SubjectCubit
          child: AssignSubjectDialog(internship: internship),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.lightBlue,
      appBar: AppBar(
        backgroundColor:
            MyColors.lightBlue, // Changed to darkBlue for better contrast
        foregroundColor: Colors.white,
        elevation: 0, // Flat AppBar for modern look

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            60.0,
          ), // Height of the search bar
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search internships...',
                hintStyle: const TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
                ), // Hint text visible
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(179, 0, 0, 0),
                ),
                filled: true,
                fillColor: MyColors.white, // Consistent with AppBar
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none, // No border
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
              ), // Input text visible
              cursorColor: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
      ),
      body: BlocConsumer<EncadrantCubit, EncadrantState>(
        listener: (context, state) {
          if (state is EncadrantActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is EncadrantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EncadrantLoading) {
            return const Center(
              child: CircularProgressIndicator(color: MyColors.darkBlue),
            );
          } else if (state is EncadrantLoaded) {
            // Filter internships based on search query
            final filteredInternships = state.internships.where((internship) {
              final query = _searchQuery;
              return internship.studentFirstName.toLowerCase().contains(
                    query,
                  ) ||
                  internship.studentLastName.toLowerCase().contains(query) ||
                  internship.typeStage.toLowerCase().contains(query) ||
                  (internship.subjectTitle?.toLowerCase().contains(query) ??
                      false) ||
                  internship.statut.toLowerCase().contains(query);
            }).toList();

            if (filteredInternships.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty
                            ? Icons.inbox_outlined
                            : Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No internships assigned to you yet.'
                            : 'No internships found matching "${_searchController.text}".',
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
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredInternships.length,
              itemBuilder: (context, index) {
                final internship = filteredInternships[index];

                // Extract only the date part from the date strings

                // Condition to show/hide the Assign Subject button
                final bool showAssignButton =
                    (internship.subjectTitle == null ||
                        internship.subjectTitle!.isEmpty ||
                        internship.sujetID == 0) &&
                    internship.statut.toLowerCase() !=
                        'refused'; // <--- ADDED CONDITION HERE

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Student: ${internship.studentFirstName} ${internship.studentLastName}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: MyColors.darkBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
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
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: _getStatusColor(internship.statut),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Type: ${internship.typeStage}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Subject: ${internship.subjectTitle ?? 'Not Assigned'}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontStyle: internship.subjectTitle == null
                                    ? FontStyle.italic
                                    : null,
                                color: internship.subjectTitle == null
                                    ? Colors.grey.shade600
                                    : null,
                              ),
                        ),
                        const SizedBox(height: 5),
                        // Updated to show only date
                        Text(
                          'Dates: ${internship.dateDebut.year}-${internship.dateDebut.month}-${internship.dateDebut.day} to ${internship.dateFin.year}-${internship.dateFin.month}-${internship.dateFin.day}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 16),
                        // Only show "Assign Subject" if conditions met
                        if (showAssignButton) // <--- USED NEW CONDITION HERE
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showAssignSubjectDialog(context, internship),
                              icon: const Icon(
                                Icons.assignment,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Assign Subject',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.darkBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                        // Show "Subject Assignment in Progress" if loading for this specific internship
                        if (state is SubjectAssignmentLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: MyColors.darkBlue,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Assigning subject...'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is EncadrantError) {
            return Center(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<EncadrantCubit>()
                          .fetchAssignedInternships(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
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
            );
          }
          return const Center(
            child: Text(
              'Welcome Encadrant! No data to display yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

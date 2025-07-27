import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Screens/Encadrant/assign_subject.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';
import 'package:pfa/cubit/subject_cubit.dart';

class EncadrantDashboardScreen extends StatefulWidget {
  const EncadrantDashboardScreen({super.key});

  @override
  State<EncadrantDashboardScreen> createState() =>
      _EncadrantDashboardScreenState();
}

class _EncadrantDashboardScreenState extends State<EncadrantDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch assigned internships when the screen initializes
    context.read<EncadrantCubit>().fetchAssignedInternships();
    // Pre-fetch subjects as they will be needed for assignment
    context.read<SubjectCubit>().fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encadrant Dashboard')),
      body: BlocConsumer<EncadrantCubit, EncadrantState>(
        listener: (context, state) {
          if (state is EncadrantActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is EncadrantError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is EncadrantLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EncadrantLoaded) {
            if (state.internships.isEmpty) {
              return const Center(child: Text('No internships assigned yet.'));
            }
            return ListView.builder(
              itemCount: state.internships.length,
              itemBuilder: (context, index) {
                final internship = state.internships[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student: ${internship.studentName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text('Title: ${internship.subjectTitle ?? 'N/A'}'),
                        Text(
                          'Subject: ${internship.subjectTitle ?? 'Not Assigned'}',
                        ),
                        Text('Status: ${internship.statut ?? ""}'),
                        const SizedBox(height: 16),
                        // Only show "Assign Subject" if no subject is assigned
                        if (internship.subjectTitle == null ||
                            internship.subjectTitle!.isEmpty ||
                            internship.sujetID ==
                                0) // Assuming 0 for unassigned subject ID
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showAssignSubjectDialog(context, internship),
                              icon: const Icon(Icons.assignment),
                              label: const Text('Assign Subject'),
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
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Please fetch internships.'));
        },
      ),
    );
  }

  // Function to show the assign subject dialog
  void _showAssignSubjectDialog(BuildContext context, Internship internship) {
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
}

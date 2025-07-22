// lib/screens/encadrant_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';

class EncadrantDashboard extends StatefulWidget {
  const EncadrantDashboard({super.key});

  @override
  State<EncadrantDashboard> createState() => _EncadrantDashboardState();
}

class _EncadrantDashboardState extends State<EncadrantDashboard> {
  @override
  void initState() {
    super.initState();
    // Fetch internships when the screen initializes
    context.read<EncadrantCubit>().fetchAssignedInternships();
  }

  Future<void> _onRefresh() async {
    // When user pulls to refresh, refetch internships
    await context.read<EncadrantCubit>().fetchAssignedInternships();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EncadrantCubit, EncadrantState>(
      listener: (context, state) {
        // Listen for action success or error states to show feedback
        if (state is EncadrantActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is EncadrantError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is EncadrantLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is EncadrantLoaded) {
          if (state.internships.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: const Center(child: Text('No internships assigned yet.')),
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.internships.length,
              itemBuilder: (context, index) {
                final internship = state.internships[index];
                return InternshipCard(internship: internship);
              },
            ),
          );
        } else if (state is EncadrantError) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(
          child: Text('Press refresh to load internships.'),
        ); // Initial state text
      },
    );
  }
}

// --- Internship Card Widget (for better organization) ---
class InternshipCard extends StatelessWidget {
  final Internship internship;

  const InternshipCard({super.key, required this.internship});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              internship.subjectTitle ?? 'No Title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Student: ${internship.studentName}',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Text(
              'Type: ${internship.typeStage}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'Status: ${internship.statut}',
              style: TextStyle(
                fontSize: 14,
                color: internship.statut == 'Validé'
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'From: ${internship.dateDebut.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  'To: ${internship.dateFin.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            // Example of buttons for actions (will lead to detail screen later)
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to Internship Details Screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Viewing details for ${internship.subjectTitle}',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

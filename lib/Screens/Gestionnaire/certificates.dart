// lib/Screens/Gestionnaire/Certificates.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Utils/Widgets/attestation_details.dart';
import 'package:pfa/cubit/internship_cubit.dart'; // Your InternshipCubit
import 'package:pfa/Model/attestation_model.dart'; // Attestation data model
import 'package:pfa/Utils/snackbar.dart'; // For snackbars

class Certificates extends StatefulWidget {
  const Certificates({super.key});

  @override
  State<Certificates> createState() => _CertificatesState();
}

class _CertificatesState extends State<Certificates> {
  @override
  void initState() {
    super.initState();
    // Fetch only attestable internships when this screen loads
    context.read<InternshipCubit>().fetchAttestableInternships();
  }

  Future<void> _onRefresh() async {
    await context.read<InternshipCubit>().fetchAttestableInternships();
  }

  // Function to show the attestation dialog
  void _showAttestationDialog(BuildContext context, AttestationData data) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Attestation de Stage'),
          content: SizedBox(
            // Use SizedBox to control dialog size
            width: MediaQuery.of(dialogContext).size.width * 0.9,
            height: MediaQuery.of(dialogContext).size.height * 0.8,
            child: AttestationDisplayWidget(
              attestationData: data,
            ), // Use the display widget here
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
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
        title: const Text('Generate Attestations'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocConsumer<InternshipCubit, InternshipState>(
        listener: (context, state) {
          if (state is AttestationLoaded) {
            // Show the dialog directly when attestation data is loaded
            _showAttestationDialog(context, state.attestationData);
          } else if (state is AttestationErrorState) {
            showFailureSnackBar(context, state.message);
          } else if (state is InternshipError) {
            showFailureSnackBar(context, state.message);
          } else if (state is AttestationLoading) {}
        },
        builder: (context, state) {
          if (state is AttestableInternshipsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttestableInternshipsLoaded) {
            final internships = state.internships;

            if (internships.isEmpty) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: const Center(
                  child: Text('No internships eligible for attestation yet.'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: internships.length,
                itemBuilder: (context, index) {
                  final internship = internships[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      // Make the card tappable
                      onTap: () {
                        // Trigger fetching of specific attestation data when card is tapped
                        // The BlocListener will then show the dialog once data is loaded.
                        context.read<InternshipCubit>().fetchAttestationData(
                          internship.internshipID!,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${internship.subjectTitle ?? 'N/A'} - ${internship.typeStage}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Student: ${internship.studentName}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Supervisor: ${internship.encadrantProName ?? 'N/A'} }',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Period: ${internship.dateDebut} to ${internship.dateFin}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Chip(
                                label: const Text('Ready for Attestation'),
                                backgroundColor: Colors.green.shade100,
                                labelStyle: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                                avatar: Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is InternshipError) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
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
          return const Center(child: Text('Loading attestable internships...'));
        },
      ),
    );
  }
}

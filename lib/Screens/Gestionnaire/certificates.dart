// lib/Screens/Gestionnaire/Certificates.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/attestation_model.dart';
import 'package:pfa/Utils/pdf_generator.dart';
// REMOVED: import 'package:pfa/Utils/Widgets/attestation_details.dart'; // No longer needed
import 'package:pfa/cubit/internship_cubit.dart';

import 'package:pfa/Utils/snackbar.dart';

class Certificates extends StatefulWidget {
  const Certificates({super.key});

  @override
  State<Certificates> createState() => _CertificatesState();
}

class _CertificatesState extends State<Certificates> {
  @override
  void initState() {
    super.initState();
    context.read<InternshipCubit>().fetchAttestableInternships();
  }

  Future<void> _onRefresh() async {
    await context.read<InternshipCubit>().fetchAttestableInternships();
  }

  // REMOVED: _showAttestationDialog method as it's no longer used

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<InternshipCubit, InternshipState>(
        listener: (context, state) {
          // Listen for AttestationLoaded to generate PDF
          if (state is AttestationLoaded) {
            _generateAttestationPdfAndShowSnackbar(
              context,
              state.attestationData,
            );
          } else if (state is AttestationErrorState) {
            showFailureSnackBar(context, state.message);
          } else if (state is InternshipError) {
            showFailureSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AttestableInternshipsLoading ||
              state is AttestationLoading) {
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
                            'Supervisor: ${internship.supervisorName ?? 'N/A'}',
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

                          if (internship.estRemunere!)
                            Text(
                              'Remuneration: ${internship.montantRemuneration?.toStringAsFixed(2) ?? '0.00'} TND',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Button for Attestation - NOW CALLS fetchAttestationData
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context
                                        .read<InternshipCubit>()
                                        .fetchAttestationData(
                                          internship.internshipID!,
                                        );
                                  },
                                  icon: const Icon(Icons.description),
                                  label: const Text('Attestation'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 3,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ), // Spacing between buttons
                                // Button for Fiche de Paie (Conditional)
                                if (internship.estRemunere!)
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        final pdfBytes =
                                            await PdfGeneratorService.generateSimplePayslipPdf(
                                              internship, // Pass the Internship object directly
                                            );
                                        final filename =
                                            'FicheDePaie_${internship.studentName?.replaceAll(' ', '_') ?? 'N/A'}_${internship.internshipID}';
                                        await PdfGeneratorService.saveAndOpenPdf(
                                          pdfBytes,
                                          filename,
                                        );
                                        showSuccessSnackBar(
                                          context,
                                          'Payslip PDF generated!',
                                        );
                                      } catch (e) {
                                        showFailureSnackBar(
                                          context,
                                          'Error generating Payslip PDF: ${e.toString()}',
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.receipt_long),
                                    label: const Text('Fiche de Paie'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 3,
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

  // Helper function to generate PDF and show snackbar
  Future<void> _generateAttestationPdfAndShowSnackbar(
    BuildContext context,
    AttestationData attestationData,
  ) async {
    try {
      final pdfBytes = await PdfGeneratorService.generateAttestationPdf(
        attestationData,
      );
      final filename =
          'Attestation_${attestationData.student.lastName}_${attestationData.internship.stageID}';
      await PdfGeneratorService.saveAndOpenPdf(pdfBytes, filename);
      showSuccessSnackBar(context, 'Attestation PDF generated!');
    } catch (e) {
      showFailureSnackBar(
        context,
        'Error generating Attestation PDF: ${e.toString()}',
      );
    }
  }
}

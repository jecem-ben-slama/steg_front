// lib/Widgets/attestation_display_widget.dart
import 'package:flutter/material.dart';
import 'package:pfa/Model/attestation_model.dart';
import 'package:pfa/Utils/pdf_generator.dart';
import 'package:pfa/Utils/snackbar.dart'; // Import for consistent snackbar messages

class AttestationDisplayWidget extends StatelessWidget {
  final AttestationData attestationData;

  const AttestationDisplayWidget({super.key, required this.attestationData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Attestation de Stage',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const Divider(height: 30, thickness: 1.5),
              _buildInfoRow(
                'Stagiaire:',
                '${attestationData.student.firstName} ${attestationData.student.lastName}',
                Icons.person,
              ),
              _buildInfoRow(
                'Email Stagiaire:',
                attestationData.student.email,
                Icons.email,
              ),
              _buildInfoRow(
                'Type de Stage:',
                attestationData.internship.typeStage,
                Icons.work,
              ),
              _buildInfoRow(
                'Sujet du Stage:',
                attestationData.subject.title ?? 'Non spécifié',
                Icons.topic,
              ),
              _buildInfoRow(
                'Période:',
                'Du ${attestationData.internship.dateDebut} au ${attestationData.internship.dateFin}',
                Icons.date_range,
              ),
              _buildInfoRow(
                'Encadrant:',
                '${attestationData.supervisor.firstName ?? 'N/A'} ${attestationData.supervisor.lastName ?? ''}',
                Icons.supervisor_account,
              ),
              const Divider(height: 30, thickness: 1.5),
              const Text(
                'Évaluation:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              _buildInfoRow(
                'Note:',
                '${attestationData.evaluation.note.toStringAsFixed(1)} / 10',
                Icons.star,
              ),
              _buildInfoRow(
                'Commentaires:',
                attestationData.evaluation.comments,
                Icons.comment,
              ),
              _buildInfoRow(
                'Date d\'évaluation:',
                attestationData.evaluation.dateEvaluation,
                Icons.calendar_today,
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final pdfBytes =
                          await PdfGeneratorService.generateAttestationPdf(
                            attestationData,
                          );
                      final filename =
                          'Attestation_${attestationData.student.lastName}_${attestationData.internship.stageID}';
                      await PdfGeneratorService.saveAndOpenPdf(
                        pdfBytes,
                        filename,
                      );
                      showSuccessSnackBar(
                        context,
                        'PDF generated and opened!',
                      ); // Using custom snackbar
                    } catch (e) {
                      showFailureSnackBar(
                        context,
                        'Error generating PDF: ${e.toString()}',
                      ); // Using custom snackbar
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Create PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

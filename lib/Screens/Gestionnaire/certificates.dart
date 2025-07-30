// lib/Screens/Gestionnaire/Certificates.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/attestation_model.dart';
import 'package:pfa/Utils/pdf_generator.dart';
import 'package:pfa/cubit/internship_cubit.dart';
import 'package:pfa/cubit/document_cubit.dart';
import 'package:pfa/Utils/snackbar.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import qr_flutter
import 'package:url_launcher/url_launcher.dart'; // For opening URLs
import 'dart:typed_data'; // Required for Uint8List
import 'package:flutter/foundation.dart'
    show kIsWeb; // To check if it's a web platform
import 'package:path_provider/path_provider.dart'; // For getting directory on non-web
import 'dart:io'
    as io; // For File operations on non-web (avoiding conflict with 'html')
import 'package:universal_html/html.dart'
    as html; // For web-specific download methods

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

  // --- NEW: PDF Download Function ---
  Future<void> _downloadPdfToClient(Uint8List pdfBytes, String filename) async {
    try {
      if (kIsWeb) {
        // Web platform: Create a Blob and trigger a download
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url); // Clean up the URL
        showSuccessSnackBar(context, 'PDF downloaded successfully!');
      } else {
        // Mobile/Desktop platforms: Save to local storage
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';
        final file = io.File(filePath);
        await file.writeAsBytes(pdfBytes);
        showSuccessSnackBar(context, 'PDF saved to: $filePath');
        // Optionally, open the file after saving on mobile/desktop
        // You might need to use a package like 'open_filex' for this.
        // For example: OpenFilex.open(filePath);
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      showFailureSnackBar(context, 'Failed to download PDF: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<InternshipCubit, InternshipState>(
            listener: (context, state) {
              if (state is AttestationLoaded) {
                // This is the correct place to trigger PDF generation and download
                // for Attestation, as AttestationData is now fully available.
                _generateAttestationPdfAndSave(context, state.attestationData);
              } else if (state is AttestationErrorState) {
                showFailureSnackBar(context, state.message);
              } else if (state is InternshipError) {
                showFailureSnackBar(context, state.message);
              }
            },
          ),
          BlocListener<DocumentCubit, DocumentState>(
            listener: (context, state) {
              if (state is DocumentSuccess) {
                showSuccessSnackBar(context, state.message);
                // After successful document save, refresh the list if needed
                context.read<InternshipCubit>().fetchAttestableInternships();
              } else if (state is DocumentError) {
                showFailureSnackBar(context, state.message);
              }
              // Handle URL states for QR code display
              else if (state is DocumentUrlLoaded) {
                _showQrCodeDialog(context, state.url);
              } else if (state is DocumentUrlError) {
                showFailureSnackBar(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<InternshipCubit, InternshipState>(
          builder: (context, state) {
            // Check DocumentCubit's loading states for combined loading indicator
            final isDocumentSaving =
                context.watch<DocumentCubit>().state is DocumentLoading;
            final isDocumentUrlLoading =
                context.watch<DocumentCubit>().state is DocumentUrlLoading;

            if (state is AttestableInternshipsLoading ||
                isDocumentSaving ||
                isDocumentUrlLoading ||
                state is AttestationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AttestableInternshipsLoaded) {
              final internships = state.internships;

              if (internships.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView(
                    // Use ListView to make RefreshIndicator work with empty content
                    children: const [
                      SizedBox(
                        height: 200, // Give some height for the center widget
                        child: Center(
                          child: Text(
                            'No internships currently eligible for attestation or payslips.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: internships.length,
                  itemBuilder: (context, index) {
                    final internship = internships[index];
                    return _buildInternshipCard(context, internship);
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
                      ElevatedButton.icon(
                        onPressed: _onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(
              child: Text('Loading attestable internships...'),
            );
          },
        ),
      ),
    );
  }

  // Helper widget for info rows
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey.shade600),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor ?? Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATED: Helper for Combined Generate/QR Button (using PopupMenuButton) ---
  Widget _buildGenerateAndQrButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onGeneratePressed,
    required VoidCallback onQrPressed,
  }) {
    return PopupMenuButton<String>(
      // Set constraints for the dropdown menu itself
      onSelected: (value) {
        if (value == 'generate') {
          onGeneratePressed();
        } else if (value == 'qr') {
          onQrPressed();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'generate',
          child: Padding(
            // Added Padding to the child
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.blueGrey.shade700,
                ), // Changed icon color
                const SizedBox(width: 12), // Increased spacing
                Text(
                  'Generate PDF',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87, // Darker text color
                    fontWeight: FontWeight.w500, // Slightly bolder
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'qr',
          child: Padding(
            // Added Padding to the child
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: Colors.purple.shade700,
                ), // Distinct color for QR icon
                const SizedBox(width: 12), // Increased spacing
                const Text(
                  'View QR Code',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87, // Darker text color
                    fontWeight: FontWeight.w500, // Slightly bolder
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      offset: const Offset(0, 40), // Adjust offset to appear below button
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white, // Background color of the dropdown menu
      elevation: 8,
      // The child of PopupMenuButton is what is displayed as the button itself
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Keep row compact
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(width: 8), // Space before dropdown arrow
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 24,
            ), // Dropdown arrow
          ],
        ),
      ),
    );
  }

  // --- Internship Card Design with Combined Buttons ---
  Widget _buildInternshipCard(BuildContext context, dynamic internship) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 20, thickness: 1, color: Colors.blueGrey),
            _buildInfoRow(
              context,
              Icons.person,
              'Student:',
              internship.studentName,
            ),
            _buildInfoRow(
              context,
              Icons.supervisor_account,
              'Supervisor:',
              internship.supervisorName ?? 'N/A',
            ),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Period:',
              '${internship.dateDebut} to ${internship.dateFin}',
            ),
            if (internship.estRemunere!)
              _buildInfoRow(
                context,
                Icons.attach_money,
                'Remuneration:',
                '${internship.montantRemuneration?.toStringAsFixed(2) ?? '0.00'} TND',
                valueColor: Colors.green.shade700,
              ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Combined Attestation Button
                _buildGenerateAndQrButton(
                  context,
                  label: 'Certificate',
                  icon: Icons.description,
                  color: Colors.red.shade700,
                  onGeneratePressed: () {
                    // Trigger cubit to fetch AttestationData.
                    // The PDF generation and download will happen in the BlocListener
                    // once AttestationLoaded state is emitted.
                    context.read<InternshipCubit>().fetchAttestationData(
                      internship.internshipID!,
                    );
                  },
                  onQrPressed: () {
                    context.read<DocumentCubit>().fetchAndDisplayDocumentUrl(
                      stageId: internship.internshipID!,
                      pdfType: 'attestation',
                    );
                  },
                ),
                // Combined Fiche de Paie Button (conditional)
                if (internship.estRemunere!)
                  _buildGenerateAndQrButton(
                    context,
                    label: 'Payslip',
                    icon: Icons.receipt_long,
                    color: Colors.blue.shade700,
                    onGeneratePressed: () async {
                      try {
                        final pdfBytes =
                            await PdfGeneratorService.generateSimplePayslipPdf(
                              context,
                              internship,
                            );
                        // Download PDF to client after generation
                        await _downloadPdfToClient(
                          pdfBytes,
                          'payslip_${internship.internshipID}.pdf',
                        );

                        context.read<DocumentCubit>().savePdfDocumentToBackend(
                          stageId: internship.internshipID!,
                          pdfBytes: pdfBytes,
                          pdfType: 'paie',
                          filename: 'payslip_${internship.internshipID}.pdf',
                        );
                      } catch (e) {
                        showFailureSnackBar(
                          context,
                          'Error generating Payslip PDF: ${e.toString()}',
                        );
                      }
                    },
                    onQrPressed: () {
                      context.read<DocumentCubit>().fetchAndDisplayDocumentUrl(
                        stageId: internship.internshipID!,
                        pdfType: 'paie',
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // This function is now correctly triggered by the BlocListener
  // when AttestationData is fully loaded.
  Future<void> _generateAttestationPdfAndSave(
    BuildContext context,
    AttestationData attestationData,
  ) async {
    try {
      final pdfBytes = await PdfGeneratorService.generateAttestationPdf(
        context,
        attestationData, // This is now the correctly fetched AttestationData
      );
      // Download PDF to client after generation
      await _downloadPdfToClient(
        pdfBytes,
        'attestation_${attestationData.internship.stageID}.pdf',
      );

      context.read<DocumentCubit>().savePdfDocumentToBackend(
        stageId: attestationData.internship.stageID,
        pdfBytes: pdfBytes,
        pdfType: 'attestation',
        filename: 'attestation_${attestationData.internship.stageID}.pdf',
      );
    } catch (e) {
      showFailureSnackBar(
        context,
        'Error generating Attestation PDF: ${e.toString()}',
      );
    }
  }

  // --- Show QR Code Dialog Design ---
  void _showQrCodeDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
              minWidth: 280.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scan QR Code to View Document',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(
                    height: 30,
                    thickness: 1,
                    color: Colors.blueGrey,
                  ),
                  if (url.isNotEmpty)
                    Column(
                      children: [
                        QrImageView(
                          data: url,
                          version: QrVersions.auto,
                          size: 200.0,
                          gapless: false,
                          errorStateBuilder: (cxt, err) {
                            return Center(
                              child: Text(
                                'Failed to generate QR code: $err',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          },
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Document URL:',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          url,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              showFailureSnackBar(
                                dialogContext,
                                'Could not open URL.',
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'No URL available to generate QR code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

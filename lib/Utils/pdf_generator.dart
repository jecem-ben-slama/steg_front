// lib/Utils/pdf_generator.dart
import 'dart:typed_data';
import 'package:flutter/material.dart'; // Import for BuildContext (if still needed for fonts etc.)
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:pfa/Repositories/document_repo.dart'; // No longer needed directly here for _sendPdfToBackend
import 'package:printing/printing.dart'; // Still useful for previewing/sharing
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:convert'; // Import for base64Encode
// import 'package:flutter_bloc/flutter_bloc.dart'; // No longer needed directly here for RepositoryProvider.of

import 'package:pfa/Model/attestation_model.dart';
import 'package:pfa/Model/internship_model.dart';

class PdfGeneratorService {
  // The _sendPdfToBackend logic is now moved to Certificates.dart
  // and is called after PDF generation and download.
  // So, this static method is no longer needed here.
  /*
  static Future<void> _sendPdfToBackend({
    required BuildContext context,
    required int stageId,
    required Uint8List pdfBytes,
    required String pdfType,
    required String filename,
  }) async {
    try {
      final documentRepository = RepositoryProvider.of<DocumentRepository>(
        context,
      );

      await documentRepository.savePdfDocumentToBackend(
        stageId: stageId,
        pdfBytes: pdfBytes,
        pdfType: pdfType,
        filename: filename,
      );
      debugPrint('PDF sent to backend and recorded successfully!');
    } catch (e) {
      debugPrint('Error from DocumentRepository during PDF send: $e');
      rethrow;
    }
  }
  */

  static Future<Uint8List> generateAttestationPdf(
    BuildContext context, // Keep BuildContext if you use it for fonts or assets
    AttestationData data,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();

    pw.MemoryImage? qrCodePngBytes;
    if (data.qrCodeData != null && data.qrCodeData!.isNotEmpty) {
      try {
        final qrPainter = QrPainter(
          data: data.qrCodeData!,
          version: QrVersions.auto,
          gapless: false,
          color: const Color.fromARGB(255, 0, 0, 0),
          emptyColor: const Color.fromARGB(255, 255, 255, 255),
        );
        final ui.Image qrCodeUiImage = await qrPainter.toImage(150);
        final ByteData? qrCodeByteData = await qrCodeUiImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        qrCodePngBytes = pw.MemoryImage(qrCodeByteData!.buffer.asUint8List());
      } catch (e) {
        debugPrint('Error generating QR code for PDF: $e');
        qrCodePngBytes = null;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'ATTESTATION DE STAGE',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Nous soussignés, certifions que :',
                  style: pw.TextStyle(font: font, fontSize: 18),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '${data.student.firstName} ${data.student.lastName}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  'Email: ${data.student.email}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'A effectué un stage de type "${data.internship.typeStage}"',
                  style: pw.TextStyle(font: font, fontSize: 18),
                ),
                pw.Text(
                  'Sur le sujet : "${data.subject.title ?? 'Non spécifié'}"',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Période : Du ${data.internship.dateDebut} au ${data.internship.dateFin}',
                  style: pw.TextStyle(font: font, fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Sous la supervision de :',
                  style: pw.TextStyle(font: font, fontSize: 18),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  '${data.supervisor.firstName ?? 'N/A'} ${data.supervisor.lastName ?? ''}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  'Email: ${data.supervisor.email ?? 'N/A'}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Évaluation du stage :',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Note : ${data.evaluation.note.toStringAsFixed(1)} / 10',
                  style: pw.TextStyle(font: font, fontSize: 16),
                ),
                pw.Text(
                  'Commentaires : ${data.evaluation.comments}',
                  style: pw.TextStyle(font: font, fontSize: 16),
                ),
                pw.Text(
                  'Date d\'évaluation : ${data.evaluation.dateEvaluation}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 30),
                // Conditionally display QR Code section
                if (qrCodePngBytes != null)
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Scan to Verify Attestation:',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Image(qrCodePngBytes, width: 100, height: 100),
                        pw.SizedBox(height: 5),
                        // Only show Attestation ID if it's not null
                        if (data.attestationID != null)
                          pw.Text(
                            'Attestation ID: ${data.attestationID}',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 10,
                              color: PdfColors.grey500,
                            ),
                          ),
                      ],
                    ),
                  ),
                pw.SizedBox(height: 30),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Fait à [Votre Ville], le ${DateTime.now().toIso8601String().split('T')[0]}',
                        style: pw.TextStyle(font: font, fontSize: 14),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        '[Nom du Directeur/Responsable]',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '[Titre/Fonction]',
                        style: pw.TextStyle(font: font, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    return pdfBytes; // Return the generated PDF bytes
  }

  static Future<Uint8List> generateSimplePayslipPdf(
    BuildContext context, // Keep BuildContext if you use it for fonts or assets
    dynamic internship, // Assuming this is an InternshipModel or similar
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'FICHE DE PAIE',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Stagiaire: ${internship.studentName}',
                  style: pw.TextStyle(font: font, fontSize: 16),
                ),
                pw.Text(
                  'Période: Du ${internship.dateDebut} au ${internship.dateFin}',
                  style: pw.TextStyle(font: font, fontSize: 16),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Description',
                      style: pw.TextStyle(
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Montant (TND)',
                      style: pw.TextStyle(
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Rémunération de stage',
                      style: pw.TextStyle(font: font),
                    ),
                    pw.Text(
                      '${internship.montantRemuneration?.toStringAsFixed(2) ?? '0.00'} TND',
                      style: pw.TextStyle(font: font),
                    ),
                  ],
                ),
                // Add more items if your payslip has more details
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Net à Payer',
                      style: pw.TextStyle(
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(
                      '${internship.montantRemuneration?.toStringAsFixed(2) ?? '0.00'} TND',
                      style: pw.TextStyle(
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                        color: PdfColors.green,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text(
                    'Date d\'émission: ${DateTime.now().toIso8601String().split('T')[0]}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    return pdfBytes; // Return the generated PDF bytes
  }
}

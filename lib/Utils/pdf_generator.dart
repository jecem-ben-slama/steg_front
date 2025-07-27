// lib/Services/pdf_generator_service.dart
import 'dart:typed_data'; // For Uint8List
// import 'dart:io'; // Removed: For File operations - not needed for web direct share
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading fonts
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// import 'package:path_provider/path_provider.dart'; // Removed: Not reliably supported for direct file saving on web

import 'package:pfa/Model/attestation_model.dart'; // Your attestation data model
import 'package:pfa/Utils/snackbar.dart'; // For snackbars (if you want to show messages from here)

class PdfGeneratorService {
  static Future<Uint8List> generateAttestationPdf(AttestationData data) async {
    final pdf = pw.Document();

    // Load a font that supports a wider range of characters.
    // PdfGoogleFonts.openSansRegular() fetches from Google Fonts.
    // For production, consider bundling a font if offline access is critical.
    final font = await PdfGoogleFonts.openSansRegular();

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
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Fait à Sfax, le ${DateTime.now().toIso8601String().split('T')[0]}',
                        style: pw.TextStyle(font: font, fontSize: 14),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        '[Chef]', // Replace with actual name
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
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

    return pdf.save();
  }

  // Function to directly open/share the PDF bytes, avoiding file system for web
  static Future<void> saveAndOpenPdf(
    Uint8List pdfBytes,
    String filename,
  ) async {
    try {
      // For web, this typically triggers a download. For mobile, it opens a share sheet.
      await Printing.sharePdf(bytes: pdfBytes, filename: '$filename.pdf');
    } catch (e) {
      debugPrint('Error saving or opening PDF: $e');
      // Use your custom snackbar utility
      // You might need to pass a BuildContext or use a GlobalKey<ScaffoldMessengerState>
      // if you want to show a SnackBar directly from this service.
      // For now, let's assume the UI handles the snackbar based on the thrown exception.
      throw Exception('Could not save or open PDF: ${e.toString()}');
    }
  }
}

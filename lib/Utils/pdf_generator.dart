// lib/Services/pdf_generator_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

import 'package:pfa/Model/attestation_model.dart';
import 'package:pfa/Model/internship_model.dart';

class PdfGeneratorService {
  static Future<Uint8List> generateAttestationPdf(AttestationData data) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();

    // Check if qrCodeData is available before attempting to generate QR code
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
        qrCodePngBytes = null; // Set to null if there's an error
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

    return pdf.save();
  }

  // ... (generatePayslipPdf and generateSimplePayslipPdf remain unchanged)

  static Future<Uint8List> generatePayslipPdf(AttestationData data) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'FICHE DE PAIE',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 30,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Company Information (Placeholder)
              pw.Text(
                '[Nom de l\'Organisation/Entreprise]',
                style: pw.TextStyle(font: boldFont, fontSize: 18),
              ),
              pw.Text(
                '[Adresse de l\'Organisation]',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.Text(
                '[Ville, Code Postal]',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              // Employee (Student) Information
              pw.Text(
                'Salarié (Stagiaire):',
                style: pw.TextStyle(font: boldFont, fontSize: 16),
              ),
              pw.Text(
                'Nom: ${data.student.firstName} ${data.student.lastName}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.Text(
                'Email: ${data.student.email}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              // Internship Details
              pw.Text(
                'Détails du Stage:',
                style: pw.TextStyle(font: boldFont, fontSize: 16),
              ),
              pw.Text(
                'Type de Stage: ${data.internship.typeStage}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.Text(
                'Sujet: ${data.subject.title ?? 'Non spécifié'}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.Text(
                'Période: Du ${data.internship.dateDebut} au ${data.internship.dateFin}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              // Remuneration Details
              pw.Text(
                'Détails de la Rémunération:',
                style: pw.TextStyle(font: boldFont, fontSize: 16),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Montant Brut:',
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                  pw.Text(
                    '${data.internship.montantRemuneration?.toStringAsFixed(2) ?? '0.00'} €',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 16,
                      color: PdfColors.green,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Cotisations Sociales (Est.):',
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                  pw.Text(
                    '0.00 €',
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'MONTANT NET À PAYER:',
                    style: pw.TextStyle(font: boldFont, fontSize: 16),
                  ),
                  pw.Text(
                    '${data.internship.montantRemuneration?.toStringAsFixed(2) ?? '0.00'} €',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 18,
                      color: PdfColors.green800,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Signature/Date
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Fait à [Votre Ville], le ${DateTime.now().toIso8601String().split('T')[0]}',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Signature de l\'Employeur',
                      style: pw.TextStyle(font: boldFont, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateSimplePayslipPdf(Internship data) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'FICHE DE PAIE',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 30,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Company Information (Placeholder)
              pw.Text(
                '[Nom de l\'Organisation/Entreprise]',
                style: pw.TextStyle(font: boldFont, fontSize: 18),
              ),
              pw.Text(
                '[Adresse de l\'Organisation]',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.Text(
                '[Ville, Code Postal]',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              // Employee (Student) Information
              pw.Text(
                'Salarié (Stagiaire):',
                style: pw.TextStyle(font: boldFont, fontSize: 16),
              ),
              pw.Text(
                'Nom: ${data.studentName ?? 'N/A'}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.Text(
                'Email: ${data.studentEmail ?? 'N/A'}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              // Internship Details
              pw.Text(
                'Détails du Stage:',
                style: pw.TextStyle(font: boldFont, fontSize: 16),
              ),
              pw.Text(
                'Type de Stage: ${data.typeStage}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.Text(
                'Sujet: ${data.subjectTitle ?? 'Non spécifié'}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.Text(
                'Période: Du ${data.dateDebut} au ${data.dateFin}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              // Remuneration Details
              pw.Text(
                'Détails de la Rémunération:',
                style: pw.TextStyle(font: boldFont, fontSize: 16),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Montant Brut:',
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                  pw.Text(
                    '${data.montantRemuneration?.toStringAsFixed(2) ?? '0.00'} €',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 16,
                      color: PdfColors.green,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Cotisations Sociales (Est.):',
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                  pw.Text(
                    '0.00 €', // Placeholder
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'MONTANT NET À PAYER:',
                    style: pw.TextStyle(font: boldFont, fontSize: 16),
                  ),
                  pw.Text(
                    '${data.montantRemuneration?.toStringAsFixed(2) ?? '0.00'} €',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 18,
                      color: PdfColors.green800,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Signature/Date
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Fait à [Votre Ville], le ${DateTime.now().toIso8601String().split('T')[0]}',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Signature de l\'Employeur',
                      style: pw.TextStyle(font: boldFont, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> saveAndOpenPdf(
    Uint8List pdfBytes,
    String filename,
  ) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: '$filename.pdf');
    } catch (e) {
      debugPrint('Error saving or opening PDF: $e');
      throw Exception('Could not save or open PDF: ${e.toString()}');
    }
  }
}

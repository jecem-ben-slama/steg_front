// lib/Screens/Gestionnaire/attestation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:pfa/Model/attestation_model.dart'; // Import your AttestationData model
import 'package:pfa/Utils/Widgets/attestation_details.dart';

class AttestationDetailScreen extends StatelessWidget {
  final AttestationData attestationData;

  const AttestationDetailScreen({super.key, required this.attestationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attestation Details'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: AttestationDisplayWidget(attestationData: attestationData),
        ),
      ),
    );
  }
}

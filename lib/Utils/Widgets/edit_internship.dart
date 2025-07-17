// lib/Utils/Widgets/internshipeditdialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/internship_cubit.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Utils/snackbar.dart';
import 'package:intl/intl.dart'; // For date formatting

class InternshipEditDialog extends StatefulWidget {
  final Internship internship;

  const InternshipEditDialog({super.key, required this.internship});

  @override
  State<InternshipEditDialog> createState() => InternshipEditDialogState();
}

class InternshipEditDialogState extends State<InternshipEditDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController studentNameController;
  late TextEditingController subjectTitleController;
  late TextEditingController supervisorNameController;
  late TextEditingController typeStageController;
  late TextEditingController dateDebutController;
  late TextEditingController dateFinController;
  late String selectedStatut; // Use a String for dropdown
  late bool estRemunere;
  late TextEditingController montantRemunerationController;

  // These are the canonical status options your dropdown expects
  final List<String> statusOptions = ['Validé', 'En attente', 'Refusé'];

  @override
  void initState() {
    super.initState();
    studentNameController = TextEditingController(
      text: widget.internship.studentName ?? '',
    );
    subjectTitleController = TextEditingController(
      text: widget.internship.subjectTitle ?? '',
    );
    supervisorNameController = TextEditingController(
      text: widget.internship.supervisorName ?? '',
    );
    typeStageController = TextEditingController(
      text: widget.internship.typeStage ?? '',
    );
    dateDebutController = TextEditingController(
      text: widget.internship.dateDebut ?? '',
    );
    dateFinController = TextEditingController(
      text: widget.internship.dateFin ?? '',
    );

    // FIX FOR DROPDOWN ERROR: Normalize the incoming statut string
    String incomingStatut =
        widget.internship.statut ?? 'En attente'; // Default if null
    incomingStatut = incomingStatut.trim(); // Remove leading/trailing spaces

    // Try to find an exact match in statusOptions.
    // If no exact match, fallback to a safe default ('En attente')
    // This ensures selectedStatut always holds a value present in statusOptions.
    if (statusOptions.contains(incomingStatut)) {
      selectedStatut = incomingStatut;
    } else {
      selectedStatut = 'En attente'; // Fallback for unmatched/unknown statuses
      // Consider logging a warning here if you get unexpected status values from the backend.
      print(
        'Warning: Incoming status "${widget.internship.statut}" from backend did not match known options. Defaulting to "En attente".',
      );
    }

    // FIX FOR TYPE ERROR: Ensure estRemunere is always a bool
    // The Internship model's fromJson should now ensure widget.internship.estRemunere is bool?
    estRemunere = widget.internship.estRemunere ?? false;

    // Handle null or invalid numbers for remuneration amount controller
    String initialMontantText;
    if (widget.internship.montantRemuneration != null) {
      initialMontantText = widget.internship.montantRemuneration!
          .toStringAsFixed(2);
    } else {
      initialMontantText = '0.00';
    }
    montantRemunerationController = TextEditingController(
      text: initialMontantText,
    );
  }

  @override
  void dispose() {
    studentNameController.dispose();
    subjectTitleController.dispose();
    supervisorNameController.dispose();
    typeStageController.dispose();
    dateDebutController.dispose();
    dateFinController.dispose();
    montantRemunerationController.dispose();
    super.dispose();
  }

  Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('yyyy-MM-dd').parseStrict(controller.text);
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternshipCubit, InternshipState>(
      listener: (context, state) {
        if (state is InternshipActionSuccess) {
          showSuccessSnackBar(context, state.message);
          Navigator.of(context).pop(); // Close the dialog on success
        } else if (state is InternshipError) {
          showFailureSnackBar(context, 'Error updating: ${state.message}');
          // Don't close the dialog on error, let the user try again
        }
      },
      child: AlertDialog(
        title: const Text('Edit Internship'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display only, not editable as they are typically foreign keys/derived
                TextFormField(
                  controller: studentNameController,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                ),
                TextFormField(
                  controller: subjectTitleController,
                  decoration: const InputDecoration(labelText: 'Subject Title'),
                ),
                TextFormField(
                  controller: supervisorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Supervisor Name',
                  ),
                ),
                TextFormField(
                  controller: typeStageController,
                  decoration: const InputDecoration(
                    labelText: 'Internship Type',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter internship type';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: dateDebutController,
                  decoration: InputDecoration(
                    labelText: 'Start Date (YYYY-MM-DD)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => selectDate(context, dateDebutController),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter start date';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: dateFinController,
                  decoration: InputDecoration(
                    labelText: 'End Date (YYYY-MM-DD)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => selectDate(context, dateFinController),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter end date';
                    }
                    return null;
                  },
                ),
                // Drodown for Status - Initial value is set to selectedStatut
                // onChanged is null because you stated it's not meant to be changed
                DropdownButtonFormField<String>(
                  value: selectedStatut,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged:
                      null, // This makes the dropdown read-only/unchangeable
                  // You can also add `enabled: false` to make it visually disabled if preferred
                  // enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    const Text('Remunerated:'),
                    Switch(
                      value: estRemunere,
                      onChanged: (bool value) {
                        setState(() {
                          estRemunere = value;
                          // If remuneration is turned off, clear the amount
                          if (!estRemunere) {
                            montantRemunerationController.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (estRemunere)
                  TextFormField(
                    controller: montantRemunerationController,
                    decoration: const InputDecoration(
                      labelText: 'Remuneration Amount',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (estRemunere && (value == null || value.isEmpty)) {
                        return 'Please enter remuneration amount';
                      }
                      if (estRemunere && double.tryParse(value ?? '') == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without saving
            },
            child: const Text('Cancel'),
          ),
          BlocBuilder<InternshipCubit, InternshipState>(
            builder: (context, state) {
              // Show loading indicator on button if an update is in progress
              if (state is InternshipLoading) {
                return const CircularProgressIndicator();
              }
              return ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final updatedInternship = Internship(
                      internshipID: widget.internship.internshipID,
                      // Fields that are not editable via form, keep original values
                      studentName: widget.internship.studentName,
                      subjectTitle: widget.internship.subjectTitle,
                      supervisorName: widget.internship.supervisorName,
                      // Editable fields
                      typeStage: typeStageController.text,
                      dateDebut: dateDebutController.text,
                      dateFin: dateFinController.text,
                      statut:
                          selectedStatut, // Use the (normalized) initial value
                      estRemunere: estRemunere,
                      montantRemuneration: estRemunere
                          ? double.tryParse(montantRemunerationController.text)
                          : null, // Parse to double or null
                      // Add other IDs if they are relevant for the update but not shown in UI
                      // e.g., encadrantProID: widget.internship.encadrantProID,
                      // chefCentreValidationID: widget.internship.chefCentreValidationID,
                    );
                    context.read<InternshipCubit>().updateInternship(
                      updatedInternship,
                    );
                  }
                },
                child: const Text('Save'),
              );
            },
          ),
        ],
      ),
    );
  }
}

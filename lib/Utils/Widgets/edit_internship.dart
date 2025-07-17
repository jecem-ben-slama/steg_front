// lib/Utils/Widgets/internship_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/internship_cubit.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Utils/snackbar.dart'; // Assuming you have showSuccessSnackBar and showFailureSnackBar

class EditInternshipPopup extends StatefulWidget {
  final Internship internship;

  const EditInternshipPopup({super.key, required this.internship});

  @override
  State<EditInternshipPopup> createState() => _EditInternshipPopupState();
}

class _EditInternshipPopupState extends State<EditInternshipPopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _studentNameController;
  late TextEditingController _subjectTitleController;
  late TextEditingController _supervisorNameController;
  late TextEditingController _typeStageController;
  late TextEditingController _dateDebutController;
  late TextEditingController _dateFinController;
  late TextEditingController
  _statutController; // For status, might use a dropdown later

  @override
  void initState() {
    super.initState();
    _studentNameController = TextEditingController(
      text: widget.internship.studentName,
    );
    _subjectTitleController = TextEditingController(
      text: widget.internship.subjectTitle,
    );
    _supervisorNameController = TextEditingController(
      text: widget.internship.supervisorName,
    );
    _typeStageController = TextEditingController(
      text: widget.internship.typeStage,
    );
    _dateDebutController = TextEditingController(
      text: widget.internship.dateDebut,
    );
    _dateFinController = TextEditingController(text: widget.internship.dateFin);
    _statutController = TextEditingController(
      text: widget.internship.statut,
    ); // Initialize with current status
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _subjectTitleController.dispose();
    _supervisorNameController.dispose();
    _typeStageController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    _statutController.dispose();
    super.dispose();
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
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _studentNameController,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter student name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _subjectTitleController,
                  decoration: const InputDecoration(labelText: 'Subject Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter subject title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _supervisorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Supervisor Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter supervisor name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _typeStageController,
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
                  controller: _dateDebutController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date (YYYY-MM-DD)',
                  ),
                  // Add date picker logic here later if needed
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter start date';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateFinController,
                  decoration: const InputDecoration(
                    labelText: 'End Date (YYYY-MM-DD)',
                  ),
                  // Add date picker logic here later if needed
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter end date';
                    }
                    return null;
                  },
                ),
                // For status, consider using a DropdownButtonFormField for predefined options
                TextFormField(
                  controller: _statutController,
                  decoration: const InputDecoration(labelText: 'Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter status';
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
              // Show loading indicator on button if an action (delete/update) is in progress
              if (state is InternshipLoading && (state is! InternshipLoaded)) {
                // Ensure it's not a background loading
                return const CircularProgressIndicator();
              }
              return ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedInternship = Internship(
                      internshipID: widget
                          .internship
                          .internshipID, // Keep the original ID
                      studentName: _studentNameController.text,
                      subjectTitle: _subjectTitleController.text,
                      supervisorName: _supervisorNameController.text,
                      typeStage: _typeStageController.text,
                      dateDebut: _dateDebutController.text,
                      dateFin: _dateFinController.text,
                      statut: _statutController.text,
                      // Add other fields from your Internship model if they exist
                      // and are relevant for editing
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

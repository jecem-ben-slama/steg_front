// lib/Utils/Widgets/manage_internships.dart
import 'dart:async'; // Import for Timer

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Cubit/student_cubit.dart';
import 'package:pfa/Model/student_model.dart';
// import 'package:pfa/Model/subject_model.dart'; // REMOVED: Subject model no longer directly used here
import 'package:pfa/Cubit/user_cubit.dart';
import 'package:pfa/Model/user_model.dart';
import 'package:pfa/cubit/internship_cubit.dart';
import 'package:pfa/Utils/snackbar.dart';
// import 'package:pfa/cubit/subject_cubit.dart'; // REMOVED: SubjectCubit no longer needed

class AddInternshipPopup extends StatefulWidget {
  const AddInternshipPopup({super.key});

  @override
  State<AddInternshipPopup> createState() => _AddInternshipPopupState();
}

class _AddInternshipPopupState extends State<AddInternshipPopup> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedInternshipType; // Changed to String? for dropdown value
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  final TextEditingController _montantRemunerationController =
      TextEditingController();

  bool _estRemunere = false;
  Student? _selectedStudent;
  User? _selectedSupervisor;
  User?
  _selectedAcademicSupervisor; // NEW: State variable for academic supervisor

  // Define internship type options
  final List<String> _internshipTypeOptions = ['PFA', 'PFE', 'Stage Ouvrier'];
  List<Student> _students = [];
  List<User> _supervisors = [];
  List<User> _academicSupervisors =
      []; // NEW: List to hold academic supervisors

  @override
  void initState() {
    super.initState();
    context.read<StudentCubit>().fetchStudents();
    context
        .read<UserCubit>()
        .fetchUsers(); // Fetches all users, including academic supervisors
  }

  @override
  void dispose() {
    _dateDebutController.dispose();
    _dateFinController.dispose();
    _montantRemunerationController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _dateDebutController.clear();
    _dateFinController.clear();
    _montantRemunerationController.clear();
    setState(() {
      _selectedInternshipType = null; // Clear selected type
      _estRemunere = false;
      _selectedStudent = null;
      _selectedSupervisor = null;
      _selectedAcademicSupervisor = null; // NEW: Clear academic supervisor
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Basic validation for dropdowns and remuneration amount
    if (_selectedInternshipType == null ||
        _selectedStudent == null ||
        _selectedSupervisor == null) {
      showFailureSnackBar(
        context,
        'Please select Internship Type, Student, and Professional Supervisor.', // Adjusted message for clarity
      );
      return;
    }

    if (_estRemunere && _montantRemunerationController.text.isEmpty) {
      showFailureSnackBar(context, 'Please enter remuneration amount.');
      return;
    }

    // Date validation: ensure dateFin is not before dateDebut
    final DateTime? debutDate = DateTime.tryParse(_dateDebutController.text);
    final DateTime? finDate = DateTime.tryParse(_dateFinController.text);

    if (debutDate != null && finDate != null && finDate.isBefore(debutDate)) {
      showFailureSnackBar(context, 'End Date cannot be before Start Date.');
      return;
    }

    final newInternship = Internship(
      typeStage: _selectedInternshipType, // Use selected value from dropdown
      dateDebut: _dateDebutController.text,
      dateFin: _dateFinController.text,
      statut: "Proposé", // Default status for new internships
      estRemunere: _estRemunere,
      montantRemuneration: _estRemunere
          ? double.tryParse(_montantRemunerationController.text)
          : null,
      etudiantID: _selectedStudent!.studentID,
      encadrantProID: _selectedSupervisor!.userID,
      encadrantAcademiqueID: _selectedAcademicSupervisor
          ?.userID, // NEW: Add academic supervisor ID (can be null)
    );

    // NEW: Debug print the full JSON payload before sending
    debugPrint('--- Full Internship Object to be Added (JSON) ---');
    debugPrint(newInternship.toJson().toString());
    debugPrint('---------------------------------------------------');

    context.read<InternshipCubit>().addInternship(newInternship);
    Navigator.of(context).pop();
    _clearForm();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Internship'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        //* Internship Type Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedInternshipType,
                          decoration: const InputDecoration(
                            labelText: 'Internship Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: _internshipTypeOptions.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedInternshipType = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an internship type.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _dateDebutController,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _selectDate(context, _dateDebutController),
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter start date.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _dateFinController,
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _selectDate(context, _dateFinController),
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter end date.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _estRemunere,
                              onChanged: (bool? value) {
                                setState(() {
                                  _estRemunere = value ?? false;
                                });
                              },
                            ),
                            const Text('Is Remunerated?'),
                          ],
                        ),
                        if (_estRemunere)
                          TextFormField(
                            controller: _montantRemunerationController,
                            decoration: const InputDecoration(
                              labelText: 'Remuneration Amount',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (_estRemunere &&
                                  (value == null || value.isEmpty)) {
                                return 'Please enter remuneration amount.';
                              }
                              if (_estRemunere &&
                                  double.tryParse(value!) == null) {
                                return 'Please enter a valid number.';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 10),
                        //* Student Dropdown
                        BlocBuilder<StudentCubit, StudentState>(
                          builder: (context, state) {
                            if (state is StudentLoaded) {
                              _students = state.students; // Update local list
                              return DropdownButtonFormField<Student>(
                                value: _selectedStudent,
                                decoration: const InputDecoration(
                                  labelText: 'Student',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                items: _students.map((student) {
                                  return DropdownMenuItem<Student>(
                                    value: student,
                                    child: Text(
                                      '${student.username} ${student.lastname}',
                                    ), // Display full name
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStudent = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a student.';
                                  }
                                  return null;
                                },
                              );
                            } else if (state is StudentLoading) {
                              return const LinearProgressIndicator();
                            } else if (state is StudentError) {
                              return Text(
                                'Error loading students: ${state.message}',
                              );
                            }
                            return const SizedBox.shrink(); // Or an error message
                          },
                        ),
                        const SizedBox(height: 10),
                        //* Professional Supervisor Dropdown
                        BlocBuilder<UserCubit, UserState>(
                          builder: (context, state) {
                            if (state is UserLoaded) {
                              // Filter users to only include 'Encadrant' role
                              _supervisors = state.users
                                  .where((user) => user.role == 'Encadrant')
                                  .toList();
                              return DropdownButtonFormField<User>(
                                value: _selectedSupervisor,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Professional Supervisor', // Changed label
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                items: _supervisors.map((user) {
                                  return DropdownMenuItem<User>(
                                    value: user,
                                    child: Text(
                                      '${user.username} ${user.lastname}', // Display full name
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSupervisor = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a professional supervisor.';
                                  }
                                  return null;
                                },
                              );
                            } else if (state is UserLoading) {
                              return const LinearProgressIndicator();
                            } else if (state is UserError) {
                              return Text(
                                'Error loading professional supervisors: ${state.message}',
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 10),
                        //* Academic Supervisor Dropdown (NEW)
                        BlocBuilder<UserCubit, UserState>(
                          builder: (context, state) {
                            if (state is UserLoaded) {
                              // Filter users to only include 'EncadrantAcademique' role
                              _academicSupervisors = state.users
                                  .where(
                                    (user) =>
                                        user.role == 'EncadrantAcademique',
                                  )
                                  .toList();
                              return DropdownButtonFormField<User>(
                                value: _selectedAcademicSupervisor,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Academic Supervisor (Optional)', // Label indicates optional
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.person_pin,
                                  ), // Distinct icon
                                ),
                                items: [
                                  const DropdownMenuItem<User>(
                                    value: null,
                                    child: Text(
                                      'None (Optional)',
                                    ), // Option for null
                                  ),
                                  ..._academicSupervisors.map((user) {
                                    return DropdownMenuItem<User>(
                                      value: user,
                                      child: Text(
                                        '${user.username} ${user.lastname}', // Display full name
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAcademicSupervisor = value;
                                  });
                                },
                                // No validator needed as it's optional
                                validator: (value) {
                                  return null; // Always valid, as it's optional
                                },
                              );
                            } else if (state is UserLoading) {
                              return const LinearProgressIndicator();
                            } else if (state is UserError) {
                              return Text(
                                'Error loading academic supervisors: ${state.message}',
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _clearForm,
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _submitForm,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Internship'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

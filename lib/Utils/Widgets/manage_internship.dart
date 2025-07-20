// lib/Utils/Widgets/manage_internships.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Cubit/student_cubit.dart'; // To fetch students for dropdown
import 'package:pfa/Model/student_model.dart'; // Student model
import 'package:pfa/Cubit/subject_cubit.dart'; // To fetch subjects for dropdown
import 'package:pfa/Model/subject_model.dart'; // Subject model
import 'package:pfa/Cubit/user_cubit.dart'; // To fetch supervisors for dropdown
import 'package:pfa/Model/user_model.dart';
import 'package:pfa/cubit/internship_cubit.dart'; // User model (for supervisors)

class ManageInternshipsDialog extends StatefulWidget {
  const ManageInternshipsDialog({super.key});

  @override
  State<ManageInternshipsDialog> createState() =>
      _ManageInternshipsDialogState();
}

class _ManageInternshipsDialogState extends State<ManageInternshipsDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _typeStageController = TextEditingController();
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  final TextEditingController _montantRemunerationController =
      TextEditingController();

  // Selected dropdown values
  String? _selectedStatut;
  bool _estRemunere = false;
  Student? _selectedStudent;
  Subject? _selectedSubject;
  User? _selectedSupervisor; // Assuming supervisor is a User type

  // Dropdown options
  final List<String> _statutOptions = [
    'Proposé',
    'Validé',
    'Refusé',
    'Annulé',
    'En Cours',
    'Terminé',
  ];
  List<Student> _students = [];
  List<Subject> _subjects = [];
  List<User> _supervisors = [];

  @override
  void initState() {
    super.initState();
    // Fetch all necessary data when dialog initializes
    context.read<StudentCubit>().fetchStudents();
    context.read<SubjectCubit>().fetchSubjects();
    context
        .read<UserCubit>()
        .fetchUsers(); // Assuming supervisors are fetched as users
  }

  @override
  void dispose() {
    _typeStageController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    _montantRemunerationController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _typeStageController.clear();
    _dateDebutController.clear();
    _dateFinController.clear();
    _montantRemunerationController.clear();
    setState(() {
      _selectedStatut = null;
      _estRemunere = false;
      _selectedStudent = null;
      _selectedSubject = null;
      _selectedSupervisor = null;
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Basic validation for dropdowns
    if (_selectedStudent == null ||
        _selectedSubject == null ||
        _selectedSupervisor == null ||
        _selectedStatut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select Student, Subject, Supervisor, and Status.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newInternship = Internship(
      typeStage: _typeStageController.text,
      dateDebut: _dateDebutController.text,
      dateFin: _dateFinController.text,
      statut: _selectedStatut,
      estRemunere: _estRemunere,
      montantRemuneration: _estRemunere
          ? double.tryParse(_montantRemunerationController.text)
          : null,
      etudiantID: _selectedStudent!.studentID,
      sujetID: _selectedSubject!.subjectID,
      encadrantProID: _selectedSupervisor!.userID,
    );

    context.read<InternshipCubit>().addInternship(newInternship);
    Navigator.of(context).pop(); // Close the dialog after submission
    _clearForm();
    // Show success message or handle navigation after adding
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Internship added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
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
        controller.text = picked.toIso8601String().split(
          'T',
        )[0]; // Format YYYY-MM-DD
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
                        TextFormField(
                          controller: _typeStageController,
                          decoration: const InputDecoration(
                            labelText: 'Internship Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter internship type.';
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
                        DropdownButtonFormField<String>(
                          value: _selectedStatut,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.info),
                          ),
                          items: _statutOptions.map((statut) {
                            return DropdownMenuItem(
                              value: statut,
                              child: Text(statut),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatut = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a status.';
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
                        // Student Dropdown
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
                                      '${student.firstName} ${student.lastName}',
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
                            }
                            return const SizedBox.shrink(); // Or an error message
                          },
                        ),
                        const SizedBox(height: 10),
                        // Subject Dropdown
                        BlocBuilder<SubjectCubit, SubjectState>(
                          builder: (context, state) {
                            if (state is SubjectLoaded) {
                              _subjects = state.subjects; // Update local list
                              return DropdownButtonFormField<Subject>(
                                value: _selectedSubject,
                                decoration: const InputDecoration(
                                  labelText: 'Subject',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.menu_book),
                                ),
                                items: _subjects.map((subject) {
                                  return DropdownMenuItem<Subject>(
                                    value: subject,
                                    child: Text(subject.subjectName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSubject = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a subject.';
                                  }
                                  return null;
                                },
                              );
                            } else if (state is SubjectLoading) {
                              return const LinearProgressIndicator();
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 10),
                        // Supervisor Dropdown (Users with 'Encadrant' role)
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
                                  labelText: 'Supervisor',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                items: _supervisors.map((user) {
                                  return DropdownMenuItem<User>(
                                    value: user,
                                    child: Text(
                                      user.username,
                                    ), // Assuming username is supervisor's name
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSupervisor = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a supervisor.';
                                  }
                                  return null;
                                },
                              );
                            } else if (state is UserLoading) {
                              return const LinearProgressIndicator();
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

// Extension to help with firstWhereOrNull, which is not built-in for List
extension IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

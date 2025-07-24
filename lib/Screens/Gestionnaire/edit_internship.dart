import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/internship_cubit.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Utils/snackbar.dart';
import 'package:intl/intl.dart';
import 'package:pfa/Model/user_model.dart';
import 'package:pfa/Model/subject_model.dart';
import 'package:pfa/Cubit/subject_cubit.dart';
import 'package:pfa/Cubit/user_cubit.dart'; // Ensure UserCubit is imported

class InternshipEditDialog extends StatefulWidget {
  final Internship internship;

  const InternshipEditDialog({super.key, required this.internship});

  @override
  State<InternshipEditDialog> createState() => InternshipEditDialogState();
}

class InternshipEditDialogState extends State<InternshipEditDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController studentNameController;
  late TextEditingController
  supervisorNameController; // Keep for initial display if needed, but not for input

  late TextEditingController dateDebutController;
  late TextEditingController dateFinController;
  late String selectedTypeStage;
  late String selectedStatut;
  late bool estRemunere;
  late TextEditingController montantRemunerationController;

  Subject? _selectedSubject;
  List<Subject> _subjects = [];
  bool _isLoadingSubjects = true;

  User? _selectedSupervisor; // NEW: Variable for selected supervisor
  List<User> _supervisors = []; // NEW: List to hold supervisors
  bool _isLoadingSupervisors = true; // NEW: Loading state for supervisors

  final List<String> statusOptions = [
    'Validé',
    'En attente',
    'Refusé',
    'Proposé',
    'Terminé',
  ];

  final List<String> typeStageOptions = [
    'PFE',
    'PFA',
    'Stage Ouvrier',
    'Stage Estival',
    'Observation',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    studentNameController = TextEditingController(
      text: widget.internship.studentName ?? '',
    );
    // Initialize supervisorNameController, but it will be replaced by dropdown
    supervisorNameController = TextEditingController(
      text: widget.internship.supervisorName ?? '',
    );

    String incomingTypeStage = widget.internship.typeStage?.trim() ?? '';
    if (typeStageOptions.contains(incomingTypeStage)) {
      selectedTypeStage = incomingTypeStage;
    } else {
      selectedTypeStage = typeStageOptions.isNotEmpty
          ? typeStageOptions.first
          : '';
      if (incomingTypeStage.isNotEmpty) {
        debugPrint(
          'Warning: Incoming typeStage "$incomingTypeStage" from backend did not match known options. Defaulting to "$selectedTypeStage".',
        );
      }
    }

    dateDebutController = TextEditingController(
      text: widget.internship.dateDebut ?? '',
    );
    dateFinController = TextEditingController(
      text: widget.internship.dateFin ?? '',
    );

    String incomingStatut = widget.internship.statut?.trim() ?? 'En attente';
    if (statusOptions.contains(incomingStatut)) {
      selectedStatut = incomingStatut;
    } else {
      selectedStatut = 'En attente';
      debugPrint(
        'Warning: Incoming status "${widget.internship.statut}" from backend did not match known options. Defaulting to "En attente".',
      );
    }

    estRemunere = widget.internship.estRemunere ?? false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSubjects();
      _fetchSupervisors(); // NEW: Fetch supervisors
    });
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      _isLoadingSubjects = true;
    });

    try {
      await context.read<SubjectCubit>().fetchSubjects();
      final state = context.read<SubjectCubit>().state;
      if (state is SubjectLoaded) {
        setState(() {
          _subjects = state.subjects;
          _selectedSubject = _subjects.firstWhereOrNull(
            (subject) => subject.subjectID == widget.internship.sujetID,
          );
          if (_selectedSubject == null && _subjects.isNotEmpty) {
            _selectedSubject = _subjects.first;
          }
        });
      }
    } catch (e) {
      print('Error fetching subjects: $e');
      if (mounted) {
        showFailureSnackBar(context, 'Failed to load subjects: $e');
      }
    } finally {
      setState(() {
        _isLoadingSubjects = false;
      });
      print(
        'Subjects loading complete. _isLoadingSubjects: $_isLoadingSubjects',
      );
    }
  }

  // NEW: Method to fetch supervisors
  Future<void> _fetchSupervisors() async {
    setState(() {
      _isLoadingSupervisors = true;
    });

    try {
      // Assuming UserCubit fetches all users. You might need to filter them
      // by role (e.g., 'supervisor', 'encadrant') if your backend provides roles.
      await context.read<UserCubit>().fetchUsers();
      final state = context.read<UserCubit>().state;
      if (state is UserLoaded) {
        setState(() {
          // Filter users to only include supervisors.
          // Adjust 'Supervisor' based on your actual User role enumeration/string.
          _supervisors = state.users
              .where(
                (user) => user.role == 'Encadrant' || user.role == 'Admin',
              ) // Adjust roles as per your User model
              .toList();

          // Try to pre-select the current supervisor
          _selectedSupervisor = _supervisors.firstWhereOrNull(
            (user) => user.userID == widget.internship.encadrantProID,
          );
          // If no matching supervisor is found and there are supervisors, select the first one
          if (_selectedSupervisor == null && _supervisors.isNotEmpty) {
            _selectedSupervisor = _supervisors.first;
          }
        });
      }
    } catch (e) {
      print('Error fetching supervisors: $e');
      if (mounted) {
        showFailureSnackBar(context, 'Failed to load supervisors: $e');
      }
    } finally {
      setState(() {
        _isLoadingSupervisors = false;
      });
      print(
        'Supervisors loading complete. _isLoadingSupervisors: $_isLoadingSupervisors',
      );
    }
  }

  @override
  void dispose() {
    studentNameController.dispose();
    supervisorNameController.dispose();
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
    debugPrint('BUILD METHOD - _subjects count: ${_subjects.length}');
    debugPrint(
      'BUILD METHOD - _selectedSubject: ${_selectedSubject?.subjectName ?? "None"}',
    );
    debugPrint('BUILD METHOD - _supervisors count: ${_supervisors.length}');
    debugPrint(
      'BUILD METHOD - _selectedSupervisor: ${_selectedSupervisor?.username ?? "None"}',
    );

    return BlocListener<InternshipCubit, InternshipState>(
      listener: (context, state) {
        if (state is InternshipActionSuccess) {
          showSuccessSnackBar(context, state.message);
          Navigator.of(context).pop();
        } else if (state is InternshipError) {
          showFailureSnackBar(context, 'Error updating: ${state.message}');
          debugPrint('Internship update error: ${state.message}');
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
                TextFormField(
                  controller: studentNameController,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                  readOnly: true,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                // NEW: Supervisor Dropdown
                _isLoadingSupervisors
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      )
                    : (_supervisors.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No supervisors available. Cannot assign.',
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : DropdownButtonFormField<User>(
                              value: _selectedSupervisor,
                              decoration: const InputDecoration(
                                labelText: 'Supervisor',
                                border: OutlineInputBorder(),
                              ),
                              items: _supervisors.map((User user) {
                                return DropdownMenuItem<User>(
                                  value: user,
                                  child: Text(
                                    user.username,
                                  ), // Assuming User has a 'userName' field
                                );
                              }).toList(),
                              onChanged: (User? newValue) {
                                setState(() {
                                  _selectedSupervisor = newValue;
                                  debugPrint(
                                    'Dropdown onChanged: Selected Supervisor: ${_selectedSupervisor?.username}, ID: ${_selectedSupervisor?.userID}',
                                  );
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a supervisor';
                                }
                                return null;
                              },
                            )),
                const SizedBox(height: 16),
                // NEW: Subject Dropdown (existing code)
                _isLoadingSubjects
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      )
                    : (_subjects.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No subjects available. Cannot assign.',
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : DropdownButtonFormField<Subject>(
                              value: _selectedSubject,
                              decoration: const InputDecoration(
                                labelText: 'Subject',
                                border: OutlineInputBorder(),
                              ),
                              items: _subjects.map((Subject subject) {
                                return DropdownMenuItem<Subject>(
                                  value: subject,
                                  child: Text(subject.subjectName),
                                );
                              }).toList(),
                              onChanged: (Subject? newValue) {
                                setState(() {
                                  _selectedSubject = newValue;
                                  debugPrint(
                                    'Dropdown onChanged: Selected Subject: ${_selectedSubject?.subjectName}, ID: ${_selectedSubject?.subjectID}',
                                  );
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a subject';
                                }
                                return null;
                              },
                            )),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTypeStage,
                  decoration: const InputDecoration(
                    labelText: 'Internship Type',
                    border: OutlineInputBorder(),
                  ),
                  items: typeStageOptions.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTypeStage = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an internship type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dateDebutController,
                  decoration: InputDecoration(
                    labelText: 'Start Date (YYYY-MM-DD)',
                    border: const OutlineInputBorder(),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: dateFinController,
                  decoration: InputDecoration(
                    labelText: 'End Date (YYYY-MM-DD)',
                    border: const OutlineInputBorder(),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatut,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatut = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Remunerated:'),
                    Switch(
                      value: estRemunere,
                      onChanged: (bool value) {
                        setState(() {
                          estRemunere = value;
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
                      border: OutlineInputBorder(),
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
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          BlocBuilder<InternshipCubit, InternshipState>(
            builder: (context, state) {
              if (state is InternshipLoading) {
                return const CircularProgressIndicator();
              }
              return ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final updatedInternship = Internship(
                      internshipID: widget.internship.internshipID,
                      etudiantID: widget.internship.etudiantID,
                      // NEW: Use selected supervisor ID
                      encadrantProID: _selectedSupervisor?.userID,
                      sujetID: _selectedSubject?.subjectID,
                      typeStage: selectedTypeStage,
                      dateDebut: dateDebutController.text,
                      dateFin: dateFinController.text,
                      statut: selectedStatut,
                      estRemunere: estRemunere,
                      montantRemuneration: estRemunere
                          ? double.tryParse(montantRemunerationController.text)
                          : null,
                      // These fields are often populated on the backend or derived,
                      // so we omit them if not directly editable by the user in this dialog.
                      // If you need to update them, ensure you have the correct source.
                      studentName:
                          widget.internship.studentName, // Keep original
                      supervisorName: _selectedSupervisor
                          ?.username, // Update with selected supervisor's name
                      subjectTitle: _selectedSubject
                          ?.subjectName, // Update with selected subject's name
                    );

                    debugPrint(
                      '--- Flutter Debug: Sending Internship Update ---',
                    );
                    debugPrint(
                      'Internship ID: ${updatedInternship.internshipID}',
                    );
                    debugPrint('Type Stage: ${updatedInternship.typeStage}');
                    debugPrint('Date Debut: ${updatedInternship.dateDebut}');
                    debugPrint('Date Fin: ${updatedInternship.dateFin}');
                    debugPrint('Statut: ${updatedInternship.statut}');
                    debugPrint(
                      'Est Remunere: ${updatedInternship.estRemunere}',
                    );
                    debugPrint(
                      'Montant Remuneration: ${updatedInternship.montantRemuneration}',
                    );
                    debugPrint('New Sujet ID: ${updatedInternship.sujetID}');
                    debugPrint(
                      'New Supervisor ID: ${updatedInternship.encadrantProID}',
                    ); // Debug new supervisor ID
                    debugPrint('-------------------------------------------');

                    context.read<InternshipCubit>().editInternship(
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

// Extension method for convenience
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

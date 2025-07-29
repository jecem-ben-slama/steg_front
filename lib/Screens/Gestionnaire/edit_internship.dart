import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/internship_cubit.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Utils/snackbar.dart';
import 'package:intl/intl.dart';
import 'package:pfa/Model/user_model.dart';
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
  supervisorNameController; // This will be deprecated for dropdown

  late TextEditingController dateDebutController;
  late TextEditingController dateFinController;
  late String selectedTypeStage;
  late bool estRemunere;
  late TextEditingController montantRemunerationController;

  User? _selectedSupervisor; // Variable for selected professional supervisor
  User?
  _selectedAcademicSupervisor; // NEW: Variable for selected academic supervisor
  List<User> _supervisors = []; // List to hold professional supervisors
  List<User> _academicSupervisors =
      []; // NEW: List to hold academic supervisors
  bool _isLoadingSupervisors =
      true; // Loading state for professional supervisors
  bool _isLoadingAcademicSupervisors =
      true; // NEW: Loading state for academic supervisors

  final List<String> typeStageOptions = [
    'PFE',
    'PFA',
    'Stage Ouvrier',
    'Observation',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    studentNameController = TextEditingController(
      text: widget.internship.studentName ?? '',
    );
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

    // Debug print the incoming academic supervisor ID
    debugPrint(
      'InternshipEditDialog: Initial widget.internship.encadrantAcademiqueID: ${widget.internship.encadrantAcademiqueID}',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsersAndSetSupervisors(); // Combined fetch and selection
    });
  }

  // NEW: Combined method to fetch all users and set selected supervisors
  Future<void> _loadUsersAndSetSupervisors() async {
    setState(() {
      _isLoadingSupervisors = true;
      _isLoadingAcademicSupervisors = true;
    });

    try {
      await context.read<UserCubit>().fetchUsers(); // Fetch all users
      final state = context.read<UserCubit>().state;
      if (state is UserLoaded) {
        setState(() {
          // Populate professional supervisors
          _supervisors = state.users
              .where((user) => user.role == 'Encadrant' || user.role == 'Admin')
              .toList();

          // Populate academic supervisors
          _academicSupervisors = state.users
              .where((user) => user.role == 'EncadrantAcademique')
              .toList();

          // Try to pre-select the current professional supervisor
          _selectedSupervisor = _supervisors.firstWhereOrNull(
            (user) => user.userID == widget.internship.encadrantProID,
          );
          // If no matching professional supervisor is found and there are supervisors, select the first one
          if (_selectedSupervisor == null && _supervisors.isNotEmpty) {
            _selectedSupervisor = _supervisors.first;
          }

          // Try to pre-select the current academic supervisor
          _selectedAcademicSupervisor = _academicSupervisors.firstWhereOrNull(
            (user) => user.userID == widget.internship.encadrantAcademiqueID,
          );
        });
      }
    } catch (e) {
      print('Error fetching users for supervisors: $e');
      if (mounted) {
        showFailureSnackBar(context, 'Failed to load supervisors: $e');
      }
    } finally {
      setState(() {
        _isLoadingSupervisors = false;
        _isLoadingAcademicSupervisors = false;
      });
      print(
        'All Supervisors loading complete. _isLoadingSupervisors: $_isLoadingSupervisors, _isLoadingAcademicSupervisors: $_isLoadingAcademicSupervisors',
      );
    }
  }

  @override
  void dispose() {
    studentNameController.dispose();
    supervisorNameController.dispose(); // Still dispose, though less used
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
    debugPrint('BUILD METHOD - _supervisors count: ${_supervisors.length}');
    debugPrint(
      'BUILD METHOD - _selectedSupervisor: ${_selectedSupervisor?.username ?? "None"}',
    );
    debugPrint(
      'BUILD METHOD - _academicSupervisors count: ${_academicSupervisors.length}',
    );
    debugPrint(
      'BUILD METHOD - _selectedAcademicSupervisor: ${_selectedAcademicSupervisor?.username ?? "None"}',
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
                //* Student Name Field
                TextFormField(
                  controller: studentNameController,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                  readOnly: true, // Make it non-editable
                  enabled: false, // Visually disable it
                ),
                //* Subject Title Field
                TextFormField(
                  controller: TextEditingController(
                    text: widget.internship.subjectTitle ?? '',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Subject Title',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // Make it non-editable
                  enabled: false, // Visually disable it
                ),
                const SizedBox(height: 16),
                //* Status
                TextFormField(
                  controller: TextEditingController(
                    text: widget.internship.statut ?? '',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // Make it non-editable
                  enabled: false, // Visually disable it
                ),
                const SizedBox(height: 16),
                //* Professional Supervisor Dropdown
                _isLoadingSupervisors
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      )
                    : (_supervisors.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No professional supervisors available. Cannot assign.',
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : DropdownButtonFormField<User>(
                              value: _selectedSupervisor,
                              decoration: const InputDecoration(
                                labelText:
                                    'Professional Supervisor', // Updated label
                                border: OutlineInputBorder(),
                              ),
                              items: _supervisors.map((User user) {
                                return DropdownMenuItem<User>(
                                  value: user,
                                  child: Text(
                                    '${user.username} ${user.lastname}', // Display full name
                                  ),
                                );
                              }).toList(),
                              onChanged: (User? newValue) {
                                setState(() {
                                  _selectedSupervisor = newValue;
                                  debugPrint(
                                    'Dropdown onChanged: Selected Professional Supervisor: ${_selectedSupervisor?.username}, ID: ${_selectedSupervisor?.userID}',
                                  );
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a professional supervisor';
                                }
                                return null;
                              },
                            )),
                const SizedBox(height: 16),
                //* Academic Supervisor Dropdown (NEW)
                _isLoadingAcademicSupervisors
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      )
                    : (_academicSupervisors.isEmpty &&
                              _selectedAcademicSupervisor == null
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No academic supervisors available.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : DropdownButtonFormField<User>(
                              value: _selectedAcademicSupervisor,
                              decoration: const InputDecoration(
                                labelText: 'Academic Supervisor (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<User>(
                                  value: null,
                                  child: Text('None (Optional)'),
                                ),
                                ..._academicSupervisors.map((User user) {
                                  return DropdownMenuItem<User>(
                                    value: user,
                                    child: Text(
                                      '${user.username} ${user.lastname}',
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (User? newValue) {
                                setState(() {
                                  _selectedAcademicSupervisor = newValue;
                                  debugPrint(
                                    'Dropdown onChanged: Selected Academic Supervisor: ${_selectedAcademicSupervisor?.username}, ID: ${_selectedAcademicSupervisor?.userID}',
                                  );
                                });
                              },
                              validator: (value) {
                                return null; // This field is optional
                              },
                            )),
                const SizedBox(height: 16),
                //* Type Stage Dropdown
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
                //* Start Date Field
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
                //* End Date Field
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

                //* Remuneration
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
                  //* Show remuneration amount field only if remunerated
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
                      // Use selected supervisor ID
                      encadrantProID: _selectedSupervisor?.userID,
                      encadrantAcademiqueID: _selectedAcademicSupervisor
                          ?.userID, // NEW: Add academic supervisor ID
                      sujetID:
                          widget.internship.sujetID, // Keep original sujetID
                      typeStage: selectedTypeStage,
                      dateDebut: dateDebutController.text,
                      dateFin: dateFinController.text,
                      statut: widget.internship.statut, // Keep original statut
                      estRemunere: estRemunere,
                      montantRemuneration: estRemunere
                          ? double.tryParse(montantRemunerationController.text)
                          : null,
                      studentName:
                          widget.internship.studentName, // Keep original
                      supervisorName: _selectedSupervisor
                          ?.username, // Update with selected professional supervisor's name
                      subjectTitle:
                          widget.internship.subjectTitle, // Keep original
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
                    debugPrint(
                      'Original Sujet ID: ${widget.internship.sujetID}',
                    ); // Debug original sujet ID
                    debugPrint(
                      'New Professional Supervisor ID: ${updatedInternship.encadrantProID}',
                    ); // Debug new professional supervisor ID
                    debugPrint(
                      'New Academic Supervisor ID: ${updatedInternship.encadrantAcademiqueID}',
                    ); // NEW: Debug new academic supervisor ID
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

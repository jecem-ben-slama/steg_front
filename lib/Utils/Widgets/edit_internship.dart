import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/internship_cubit.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Repositories/user_repo.dart';
import 'package:pfa/Utils/snackbar.dart';
import 'package:intl/intl.dart';
import 'package:pfa/Model/user_model.dart';
import 'package:dio/dio.dart';

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
  late String selectedTypeStage;
  late TextEditingController dateDebutController;
  late TextEditingController dateFinController;
  late String selectedStatut;
  late bool estRemunere;
  late TextEditingController montantRemunerationController;

  List<User> _supervisors = [];
  User? _selectedSupervisor;
  bool _isLoadingSupervisors = true;

  final List<String> statusOptions = [
    'Validé',
    'En attente',
    'Refusé',
    'Proposé',
  ];

  final List<String> typeStageOptions = [
    'PFE',
    'Été',
    'Observation',
    'Stage Ouvrier',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    studentNameController = TextEditingController(
      text: widget.internship.studentName ?? '',
    );
    subjectTitleController = TextEditingController(
      text: widget.internship.subjectTitle ?? '',
    );

    String incomingTypeStage = widget.internship.typeStage ?? '';
    incomingTypeStage = incomingTypeStage.trim();

    if (typeStageOptions.contains(incomingTypeStage)) {
      selectedTypeStage = incomingTypeStage;
    } else {
      selectedTypeStage = typeStageOptions.isNotEmpty
          ? typeStageOptions.first
          : '';
      if (incomingTypeStage.isNotEmpty) {
        print(
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

    String incomingStatut = widget.internship.statut ?? 'En attente';
    incomingStatut = incomingStatut.trim();

    if (statusOptions.contains(incomingStatut)) {
      selectedStatut = incomingStatut;
    } else {
      selectedStatut = 'En attente';
      print(
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

    print(
      'INIT STATE - Internship encadrantProID: ${widget.internship.encadrantProID}',
    );
    print(
      'INIT STATE - Internship supervisorName: ${widget.internship.supervisorName}',
    );

    _fetchSupervisors();
  }

  Future<void> _fetchSupervisors() async {
    setState(() {
      _isLoadingSupervisors = true;
      _supervisors = [];
      _selectedSupervisor = null;
    });
    try {
      final userRepository = RepositoryProvider.of<UserRepository>(context);

      print('Fetching supervisors with role "Encadrant"...');
      final encadrantUsers = await userRepository.fetchUsersByRole('Encadrant');
      print('Fetched ${encadrantUsers.length} supervisors from backend.');
      for (var user in encadrantUsers) {
        print('  - Supervisor: ${user.username}, ID: ${user.userID}');
      }

      setState(() {
        _supervisors = encadrantUsers;

        if (widget.internship.encadrantProID != null) {
          _selectedSupervisor = _supervisors.firstWhereOrNull(
            (s) => s.userID == widget.internship.encadrantProID,
          );
          print(
            'Attempted to pre-select supervisor by ID: ${widget.internship.encadrantProID}, Found: ${_selectedSupervisor?.username ?? "NOT FOUND"}',
          );
        }

        if (_selectedSupervisor == null &&
            widget.internship.supervisorName != null) {
          _selectedSupervisor = _supervisors.firstWhereOrNull(
            (s) => s.username == widget.internship.supervisorName,
          );
          print(
            'Attempted to pre-select supervisor by Name (fallback): ${widget.internship.supervisorName}, Found: ${_selectedSupervisor?.username ?? "NOT FOUND"}',
          );
        }
        print(
          'Final _selectedSupervisor after fetch: ${_selectedSupervisor?.username ?? "None"} (ID: ${_selectedSupervisor?.userID ?? "N/A"})',
        );
      });
    } on DioException catch (e) {
      print('Dio error fetching supervisors: ${e.message}');
      if (e.response != null) {
        print('Dio error response data: ${e.response?.data}');
      }
      showFailureSnackBar(context, 'Network error: ${e.message}');
    } catch (e) {
      print('Error fetching supervisors: $e');
      showFailureSnackBar(context, 'Failed to load supervisors: $e');
    } finally {
      setState(() {
        _isLoadingSupervisors = false;
        print(
          'Supervisors loading complete. _isLoadingSupervisors: $_isLoadingSupervisors',
        );
      });
    }
  }

  @override
  void dispose() {
    studentNameController.dispose();
    subjectTitleController.dispose();
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
    print('BUILD METHOD - _supervisors count: ${_supervisors.length}');
    print(
      'BUILD METHOD - _selectedSupervisor: ${_selectedSupervisor?.username ?? "None"}',
    );

    return BlocListener<InternshipCubit, InternshipState>(
      listener: (context, state) {
        if (state is InternshipActionSuccess) {
          showSuccessSnackBar(context, state.message);
          Navigator.of(context).pop();
        } else if (state is InternshipError) {
          showFailureSnackBar(context, 'Error updating: ${state.message}');
          print('Internship update error: ${state.message}');
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
                TextFormField(
                  controller: subjectTitleController,
                  decoration: const InputDecoration(labelText: 'Subject Title'),
                  readOnly: true,
                  enabled: false,
                ),
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
                              ),
                            )
                          : DropdownButtonFormField<User>(
                              value: _selectedSupervisor,
                              decoration: const InputDecoration(
                                labelText: 'Supervisor Name',
                                border: OutlineInputBorder(),
                              ),
                              items: _supervisors.map((User supervisor) {
                                return DropdownMenuItem<User>(
                                  value: supervisor,
                                  child: Text(supervisor.username),
                                );
                              }).toList(),
                              onChanged: (User? newValue) {
                                setState(() {
                                  _selectedSupervisor = newValue;
                                  print(
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
                              selectedItemBuilder: (context) {
                                return _supervisors.map<Widget>((User item) {
                                  return Text(item.username);
                                }).toList();
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
                  onChanged: null,
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
                      studentName: widget.internship.studentName,
                      subjectTitle: widget.internship.subjectTitle,
                      supervisorName: _selectedSupervisor?.username,
                      encadrantProID: _selectedSupervisor?.userID,
                      typeStage: selectedTypeStage,
                      dateDebut: dateDebutController.text,
                      dateFin: dateFinController.text,
                      statut: selectedStatut,
                      estRemunere: estRemunere,
                      montantRemuneration: estRemunere
                          ? double.tryParse(montantRemunerationController.text)
                          : null,
                    );

                    print('--- Flutter Debug: Sending Internship Update ---');
                    print('Internship ID: ${updatedInternship.internshipID}');
                    print('Type Stage: ${updatedInternship.typeStage}');
                    print('Date Debut: ${updatedInternship.dateDebut}');
                    print('Date Fin: ${updatedInternship.dateFin}');
                    print('Statut: ${updatedInternship.statut}');
                    print('Est Remunere: ${updatedInternship.estRemunere}');
                    print(
                      'Montant Remuneration: ${updatedInternship.montantRemuneration}',
                    );
                    print(
                      'Supervisor Name (from dropdown): ${updatedInternship.supervisorName}',
                    );
                    print(
                      'EncadrantPro ID (from dropdown): ${updatedInternship.encadrantProID}',
                    );
                    print('-------------------------------------------');

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

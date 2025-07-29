import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/encadrant_internships_model.dart';
import 'package:pfa/Model/subject_model.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';
import 'package:pfa/cubit/subject_cubit.dart';

class AssignSubjectDialog extends StatefulWidget {
  final AssignedInternship internship;

  const AssignSubjectDialog({super.key, required this.internship});

  @override
  State<AssignSubjectDialog> createState() => _AssignSubjectDialogState();
}

class _AssignSubjectDialogState extends State<AssignSubjectDialog> {
  Subject? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Subject to ${widget.internship.studentFirstName} ${widget.internship.studentLastName} '),
      content: SingleChildScrollView(
        child: BlocConsumer<SubjectCubit, SubjectState>(
          listener: (context, state) {
            // Optional: You could show a snackbar here if a subject action
            // (like add/update/delete) happened within the SubjectCubit context,
            // though for this dialog, we mostly care about loading and errors.
            if (state is SubjectActionSuccess && state.actionType == 'assign') {
              Navigator.of(context).pop(); // Close dialog on success
            }
          },
          builder: (context, state) {
            if (state is SubjectLoading) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Loading subjects...'),
                ],
              );
            } else if (state is SubjectLoaded) {
              if (state.subjects.isEmpty) {
                return const Text('No subjects available.');
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Subject>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Select Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: state.subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.subjectName),
                      );
                    }).toList(),
                    onChanged: (Subject? newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectedSubject == null
                        ? null
                        : () {
                            // Call the cubit method to assign the subject
                            context
                                .read<EncadrantCubit>()
                                .assignSubjectToInternship(
                                  widget.internship.stageID,
                                  _selectedSubject!.subjectID!,
                                );
                            Navigator.of(context).pop(); // Close the dialog
                          },
                    child: const Text('Assign'),
                  ),
                ],
              );
            } else if (state is SubjectError) {
              return Text('Error loading subjects: ${state.message}');
            }
            return const Text('Select a subject to assign.');
          },
        ),
      ),
    );
  }
}

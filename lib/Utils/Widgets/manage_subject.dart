// lib/Utils/Widgets/manage_subject.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/subject_cubit.dart'; 
import 'package:pfa/Model/subject_model.dart'; 

class ManageSubjects extends StatefulWidget {
  const ManageSubjects({super.key});

  @override
  State<ManageSubjects> createState() => _ManageSubjectsState();
}

class _ManageSubjectsState extends State<ManageSubjects> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Subject? _editingSubject;
  bool _isFormVisible = false;

  @override
  void initState() {
    super.initState();
    // Fetch subjects when the dialog is initialized
    context.read<SubjectCubit>().fetchSubjects();
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _subjectNameController.clear();
    _descriptionController.clear();
    setState(() {
      _editingSubject = null;
    });
  }

  void _populateForm(Subject subject) {
    _subjectNameController.text = subject.subjectName;
    _descriptionController.text = subject.description ?? '';
    setState(() {
      _editingSubject = subject;
      _isFormVisible = true; // Show the form when populating for editing
    });
  }

  void _submitForm() {
    if (_subjectNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subject Name cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newSubject = Subject(
      subjectID: _editingSubject?.subjectID, // Retain ID if editing
      subjectName: _subjectNameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
    );

    if (_editingSubject == null) {
      context.read<SubjectCubit>().addSubject(newSubject);
    } else {
      context.read<SubjectCubit>().updateSubject(newSubject);
    }
    _clearForm(); // Clear form fields
    _toggleFormVisibility(); // Hide the form after submission
  }

  void _deleteSubject(int subjectId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this Subject?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SubjectCubit>().deleteSubject(subjectId);
              Navigator.of(ctx).pop(); // Close the confirmation dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleFormVisibility() {
    setState(() {
      _isFormVisible = !_isFormVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Subjects'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7, // Responsive width
        height: MediaQuery.of(context).size.height * 0.8, // Responsive height
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _editingSubject == null ? 'Add New Subject' : 'Edit Subject',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: _toggleFormVisibility,
                  icon: Icon(
                    _isFormVisible
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                  ),
                  tooltip: _isFormVisible ? 'Hide Form' : 'Show Form',
                ),
              ],
            ),
            // AnimatedSwitcher for smooth form visibility
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: _isFormVisible
                  ? Padding(
                      key: const ValueKey(
                        'SubjectForm',
                      ), // Unique key for AnimatedSwitcher
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: _subjectNameController,
                              decoration: const InputDecoration(
                                labelText: 'Subject Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.menu_book),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description (Optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              maxLines:
                                  3, // Allow multi-line input for description
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
                                  icon: Icon(
                                    _editingSubject == null
                                        ? Icons.add
                                        : Icons.save,
                                  ),
                                  label: Text(
                                    _editingSubject == null
                                        ? 'Add Subject'
                                        : 'Update Subject',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
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
                    )
                  : const SizedBox.shrink(),
            ),
            const Divider(height: 30, thickness: 1),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Existing Subjects',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocConsumer<SubjectCubit, SubjectState>(
                // Use SubjectCubit
                listener: (context, state) {
                  if (state is SubjectActionSuccess) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is SubjectError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SubjectLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SubjectLoaded) {
                    if (state.subjects.isEmpty) {
                      return const Center(
                        child: Text(
                          'No subjects found. Add one using the form above!',
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = state.subjects[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(subject.subjectName[0].toUpperCase()),
                            ),
                            title: Text(
                              subject.subjectName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Description: ${subject.description ?? 'N/A'}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _populateForm(subject),
                                  tooltip: 'Edit Subject',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _deleteSubject(subject.subjectID!),
                                  tooltip: 'Delete Subject',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is SubjectError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  // Initial state or unexpected state, show a default message
                  return const Center(
                    child: Text('Start managing Subjects by adding one above.'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

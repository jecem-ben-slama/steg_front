import 'dart:async'; // Import for Timer

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/subject_cubit.dart';
import 'package:pfa/Model/subject_model.dart';

// Enum to define message types for styling
enum MessageType { success, info, error, none }

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variables for displaying messages within the popup
  String? _displayMessage;
  MessageType _displayMessageType = MessageType.none;
  Timer? _messageTimer; // Timer to clear the message automatically

  @override
  void initState() {
    super.initState();
    context.read<SubjectCubit>().fetchSubjects();
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _descriptionController.dispose();
    _messageTimer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  void _clearForm() {
    _subjectNameController.clear();
    _descriptionController.clear();
    setState(() {
      _editingSubject = null;
      _isFormVisible = false; // Hide form after clearing for new entry
    });
    _clearMessage(); // Clear any displayed message when form is cleared
  }

  void _populateForm(Subject subject) {
    _subjectNameController.text = subject.subjectName;
    _descriptionController.text = subject.description ?? '';
    setState(() {
      _editingSubject = subject;
      _isFormVisible = true; // Show the form when populating for editing
    });
    _clearMessage(); // Clear any displayed message when populating form
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      _displayMessageInPopup(
        'Please fill in all required fields.',
        MessageType.error,
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

    _clearForm(); // Clear form fields after submission
  }

  void _deleteSubject(int subjectId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this Subject?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(), // Close confirmation dialog
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
      if (!_isFormVisible) {
        _clearForm(); // Clear form when hiding if not editing
      }
    });
  }

  // Helper to display message within the popup
  void _displayMessageInPopup(String message, MessageType type) {
    setState(() {
      _displayMessage = message;
      _displayMessageType = type;
    });

    // Cancel any existing timer
    _messageTimer?.cancel();
    // Start a new timer to clear the message after 3 seconds
    _messageTimer = Timer(const Duration(seconds: 3), () {
      _clearMessage();
    });
  }

  // Helper to clear the displayed message
  void _clearMessage() {
    setState(() {
      _displayMessage = null;
      _displayMessageType = MessageType.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Subjects'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Message display area
            AnimatedOpacity(
              opacity: _displayMessage != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _displayMessage != null
                  ? Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        color: _displayMessageType == MessageType.success
                            ? Colors.green.withOpacity(0.1)
                            // Removed SubjectActionInfo case, now info is treated as success visually
                            : _displayMessageType ==
                                  MessageType
                                      .info // This case will now be unreachable if SubjectActionInfo is removed from Cubit
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: _displayMessageType == MessageType.success
                              ? Colors.green
                              : _displayMessageType ==
                                    MessageType
                                        .info // This case will now be unreachable
                              ? Colors.blue
                              : Colors.red,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _displayMessageType == MessageType.success
                                ? Icons.check_circle_outline
                                : _displayMessageType ==
                                      MessageType
                                          .info // This case will now be unreachable
                                ? Icons.info_outline
                                : Icons.error_outline,
                            color: _displayMessageType == MessageType.success
                                ? Colors.green
                                : _displayMessageType ==
                                      MessageType
                                          .info // This case will now be unreachable
                                ? Colors.blue
                                : Colors.red,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _displayMessage!,
                              style: TextStyle(
                                color:
                                    _displayMessageType == MessageType.success
                                    ? Colors.green.shade800
                                    : _displayMessageType ==
                                          MessageType
                                              .info // This case will now be unreachable
                                    ? Colors.blue.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: _isFormVisible
                  ? Padding(
                      key: const ValueKey('SubjectForm'),
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _subjectNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Subject Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.menu_book),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Subject Name cannot be empty.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description (Optional)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.description),
                                ),
                                maxLines: 3,
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
                listener: (context, state) {
                  // Listen for action-specific success/error messages
                  if (state is SubjectActionSuccess) {
                    _displayMessageInPopup(state.message, MessageType.success);
                  } else if (state is SubjectError) {
                    _displayMessageInPopup(state.message, MessageType.error);
                  }
                  // SubjectActionInfo is no longer emitted by Cubit
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
                    // If the error occurred during initial fetch, show the error message.
                    // Otherwise, the list will be shown, and the message in the AnimatedOpacity.
                    if (state.lastLoadedSubjects == null ||
                        state.lastLoadedSubjects!.isEmpty) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const SizedBox.shrink(); // Message handled by AnimatedOpacity
                  }
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

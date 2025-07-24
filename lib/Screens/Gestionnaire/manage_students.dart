// lib/Utils/Widgets/manage_student.dart
import 'dart:async'; // Import for Timer

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/student_cubit.dart'; // Make sure this path is correct
import 'package:pfa/Model/student_model.dart'; // Make sure this path is correct

// Enum to define message types for styling (same as for subjects)
enum MessageType { success, info, error, none }

class ManageStudents extends StatefulWidget {
  const ManageStudents({super.key});

  @override
  State<ManageStudents> createState() => _ManageStudentsState();
}

class _ManageStudentsState extends State<ManageStudents> {
  // Update controllers to match database columns
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController cinController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController niveauEtudeController = TextEditingController();
  final TextEditingController nomFaculteController = TextEditingController();
  final TextEditingController cycleController = TextEditingController();
  final TextEditingController specialiteController = TextEditingController();

  Student? editingStudent;
  bool isFormVisible = false;

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added GlobalKey for form validation

  // State variables for displaying messages within the popup
  String? _displayMessage;
  MessageType _displayMessageType = MessageType.none;
  Timer? _messageTimer; // Timer to clear the message automatically

  @override
  void initState() {
    super.initState();
    // Ensure data is fetched when the dialog opens
    context.read<StudentCubit>().fetchStudents();
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    usernameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    majorController.dispose();
    levelController.dispose();
    cinController.dispose();
    phoneNumberController.dispose();
    niveauEtudeController.dispose();
    nomFaculteController.dispose();
    cycleController.dispose();
    specialiteController.dispose();
    _messageTimer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  void _clearForm() {
    // Renamed to _clearForm for consistency
    usernameController.clear();
    lastnameController.clear();
    emailController.clear();
    majorController.clear();
    levelController.clear();
    cinController.clear();
    phoneNumberController.clear();
    niveauEtudeController.clear();
    nomFaculteController.clear();
    cycleController.clear();
    specialiteController.clear();
    setState(() {
      editingStudent = null;
      isFormVisible = false; // Hide form after clearing for new entry
    });
    _clearMessage(); // Clear any displayed message when form is cleared
  }

  void _populateForm(Student student) {
    // Renamed to _populateForm for consistency
    // Populate controllers with student data
    usernameController.text = student.username;
    lastnameController.text = student.lastname;
    emailController.text = student.email;
    majorController.text = student.major ?? '';
    levelController.text = student.level ?? '';
    cinController.text = student.cin ?? '';
    phoneNumberController.text = student.phoneNumber ?? '';
    niveauEtudeController.text = student.niveauEtude ?? '';
    nomFaculteController.text = student.nomFaculte ?? '';
    cycleController.text = student.cycle ?? '';
    specialiteController.text = student.specialite ?? '';
    setState(() {
      editingStudent = student;
      isFormVisible = true; // Show the form when populating for editing
    });
    _clearMessage(); // Clear any displayed message when populating form
  }

  Future<void> _submitForm() async {
    // Renamed to _submitForm for consistency
    if (!_formKey.currentState!.validate()) {
      // Validate the form
      _displayMessageInPopup(
        'Please fill in all required fields.',
        MessageType.error,
      );
      return;
    }

    final newStudent = Student(
      studentID: editingStudent?.studentID, // Use studentID for updates
      userID: editingStudent?.userID, // Preserve userID if editing
      username: usernameController.text,
      lastname: lastnameController.text,
      email: emailController.text,
      major: majorController.text.isNotEmpty ? majorController.text : null,
      level: levelController.text.isNotEmpty ? levelController.text : null,
      cin: cinController.text.isNotEmpty ? cinController.text : null,
      phoneNumber: phoneNumberController.text.isNotEmpty
          ? phoneNumberController.text
          : null,
      niveauEtude: niveauEtudeController.text.isNotEmpty
          ? niveauEtudeController.text
          : null,
      nomFaculte: nomFaculteController.text.isNotEmpty
          ? nomFaculteController.text
          : null,
      cycle: cycleController.text.isNotEmpty ? cycleController.text : null,
      specialite: specialiteController.text.isNotEmpty
          ? specialiteController.text
          : null,
    );

    try {
      if (editingStudent == null) {
        await context.read<StudentCubit>().addStudent(newStudent);
      } else {
        await context.read<StudentCubit>().updateStudent(newStudent);
      }
      _clearForm(); // Clear form fields and hide form after submission
    } catch (e) {
      // The Cubit will emit StudentError, which the BlocConsumer listener will catch
      // and display the message in the popup. No need for extra handling here.
    }
  }

  void _deleteStudent(int studentId) {
    // Renamed to _deleteStudent for consistency
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this Student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the confirmation dialog
              try {
                await context.read<StudentCubit>().deleteStudent(studentId);
              } catch (e) {
                // The Cubit will emit StudentError, which the BlocConsumer listener will catch.
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleFormVisibility() {
    // Renamed to _toggleFormVisibility for consistency
    setState(() {
      isFormVisible = !isFormVisible;
      if (!isFormVisible) {
        _clearForm(); // Clear form if hiding and not editing
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
    _messageTimer = Timer(const Duration(seconds: 7), () {
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
      title: const Text('Manage Students'),
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
                            : _displayMessageType ==
                                  MessageType
                                      .info // This case might be unused if Cubit doesn't emit info
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: _displayMessageType == MessageType.success
                              ? Colors.green
                              : _displayMessageType ==
                                    MessageType
                                        .info // This case might be unused
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
                                          .info // This case might be unused
                                ? Icons.info_outline
                                : Icons.error_outline,
                            color: _displayMessageType == MessageType.success
                                ? Colors.green
                                : _displayMessageType ==
                                      MessageType
                                          .info // This case might be unused
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
                                              .info // This case might be unused
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
                  editingStudent == null ? 'Add New Student' : 'Edit Student',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () {
                    if (isFormVisible && editingStudent != null) {
                      _clearForm(); // Clear form if hiding and in edit mode
                    }
                    _toggleFormVisibility(); // Use the renamed method
                  },
                  icon: Icon(
                    isFormVisible
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                  ),
                  tooltip: isFormVisible ? 'Hide Form' : 'Show Form',
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: isFormVisible
                  ? Padding(
                      key: const ValueKey('UserForm'),
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Form(
                          // Added Form widget
                          key: _formKey, // Assigned GlobalKey
                          child: Column(
                            children: [
                              // Row 1: First Name and Last Name
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: usernameController,
                                      decoration: const InputDecoration(
                                        labelText: 'First Name',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'First Name cannot be empty.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: lastnameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Last Name',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Last Name cannot be empty.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Row 2: Email and Major
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.email),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Email cannot be empty.';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Please enter a valid email.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: majorController,
                                      decoration: const InputDecoration(
                                        labelText: 'Major',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.science),
                                      ),
                                      // No validator if optional
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Row 3: Level and CIN
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: levelController,
                                      decoration: const InputDecoration(
                                        labelText: 'Level',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.trending_up),
                                      ),
                                      // No validator if optional
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: cinController,
                                      decoration: const InputDecoration(
                                        labelText: 'CIN',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.credit_card),
                                      ),
                                      // No validator if optional
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Row 4: Phone Number and Niveau d'étude
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: phoneNumberController,
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.phone),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      // No validator if optional
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: niveauEtudeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Niveau d\'étude',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.school),
                                      ),
                                      // No validator if optional
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Row 5: Nom de la Faculté and Cycle
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: nomFaculteController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nom de la Faculté',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.apartment),
                                      ),
                                      // No validator if optional
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      // Changed to TextFormField for validation
                                      controller: cycleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Cycle',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.repeat),
                                      ),
                                      // No validator if optional
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Row 6: Spécialité (can be a single field if no pair)
                              TextFormField(
                                // Changed to TextFormField for validation
                                controller: specialiteController,
                                decoration: const InputDecoration(
                                  labelText: 'Spécialité',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.category),
                                ),
                                // No validator if optional
                              ),
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _clearForm, // Use renamed method
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Clear'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed:
                                        _submitForm, // Use renamed method
                                    icon: Icon(
                                      editingStudent == null
                                          ? Icons.add
                                          : Icons.save,
                                    ),
                                    label: Text(
                                      editingStudent == null
                                          ? 'Add Student'
                                          : 'Update Student',
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
                'Existing Students',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocConsumer<StudentCubit, StudentState>(
                listener: (context, state) {
                  // Listen for action-specific success/error messages
                  if (state is StudentActionSuccess) {
                    _displayMessageInPopup(state.message, MessageType.success);
                  } else if (state is StudentError) {
                    _displayMessageInPopup(state.message, MessageType.error);
                  }
                  // StudentActionInfo state handling would go here if it existed
                },
                builder: (context, state) {
                  if (state is StudentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StudentLoaded) {
                    if (state.students.isEmpty) {
                      return const Center(
                        child: Text(
                          'No students found. Add one using the form above!',
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.students.length,
                      itemBuilder: (context, index) {
                        final student = state.students[index];
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
                              child: Text(student.username[0].toUpperCase()),
                            ),
                            title: Text(
                              '${student.username} ${student.lastname}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${student.email}'),
                                if (student.major != null &&
                                    student.major!.isNotEmpty)
                                  Text('Major: ${student.major}'),
                                if (student.level != null &&
                                    student.level!.isNotEmpty)
                                  Text('Level: ${student.level}'),
                                if (student.cin != null &&
                                    student.cin!.isNotEmpty)
                                  Text('CIN: ${student.cin}'),
                                if (student.phoneNumber != null &&
                                    student.phoneNumber!.isNotEmpty)
                                  Text('Phone: ${student.phoneNumber}'),
                                if (student.niveauEtude != null &&
                                    student.niveauEtude!.isNotEmpty)
                                  Text(
                                    'Niveau d\'étude: ${student.niveauEtude}',
                                  ),
                                if (student.nomFaculte != null &&
                                    student.nomFaculte!.isNotEmpty)
                                  Text('Faculté: ${student.nomFaculte}'),
                                if (student.cycle != null &&
                                    student.cycle!.isNotEmpty)
                                  Text('Cycle: ${student.cycle}'),
                                if (student.specialite != null &&
                                    student.specialite!.isNotEmpty)
                                  Text('Spécialité: ${student.specialite}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _populateForm(
                                    student,
                                  ), // Use renamed method
                                  tooltip: 'Edit Student',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    if (student.studentID != null) {
                                      _deleteStudent(
                                        student.studentID!,
                                      ); // Use renamed method
                                    }
                                  },
                                  tooltip: 'Delete Student',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('Loading students or no data yet.'),
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

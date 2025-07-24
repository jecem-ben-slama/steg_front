import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/student_cubit.dart'; // Make sure this path is correct
import 'package:pfa/Model/student_model.dart'; // Make sure this path is correct

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
  final TextEditingController majorController =
      TextEditingController(); // From Student model
  final TextEditingController levelController =
      TextEditingController(); // From Student model
  final TextEditingController cinController =
      TextEditingController(); // From Student model
  final TextEditingController phoneNumberController =
      TextEditingController(); // From Student model
  final TextEditingController niveauEtudeController =
      TextEditingController(); // From Student model
  final TextEditingController nomFaculteController =
      TextEditingController(); // From Student model
  final TextEditingController cycleController =
      TextEditingController(); // From Student model
  final TextEditingController specialiteController =
      TextEditingController(); // From Student model

  Student? editingStudent;
  bool isFormVisible = false;

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
    super.dispose();
  }

  void clearForm() {
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
    });
  }

  void populateForm(Student student) {
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
  }

  Future<void> submitForm() async {
    // Create new Student object with all database fields
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully!')),
        );
      } else {
        await context.read<StudentCubit>().updateStudent(newStudent);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated successfully!')),
        );
      }
      clearForm();
      toggleFormVisibility(); // Hide the form after submission
    } catch (e) {
      // The Cubit will emit StudentError, which the BlocConsumer listener will catch.
      // So no need for an extra SnackBar here, but you could add more specific handling if desired.
    }
  }

  void deleteStudent(int studentId) {
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
              Navigator.of(ctx).pop(); // Close the dialog first
              try {
                await context.read<StudentCubit>().deleteStudent(studentId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student deleted successfully!'),
                  ),
                );
              } catch (e) {
                // The Cubit will emit StudentError, which the BlocConsumer listener will catch.
                // You might want to display a more specific error message here if needed.
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void toggleFormVisibility() {
    setState(() {
      isFormVisible = !isFormVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Manage Students',
      ), // Changed from Supervisors to Students
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  editingStudent == null
                      ? 'Add New Student'
                      : 'Edit Student', // Changed text
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () {
                    if (isFormVisible && editingStudent != null) {
                      clearForm(); // Clear form if hiding and in edit mode
                    }
                    toggleFormVisibility();
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
                      //* Form for adding/editing students
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Row 1: First Name and Last Name
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: usernameController,
                                    decoration: const InputDecoration(
                                      labelText: 'First Name',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: lastnameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Row 2: Email and Major
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: majorController,
                                    decoration: const InputDecoration(
                                      labelText: 'Major',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.science),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Row 3: Level and CIN
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: levelController,
                                    decoration: const InputDecoration(
                                      labelText: 'Level',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.trending_up),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: cinController,
                                    decoration: const InputDecoration(
                                      labelText: 'CIN',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.credit_card),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Row 4: Phone Number and Niveau d'étude
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: phoneNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.phone),
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: niveauEtudeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Niveau d\'étude',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.school),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Row 5: Nom de la Faculté and Cycle
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: nomFaculteController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nom de la Faculté',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.apartment),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: cycleController,
                                    decoration: const InputDecoration(
                                      labelText: 'Cycle',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.repeat),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Row 6: Spécialité (can be a single field if no pair)
                            TextField(
                              controller: specialiteController,
                              decoration: const InputDecoration(
                                labelText: 'Spécialité',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: clearForm,
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Clear'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: submitForm,
                                  icon: Icon(
                                    editingStudent == null
                                        ? Icons.add
                                        : Icons.save,
                                  ),
                                  label: Text(
                                    editingStudent == null
                                        ? 'Add Student' // Changed text
                                        : 'Update Student', // Changed text
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
                'Existing Students', // Changed from Supervisors to Students
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocConsumer<StudentCubit, StudentState>(
                listener: (context, state) {
                  if (state is StudentError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is StudentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StudentLoaded) {
                    if (state.students.isEmpty) {
                      return const Center(
                        child: Text(
                          'No students found. Add one using the form above!', // Changed text
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
                              child: Text(
                                student.username[0].toUpperCase(),
                              ), // Changed to username initial
                            ),
                            title: Text(
                              // Display username and lastname
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
                                  onPressed: () => populateForm(student),
                                  tooltip: 'Edit Student',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    // Ensure studentID is not null before deleting
                                    if (student.studentID != null) {
                                      deleteStudent(student.studentID!);
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
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

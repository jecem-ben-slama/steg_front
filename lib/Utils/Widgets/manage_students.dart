import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/student_cubit.dart';
import 'package:pfa/Model/student_model.dart';
// Adjust path

class ManageStudents extends StatefulWidget {
  const ManageStudents({super.key});

  @override
  State<ManageStudents> createState() => _ManageStudentsState();
}

class _ManageStudentsState extends State<ManageStudents> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController majorController =
      TextEditingController(); // Renamed for clarity
  Student? editingStudent;
  bool isFormVisible = false; // Renamed for clarity

  @override
  void initState() {
    super.initState();
    context.read<StudentCubit>().fetchStudents();
  }

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    majorController.clear();
    setState(() {
      editingStudent = null;
    });
  }

  void populateForm(Student student) {
    firstNameController.text = student.firstName;
    // Adjusted to match student model
    lastNameController.text = student.lastName;
    emailController.text = student.email;
    majorController.text = student.major ?? ''; // Assuming major is the role
    setState(() {
      editingStudent = student;
      isFormVisible = true; // Show the form when populating for editing
    });
  }

  void submitForm() {
    final newStudent = Student(
      studentID: editingStudent?.studentID,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      major: majorController.text,
    );

    if (editingStudent == null) {
      context.read<StudentCubit>().addStudent(newStudent);
    } else {
      context.read<StudentCubit>().updateStudent(newStudent);
    }
    clearForm();
    toggleFormVisibility(); // Hide the form after submission
  }

  void deleteStudent(int studentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this User?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StudentCubit>().deleteStudent(studentId);
              Navigator.of(ctx).pop();
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
      title: const Text('Manage Supervisors'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Toggle Button and Title for the Form Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  editingStudent == null ? 'Add New User' : 'Edit User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: toggleFormVisibility,
                  icon: Icon(
                    isFormVisible
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                  ),
                  tooltip: isFormVisible ? 'Hide Form' : 'Show Form',
                ),
              ],
            ),
            // AnimatedSwitcher for smooth form visibility
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: isFormVisible
                  ? Padding(
                      key: const ValueKey(
                        'UserForm',
                      ), // Key is important for AnimatedSwitcher
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: majorController,
                              decoration: const InputDecoration(
                                labelText: 'major (e.g., Supervisor, Admin)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge),
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
                                        ? 'Add User'
                                        : 'Update User',
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
                  : const SizedBox.shrink(), // Show nothing when hidden
            ),
            const Divider(height: 30, thickness: 1), // A clearer divider
            // User List Section Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Existing Supervisors',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocConsumer<StudentCubit, StudentState>(
                listener: (context, state) {
                  if (state is StudentActionSuccess) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is StudentError) {
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
                          'No supervisors found. Add one using the form above!',
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
                          elevation: 3, // Add some shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                student.firstName[0].toUpperCase(),
                              ), // First letter of Studentname
                            ),
                            title: Text(
                              '${student.firstName} ${student.lastName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${student.email}'),
                                Text('major: ${student.major ?? 'N/A'}'),
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
                                  onPressed: () =>
                                      deleteStudent(student.studentID!),
                                  tooltip: 'Delete Student',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is StudentError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(
                    child: Text('Start managing Students by adding one above.'),
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

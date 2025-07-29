import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/student_cubit.dart'; // Make sure this path is correct
import 'package:pfa/Model/student_model.dart';
import 'package:pfa/Utils/Consts/validator.dart'; // Assuming you have a Validators class

// Enum to define message types for styling
enum MessageType { success, info, error, none }

class ManageStudentsPopup extends StatefulWidget {
  const ManageStudentsPopup({super.key});

  @override
  State<ManageStudentsPopup> createState() => _ManageStudentsPopupState();
}

class _ManageStudentsPopupState extends State<ManageStudentsPopup> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cinController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Student? editingStudent;
  bool isFormVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _displayMessage;
  MessageType _displayMessageType = MessageType.none;
  Timer? _messageTimer;

  // Lists for dropdown options
  final List<String> niveauEtudeOptions = ['Anneé 1', 'Anneé 2', 'Anneé 3'];

  final List<String> facultesOptions = [
    "FST",
    "ISTIC",
    "ISET",
    "FSEG",
    "Ecole Ingernieur",
  ];

  final List<String> specialitiesOptions = ["Info", "Electronique", "Reseau"];

  final List<String> cycleOptions = ["Licence", "Master", "ingénierie"];

  // State variables for selected dropdown values
  String? selectedNiveauEtude;
  String? selectedFaculte;
  String? selectedSpeciality;
  String? selectedCycle;

  @override
  void initState() {
    super.initState();
    context.read<StudentCubit>().fetchStudents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    usernameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    cinController.dispose();
    _messageTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _clearForm() {
    usernameController.clear();
    lastnameController.clear();
    emailController.clear();
    cinController.clear();
    setState(() {
      selectedNiveauEtude = null;
      selectedFaculte = null;
      selectedSpeciality = null;
      selectedCycle = null;
      editingStudent = null;
      isFormVisible = false;
    });
    _clearMessage();
  }

  void _populateForm(Student student) {
    usernameController.text = student.username;
    lastnameController.text = student.lastname;
    emailController.text = student.email;
    cinController.text = student.cin ?? '';
    setState(() {
      selectedNiveauEtude = student.niveau_etude;
      selectedFaculte = student.faculte;
      selectedCycle = student.cycle;
      selectedSpeciality = student.specialite;
      editingStudent = student;
      isFormVisible = true;
    });

    // --- Debugging Prints (Keep these for verification) ---
    debugPrint(
      'Populating form for student: ${student.username} ${student.lastname}',
    );
    debugPrint('Student.niveau_etude: ${student.niveau_etude}');
    debugPrint('Student.faculte: ${student.faculte}');
    debugPrint('Assigned selectedNiveauEtude: $selectedNiveauEtude');
    debugPrint('Assigned selectedFaculte: $selectedFaculte');
    // --- End Debugging Prints ---

    _clearMessage();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _displayMessageInPopup(
        'Please fill in all required fields.',
        MessageType.error,
      );
      return;
    }

    final newStudent = Student(
      studentID: editingStudent?.studentID, // Use studentID for updates
      username: usernameController.text,
      lastname: lastnameController.text,
      email: emailController.text,
      cin: cinController.text.isNotEmpty ? cinController.text : null,
      // Ensure these properties match your Student model's constructor
      niveau_etude:
          selectedNiveauEtude, // Ensure this is snake_case in your model
      faculte: selectedFaculte, // Ensure this is snake_case in your model
      cycle: selectedCycle,
      specialite: selectedSpeciality,
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
    setState(() {
      isFormVisible = !isFormVisible;
      if (!isFormVisible) {
        _clearForm();
      }
    });
  }

  void _displayMessageInPopup(String message, MessageType type) {
    setState(() {
      _displayMessage = message;
      _displayMessageType = type;
    });

    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 7), () {
      _clearMessage();
    });
  }

  void _clearMessage() {
    setState(() {
      _displayMessage = null;
      _displayMessageType = MessageType.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 202, 218, 236),
      title: const Center(child: Text('Manage Students')),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.55,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            //* Display a message in case of success, info, or error
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
                            : _displayMessageType == MessageType.info
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: _displayMessageType == MessageType.success
                              ? Colors.green
                              : _displayMessageType == MessageType.info
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
                                : _displayMessageType == MessageType.info
                                ? Icons.info_outline
                                : Icons.error_outline,
                            color: _displayMessageType == MessageType.success
                                ? Colors.green
                                : _displayMessageType == MessageType.info
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
                                    : _displayMessageType == MessageType.info
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
                    _toggleFormVisibility();
                  },
                  icon: Icon(isFormVisible ? Icons.arrow_circle_up : Icons.add),
                  tooltip: isFormVisible ? 'Hide Form' : 'Show Form',
                ),
              ],
            ),
            //* Form for adding/editing a student
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
                          key: _formKey,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: usernameController,
                                      decoration: const InputDecoration(
                                        labelText: "First Name",
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                      validator: Validators.validateName,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
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

                              // Row 2: Email
                              TextFormField(
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
                              const SizedBox(height: 10),

                              // Row 3: CIN and Niveau d'étude (Dropdown)
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: cinController,
                                      decoration: const InputDecoration(
                                        labelText: 'CIN',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.credit_card),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedNiveauEtude,
                                      decoration: const InputDecoration(
                                        labelText: 'Niveau d\'étude',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.school),
                                      ),
                                      items: niveauEtudeOptions
                                          .map<DropdownMenuItem<String>>((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedNiveauEtude = newValue;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a Niveau d\'étude.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Row 4: Faculté (Dropdown) and Cycle (Dropdown)
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedFaculte,
                                      decoration: const InputDecoration(
                                        labelText: 'Faculté',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.apartment),
                                      ),
                                      items: facultesOptions
                                          .map<DropdownMenuItem<String>>((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          })
                                          .toList(),

                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedFaculte = newValue;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a Faculté.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedCycle,
                                      decoration: const InputDecoration(
                                        labelText: 'Cycle',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.repeat),
                                      ),
                                      items: cycleOptions
                                          .map<DropdownMenuItem<String>>((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCycle = newValue;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a Cycle.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Row 5: Spécialité (Dropdown)
                              DropdownButtonFormField<String>(
                                value: selectedSpeciality,
                                decoration: const InputDecoration(
                                  labelText: 'Spécialité',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.category),
                                ),
                                items: specialitiesOptions
                                    .map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    })
                                    .toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedSpeciality = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a Spécialité.';
                                  }
                                  return null;
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
            // Modified Row for "Existing Students" and Search Bar
            isFormVisible
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Existing Students',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2, // Give more space to the search bar
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Students',
                              hintText: 'Search by name, email, CIN...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 10),
            isFormVisible
                ? const SizedBox.shrink()
                : Expanded(
                    child: BlocConsumer<StudentCubit, StudentState>(
                      listener: (context, state) {
                        // Listen for action-specific success/info/error messages
                        if (state is StudentActionSuccess) {
                          _displayMessageInPopup(
                            state.message,
                            MessageType.success,
                          );
                        } else if (state is StudentError) {
                          _displayMessageInPopup(
                            state.message,
                            MessageType.error,
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is StudentLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is StudentLoaded) {
                          // Filter students based on search query
                          final filteredStudents = state.students.where((
                            student,
                          ) {
                            final query = _searchQuery;
                            return student.username.toLowerCase().contains(
                                  query,
                                ) ||
                                student.lastname.toLowerCase().contains(
                                  query,
                                ) ||
                                student.email.toLowerCase().contains(query) ||
                                (student.cin?.toLowerCase().contains(query) ??
                                    false);
                          }).toList();

                          if (filteredStudents.isEmpty) {
                            return Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? 'No students found. Add one using the form above!'
                                    : 'No students found matching "${_searchController.text}".',
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 8,
                                ),
                                elevation: 2,
                                child: ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(
                                    '${student.username} ${student.lastname}',
                                  ),
                                  subtitle: Text(student.email),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _populateForm(student),
                                        tooltip: 'Edit Student',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deleteStudent(student.studentID!),
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
                          child: Text('No students to display.'),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

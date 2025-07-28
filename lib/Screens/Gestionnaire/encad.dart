// lib/Screens/Gestionnaire/manage_academic_supervisor.dart
import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/encad_cubit.dart'; // Import your EncadrantCubit
import 'package:pfa/Model/encadrant_model.dart'; // Import your Encadrant model
import 'package:pfa/Utils/Consts/validator.dart'; // Assuming you have a Validators class

// Enum to define message types for styling
enum MessageType { success, info, error, none }

class ManageAcademicSupervisorPopup extends StatefulWidget {
  const ManageAcademicSupervisorPopup({super.key});

  @override
  State<ManageAcademicSupervisorPopup> createState() =>
      _ManageAcademicSupervisorPopupState();
}

class _ManageAcademicSupervisorPopupState
    extends State<ManageAcademicSupervisorPopup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // New: Controller for the search bar
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // State variable to hold the current search query

  Encadrant? editingEncadrant; // Holds the encadrant being edited
  bool isFormVisible = false; // Controls visibility of the add/edit form
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key for validation
  String? _displayMessage;
  MessageType _displayMessageType = MessageType.none;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    // Fetch encadrants when the popup is initialized
    context.read<EncadrantCubit1>().fetchEncadrants();

    // Add listener to search controller for real-time filtering
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    nameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _messageTimer?.cancel(); // Cancel any active timer
    super.dispose();
  }

  // Updates the search query and triggers a UI rebuild
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Clears all form fields and resets the editing state
  void _clearForm() {
    nameController.clear();
    lastnameController.clear();
    emailController.clear();
    setState(() {
      editingEncadrant = null;
      isFormVisible = false; // Hide form after clearing
    });
    _clearMessage(); // Clear any displayed messages
  }

  // Populates the form fields with data from an existing Encadrant for editing
  void _populateForm(Encadrant encadrant) {
    nameController.text = encadrant.name;
    lastnameController.text = encadrant.lastname;
    emailController.text = encadrant.email ?? ''; // Handle nullable email
    setState(() {
      editingEncadrant = encadrant;
      isFormVisible = true; // Show form when editing
    });
    _clearMessage(); // Clear any previous messages
  }

  // Handles form submission (add or update)
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _displayMessageInPopup(
        'Please fill in all required fields correctly.',
        MessageType.error,
      );
      return;
    }

    final newEncadrant = Encadrant(
      encadrantID: editingEncadrant?.encadrantID, // Preserve ID for updates
      name: nameController.text,
      lastname: lastnameController.text,
      email: emailController.text.isNotEmpty
          ? emailController.text
          : null, // Send null if empty
    );

    try {
      if (editingEncadrant == null) {
        // Add new encadrant
        await context.read<EncadrantCubit1>().addEncadrant(newEncadrant);
      } else {
        // Update existing encadrant (implement this in your Cubit/Repository later)
        // For now, we'll just show a message.
        _displayMessageInPopup(
          'Update functionality for academic supervisors is not yet implemented.',
          MessageType.info,
        );
        // await context.read<EncadrantCubit>().updateEncadrant(newEncadrant);
      }
      _clearForm(); // Clear form fields and hide form after successful submission
    } catch (e) {
      // The Cubit will emit EncadrantError, which the BlocConsumer listener will catch
      // and display the message in the popup. No need for extra handling here.
    }
  }

  // Handles deleting an encadrant (placeholder for now)
  void _deleteEncadrant(int encadrantId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this Academic Supervisor?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the confirmation dialog
              // Implement delete functionality in your Cubit/Repository later
              _displayMessageInPopup(
                'Delete functionality for academic supervisors is not yet implemented.',
                MessageType.info,
              );
              // try {
              //   await context.read<EncadrantCubit>().deleteEncadrant(encadrantId);
              // } catch (e) {
              //   // The Cubit will emit EncadrantError, which the BlocConsumer listener will catch.
              // }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Toggles the visibility of the add/edit form
  void _toggleFormVisibility() {
    setState(() {
      isFormVisible = !isFormVisible;
      if (!isFormVisible) {
        _clearForm(); // Clear form if hiding it
      }
    });
  }

  // Displays a message in the popup for a short duration
  void _displayMessageInPopup(String message, MessageType type) {
    setState(() {
      _displayMessage = message;
      _displayMessageType = type;
    });

    _messageTimer?.cancel(); // Cancel any existing timer
    _messageTimer = Timer(const Duration(seconds: 7), () {
      _clearMessage(); // Clear the message after 7 seconds
    });
  }

  // Clears the currently displayed message
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
      title: const Center(child: Text('Manage Academic Supervisors')),
      content: SizedBox(
        width:
            MediaQuery.of(context).size.width * 0.55, // Adjust width as needed
        height:
            MediaQuery.of(context).size.height * 0.7, // Adjust height as needed
        child: Column(
          children: [
            // Display a message in case of success, info, or error
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
                  editingEncadrant == null
                      ? 'Add New Supervisor'
                      : 'Edit Supervisor',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: _toggleFormVisibility,
                  icon: Icon(isFormVisible ? Icons.arrow_circle_up : Icons.add),
                  tooltip: isFormVisible ? 'Hide Form' : 'Show Form',
                ),
              ],
            ),
            // Form for adding/editing an academic supervisor
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: isFormVisible
                  ? Padding(
                      key: const ValueKey('EncadrantForm'),
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
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        labelText: "Name",
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                      validator: Validators
                                          .validateName, // Using your validator
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
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email (Optional)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      !value.contains('@')) {
                                    return 'Please enter a valid email.';
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
                                      editingEncadrant == null
                                          ? Icons.add
                                          : Icons.save,
                                    ),
                                    label: Text(
                                      editingEncadrant == null
                                          ? 'Add Supervisor'
                                          : 'Update Supervisor',
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
            // Section for existing academic supervisors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Existing Academic Supervisors',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2, // Give more space to the search bar
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Supervisors',
                        hintText: 'Search by name, email...',
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
            Expanded(
              child: BlocConsumer<EncadrantCubit1, EncadrantState>(
                listener: (context, state) {
                  // Listen for action-specific success/error messages
                  if (state is EncadrantOperationSuccess) {
                    _displayMessageInPopup(state.message, MessageType.success);
                  } else if (state is EncadrantAddedSuccess) {
                    _displayMessageInPopup(
                      'Encadrant ${state.newEncadrant.name} added successfully!',
                      MessageType.success,
                    );
                  } else if (state is EncadrantError) {
                    _displayMessageInPopup(state.message, MessageType.error);
                  }
                },
                builder: (context, state) {
                  if (state is EncadrantLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is EncadrantLoaded) {
                    // Filter encadrants based on search query
                    final filteredEncadrants = state.encadrants.where((
                      encadrant,
                    ) {
                      final query = _searchQuery;
                      return encadrant.name.toLowerCase().contains(query) ||
                          encadrant.lastname.toLowerCase().contains(query) ||
                          (encadrant.email?.toLowerCase().contains(query) ??
                              false);
                    }).toList();

                    if (filteredEncadrants.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No academic supervisors found. Add one using the form above!'
                              : 'No academic supervisors found matching "${_searchController.text}".',
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: filteredEncadrants.length,
                      itemBuilder: (context, index) {
                        final encadrant = filteredEncadrants[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 8,
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(
                              '${encadrant.name} ${encadrant.lastname}',
                            ),
                            subtitle: Text(encadrant.email ?? 'No Email'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _populateForm(encadrant),
                                  tooltip: 'Edit Supervisor',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _deleteEncadrant(encadrant.encadrantID!),
                                  tooltip: 'Delete Supervisor',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is EncadrantError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(
                    child: Text('No academic supervisors to display.'),
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

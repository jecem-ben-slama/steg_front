// lib/Widgets/manage_supervisors_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/user_cubit.dart'; // Using your existing UserCubit
import 'package:pfa/Model/user_model.dart'; // Using your existing User model
import 'package:pfa/Utils/Widgets/add_edit_user.dart';
import 'package:pfa/Utils/snackbar.dart'; // Assuming you have this utility

class ManageSupervisorsDialog extends StatefulWidget {
  const ManageSupervisorsDialog({super.key});

  @override
  State<ManageSupervisorsDialog> createState() =>
      _ManageSupervisorsDialogState();
}

class _ManageSupervisorsDialogState extends State<ManageSupervisorsDialog> {
  @override
  void initState() {
    super.initState();
    // Fetch supervisors when the dialog is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // You can filter by role here if your backend supports it,
      // or filter the list received by fetchUsers() if it fetches all.
      context
          .read<UserCubit>()
          .fetchUsers(); // Fetch all users and then filter locally
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.7, // Adjust width as needed
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ), // Limit height
        padding: const EdgeInsets.all(20.0),
        child: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  showFailureSnackBar(context, state.message);
                }
              });
            } else if (state is UserActionSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  showSuccessSnackBar(context, state.message);
                }
              });
            }
          },
          builder: (context, state) {
            List<User> supervisors = [];
            if (state is UserLoaded) {
              // Filter for 'Encadrant' and 'Gestionnaire' roles from all fetched users
              supervisors = state.users
                  .where(
                    (user) =>
                        user.role == 'Encadrant' || user.role == 'Gestionnaire',
                  )
                  .toList();
            } else if (state is UserActionSuccess) {
              // After an action, the lastLoadedUsers might be available
              supervisors = (state.lastLoadedUsers ?? [])
                  .where(
                    (user) =>
                        user.role == 'Encadrant' || user.role == 'Gestionnaire',
                  )
                  .toList();
            } else if (state is UserError && state.lastLoadedUsers != null) {
              supervisors = (state.lastLoadedUsers ?? [])
                  .where(
                    (user) =>
                        user.role == 'Encadrant' || user.role == 'Gestionnaire',
                  )
                  .toList();
            }

            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              // Handle UserLoaded, UserActionSuccess, UserError (with previous data)
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manage Supervisors',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddEditSupervisorDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Supervisor'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  if (supervisors.isEmpty &&
                      state
                          is! UserLoading) // Only show if no supervisors and not loading
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No supervisors found.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: supervisors.length,
                        itemBuilder: (context, index) {
                          final supervisor = supervisors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                '${supervisor.username} ${supervisor.lastname}',
                              ),
                              subtitle: Text(
                                'Role: ${supervisor.role}\nEmail: ${supervisor.email}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'Edit Supervisor',
                                    onPressed: () =>
                                        _showAddEditSupervisorDialog(
                                          context,
                                          supervisor: supervisor,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete Supervisor',
                                    onPressed: () =>
                                        _confirmDelete(context, supervisor),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _showAddEditSupervisorDialog(BuildContext context, {User? supervisor}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Provide the existing UserCubit to the AddEditSupervisorDialog
        return BlocProvider.value(
          value: BlocProvider.of<UserCubit>(context),
          child: AddEditSupervisorDialog(supervisor: supervisor),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, User supervisor) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete ${supervisor.username} ${supervisor.lastname}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (supervisor.userID != null) {
                  context.read<UserCubit>().deleteUser(supervisor.userID!);
                } else {
                  showFailureSnackBar(
                    context,
                    'Supervisor ID not found for deletion.',
                  );
                }
                Navigator.of(
                  dialogContext,
                ).pop(); // Close the confirmation dialog
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

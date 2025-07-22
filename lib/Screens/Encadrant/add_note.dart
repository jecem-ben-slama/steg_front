import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';
import 'package:pfa/Utils/snackbar.dart'; // Assuming you have this for showing messages

class AddNoteDialog extends StatefulWidget {
  final int
  internshipId; // The ID of the internship to which the note will be added

  const AddNoteDialog({super.key, required this.internshipId});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final TextEditingController _noteContentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _noteContentController.dispose();
    super.dispose();
  }

  void _submitNote() {
    if (_formKey.currentState?.validate() ?? false) {
      // Access the EncadrantCubit and call addNoteToInternship
      // The encadrantID is expected to be managed by the EncadrantCubit internally
      context.read<EncadrantCubit>().addNoteToInternship(
        widget.internshipId,
        _noteContentController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EncadrantCubit, EncadrantState>(
      // Listen for EncadrantActionSuccess or EncadrantError states from the Cubit
      listener: (context, state) {
        if (state is EncadrantActionSuccess) {
          showSuccessSnackBar(context, state.message);
          Navigator.of(context).pop(); // Close the dialog on success
        } else if (state is EncadrantError) {
          showFailureSnackBar(context, state.message);
        }
      },
      child: AlertDialog(
        title: const Text('Add New Note'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _noteContentController,
                decoration: const InputDecoration(
                  labelText: 'Note Content',
                  hintText: 'Enter your note here...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint:
                      true, // Align label to top for multiline input
                ),
                maxLines: 5, // Allow multiple lines for the note
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter note content.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<EncadrantCubit, EncadrantState>(
            // Use BlocBuilder to update the button state (e.g., disable during loading)
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is EncadrantLoading ? null : _submitNote,
                child: state is EncadrantLoading
                    ? const CircularProgressIndicator() // Show loading indicator
                    : const Text('Add Note'),
              );
            },
          ),
        ],
      ),
    );
  }
}

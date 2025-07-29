import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';

class EvaluateInternshipPopup extends StatefulWidget {
  final int internshipId;
  final double? currentNote;
  final String? currentComments;

  const EvaluateInternshipPopup({
    super.key,
    required this.internshipId,
    this.currentNote,
    this.currentComments,
  });

  @override
  State<EvaluateInternshipPopup> createState() =>
      _EvaluateInternshipPopupState();
}

class _EvaluateInternshipPopupState extends State<EvaluateInternshipPopup> {
  late TextEditingController _noteController;
  late TextEditingController _commentsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.currentNote?.toString() ?? '',
    );
    _commentsController = TextEditingController(
      text: widget.currentComments ?? '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void _saveEvaluation() {
    if (_formKey.currentState?.validate() ?? false) {
      final double? note = double.tryParse(_noteController.text);
      final String comments = _commentsController.text.trim();

      context.read<EncadrantCubit>().evaluateInternship(
        stageID: widget.internshipId,
        actionType:
            'validate', // This action type is for saving/updating evaluation
        note: note,
        commentaires: comments,
      );
      Navigator.of(
        context,
      ).pop(); // Close the dialog immediately after dispatching action
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EncadrantCubit, EncadrantState>(
      // Listen for success/error messages related to evaluation action
      listenWhen: (previous, current) =>
          current is EncadrantActionSuccess || current is EncadrantError,
      listener: (context, state) {
        // SnackBar messages will be handled by the main screen's BlocConsumer
        // The dialog closes itself after dispatching the action, so no direct SnackBar here.
        // This listener is mainly for debugging or if you wanted different feedback here.
      },
      child: AlertDialog(
        title: Text('Evaluate Internship ID: ${widget.internshipId}'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _noteController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Note (0-10)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      // Note is optional in your PHP, but if entered, it must be valid.
                      // If you want to make note strictly required for 'validate', uncomment this:
                      // return 'Please enter a note.';
                      return null; // Note is optional
                    }
                    final double? parsedNote = double.tryParse(value);
                    if (parsedNote == null ||
                        parsedNote < 0 ||
                        parsedNote > 20) {
                      return 'Note must be a number between 0 and 20.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _commentsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Comments (Optional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            onPressed: _saveEvaluation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Visual cue for saving
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Evaluation'),
          ),
        ],
      ),
    );
  }
}

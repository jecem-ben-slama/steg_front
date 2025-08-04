import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';

class EvaluateInternshipPopup extends StatefulWidget {
  final int internshipId;
  final String? currentComments;

  final String? currentDispline;
  final String? currentInterest;
  final String? currentPresence;
  final double? currentNote; // Now represents the number of missed days

  const EvaluateInternshipPopup({
    super.key,
    required this.internshipId,
    this.currentComments,
    this.currentDispline,
    this.currentInterest,
    this.currentPresence,
    this.currentNote,
  });

  @override
  State<EvaluateInternshipPopup> createState() =>
      _EvaluateInternshipPopupState();
}

class _EvaluateInternshipPopupState extends State<EvaluateInternshipPopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _commentsController;
  late TextEditingController _noteController;

  String? _selectedDispline;
  String? _selectedInterest;
  String? _selectedPresence;

  @override
  void initState() {
    super.initState();
    _commentsController = TextEditingController(
      text: widget.currentComments ?? '',
    );
    _noteController = TextEditingController(
      text: widget.currentNote?.toString() ?? '',
    );
    _selectedDispline = widget.currentDispline;
    _selectedInterest = widget.currentInterest;
    _selectedPresence = widget.currentPresence;
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveEvaluation() {
    if (_formKey.currentState?.validate() ?? false) {
      final String comments = _commentsController.text.trim();

      // Ensure all radio buttons have been selected
      if (_selectedDispline == null ||
          _selectedInterest == null ||
          _selectedPresence == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a rating for all criteria.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      double? missedDays;
      if (_selectedPresence?.toLowerCase() == 'poor') {
        missedDays = double.tryParse(_noteController.text.trim());
        if (missedDays == null || missedDays < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please enter a valid number of missed days for "Poor" presence.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // --- START OF FIX: Correctly pass all required parameters to the cubit ---
      context.read<EncadrantCubit>().evaluateInternship(
        stageID: widget.internshipId,
        actionType: 'validate',
        commentaires: comments,
        displine: _selectedDispline,
        interest: _selectedInterest,
        presence: _selectedPresence,
        note: missedDays, // The `note` parameter is now used for missed days.
      );
      // --- END OF FIX ---

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> ratingOptions = ['Excellent', 'Average', 'Poor'];

    return BlocListener<EncadrantCubit, EncadrantState>(
      listenWhen: (previous, current) =>
          current is EncadrantActionSuccess || current is EncadrantError,
      listener: (context, state) {},
      child: AlertDialog(
        title: Text('Evaluate Internship ID: ${widget.internshipId}'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Discipline:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...ratingOptions.map(
                  (String value) => RadioListTile<String>(
                    title: Text(value),
                    value: value,
                    groupValue: _selectedDispline,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDispline = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Interest:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...ratingOptions.map(
                  (String value) => RadioListTile<String>(
                    title: Text(value),
                    value: value,
                    groupValue: _selectedInterest,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedInterest = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Presence:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...ratingOptions.map(
                  (String value) => RadioListTile<String>(
                    title: Text(value),
                    value: value,
                    groupValue: _selectedPresence,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPresence = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),
                if (_selectedPresence?.toLowerCase() == 'poor')
                  TextFormField(
                    controller: _noteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Missed Days',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of missed days.';
                      }
                      if (double.tryParse(value) == null ||
                          double.tryParse(value)! < 0) {
                        return 'Please enter a valid number.';
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
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Evaluation'),
          ),
        ],
      ),
    );
  }
}

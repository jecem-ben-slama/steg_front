import 'dart:async'; // Import for Timer
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:url_launcher/url_launcher.dart'; // To open PDF URLs

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

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Subject? _editingSubject;
  bool _isFormVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _displayMessage;
  MessageType _displayMessageType = MessageType.none;
  Timer? _messageTimer;

  Uint8List? _pickedPdfBytes; // To store picked PDF bytes
  String? _pickedPdfFilename; // To store picked PDF filename

  @override
  void initState() {
    super.initState();
    context.read<SubjectCubit>().fetchSubjects();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _descriptionController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _clearForm() {
    _subjectNameController.clear();
    _descriptionController.clear();
    setState(() {
      _editingSubject = null;
      _isFormVisible = false;
      _pickedPdfBytes = null; // Clear picked PDF data
      _pickedPdfFilename = null; // Clear picked PDF data
    });
    _clearMessage();
  }

  void _populateForm(Subject subject) {
    _subjectNameController.text = subject.subjectName;
    _descriptionController.text = subject.description ?? '';
    setState(() {
      _editingSubject = subject;
      _isFormVisible = true;
      _pickedPdfBytes = null; // Clear previously picked PDF when editing
      _pickedPdfFilename = null; // Clear previously picked PDF when editing
    });
    _clearMessage();
  }

  // New function to pick PDF file
  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _pickedPdfBytes = result.files.single.bytes!;
          _pickedPdfFilename = result.files.single.name;
        });
        _displayMessageInPopup(
          'PDF "${_pickedPdfFilename!}" selected.',
          MessageType.info,
        );
      } else {
        // User canceled the picker
        _displayMessageInPopup('PDF selection canceled.', MessageType.info);
      }
    } catch (e) {
      _displayMessageInPopup('Error picking PDF: $e', MessageType.error);
    }
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
      subjectID: _editingSubject?.subjectID,
      subjectName: _subjectNameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      pdfUrl: _editingSubject
          ?.pdfUrl, // Keep existing PDF URL if not picking a new one
    );

    if (_editingSubject == null) {
      context.read<SubjectCubit>().addSubject(
        newSubject,
        pdfBytes: _pickedPdfBytes,
        pdfFilename: _pickedPdfFilename,
      );
    } else {
      context.read<SubjectCubit>().updateSubject(
        newSubject,
        pdfBytes: _pickedPdfBytes,
        pdfFilename: _pickedPdfFilename,
      );
    }

    _clearForm();
  }

  void _deleteSubject(int subjectId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this Subject?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SubjectCubit>().deleteSubject(subjectId);
              Navigator.of(ctx).pop();
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
    _messageTimer = Timer(const Duration(seconds: 3), () {
      _clearMessage();
    });
  }

  void _clearMessage() {
    setState(() {
      _displayMessage = null;
      _displayMessageType = MessageType.none;
    });
  }

  // Renamed from _openPdfUrl to _downloadPdf for clarity, as it uses externalApplication mode
  Future<void> _downloadPdf(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        // Use externalApplication to typically prompt download on web for PDFs
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _displayMessageInPopup(
          'Could not launch PDF link: $url',
          MessageType.error,
        );
      }
    } else {
      _displayMessageInPopup('No PDF URL available.', MessageType.info);
    }
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
            _buildMessageDisplayArea(),
            // Form Header and Toggle Button
            _buildFormHeader(),
            // Subject Form
            _buildSubjectForm(),
            const Divider(height: 30, thickness: 1),
            // Existing Subjects Header and Search Bar
            _buildExistingSubjectsHeader(),
            const SizedBox(height: 10),
            // Subject List
            _buildSubjectList(),
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

  // Extracted Widgets
  Widget _buildMessageDisplayArea() {
    return AnimatedOpacity(
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
                        color: _displayMessageType == MessageType.success
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
    );
  }

  Widget _buildFormHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _editingSubject == null ? 'Add New Subject' : 'Edit Subject',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        IconButton(
          onPressed: _toggleFormVisibility,
          icon: Icon(
            _isFormVisible ? Icons.arrow_circle_up : Icons.arrow_circle_down,
          ),
          tooltip: _isFormVisible ? 'Hide Form' : 'Show Form',
        ),
      ],
    );
  }

  Widget _buildSubjectForm() {
    return AnimatedSwitcher(
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
                      // PDF Picker Button and Display
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickPdfFile,
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Pick PDF File'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _pickedPdfFilename ??
                                  (_editingSubject?.pdfUrl != null
                                      ? 'Existing PDF: ${Uri.parse(_editingSubject!.pdfUrl!).pathSegments.last}'
                                      : 'No PDF selected'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    _pickedPdfFilename != null ||
                                        _editingSubject?.pdfUrl != null
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
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
                              _editingSubject == null ? Icons.add : Icons.save,
                            ),
                            label: Text(
                              _editingSubject == null
                                  ? 'Add Subject'
                                  : 'Update Subject',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
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
    );
  }

  Widget _buildExistingSubjectsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Existing Subjects',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search subjects by name or description...',
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
    );
  }

  Widget _buildSubjectList() {
    return Expanded(
      child: BlocConsumer<SubjectCubit, SubjectState>(
        listener: (context, state) {
          if (state is SubjectActionSuccess) {
            _displayMessageInPopup(state.message, MessageType.success);
          } else if (state is SubjectError) {
            _displayMessageInPopup(state.message, MessageType.error);
          }
        },
        builder: (context, state) {
          if (state is SubjectLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubjectLoaded) {
            final filteredSubjects = state.subjects.where((subject) {
              final subjectNameLower = subject.subjectName.toLowerCase();
              final descriptionLower = subject.description?.toLowerCase() ?? '';
              final searchQueryLower = _searchQuery.toLowerCase();

              return subjectNameLower.contains(searchQueryLower) ||
                  descriptionLower.contains(searchQueryLower);
            }).toList();

            if (filteredSubjects.isEmpty && _searchQuery.isNotEmpty) {
              return Center(
                child: Text('No subjects found matching "${_searchQuery}".'),
              );
            } else if (filteredSubjects.isEmpty) {
              return const Center(
                child: Text('No subjects found. Add one using the form above!'),
              );
            }
            return ListView.builder(
              itemCount: filteredSubjects.length,
              itemBuilder: (context, index) {
                final subject = filteredSubjects[index];
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
                    // Reverted leading to CircleAvatar
                    leading: CircleAvatar(
                      child: Text(subject.subjectName[0].toUpperCase()),
                    ),
                    title: Text(
                      subject.subjectName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${subject.description ?? 'N/A'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- NEW: Download Button moved here ---
                        if (subject.pdfUrl != null &&
                            subject.pdfUrl!.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.download_for_offline,
                              color: Colors.green,
                            ), // Changed color for distinction
                            onPressed: () => _downloadPdf(subject.pdfUrl),
                            tooltip: 'Download PDF',
                          ),
                        // --- END NEW ---
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _populateForm(subject),
                          tooltip: 'Edit Subject',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSubject(subject.subjectID!),
                          tooltip: 'Delete Subject',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is SubjectError) {
            if (state.lastLoadedSubjects == null ||
                state.lastLoadedSubjects!.isEmpty) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          }
          return const Center(
            child: Text('Start managing Subjects by adding one above.'),
          );
        },
      ),
    );
  }
}

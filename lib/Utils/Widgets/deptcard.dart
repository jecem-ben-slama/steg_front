// lib/Utils/Widgets/dept_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/user_cubit.dart';
import 'package:pfa/Cubit/student_cubit.dart';
import 'package:pfa/Cubit/subject_cubit.dart'; // Import SubjectCubit
import 'package:pfa/Utils/Widgets/manage_students.dart';
import 'package:pfa/Utils/Widgets/manage_supervisor.dart';
import 'package:pfa/repositories/user_repo.dart';
import 'package:pfa/repositories/student_repo.dart';
import 'package:pfa/repositories/subject_repo.dart'; // Import SubjectRepository
import 'package:pfa/Utils/Widgets/manage_subject.dart'; // New: ManageSubjectsDialog

class DeptCard extends StatefulWidget {
  final String title;
  const DeptCard({super.key, required this.title});

  @override
  State<DeptCard> createState() => _DeptCardState();
}

class _DeptCardState extends State<DeptCard> {
  void _showManagementDialog(BuildContext context) {
    print('DeptCard tapped! Title: "${widget.title}"');
    if (widget.title == 'Manage Supervisor') {
      print('Condition met: "Manage Supervisor" card tapped.');
      showDialog(
        context: context,
        builder: (dialogContext) {
          return BlocProvider(
            create: (_) =>
                UserCubit(RepositoryProvider.of<UserRepository>(context)),
            child:
                const ManageUsers(), // Ensure this is the correct class name for your user management dialog
          );
        },
      );
    } else if (widget.title == 'Manage Student') {
      print('Condition met: "Manage Student" card tapped.');
      showDialog(
        context: context,
        builder: (dialogContext) {
          return BlocProvider(
            create: (_) =>
                StudentCubit(RepositoryProvider.of<StudentRepository>(context)),
            child:
                const ManageStudents(), // Ensure this matches your class name
          );
        },
      );
    } else if (widget.title == 'Manage Subject') {
      // <-- New Condition for Subject
      print('Condition met: "Manage Subject" card tapped.');
      showDialog(
        context: context,
        builder: (dialogContext) {
          return BlocProvider(
            create: (_) =>
                SubjectCubit(RepositoryProvider.of<SubjectRepository>(context)),
            child: const ManageSubjects(), // Use the new Subject dialog
          );
        },
      );
    } else {
      print(
        'Condition NOT met for title: "${widget.title}". Dialog not shown.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showManagementDialog(context);
      },
      child: Container(
        // ... (your existing DeptCard UI)
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForTitle(
                widget.title,
              ), // Assuming you have this helper or you can add it
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 10),
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get the appropriate icon based on the card title
  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Manage Supervisor':
        return Icons.people;
      case 'Manage Student':
        return Icons.school;
      case 'Manage Subject':
        return Icons.book; // Icon for subjects
      default:
        return Icons.category; // Default icon
    }
  }
}

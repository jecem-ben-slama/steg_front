// lib/Utils/Widgets/dept_card.dart (Updated part)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/user_cubit.dart'; // For Manage Supervisor
import 'package:pfa/Cubit/student_cubit.dart'; // Import StudentCubit
import 'package:pfa/Utils/Widgets/manage_students.dart';
import 'package:pfa/Utils/Widgets/manage_supervisor.dart';
import 'package:pfa/repositories/user_repo.dart';
import 'package:pfa/repositories/student_repo.dart'; // Import StudentRepository

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
            child: const ManageUsers(),
          );
        },
      );
    } else if (widget.title == 'Manage Student') {
      // <-- New Condition
      print('Condition met: "Manage Student" card tapped.');
      showDialog(
        context: context,
        builder: (dialogContext) {
          return BlocProvider(
            create: (_) =>
                StudentCubit(RepositoryProvider.of<StudentRepository>(context)),
            child: const ManageStudents(),
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
        child: Center(
          child: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

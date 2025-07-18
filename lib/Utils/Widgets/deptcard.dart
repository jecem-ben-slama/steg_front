// lib/Utils/Widgets/dept_card.dart (Updated)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/user_cubit.dart';
import 'package:pfa/repositories/user_repo.dart'; // Ensure correct casing: 'repositories'
import 'package:pfa/Utils/Widgets/manage_user.dart'; // Assuming ManageSupervisorsDialog is here

class DeptCard extends StatefulWidget {
  final String title;
  const DeptCard({super.key, required this.title});

  @override
  State<DeptCard> createState() => _DeptCardState();
}

class _DeptCardState extends State<DeptCard> {
  void _showSupervisorManagement(BuildContext context) {
    // 'context' here is the DeptCard's context
    print('DeptCard tapped! Title: "${widget.title}"');
    if (widget.title == 'Manage Supervisor') {
      print('Condition met: "Manage Supervisor" card tapped.');
      showDialog(
        context:
            context, // Use the original 'context' that has access to UserRepository
        builder: (dialogContext) {
          // 'dialogContext' is for the dialog's subtree
          print('Attempting to show ManageSupervisorsDialog.');
          return BlocProvider(
            // Use the 'context' from DeptCard's build method, which *should* have access
            // to the RepositoryProvider for UserRepository.
            create: (_) => UserCubit(
              RepositoryProvider.of<UserRepository>(context),
            ), // <--- IMPORTANT CHANGE HERE
            child: const ManageSupervisorsDialog(),
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
    // This 'context' implicitly has access to all providers above DeptCard in the tree.
    return GestureDetector(
      onTap: () {
        print(
          'GestureDetector onTap called for DeptCard with title: "${widget.title}"',
        );
        _showSupervisorManagement(context); // Pass this 'context'
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.11,
        height: MediaQuery.of(context).size.height * 0.1,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
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

// [Unchanged imports...]
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/Stats/internships_distribution.dart';
import 'package:pfa/Model/Stats/kpi_model.dart';
import 'package:pfa/Utils/Widgets/statcard.dart';
import 'package:pfa/cubit/internship_cubit.dart';
import 'package:pfa/Model/internship_model.dart';
import 'package:pfa/Utils/Widgets/deptcard.dart';
import 'package:pfa/Screens/Gestionnaire/edit_internship.dart';
import 'package:pfa/Screens/Gestionnaire/add_internship.dart';
import 'package:pfa/Utils/snackbar.dart';
import 'package:pfa/Cubit/student_cubit.dart';
import 'package:pfa/cubit/subject_cubit.dart';
import 'package:pfa/Cubit/user_cubit.dart';
import 'package:pfa/cubit/stats_cubit.dart';
import 'package:pfa/repositories/student_repo.dart';
import 'package:pfa/Repositories/subject_repo.dart';
import 'package:pfa/repositories/user_repo.dart';

class GestionnaireDashboard extends StatefulWidget {
  const GestionnaireDashboard({super.key});

  @override
  State<GestionnaireDashboard> createState() => _GestionnaireDashboardState();
}

class _GestionnaireDashboardState extends State<GestionnaireDashboard> {
  Dio dio = Dio();
  String _searchQuery = '';
  String? _selectedStatusFilter;
  String? _selectedTypeFilter;

  final List<String> _statusOptions = [
    'All',
    'Validé',
    'En attente',
    'Refusé',
    'Proposé',
  ];

  final List<String> _typeOptions = ['All', 'PFA', 'PFE', 'Stage Ouvrier'];

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'validé':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'refusé':
        return Colors.red;
      case 'proposé':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this internship? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  List<Internship> _applyFilters(List<Internship> internships) {
    List<Internship> filteredList = List.from(internships);

    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((internship) {
        final query = _searchQuery.toLowerCase();
        return (internship.studentName?.toLowerCase().contains(query) ??
                false) ||
            (internship.subjectTitle?.toLowerCase().contains(query) ?? false) ||
            (internship.supervisorName?.toLowerCase().contains(query) ??
                false) ||
            (internship.typeStage?.toLowerCase().contains(query) ?? false) ||
            (internship.statut?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_selectedStatusFilter != null && _selectedStatusFilter != 'All') {
      filteredList = filteredList.where((internship) {
        return internship.statut?.toLowerCase() ==
            _selectedStatusFilter!.toLowerCase();
      }).toList();
    }

    if (_selectedTypeFilter != null && _selectedTypeFilter != 'All') {
      filteredList = filteredList.where((internship) {
        return internship.typeStage?.toLowerCase() ==
            _selectedTypeFilter!.toLowerCase();
      }).toList();
    }

    return filteredList;
  }

  void _showAddInternshipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: BlocProvider.of<InternshipCubit>(context),
            ),
            BlocProvider(
              create: (_) => StudentCubit(
                RepositoryProvider.of<StudentRepository>(dialogContext),
              ),
            ),
            BlocProvider(
              create: (_) => SubjectCubit(
                RepositoryProvider.of<SubjectRepository>(dialogContext),
              ),
            ),
            BlocProvider(
              create: (_) => UserCubit(
                RepositoryProvider.of<UserRepository>(dialogContext),
              ), // Corrected context for UserRepository
            ),
          ],
          child: const AddInternshipPopup(),
        );
      },
    );
  }

  // New method for showing the edit internship dialog
  void _showEditInternshipDialog(
    BuildContext parentContext,
    Internship internship,
  ) {
    showDialog(
      context: parentContext, // Use the parent context to inherit providers
      builder: (dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: BlocProvider.of<InternshipCubit>(parentContext),
            ),
            BlocProvider(
              create: (_) => StudentCubit(
                RepositoryProvider.of<StudentRepository>(dialogContext),
              ),
            ),
            BlocProvider(
              create: (_) => SubjectCubit(
                RepositoryProvider.of<SubjectRepository>(dialogContext),
              ),
            ),
            BlocProvider(
              create: (_) => UserCubit(
                RepositoryProvider.of<UserRepository>(dialogContext),
              ),
            ),
          ],
          child: InternshipEditDialog(internship: internship),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<InternshipCubit>().fetchInternships();
    context.read<GestionnaireStatsCubit>().fetchAllGestionnaireStats();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<InternshipCubit, InternshipState>(
      listener: (context, state) {
        if (state is InternshipActionSuccess) {
          showSuccessSnackBar(context, state.message);
          context
              .read<InternshipCubit>()
              .fetchInternships(); // ✅ Auto-refresh list
        } else if (state is InternshipError) {
          showFailureSnackBar(context, 'Error: ${state.message}');
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.3,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText:
                            "Search by student, subject, supervisor, status...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: screenWidth * 0.1,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      value: _selectedStatusFilter ?? 'All',
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatusFilter = newValue == 'All'
                              ? null
                              : newValue;
                        });
                      },
                      items: _statusOptions.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: screenWidth * 0.2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      value: _selectedTypeFilter ?? 'All',
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTypeFilter = newValue == 'All'
                              ? null
                              : newValue;
                        });
                      },
                      items: _typeOptions.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/men/1.jpg",
                    ),
                    radius: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            //? Stats
            BlocBuilder<GestionnaireStatsCubit, GestionnaireStatsState>(
              builder: (context, statsState) {
                if (statsState is GestionnaireStatsLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (statsState is GestionnaireStatsLoaded) {
                  final kpi = statsState.kpiData;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          StatCard(
                            title: 'Active Internships',
                            value: kpi.activeInternshipsCount.toString(),
                            icon: Icons.work,
                            color: Colors.blueAccent,
                          ),
                          StatCard(
                            title: 'Total Encadrants',
                            value: kpi.encadrantsCount.toString(),
                            icon: Icons.people,
                            color: Colors.green,
                          ),
                          StatCard(
                            title: 'Pending Evaluations',
                            value: kpi.pendingEvaluationsCount.toString(),
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                } else if (statsState is GestionnaireStatsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Error loading statistics: ${statsState.message}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => context
                                .read<GestionnaireStatsCubit>()
                                .fetchAllGestionnaireStats(),
                            child: const Text('Retry Stats'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DeptCard(title: "Manage Student"),
                DeptCard(title: "Manage Subject"),
                DeptCard(title: "Manage Supervisor"),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Internships",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddInternshipDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Internship'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<InternshipCubit, InternshipState>(
                      builder: (context, state) {
                        List<Internship>? internshipsRaw;
                        if (state is InternshipLoaded) {
                          internshipsRaw = state.internships;
                        } else if (state is InternshipError) {
                          internshipsRaw = state.lastLoadedInternships;
                        } else if (state is InternshipLoading &&
                            context.read<InternshipCubit>().state
                                is InternshipLoaded) {
                          internshipsRaw =
                              (context.read<InternshipCubit>().state
                                      as InternshipLoaded)
                                  .internships;
                        } else if (state is InternshipLoading &&
                            context.read<InternshipCubit>().state
                                is InternshipError &&
                            (context.read<InternshipCubit>().state
                                        as InternshipError)
                                    .lastLoadedInternships !=
                                null) {
                          internshipsRaw =
                              (context.read<InternshipCubit>().state
                                      as InternshipError)
                                  .lastLoadedInternships;
                        }

                        List<Internship>? internshipsToDisplay;
                        if (internshipsRaw != null) {
                          internshipsToDisplay = _applyFilters(internshipsRaw);
                        }

                        if (internshipsToDisplay == null ||
                            internshipsToDisplay.isEmpty) {
                          if (state is InternshipLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is InternshipError) {
                            return Center(
                              child: Text(
                                'Error loading internships: ${state.message}',
                              ),
                            );
                          } else {
                            return Center(
                              child: Text(
                                _searchQuery.isNotEmpty ||
                                        _selectedStatusFilter != null ||
                                        _selectedTypeFilter != null
                                    ? 'No matching internships found for current filters.'
                                    : 'No internships found.',
                              ),
                            );
                          }
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text("Student Name")),
                              DataColumn(label: Text("Subject")),
                              DataColumn(label: Text("Supervisor")),
                              DataColumn(label: Text("Type")),
                              DataColumn(label: Text("Start Date")),
                              DataColumn(label: Text("End Date")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Actions")),
                            ],
                            rows: internshipsToDisplay.map((internship) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(internship.studentName ?? 'N/A'),
                                  ),
                                  DataCell(
                                    Text(internship.subjectTitle ?? 'N/A'),
                                  ),
                                  DataCell(
                                    Text(internship.supervisorName ?? 'N/A'),
                                  ),
                                  DataCell(Text(internship.typeStage ?? 'N/A')),
                                  DataCell(Text(internship.dateDebut ?? 'N/A')),
                                  DataCell(Text(internship.dateFin ?? 'N/A')),
                                  DataCell(
                                    Text(
                                      internship.statut ?? 'N/A',
                                      style: TextStyle(
                                        color: _getStatusColor(
                                          internship.statut,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            // Use the new method to show the edit dialog
                                            _showEditInternshipDialog(
                                              context,
                                              internship,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final confirmed =
                                                await _showDeleteConfirmationDialog(
                                                  context,
                                                );
                                            if (confirmed == true &&
                                                internship.internshipID !=
                                                    null) {
                                              context
                                                  .read<InternshipCubit>()
                                                  .deleteInternship(
                                                    internship.internshipID!,
                                                  );
                                            } else if (confirmed == true) {
                                              showFailureSnackBar(
                                                context,
                                                "Internship ID is missing for deletion.",
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

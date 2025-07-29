import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/Stats/internships_distribution.dart'; // Your updated model
import 'package:pfa/Screens/Gestionnaire/dashboard_charts.dart'; // Assuming CustomPieChart and CustomBarChart are here
import 'package:pfa/cubit/stats_cubit.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  @override
  void initState() {
    super.initState();
    // Trigger the data fetch when the screen initializes
    context.read<GestionnaireStatsCubit>().fetchAllGestionnaireStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GestionnaireStatsCubit, GestionnaireStatsState>(
        builder: (context, state) {
          if (state is GestionnaireStatsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GestionnaireStatsLoaded) {
            final Data allDistributions = state.allDistributions;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Internship Distributions Section Title
                  const Text(
                    'Internship Distributions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Internship Status Distribution (Pie Chart)
                  SizedBox(
                    height: 300, // Explicit height for the chart container
                    child: CustomPieChart(
                      title: 'Internship Status Distribution',
                      data: {
                        for (var d in allDistributions.statusDistribution ?? [])
                          d.status!: d.count!,
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Internship Type Distribution (Pie Chart)
                  SizedBox(
                    height: 300, // Explicit height for the chart container
                    child: CustomPieChart(
                      title: 'Internship Type Distribution',
                      data: {
                        for (var d in allDistributions.typeDistribution ?? [])
                          d.type!: d.count!,
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Internship Duration Distribution (Bar Chart)
                  SizedBox(
                    height: 300, // Explicit height for the chart container
                    child: CustomBarChart(
                      title: 'Internship Duration Distribution',
                      data: {
                        for (var d
                            in allDistributions.durationDistribution ?? [])
                          d.range!: d.count!,
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Encadrant Workload Distribution (Bar Chart)
                  SizedBox(
                    height: 300, // Explicit height for the chart container
                    child: CustomBarChart(
                      title: 'Encadrant Workload Distribution',
                      data: {
                        for (var d
                            in allDistributions.encadrantDistribution ?? [])
                          d.encadrantName!: d.internshipCount!,
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- NEW: Faculty Internship Summary (Table/List) ---
                  const Text(
                    'Faculty Internship Summary',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Check if data exists before trying to build the table
                  if (allDistributions.facultyInternshipSummary != null &&
                      allDistributions.facultyInternshipSummary!.isNotEmpty)
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          // Allow horizontal scrolling for table if needed
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 20,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 60,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Faculty',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Total Students',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(
                                  'Total Internships',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(
                                  'Validated Internships',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(
                                  'Success Rate (%)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                numeric: true,
                              ),
                            ],
                            rows: allDistributions.facultyInternshipSummary!
                                .map(
                                  (summary) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(summary.facultyName ?? 'N/A'),
                                      ),
                                      DataCell(
                                        Text(
                                          summary.totalStudents?.toString() ??
                                              '0',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          summary.totalInternships
                                                  ?.toString() ??
                                              '0',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          summary.validatedInternships
                                                  ?.toString() ??
                                              '0',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${summary.successRate?.toStringAsFixed(2) ?? '0.00'}%',
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'No faculty internship summary data available.',
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Subject Distribution (Pie Chart)
                  SizedBox(
                    height: 300, // Explicit height for the chart container
                    child: CustomPieChart(
                      title: 'Subject Distribution',
                      data: {
                        for (var d
                            in allDistributions.subjectDistribution ?? [])
                          d.subjectTitle!: d.count!,
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else if (state is GestionnaireStatsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<GestionnaireStatsCubit>()
                            .fetchAllGestionnaireStats();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: Text(
              'Loading Internship Statistics...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}

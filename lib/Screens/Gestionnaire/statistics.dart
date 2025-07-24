import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/Stats/internships_distribution.dart';
import 'package:pfa/Screens/Gestionnaire/dashboard_charts.dart';
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
    // This will fetch both KPI and distribution data, but we only use distributions here.
    context.read<GestionnaireStatsCubit>().fetchAllGestionnaireStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internship Statistics & Distributions'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocBuilder<GestionnaireStatsCubit, GestionnaireStatsState>(
        builder: (context, state) {
          if (state is GestionnaireStatsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GestionnaireStatsLoaded) {
            // Data is successfully loaded, display it
            // final KpiData kpiData = state.kpiData; // KPIs are not displayed here
            final Data allDistributions = state.allDistributions;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Internship Distributions Section
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
                  CustomPieChart(
                    title: 'Internship Status Distribution',
                    data: {
                      for (var d in allDistributions.statusDistribution ?? [])
                        d.status!: d.count!,
                    },
                  ),
                  const SizedBox(height: 20),

                  // Internship Type Distribution (Pie Chart)
                  CustomPieChart(
                    title: 'Internship Type Distribution',
                    data: {
                      for (var d in allDistributions.typeDistribution ?? [])
                        d.type!: d.count!,
                    },
                  ),
                  const SizedBox(height: 20),

                  // Internship Duration Distribution (Bar Chart)
                  CustomBarChart(
                    title: 'Internship Duration Distribution',
                    data: {
                      for (var d in allDistributions.durationDistribution ?? [])
                        d.range!: d.count!,
                    },
                  ),
                  const SizedBox(height: 20),

                  // Encadrant Workload Distribution (Bar Chart)
                  CustomBarChart(
                    title: 'Encadrant Workload Distribution',
                    data: {
                      for (var d
                          in allDistributions.encadrantDistribution ?? [])
                        d.encadrantName!: d.internshipCount!,
                    },
                  ),
                  const SizedBox(height: 20),

                  // Faculty Distribution (Pie Chart)
                  CustomPieChart(
                    title: 'Faculty Distribution',
                    data: {
                      for (var d in allDistributions.facultyDistribution ?? [])
                        d.facultyName!: d.count!,
                    },
                  ),
                  const SizedBox(height: 20),

                  // Subject Distribution (Pie Chart)
                  CustomPieChart(
                    title: 'Subject Distribution',
                    data: {
                      for (var d in allDistributions.subjectDistribution ?? [])
                        d.subjectTitle!: d.count!,
                    },
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

// REMOVE KpiCard definition here if you moved it to a shared file like deptcard.dart
// (It should NOT be duplicated if it's already defined elsewhere and imported)

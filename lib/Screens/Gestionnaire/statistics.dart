import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Model/Stats/internships_distribution.dart';
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
                  // Wrapped in SizedBox to provide a fixed height
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
                  // Wrapped in SizedBox to provide a fixed height
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
                  // Wrapped in SizedBox to provide a fixed height
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
                  // Wrapped in SizedBox to provide a fixed height
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

                  // Faculty Distribution (Pie Chart)
                  // Wrapped in SizedBox to provide a fixed height
                  SizedBox(
                    height: 300, // Explicit height for the chart container
                    child: CustomPieChart(
                      title: 'Faculty Distribution',
                      data: {
                        for (var d
                            in allDistributions.facultyDistribution ?? [])
                          d.facultyName!: d.count!,
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Subject Distribution (Pie Chart)
                  // Wrapped in SizedBox to provide a fixed height
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

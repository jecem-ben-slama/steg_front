// lib/cubits/gestionnaire_stats_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/Stats/internships_distribution.dart';
import 'package:pfa/Model/Stats/kpi_model.dart';
import 'package:pfa/Repositories/stats_repo.dart'; // Import Equatable

// --- States ---
abstract class GestionnaireStatsState extends Equatable {
  const GestionnaireStatsState();

  @override
  List<Object?> get props => [];
}

class GestionnaireStatsInitial extends GestionnaireStatsState {}

class GestionnaireStatsLoading extends GestionnaireStatsState {}

class GestionnaireStatsLoaded extends GestionnaireStatsState {
  final KpiData kpiData;
  final Data allDistributions;

  const GestionnaireStatsLoaded({
    required this.kpiData,
    required this.allDistributions,
  });

  @override
  List<Object> get props => [kpiData, allDistributions];
}

class GestionnaireStatsError extends GestionnaireStatsState {
  final String message;
  const GestionnaireStatsError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Cubit ---
class GestionnaireStatsCubit extends Cubit<GestionnaireStatsState> {
  final StatsRepository _statsRepository;

  GestionnaireStatsCubit(this._statsRepository)
    : super(GestionnaireStatsInitial());

  //* Fetch Key Performance Indicator (KPI) Data and All Internship Distribution Data
  Future<void> fetchAllGestionnaireStats() async {
    emit(GestionnaireStatsLoading()); // Emit loading state

    try {
      // Fetch both KPI data and all internship distributions concurrently
      final kpiData = await _statsRepository.getKpiData();
      final allDistributionsData = await _statsRepository
          .getAllInternshipDistributions();

      // Emit loaded state with both pieces of data
      emit(
        GestionnaireStatsLoaded(
          kpiData: kpiData,
          allDistributions: allDistributionsData,
        ),
      );
    } catch (e) {
      // Handle errors
      if (e is Exception) {
        emit(
          GestionnaireStatsError(e.toString().replaceFirst('Exception: ', '')),
        );
      } else {
        emit(
          GestionnaireStatsError(
            'An unexpected error occurred: ${e.toString()}',
          ),
        );
      }
    }
  }
}

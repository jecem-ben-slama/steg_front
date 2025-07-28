// lib/Cubit/encadrant_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:pfa/Repositories/encad_repo.dart';
import '../Model/encadrant_model.dart'; // Import your Encadrant model

// --- Encadrant States ---
abstract class EncadrantState extends Equatable {
  const EncadrantState();

  @override
  List<Object?> get props => [];
}

class EncadrantInitial extends EncadrantState {}

class EncadrantLoading extends EncadrantState {}

class EncadrantLoaded extends EncadrantState {
  final List<Encadrant> encadrants;

  const EncadrantLoaded(this.encadrants);

  @override
  List<Object?> get props => [encadrants];
}

class EncadrantError extends EncadrantState {
  final String message;

  const EncadrantError(this.message);

  @override
  List<Object?> get props => [message];
}

class EncadrantAddedSuccess extends EncadrantState {
  final Encadrant newEncadrant; // The encadrant that was successfully added

  const EncadrantAddedSuccess(this.newEncadrant);

  @override
  List<Object?> get props => [newEncadrant];
}

class EncadrantOperationSuccess extends EncadrantState {
  final String message;

  const EncadrantOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Encadrant Cubit ---
class EncadrantCubit1 extends Cubit<EncadrantState> {
  final EncadrantRepository1 _encadrantRepository1;

  EncadrantCubit1(EncadrantRepository1 of, {required EncadrantRepository1 encadrantRepository1})
    : _encadrantRepository1 = encadrantRepository1,
      super(EncadrantInitial()); // Initial state

  // Method to fetch all encadrants
  Future<void> fetchEncadrants() async {
    emit(EncadrantLoading()); // Emit loading state
    try {
      final encadrants = await _encadrantRepository1.getAllEncadrants();
      emit(EncadrantLoaded(encadrants)); // Emit success state with data
    } catch (e) {
      debugPrint('Error in EncadrantCubit1.fetchEncadrants: $e');
      emit(EncadrantError(e.toString())); // Emit error state
    }
  }

  // Method to add a new encadrant
  Future<void> addEncadrant(Encadrant encadrant) async {
    emit(EncadrantLoading()); // Emit loading state
    try {
      final newEncadrant = await _encadrantRepository1.addEncadrant(encadrant);
      emit(
        EncadrantAddedSuccess(newEncadrant),
      ); // Emit success state with added encadrant
      // Optionally, refetch all encadrants to update the list immediately
      fetchEncadrants();
    } catch (e) {
      debugPrint('Error in EncadrantCubit1.addEncadrant: $e');
      emit(EncadrantError(e.toString())); // Emit error state
    }
  }

  // You would add updateEncadrant, deleteEncadrant methods here later
  // ...
}

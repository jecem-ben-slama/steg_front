import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/user_model.dart'; // Ensure this import is correct
import 'package:pfa/repositories/user_repo.dart'; // Ensure this import is correct

// --- User States ---
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  const UserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserActionSuccess extends UserState {
  final String message;
  final List<User>? lastLoadedUsers; // To retain current list after an action
  const UserActionSuccess(this.message, {this.lastLoadedUsers});

  @override
  List<Object?> get props => [message, lastLoadedUsers];
}

class UserError extends UserState {
  final String message;
  final List<User>?
  lastLoadedUsers; // To retain previously loaded data on error
  const UserError(this.message, {this.lastLoadedUsers});

  @override
  List<Object?> get props => [message, lastLoadedUsers];
}

// --- User Cubit ---
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(UserInitial());

  // Helper to get current users from state if available
  List<User>? _getCurrentUsers() {
    if (state is UserLoaded) {
      return (state as UserLoaded).users;
    } else if (state is UserActionSuccess) {
      return (state as UserActionSuccess).lastLoadedUsers;
    } else if (state is UserError) {
      return (state as UserError).lastLoadedUsers;
    }
    return null;
  }

  Future<void> fetchUsers() async {
    if (state is UserLoading) return; // Prevent multiple fetches

    final currentUsers = _getCurrentUsers();
    emit(UserLoading());
    try {
      final users = await _repository.fetchAllUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(
        UserError(
          'Failed to load users: ${e.toString()}',
          lastLoadedUsers: currentUsers,
        ),
      );
    }
  }

  Future<void> addUser(User user) async {
    List<User> currentUsers = List.from(_getCurrentUsers() ?? []);
    emit(UserLoading()); // Or a more specific state like UserAdding
    try {
      final newUser = await _repository.addUser(user);
      currentUsers.add(newUser); // Add the newly created user (with ID)
      emit(
        UserActionSuccess(
          'User added successfully!',
          lastLoadedUsers: currentUsers,
        ),
      );
      emit(UserLoaded(currentUsers)); // Update the main list
    } catch (e) {
      emit(
        UserError(
          'Failed to add user: ${e.toString()}',
          lastLoadedUsers: currentUsers,
        ),
      );
    }
  }

  Future<void> updateUser(User user) async {
    List<User> currentUsers = List.from(_getCurrentUsers() ?? []);
    emit(UserLoading()); // Or UserUpdating
    try {
      final updatedUser = await _repository.updateUser(user);
      final index = currentUsers.indexWhere(
        (u) => u.userID == updatedUser.userID,
      );
      if (index != -1) {
        currentUsers[index] =
            updatedUser; // Replace the old user with the updated one
      }
      emit(
        UserActionSuccess(
          'User updated successfully!',
          lastLoadedUsers: currentUsers,
        ),
      );
      emit(UserLoaded(currentUsers)); // Update the main list
    } catch (e) {
      emit(
        UserError(
          'Failed to update user: ${e.toString()}',
          lastLoadedUsers: currentUsers,
        ),
      );
    }
  }

  Future<void> deleteUser(int userID) async {
    List<User> currentUsers = List.from(_getCurrentUsers() ?? []);
    emit(UserLoading()); // Or UserDeleting
    try {
      await _repository.deleteUser(userID);
      currentUsers.removeWhere((u) => u.userID == userID); // Remove from list
      emit(
        UserActionSuccess(
          'User deleted successfully!',
          lastLoadedUsers: currentUsers,
        ),
      );
      emit(UserLoaded(currentUsers)); // Update the main list
    } catch (e) {
      emit(
        UserError(
          'Failed to delete user: ${e.toString()}',
          lastLoadedUsers: currentUsers,
        ),
      );
    }
  }
}

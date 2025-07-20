import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/user_model.dart'; 
import 'package:pfa/repositories/user_repo.dart';

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
  final List<User>? lastLoadedUsers; 
  const UserActionSuccess(this.message, {this.lastLoadedUsers});

  @override
  List<Object?> get props => [message, lastLoadedUsers];
}

class UserError extends UserState {
  final String message;
  final List<User>?
  lastLoadedUsers;// in case of error, we can provide the last loaded users
  const UserError(this.message, {this.lastLoadedUsers});

  @override
  List<Object?> get props => [message, lastLoadedUsers];
}

class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(UserInitial());
//* Fetch Current users
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
//* Fetch users 
  Future<void> fetchUsers() async {
    if (state is UserLoading) return;

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
//* Add a new user
  Future<void> addUser(User user) async {
    List<User> currentUsers = List.from(_getCurrentUsers() ?? []);
    emit(UserLoading()); 
    try {
      final newUser = await _repository.addUser(user);
      currentUsers.add(newUser); 
      emit(
        UserActionSuccess(
          'User added successfully!',
          lastLoadedUsers: currentUsers,
        ),
      );
      emit(UserLoaded(currentUsers)); 
    } catch (e) {
      emit(
        UserError(
          'Failed to add user: ${e.toString()}',
          lastLoadedUsers: currentUsers,
        ),
      );
    }
  }
//* Update user
  Future<void> updateUser(User user) async {
    List<User> currentUsers = List.from(_getCurrentUsers() ?? []);
    emit(UserLoading()); 
    try {
      final updatedUser = await _repository.updateUser(user);
      final index = currentUsers.indexWhere(
        (u) => u.userID == updatedUser.userID,
      );
      if (index != -1) {
        currentUsers[index] =
            updatedUser;
      }
      emit(
        UserActionSuccess(
          'User updated successfully!',
          lastLoadedUsers: currentUsers,
        ),
      );
      emit(UserLoaded(currentUsers));
    } catch (e) {
      emit(
        UserError(
          'Failed to update user: ${e.toString()}',
          lastLoadedUsers: currentUsers,
        ),
      );
    }
  }
//* Delete user
  Future<void> deleteUser(int userID) async {
    List<User> currentUsers = List.from(_getCurrentUsers() ?? []);
    emit(UserLoading()); 
    try {
      await _repository.deleteUser(userID);
      currentUsers.removeWhere((u) => u.userID == userID); 
      emit(
        UserActionSuccess(
          'User deleted successfully!',
          lastLoadedUsers: currentUsers,
        ),
      );
      emit(UserLoaded(currentUsers)); 
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

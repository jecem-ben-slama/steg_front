import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pfa/Model/user_model.dart';
import 'package:pfa/repositories/user_repo.dart';

// --- NEW STATES FOR SINGLE USER PROFILE ---
/// State indicating that a single user profile is currently being loaded.
class UserProfileLoading extends UserState {}

/// State indicating that a single user profile has been successfully loaded.
class UserProfileLoaded extends UserState {
  final User user; // The loaded user object
  const UserProfileLoaded(this.user);

  @override
  List<Object?> get props => [user]; // Equatable props for state comparison
}
// --- END NEW STATES ---

// Base abstract class for all User-related states
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

// Initial state of the UserCubit
class UserInitial extends UserState {}

// State indicating that a list of users is currently being loaded.
class UserLoading extends UserState {}

// State indicating that a list of users has been successfully loaded.
class UserLoaded extends UserState {
  final List<User> users; // The list of loaded users
  // Removed 'message' field as action-specific states will handle messages
  const UserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

// State indicating that a user action (add, update, delete) was successful.
class UserActionSuccess extends UserState {
  final String message; // Success message to display
  final String actionType; // Added actionType for more specific UI feedback
  final List<User>?
  lastLoadedUsers; // Optional: last loaded list of users (for list views)
  final User?
  updatedUser; // Optional: the user object that was just updated/added (for single profile view)
  const UserActionSuccess(
    this.message, {
    required this.actionType, // actionType is now required
    this.lastLoadedUsers,
    this.updatedUser,
  });

  @override
  List<Object?> get props => [
    message,
    actionType,
    lastLoadedUsers,
    updatedUser,
  ];
}

// State indicating that a user action or fetch operation resulted in an error.
class UserError extends UserState {
  final String message; // Error message to display
  final List<User>?
  lastLoadedUsers; // Optional: last loaded list of users (for list views)
  final User?
  lastLoadedUser; // Optional: last loaded single user (for profile view)
  const UserError(this.message, {this.lastLoadedUsers, this.lastLoadedUser});

  @override
  List<Object?> get props => [message, lastLoadedUsers, lastLoadedUser];
}

// The Cubit responsible for managing user-related states
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository; // Dependency on UserRepository

  UserCubit(this._repository)
    : super(UserInitial()); // Initialize with UserInitial state

  // Helper method to get the current list of users from the state
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

  // Helper method to get the current single user profile from the state
  User? _getCurrentUserProfile() {
    if (state is UserProfileLoaded) {
      return (state as UserProfileLoaded).user;
    } else if (state is UserActionSuccess) {
      return (state as UserActionSuccess).updatedUser;
    } else if (state is UserError) {
      return (state as UserError).lastLoadedUser;
    }
    return null;
  }

  // Helper to refetch all users and emit UserLoaded
  Future<void> _refetchAllUsersAndEmitLoaded() async {
    try {
      final users = await _repository.fetchAllUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(
        UserError(
          'Failed to refresh user list: ${e.toString()}',
          lastLoadedUsers: _getCurrentUsers(),
        ),
      );
    }
  }

  // Helper to refetch current user profile and emit UserProfileLoaded
  Future<void> _refetchCurrentUserProfileAndEmitLoaded(int userID) async {
    try {
      final user = await _repository.fetchUserById(userID);
      emit(UserProfileLoaded(user));
    } catch (e) {
      emit(
        UserError(
          'Failed to refresh user profile: ${e.toString()}',
          lastLoadedUser: _getCurrentUserProfile(),
        ),
      );
    }
  }

  //* Fetch Current User Profile
  /// Fetches a single user's profile data by their ID.
  /// Emits UserProfileLoading, then UserProfileLoaded or UserError.
  Future<void> fetchCurrentUserProfile(int userID) async {
    final currentUser = _getCurrentUserProfile(); // Capture for error fallback
    emit(UserProfileLoading()); // Indicate loading for the profile screen
    try {
      final user = await _repository.fetchUserById(
        userID,
      ); // Fetch user from repository
      emit(UserProfileLoaded(user)); // Emit success with the loaded user
    } catch (e) {
      // Emit error if fetching fails, providing the last known good user if available
      emit(
        UserError(
          'Failed to load profile: ${e.toString()}',
          lastLoadedUser: currentUser, // Provide original user on error
        ),
      );
    }
  }

  //* Fetch users (for lists, e.g., GestionnaireManagementScreen)
  /// Fetches all users from the backend.
  /// Emits UserLoading, then UserLoaded or UserError.
  Future<void> fetchUsers() async {
    if (state is UserLoading) return; // Prevent multiple simultaneous fetches

    final currentUsers =
        _getCurrentUsers(); // Capture current state for error recovery
    emit(UserLoading()); // Indicate loading for the list view
    try {
      final users = await _repository
          .fetchAllUsers(); // Fetch all users from repository
      emit(UserLoaded(users)); // Emit success with the loaded list of users
    } catch (e) {
      // Emit error if fetching fails, providing the last known good list if available
      emit(
        UserError(
          'Failed to load users: ${e.toString()}',
          lastLoadedUsers: currentUsers, // Provide original list on error
        ),
      );
    }
  }

  //* Add a new user
  /// Adds a new user to the system.
  /// Emits UserLoading, then UserActionSuccess and UserLoaded, or UserError.
  Future<void> addUser(User user) async {
    final currentUsers =
        _getCurrentUsers(); // Get current list for error revert
    emit(UserLoading()); // Indicate loading
    try {
      final newUser = await _repository.addUser(
        user,
      ); // Add user via repository

      emit(
        UserActionSuccess(
          'User "${newUser.username} ${newUser.lastname}" added successfully!',
          actionType: 'add',
          // No need to pass lastLoadedUsers or updatedUser here, as _refetchAllUsersAndEmitLoaded will handle the list update.
        ),
      );
      await _refetchAllUsersAndEmitLoaded(); // Refetch and update the entire list
    } catch (e) {
      // Emit error if adding fails
      emit(
        UserError(
          'Failed to add user: ${e.toString()}',
          lastLoadedUsers: currentUsers, // Provide original list on error
        ),
      );
      await _refetchAllUsersAndEmitLoaded(); // Revert to previous list if possible on error
    }
  }

  //* Update user (adaptable for single profile or list item)
  /// Updates an existing user's information.
  /// Handles updates for both a single user profile and users within a list.
  /// Emits UserProfileLoading/UserLoading, then UserActionSuccess and UserProfileLoaded/UserLoaded, or UserError.
  Future<void> updateUser(User user) async {
    final isUpdatingCurrentProfile =
        _getCurrentUserProfile()?.userID == user.userID;
    final currentUsers = _getCurrentUsers(); // For list view error fallback
    final currentUserProfile =
        _getCurrentUserProfile(); // For profile view error fallback

    // Emit appropriate loading state based on context
    if (isUpdatingCurrentProfile) {
      emit(UserProfileLoading()); // Show loading for the single profile screen
    } else {
      emit(UserLoading()); // Show loading for the list view
    }

    try {
      final updatedUser = await _repository.updateUser(
        user,
      ); // Perform the update via repository

      // Emit success with the updated user, then update the state.
      emit(
        UserActionSuccess(
          'User "${updatedUser.username} ${updatedUser.lastname}" updated successfully!',
          actionType: 'update',
          updatedUser:
              updatedUser, // Provide updated user for single profile view
        ),
      );

      if (isUpdatingCurrentProfile) {
        await _refetchCurrentUserProfileAndEmitLoaded(
          updatedUser.userID!,
        ); // Refetch and update single profile
      } else {
        await _refetchAllUsersAndEmitLoaded(); // Refetch and update the entire list
      }
    } catch (e) {
      // Handle errors based on whether it was a single profile update or list update
      if (isUpdatingCurrentProfile) {
        emit(
          UserError(
            'Failed to update profile: ${e.toString()}',
            lastLoadedUser:
                currentUserProfile, // Provide original profile on error
          ),
        );
        await _refetchCurrentUserProfileAndEmitLoaded(
          user.userID!,
        ); // Revert to the last good profile state on error
      } else {
        emit(
          UserError(
            'Failed to update user: ${e.toString()}',
            lastLoadedUsers: currentUsers, // Provide original list on error
          ),
        );
        await _refetchAllUsersAndEmitLoaded(); // Revert to the last good list state on error
      }
    }
  }

  //* Delete user
  /// Deletes a user from the system.
  /// Emits UserLoading, then UserActionSuccess and UserLoaded, or UserError.
  Future<void> deleteUser(int userID) async {
    final currentUsers =
        _getCurrentUsers(); // Get current list for error revert
    emit(UserLoading()); // Indicate loading
    try {
      await _repository.deleteUser(userID); // Delete user via repository

      emit(
        UserActionSuccess(
          'User deleted successfully!',
          actionType: 'delete',
          // No need to pass lastLoadedUsers here, as _refetchAllUsersAndEmitLoaded will handle the list update.
        ),
      );
      await _refetchAllUsersAndEmitLoaded(); // Refetch and update the entire list
    } catch (e) {
      // Emit error if deletion fails
      emit(
        UserError(
          'Failed to delete user: ${e.toString()}',
          lastLoadedUsers: currentUsers, // Provide original list on error
        ),
      );
      await _refetchAllUsersAndEmitLoaded(); // Revert to previous list if possible on error
    }
  }
}

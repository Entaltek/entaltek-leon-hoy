import '../../domain/entities/user.dart';

sealed class AuthUiState {
  const AuthUiState();
}

final class AuthInitial extends AuthUiState {
  const AuthInitial();
}

final class AuthLoading extends AuthUiState {
  const AuthLoading();
}

final class AuthSuccess extends AuthUiState {
  const AuthSuccess(this.user);

  final User user;
}

final class AuthError extends AuthUiState {
  const AuthError(this.message);

  final String message;
}

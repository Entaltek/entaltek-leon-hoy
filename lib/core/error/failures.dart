import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure();
}

final class ServerFailure extends Failure {
  const ServerFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure();

  @override
  List<Object?> get props => [];
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();

  @override
  List<Object?> get props => [];
}

final class CacheFailure extends Failure {
  const CacheFailure();

  @override
  List<Object?> get props => [];
}

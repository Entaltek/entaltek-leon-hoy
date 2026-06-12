import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/secure_storage_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../dtos/user_dto.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.dataSource,
    required this.storage,
  });

  final AuthRemoteDataSource dataSource;
  final SecureStorage storage;

  @override
  Future<Either<Failure, User>> login(String email, String password) =>
      _execute(() => dataSource.login(email, password));

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
  ) =>
      _execute(() => dataSource.register(email, password, name));

  Future<Either<Failure, User>> _execute(
    Future<({UserDto user, String accessToken, String refreshToken})>
        Function()
        call,
  ) async {
    try {
      final result = await call();
      await storage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return Right(result.user.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    final status = e.response?.statusCode ?? 0;
    if (status == 401) return const UnauthorizedFailure();
    if (status >= 500) {
      return ServerFailure(e.response?.statusMessage ?? 'Error del servidor');
    }
    return ServerFailure(e.message ?? 'Error desconocido');
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepositoryImpl(
      dataSource: ref.read(authRemoteDataSourceProvider),
      storage: ref.read(secureStorageProvider),
    );

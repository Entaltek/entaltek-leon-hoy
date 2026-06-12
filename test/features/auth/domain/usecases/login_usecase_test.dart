import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:leon_hoy/core/error/failures.dart';
import 'package:leon_hoy/features/auth/domain/entities/user.dart';
import 'package:leon_hoy/features/auth/domain/repositories/auth_repository.dart';
import 'package:leon_hoy/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase useCase;

  const tUser = User(id: '1', email: 'test@test.com', name: 'Test User');
  const tParams = LoginParams(email: 'test@test.com', password: '123456');

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('retorna User en caso de éxito', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tUser));

      final result = await useCase(tParams);

      expect(result, const Right<Failure, User>(tUser));
      verify(() => mockRepository.login(tParams.email, tParams.password))
          .called(1);
    });

    test('retorna UnauthorizedFailure cuando las credenciales son inválidas',
        () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Left(UnauthorizedFailure()));

      final result = await useCase(tParams);

      expect(result, const Left<Failure, User>(UnauthorizedFailure()));
    });

    test('retorna NetworkFailure cuando no hay conexión', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(tParams);

      expect(result, const Left<Failure, User>(NetworkFailure()));
    });
  });
}

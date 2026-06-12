import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:leon_hoy/core/error/failures.dart';
import 'package:leon_hoy/features/auth/domain/entities/user.dart';
import 'package:leon_hoy/features/auth/domain/repositories/auth_repository.dart';
import 'package:leon_hoy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:leon_hoy/features/auth/presentation/providers/auth_notifier.dart';
import 'package:leon_hoy/features/auth/presentation/state/auth_ui_state.dart';

import '../../../../helpers/test_helpers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  const tUser = User(id: '1', email: 'test@test.com', name: 'Test User');

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  ProviderContainer buildContainer() => createContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

  group('AuthNotifier', () {
    test('estado inicial es AuthInitial', () {
      final container = buildContainer();
      expect(
        container.read(authNotifierProvider),
        isA<AuthInitial>(),
      );
    });

    test('transiciona a AuthSuccess tras login exitoso', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tUser));

      final container = buildContainer();
      final states = <AuthUiState>[];

      container.listen<AuthUiState>(
        authNotifierProvider,
        (_, next) => states.add(next),
        fireImmediately: false,
      );

      await container
          .read(authNotifierProvider.notifier)
          .login('test@test.com', '123456');

      expect(states, [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ]);
      expect((states.last as AuthSuccess).user, tUser);
    });

    test('transiciona a AuthError tras login fallido', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Left(UnauthorizedFailure()));

      final container = buildContainer();
      final states = <AuthUiState>[];

      container.listen<AuthUiState>(
        authNotifierProvider,
        (_, next) => states.add(next),
        fireImmediately: false,
      );

      await container
          .read(authNotifierProvider.notifier)
          .login('test@test.com', 'wrong');

      expect(states, [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ]);
    });
  });
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../state/auth_ui_state.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthUiState build() => const AuthInitial();

  Future<void> login(String email, String password) async {
    state = const AuthLoading();

    final useCase = LoginUseCase(ref.read(authRepositoryProvider));
    final result = await useCase(LoginParams(email: email, password: password));

    // ref.read en lugar de ref.watch porque este código corre fuera del build.
    state = result.fold(
      (failure) => AuthError(failure.toString()),
      (user) => AuthSuccess(user),
    );
  }

  Future<void> register(String email, String password, String name) async {
    state = const AuthLoading();

    final useCase = RegisterUseCase(ref.read(authRepositoryProvider));
    final result = await useCase(
      RegisterParams(email: email, password: password, name: name),
    );

    state = result.fold(
      (failure) => AuthError(failure.toString()),
      (user) => AuthSuccess(user),
    );
  }
}

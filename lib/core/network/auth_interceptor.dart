import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.storage,
    // Se pasa una factory para crear un Dio sin interceptores y evitar loops.
    required this.dioFactory,
  });

  final SecureStorage storage;
  final Dio Function() dioFactory;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    // Evita loop si el propio endpoint de refresh devuelve 401.
    final isRefreshEndpoint =
        err.requestOptions.path.contains('/auth/refresh');

    if (!is401 || isRefreshEndpoint || _isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) {
        await storage.clear();
        handler.next(err);
        return;
      }

      // Usa un cliente Dio limpio para no entrar en el interceptor nuevamente.
      final refreshDio = dioFactory();
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data!;
      await storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      // Reintenta la petición original con el nuevo token.
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer ${data['access_token']}';

      final retryResponse = await refreshDio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await storage.clear();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}

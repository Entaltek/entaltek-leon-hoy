import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/secure_storage_impl.dart';
import 'auth_interceptor.dart';

part 'dio_client.g.dart';

const _baseUrl = 'https://api.leonhoy.entaltek.com/v1';

Dio _buildBaseDio() => Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  final storage = ref.read(secureStorageProvider);
  final dio = _buildBaseDio();

  dio.interceptors.add(
    AuthInterceptor(
      storage: storage,
      // Factory que crea un Dio limpio para el refresh, sin el interceptor.
      dioFactory: _buildBaseDio,
    ),
  );

  return dio;
}

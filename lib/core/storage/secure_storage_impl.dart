import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'secure_storage.dart';

part 'secure_storage_impl.g.dart';

const _keyAccessToken = 'access_token';
const _keyRefreshToken = 'refresh_token';

class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  @override
  Future<void> clear() => _storage.deleteAll();
}

@Riverpod(keepAlive: true)
SecureStorage secureStorage(SecureStorageRef ref) {
  const androidOptions = AndroidOptions(encryptedSharedPreferences: true);
  const storage = FlutterSecureStorage(aOptions: androidOptions);
  return SecureStorageImpl(storage);
}

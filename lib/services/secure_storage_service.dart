// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyWebAppUrl    = 'gas_web_app_url';
  static const _keySecretKey    = 'gas_secret_key';
  static const _keySessionToken = 'session_token';

  Future<void> saveWebAppUrl(String url) async =>
      _storage.write(key: _keyWebAppUrl, value: url);

  Future<String?> getWebAppUrl() => _storage.read(key: _keyWebAppUrl);

  Future<void> saveSecretKey(String key) async =>
      _storage.write(key: _keySecretKey, value: key);

  Future<String?> getSecretKey() => _storage.read(key: _keySecretKey);

  Future<void> saveSessionToken(String token) async =>
      _storage.write(key: _keySessionToken, value: token);

  Future<String?> getSessionToken() => _storage.read(key: _keySessionToken);

  Future<void> clearSessionToken() async =>
      _storage.delete(key: _keySessionToken);

  Future<void> clearAll() async => _storage.deleteAll();
}

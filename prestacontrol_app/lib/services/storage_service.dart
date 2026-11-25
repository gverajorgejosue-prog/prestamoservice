import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _emailKey = 'user_email';
  static const _nombreKey = 'user_nombre';

  Future<void> saveSession({required String token, required String email, required String nombre}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _nombreKey, value: nombre);
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<String?> getEmail() => _storage.read(key: _emailKey);
  Future<String?> getNombre() => _storage.read(key: _nombreKey);

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _nombreKey);
  }
}

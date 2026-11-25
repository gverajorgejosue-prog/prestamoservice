import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/usuario_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _client;
  final StorageService _storage;

  AuthService(this._client, this._storage);

  Future<UsuarioModel> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final data = await _client.post('/auth/register', auth: false, body: {
      'nombre': nombre,
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    await _storage.saveSession(
      token: data['token'].toString(),
      email: data['email'].toString(),
      nombre: data['nombre'].toString(),
    );
    return UsuarioModel.fromJson(data);
  }

  Future<UsuarioModel> login({required String email, required String password}) async {
    final data = await _client.post('/auth/login', auth: false, body: {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    await _storage.saveSession(
      token: data['token'].toString(),
      email: data['email'].toString(),
      nombre: data['nombre'].toString(),
    );
    return UsuarioModel.fromJson(data);
  }

  Future<void> logout() async {
    await _storage.clearSession();
  }

  Future<bool> hasValidSession() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  Future<DateTime?> getTokenExpiry() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) return null;
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (_) {
      return null;
    }
  }

  Future<UsuarioModel?> getCurrentUser() async {
    final email = await _storage.getEmail();
    final nombre = await _storage.getNombre();
    if (email == null || nombre == null) return null;
    return UsuarioModel(email: email, nombre: nombre);
  }
}

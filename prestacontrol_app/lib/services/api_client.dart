import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../screens/login_screen.dart';
import 'storage_service.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Sesión expirada, vuelve a iniciar sesión']);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

class ApiClient {
  final StorageService _storage;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _handlingUnauthorized = false;

  ApiClient(this._storage);

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool auth = true}) async {
    final response = await http.get(_uri(path), headers: await _headers(auth: auth));
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final response = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    final response = await http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<void> delete(String path, {bool auth = true}) async {
    final response = await http.delete(_uri(path), headers: await _headers(auth: auth));
    await _handleResponse(response, allowEmpty: true);
  }

  dynamic _handleResponse(http.Response response, {bool allowEmpty = false}) async {
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw UnauthorizedException();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Error de servidor (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        } else if (decoded is String && decoded.isNotEmpty) {
          message = decoded;
        }
      } catch (_) {
        if (response.body.isNotEmpty) message = response.body;
      }
      throw ApiException(message, response.statusCode);
    }

    if (allowEmpty || response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    try {
      await _storage.clearSession();
      final nav = navigatorKey.currentState;
      if (nav != null) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = navigatorKey.currentContext;
          if (ctx != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Sesión expirada, vuelve a iniciar sesión')),
            );
          }
        });
      }
    } finally {
      Future.delayed(const Duration(seconds: 1), () => _handlingUnauthorized = false);
    }
  }
}

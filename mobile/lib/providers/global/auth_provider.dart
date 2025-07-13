import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../services/sample_service.dart';

class AuthProvider extends ChangeNotifier {
  // Fields
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _isChecking = false;

  // Services
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isChecking => _isChecking;

  // Setters
  void setIsChecking(bool value) {
    _isChecking = value;
    notifyListeners();
  }

  // Initialize
  AuthProvider() {
    handleCheckAuth();
  }

  // Login
  Future<void> handleLogin({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      Map<String, dynamic> response = await _authService.login(
        username: username,
        password: password,
      );
      
      // Extract token from response
      String token = response['token'] ?? response['data'];
      await saveAuthData(token);
      _isLoggedIn = true;
    } catch (e) {
      _error = "Invalid Credential.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> handleLogout() async {
    _isLoggedIn = false;
    await _storage.deleteAll();
    notifyListeners();
  }

  // Check Auth
  Future<void> handleCheckAuth() async {
    try {
      _isChecking = true;
      notifyListeners();
      _isLoggedIn = await _validateToken();
    } catch (e) {
      _isLoggedIn = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<bool> _validateToken() async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        return false;
      }

      // Check if token is expired
      String? expStr = await _storage.read(key: 'token_exp');
      if (expStr != null) {
        int exp = int.parse(expStr);
        int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (currentTime >= exp) {
          await handleLogout();
          return false;
        }
      }

      // Optionally verify with server
      // await _authService.checkAuth();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveAuthData(String token) async {
    try {
      // Decode JWT token
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format');
      }

      // Decode the payload (second part)
      String payload = parts[1];

      // Add padding if necessary for base64 decoding
      switch (payload.length % 4) {
        case 0:
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        default:
          throw Exception('Invalid base64 string');
      }

      // Decode base64
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = json.decode(decoded);

      // Save token
      await _storage.write(key: 'token', value: token);

      // Extract user data from decoded token
      final user = data['user'];

      // Save basic user info
      await _storage.write(key: 'name', value: user['name'] ?? '');
      await _storage.write(key: 'phone_number', value: user['phone'] ?? '');
      await _storage.write(key: 'email', value: user['email'] ?? '');
      await _storage.write(key: 'avatar', value: user['avatar'] ?? '');
      await _storage.write(key: 'user_id', value: user['id']?.toString() ?? '');
      await _storage.write(key: 'created_at', value: user['created_at'] ?? '');

      // Save roles data
      final roles = user['roles'] as List?;
      if (roles != null && roles.isNotEmpty) {
        // Save first role as primary role
        final primaryRole = roles[0];
        await _storage.write(key: 'role_name', value: primaryRole['name'] ?? '');
        await _storage.write(key: 'role_slug', value: primaryRole['slug'] ?? '');
        await _storage.write(
          key: 'is_default_role',
          value: primaryRole['is_default']?.toString() ?? 'false',
        );

        // Save all roles as JSON string for future reference
        await _storage.write(key: 'all_roles', value: json.encode(roles));
      }

      // Save token expiration info
      if (data['exp'] != null) {
        await _storage.write(key: 'token_exp', value: data['exp'].toString());
      }
      if (data['iat'] != null) {
        await _storage.write(key: 'token_iat', value: data['iat'].toString());
      }
    } catch (e) {
      print('Error saving auth data: $e');
      rethrow;
    }
  }
  Future<void> switchRole(Map<String, dynamic> role) async {
    try {
      // Update the primary role in secure storage
      await _storage.write(key: 'role_name', value: role['name'] ?? '');
      await _storage.write(key: 'role_slug', value: role['slug'] ?? '');
      await _storage.write(
        key: 'is_default_role',
        value: role['is_default']?.toString() ?? 'false',
      );
      
      notifyListeners();
    } catch (e) {
      print('Error switching role: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentRole() async {
    try {
      String? rolesJson = await _storage.read(key: 'all_roles');
      String? currentRoleSlug = await _storage.read(key: 'role_slug');
      
      if (rolesJson != null && currentRoleSlug != null) {
        List<dynamic> roles = json.decode(rolesJson);
        return roles.firstWhere(
          (role) => role['slug'] == currentRoleSlug,
          orElse: () => null,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  // Helper methods to get user data
  Future<String?> getUserName() async {
    return await _storage.read(key: 'name');
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: 'email');
  }

  Future<String?> getUserPhone() async {
    return await _storage.read(key: 'phone_number');
  }

  Future<String?> getUserAvatar() async {
    return await _storage.read(key: 'avatar');
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: 'role_slug');
  }

  Future<List<dynamic>?> getAllRoles() async {
    String? rolesJson = await _storage.read(key: 'all_roles');
    if (rolesJson != null) {
      return json.decode(rolesJson);
    }
    return null;
  }
}
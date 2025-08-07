import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _isChecking = false;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isChecking => _isChecking;

  void setIsChecking(bool value) {
    _isChecking = value;
    notifyListeners();
  }

  void setIsLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  AuthProvider() {
    handleCheckAuth();
  }

  // Handle user login
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

  // Handle user logout
  Future<void> handleLogout() async {
    _isLoggedIn = false;
    await _storage.deleteAll();
    notifyListeners();
  }

  // Check authentication status
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

  // Validate token from secure storage
  Future<bool> _validateToken() async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        print("❌ No token found in secure storage");
        return false;
      }

      String? expStr = await _storage.read(key: 'token_exp');
      if (expStr != null) {
        int exp = int.parse(expStr);
        int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (currentTime >= exp) {
          await handleLogout();
          print("❌ Token expired");
          return false;
        }
      }
      print("🔍 Token validated successfully");
      return true;
    } catch (e) {
      print("❌ Error validating token: $e");
      return false;
    }
  }

  // Save authentication data to secure storage
  Future<void> saveAuthData(String token) async {
    try {
      // Decode JWT token
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format');
      }

      String payload = parts[1];
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

      final decoded = utf8.decode(base64Url.decode(payload));
      final data = json.decode(decoded);

      // Save token
      await _storage.write(key: 'token', value: token);
      print("🔍 Token saved: $token");

      // Extract user data
      final user = data['user'] as Map<String, dynamic>?;
      if (user == null) {
        throw Exception('No user data in token');
      }

      // Save basic user info
      await _storage.write(key: 'name', value: user['name'] ?? '');
      await _storage.write(key: 'phone_number', value: user['phone'] ?? '');
      await _storage.write(key: 'email', value: user['email'] ?? '');
      await _storage.write(key: 'avatar', value: user['avatar'] ?? '');
      await _storage.write(key: 'user_id', value: user['id']?.toString() ?? '');
      await _storage.write(key: 'created_at', value: user['created_at'] ?? '');

      // Save roles data
      final roles = user['roles'] as List<dynamic>?;
      if (roles == null || roles.isEmpty) {
        throw Exception('No roles in user data');
      }

      // Find default role
      final defaultRole = roles.firstWhere(
        (role) => role['is_default'] == true,
        orElse: () => roles[0], // Fallback to first role
      );

      // Save default role data
      await _storage.write(key: 'role_name', value: defaultRole['name'] ?? '');
      await _storage.write(key: 'role_slug', value: defaultRole['slug'] ?? '');
      await _storage.write(
        key: 'is_default_role',
        value: defaultRole['is_default']?.toString() ?? 'false',
      );

      // Save all roles
      await _storage.write(key: 'all_roles', value: json.encode(roles));
      print(
        "🔍 Saved role data - Name: ${defaultRole['name']}, Slug: ${defaultRole['slug']}, Roles: $roles",
      );

      // Save token expiration
      if (data['exp'] != null) {
        await _storage.write(key: 'token_exp', value: data['exp'].toString());
      }
      if (data['iat'] != null) {
        await _storage.write(key: 'token_iat', value: data['iat'].toString());
      }
    } catch (e) {
      print('❌ Error saving auth data: $e');
      rethrow;
    }
  }

  // Update profile
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? imageBase64,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        imageBase64: imageBase64,
      );

      String? token = response['token'];
      if (token != null) {
        await saveAuthData(token);
      } else {
        // Update storage directly if no new token is provided
        await _storage.write(key: 'name', value: name);
        await _storage.write(key: 'email', value: email);
        await _storage.write(key: 'phone_number', value: phone);
        if (imageBase64 != null) {
          await _storage.write(
            key: 'avatar',
            value:
                imageBase64.startsWith('data:image')
                    ? imageBase64.split(',').last
                    : imageBase64,
          );
        }
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update password
  Future<void> updatePassword({
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updatePassword(
        password: password,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Switch user role API
  Future<bool> switchRoleApi({
    required String defRoleId,
    required String swRoleId,
  }) async {
    try {
      print("🔍 Switching from role ID: $defRoleId to role ID: $swRoleId");
      final response = await _authService.switchRole(
        defRoleId: defRoleId,
        swRoleId: swRoleId,
      );
      print("🔍 API Response (raw): $response");

      final message = response['message'] as String?;
      final newToken = response['token'] as String?;

      print(
        "🔍 API Response details - Message: $message, New Token: $newToken",
      );

      if (message == 'This role is already set as default.' &&
          newToken != null) {
        print(
          "🔍 Role ID $swRoleId is already default, updating with new token",
        );
        await saveAuthData(newToken); // Use the new token to update storage
        return false; // No switch occurred, but data is synced
      }

      if (newToken == null || newToken.isEmpty) {
        throw Exception('No token received in response');
      }

      // Decode the new token to verify structure
      final parts = newToken.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format in response');
      }
      String payload = parts[1];
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
          throw Exception('Invalid base64 string in token');
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = json.decode(decoded);
      print("🔍 Decoded token data: $data");

      final user = data['user'] as Map<String, dynamic>?;
      if (user == null) {
        throw Exception('User data missing in response token');
      }

      final roles = user['roles'] as List<dynamic>?;
      if (roles == null || roles.isEmpty) {
        throw Exception('Roles data missing or empty in response token');
      }

      final newDefaultRole = roles.firstWhere(
        (role) => role['is_default'] == true,
        orElse: () => null,
      );
      if (newDefaultRole == null) {
        throw Exception('No default role found in response token');
      }
      print(
        "🔍 New default role: ${newDefaultRole['name']} (ID: ${newDefaultRole['id']})",
      );

      await saveAuthData(newToken);
      print("🔍 Token saved successfully");

      _isLoggedIn = true;
      notifyListeners();
      print("🔍 State updated, listeners notified");
      return true;
    } catch (e) {
      print("❌ Error switching role: $e");
      rethrow;
    }
  }

  // Fetch current role from the token
  Future<Map<String, dynamic>?> getCurrentRole() async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) {
        print("❌ No token found in secure storage");
        return null;
      }

      // Decode token to get the latest role data
      final parts = token.split('.');
      if (parts.length != 3) {
        print("❌ Invalid JWT token format");
        return null;
      }

      String payload = parts[1];
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
          print("❌ Invalid base64 string");
          return null;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final data = json.decode(decoded);
      final user = data['user'] as Map<String, dynamic>?;
      if (user == null) {
        print("❌ No user data in token");
        return null;
      }

      final roles = user['roles'] as List<dynamic>?;
      if (roles == null || roles.isEmpty) {
        print("❌ No roles in user data");
        return null;
      }

      final defaultRole = roles.firstWhere(
        (role) => role['is_default'] == true,
        orElse: () => null,
      );
      if (defaultRole == null) {
        print("❌ No default role found");
        return null;
      }

      print(
        "🔍 Fetched current role: ${defaultRole['name']} (ID: ${defaultRole['id']}, Slug: ${defaultRole['slug']})",
      );
      return defaultRole as Map<String, dynamic>?;
    } catch (e) {
      print("❌ Error fetching current role: $e");
      return null;
    }
  }

  // Fetch user role from the token
  Future<String?> getUserRole() async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) {
        print("❌ No token found in secure storage");
        return null;
      }

      // Decode token to get the latest role data
      final parts = token.split('.');
      if (parts.length != 3) {
        print("❌ Invalid JWT token format");
        return null;
      }

      String payload = parts[1];
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
          print("❌ Invalid base64 string");
          return null;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final data = json.decode(decoded);
      final user = data['user'] as Map<String, dynamic>?;
      if (user == null) {
        print("❌ No user data in token");
        return null;
      }

      final roles = user['roles'] as List<dynamic>?;
      if (roles == null || roles.isEmpty) {
        print("❌ No roles in user data");
        return null;
      }

      final defaultRole = roles.firstWhere(
        (role) => role['is_default'] == true,
        orElse: () => null,
      );
      if (defaultRole == null) {
        print("❌ No default role found");
        return null;
      }

      print(
        "🔍 Fetched user role: ${defaultRole['name']} (Slug: ${defaultRole['slug']})",
      );
      return defaultRole['name'] as String?;
    } catch (e) {
      print("❌ Error fetching user role: $e");
      return null;
    }
  }

  // Fetch user name
  Future<String?> getUserName() async {
    try {
      final name = await _storage.read(key: 'name');
      print("🔍 Fetched user name: $name");
      return name;
    } catch (e) {
      print("❌ Error fetching user name: $e");
      return null;
    }
  }

  // Fetch user email
  Future<String?> getUserEmail() async {
    try {
      final email = await _storage.read(key: 'email');
      print("🔍 Fetched user email: $email");
      return email;
    } catch (e) {
      print("❌ Error fetching user email: $e");
      return null;
    }
  }

  Future<String?> getUserPhone() async {
    try {
      final phone = await _storage.read(key: 'phone_number');
      print("🔍 Fetched user phone: $phone");
      return phone;
    } catch (e) {
      print("❌ Error fetching user phone: $e");
      return null;
    }
  }

  // Fetch user last login time
  Future<String?> getLastUpdated() async {
    try {
      final iatStr = await _storage.read(key: 'created_at');
      print("🔍 Fetched user last login at: $iatStr");

      if (iatStr == null) {
        print("❌ No 'created_at' found in secure storage");
        return null;
      }

      final DateTime loginTime = DateTime.parse(iatStr).toLocal();
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(loginTime);

      if (difference.inMinutes < 1) {
        return "just now";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes}m";
      } else if (difference.inHours < 24) {
        return "${difference.inHours}h";
      } else {
        return "${difference.inDays}d";
      }
    } catch (e) {
      print("❌ Error parsing or processing 'created_at': $e");
      return null;
    }
  }

  // Fetch user avatar
  Future<String?> getUserAvatar() async {
    try {
      final avatar = await _storage.read(key: 'avatar');
      print("🔍 Fetched user avatar: $avatar");
      return avatar;
    } catch (e) {
      print("❌ Error fetching user avatar: $e");
      return null;
    }
  }

  // Fetch user ID
  Future<List<dynamic>?> getAllRoles() async {
    try {
      String? rolesJson = await _storage.read(key: 'all_roles');
      if (rolesJson != null) {
        final roles = json.decode(rolesJson);
        print("🔍 Fetched all roles: $roles");
        return roles;
      }
      print("❌ No roles found in storage");
      return null;
    } catch (e) {
      print("❌ Error fetching all roles: $e");
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final currentRole = await getCurrentRole();
    final isAdmin = currentRole != null && currentRole['slug'] == 'admin';
    print("🔍 isAdmin check: $isAdmin");
    return isAdmin;
  }
}

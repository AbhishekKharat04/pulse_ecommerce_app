import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmailPassword(String email, String password);
  Future<UserEntity> registerWithEmailPassword(String email, String password, String name);
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({required this.sharedPreferences});

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userJson = sharedPreferences.getString(ApiConstants.cachedUserKey);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<UserEntity> signInWithEmailPassword(String email, String password) async {
    // Simulated Firebase Auth Network Call with latency
    await Future.delayed(const Duration(milliseconds: 800));

    if (password.length < 6) {
      throw AuthenticationFailure(message: 'Password must be at least 6 characters long');
    }

    if (!email.contains('@')) {
      throw AuthenticationFailure(message: 'Please provide a valid email address');
    }

    final user = UserModel(
      id: 'fb_usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first.toUpperCase(),
      token: 'jwt_firebase_mock_token_xyz987',
    );

    // Save session
    await sharedPreferences.setString(
      ApiConstants.cachedUserKey,
      jsonEncode(user.toJson()),
    );

    return user;
  }

  @override
  Future<UserEntity> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final user = UserModel(
      id: 'fb_usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name.isEmpty ? 'New User' : name,
      token: 'jwt_firebase_mock_token_abc123',
    );

    await sharedPreferences.setString(
      ApiConstants.cachedUserKey,
      jsonEncode(user.toJson()),
    );

    return user;
  }

  @override
  Future<void> signOut() async {
    await sharedPreferences.remove(ApiConstants.cachedUserKey);
  }
}

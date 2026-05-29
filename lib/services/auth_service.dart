import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser    => _supabase.auth.currentUser;
  bool get isLoggedIn      => currentUser != null;
  String? get currentUserId => currentUser?.id;

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        return AuthResult.error('Signup failed. Please try again.');
      }

      await Future.delayed(const Duration(milliseconds: 500));
      await _supabase.from('profiles').upsert({
        'id':    response.user!.id,
        'name':  name,
        'email': email,
      });

      final profile = await getProfile(response.user!.id);
      return AuthResult.success(profile);
    } on AuthException catch (e) {
      return AuthResult.error(_friendlyError(e.message));
    } catch (e) {
      return AuthResult.error('Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('Login failed. Please try again.');
      }

      final profile = await getProfile(response.user!.id);
      return AuthResult.success(profile);
    } on AuthException catch (e) {
      return AuthResult.error(_friendlyError(e.message));
    } catch (e) {
      return AuthResult.error('Something went wrong. Please try again.');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
    List<String>? selectedSkills,
    String? fcmToken,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name           != null) updates['name']            = name;
      if (photoUrl       != null) updates['photo_url']       = photoUrl;
      if (selectedSkills != null) updates['selected_skills'] = selectedSkills;
      if (fcmToken       != null) updates['fcm_token']       = fcmToken;

      if (updates.isEmpty) return true;

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateXP({
    required String userId,
    required int newXp,
    required int newLevel,
  }) async {
    try {
      await _supabase.from('profiles').update({
        'xp':    newXp,
        'level': newLevel,
      }).eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStreak({
    required String userId,
    required int streakCurrent,
    required int streakBest,
    required String lastActiveDate,
  }) async {
    try {
      await _supabase.from('profiles').update({
        'streak_current':   streakCurrent,
        'streak_best':      streakBest,
        'last_active_date': lastActiveDate,
      }).eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _friendlyError(String message) {
    if (message.contains('already registered')) {
      return 'This email is already registered. Please login.';
    }
    if (message.contains('Invalid login credentials')) {
      return 'Wrong email or password. Please try again.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please confirm your email first.';
    }
    if (message.contains('Password should be')) {
      return 'Password must be at least 6 characters.';
    }
    if (message.contains('Unable to validate email')) {
      return 'Please enter a valid email address.';
    }
    return message;
  }
}

class AuthResult {
  final bool success;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({
    required this.success,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel? user) =>
      AuthResult._(success: true, user: user);

  factory AuthResult.error(String message) =>
      AuthResult._(success: false, errorMessage: message);
}
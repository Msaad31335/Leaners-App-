import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user         => _user;
  bool       get isLoading    => _isLoading;
  String?    get errorMessage => _errorMessage;
  bool       get isLoggedIn   => _user != null;

  // ── Load on app start ────────────────────────────────────
  Future<void> loadUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;
    await _fetchProfile(session.user.id);
  }

  Future<void> _fetchProfile(String uid) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .single();
      _user = UserModel.fromMap(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Profile fetch error: $e');
    }
  }

  // ── Sign Up ──────────────────────────────────────────────
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        _errorMessage = 'Signup failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await Future.delayed(const Duration(milliseconds: 600));

      await _supabase.from('profiles').upsert({
        'id':    response.user!.id,
        'name':  name,
        'email': email,
      });

      await _fetchProfile(response.user!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _friendlyError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Login ────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _errorMessage = 'Login failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _fetchProfile(response.user!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _friendlyError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }

  // ── Update Skills ────────────────────────────────────────
  Future<void> updateSkills(List<String> skills) async {
    if (_user == null) return;
    await _supabase.from('profiles').update({
      'selected_skills': skills,
    }).eq('id', _user!.id);
    _user = UserModel(
      id:             _user!.id,
      name:           _user!.name,
      email:          _user!.email,
      streakCount:    _user!.streakCount,
      bestStreak:     _user!.bestStreak,
      xp:             _user!.xp,
      level:          _user!.level,
      selectedSkills: skills,
      lastActiveDate: _user!.lastActiveDate,
    );
    notifyListeners();
  }

  // ── Add XP ───────────────────────────────────────────────
  Future<void> addXP(int xp) async {
    if (_user == null) return;
    final newXP    = _user!.xp + xp;
    final newLevel = (newXP / 100).floor() + 1;

    await _supabase.from('profiles').update({
      'xp':    newXP,
      'level': newLevel,
    }).eq('id', _user!.id);

    _user = UserModel(
      id:             _user!.id,
      name:           _user!.name,
      email:          _user!.email,
      streakCount:    _user!.streakCount,
      bestStreak:     _user!.bestStreak,
      xp:             newXP,
      level:          newLevel,
      selectedSkills: _user!.selectedSkills,
      lastActiveDate: _user!.lastActiveDate,
    );
    notifyListeners();
  }

  // ── Update Streak ────────────────────────────────────────
  Future<void> updateStreak() async {
    if (_user == null) return;
    final newStreak  = _user!.streakCount + 1;
    final bestStreak = newStreak > _user!.bestStreak ? newStreak : _user!.bestStreak;
    final today      = DateTime.now().toIso8601String().split('T').first;

    await _supabase.from('profiles').update({
      'streak_current':   newStreak,
      'streak_best':      bestStreak,
      'last_active_date': today,
    }).eq('id', _user!.id);

    _user = UserModel(
      id:             _user!.id,
      name:           _user!.name,
      email:          _user!.email,
      streakCount:    newStreak,
      bestStreak:     bestStreak,
      xp:             _user!.xp,
      level:          _user!.level,
      selectedSkills: _user!.selectedSkills,
      lastActiveDate: today,
    );
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _friendlyError(String message) {
    if (message.contains('already registered'))        return 'This email is already registered. Please login.';
    if (message.contains('Invalid login credentials')) return 'Wrong email or password. Please try again.';
    if (message.contains('Email not confirmed'))       return 'Please confirm your email first.';
    if (message.contains('Password should be'))        return 'Password must be at least 6 characters.';
    return message;
  }
}
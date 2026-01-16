import 'package:shared_preferences/shared_preferences.dart';
import 'package:sca_members_clubs/features/auth/data/models/user_model.dart';

class SessionManager {
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';
  static const String _membershipIdKey = 'membership_id';

  final SharedPreferences _prefs;

  SessionManager(this._prefs);

  /// Save user session to SharedPreferences
  Future<void> saveUserSession(UserModel user) async {
    await Future.wait([
      _prefs.setString(_userIdKey, user.id),
      _prefs.setString(_usernameKey, user.username),
      _prefs.setString(_roleKey, user.role),
      if (user.membershipId != null)
        _prefs.setString(_membershipIdKey, user.membershipId!)
      else
        _prefs.remove(_membershipIdKey),
    ]);
  }

  /// Get saved user session from SharedPreferences
  UserModel? getSavedUserSession() {
    final userId = _prefs.getString(_userIdKey);
    final username = _prefs.getString(_usernameKey);
    final role = _prefs.getString(_roleKey);

    if (userId == null || username == null || role == null) {
      return null;
    }

    final membershipId = _prefs.getString(_membershipIdKey);

    return UserModel(
      id: userId,
      username: username,
      role: role,
      membershipId: membershipId,
    );
  }

  /// Clear user session from SharedPreferences
  Future<void> clearUserSession() async {
    await Future.wait([
      _prefs.remove(_userIdKey),
      _prefs.remove(_usernameKey),
      _prefs.remove(_roleKey),
      _prefs.remove(_membershipIdKey),
    ]);
  }

  /// Check if user session exists
  bool hasUserSession() {
    return _prefs.containsKey(_userIdKey);
  }

  /// Get saved username
  String? getSavedUsername() {
    return _prefs.getString(_usernameKey);
  }

  /// Get saved role
  String? getSavedRole() {
    return _prefs.getString(_roleKey);
  }

  /// Get saved membership ID
  String? getSavedMembershipId() {
    return _prefs.getString(_membershipIdKey);
  }
}

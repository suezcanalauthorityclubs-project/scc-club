import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sca_members_clubs/core/services/session_manager.dart';
import 'package:sca_members_clubs/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sca_members_clubs/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SessionManager _sessionManager;

  AuthRemoteDataSourceImpl(this._firestore, this._sessionManager);

  static const String _usersCollection = 'users';

  @override
  Future<UserModel?> login(String username, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('مستخدم غير موجود');
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      // Verify password
      if (userData['password'] != password) {
        throw Exception('كلمة المرور غير صحيحة');
      }

      // Create UserModel from Firestore data
      final user = UserModel(
        id: userDoc.id,
        username: userData['username'] ?? '',
        role: userData['role'] ?? 'member',
        membershipId: userData['membership_id'],
      );

      // Save session
      await _sessionManager.saveUserSession(user);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> register(Map<String, dynamic> userData) async {
    try {
      // Validate that username doesn't already exist
      final existing = await _firestore
          .collection(_usersCollection)
          .where('username', isEqualTo: userData['username'])
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('اسم المستخدم موجود بالفعل');
      }

      // Add new user to Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(userData['id'] ?? userData['username'])
          .set(userData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear session
      await _sessionManager.clearUserSession();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // First try to get from saved session
      final savedUser = _sessionManager.getSavedUserSession();
      if (savedUser != null) {
        // Optionally verify the user still exists in Firestore
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(savedUser.id)
            .get();
        if (userDoc.exists) {
          return UserModel(
            id: userDoc.id,
            username: userDoc.data()?['username'] ?? savedUser.username,
            role: userDoc.data()?['role'] ?? savedUser.role,
            membershipId:
                userDoc.data()?['membership_id'] ?? savedUser.membershipId,
          );
        } else {
          // User no longer exists, clear session
          await _sessionManager.clearUserSession();
          return null;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}

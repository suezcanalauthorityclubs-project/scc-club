import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class to seed Firestore with test users
class FirestoreSeeder {
  static const String _usersCollection = 'users';

  static final List<Map<String, dynamic>> _testUsers = [
    {
      'id': 'abadr',
      'username': 'abadr',
      'password': '123',
      'membership_id': '1036711',
      'role': 'member',
    },
    {
      'id': 'badr',
      'username': 'badr',
      'password': '123',
      'membership_id': '1036711',
      'role': 'child',
    },
    {'id': 'hamdy', 'username': 'hamdy', 'password': '123', 'role': 'security'},
    {
      'id': 'mennah',
      'username': 'mennah',
      'password': '123',
      'membership_id': '1036711',
      'role': 'wife',
    },
  ];

  /// Seed the users collection with test data
  /// Set [overwrite] to true to overwrite existing data
  static Future<void> seedUsers({
    required FirebaseFirestore firestore,
    bool overwrite = false,
  }) async {
    try {
      final collection = firestore.collection(_usersCollection);

      // Check if collection already has data
      if (!overwrite) {
        final snapshot = await collection.limit(1).get();
        if (snapshot.docs.isNotEmpty) {
          print('Users collection already has data. Skipping seeding.');
          return;
        }
      }

      // Add test users
      for (final user in _testUsers) {
        await collection.doc(user['id']).set({
          'username': user['username'],
          'password': user['password'],
          'role': user['role'],
          if (user['membership_id'] != null)
            'membership_id': user['membership_id'],
        });
      }

      print(
        'Firestore seeded successfully with ${_testUsers.length} test users.',
      );
    } catch (e) {
      print('Error seeding Firestore: $e');
      rethrow;
    }
  }
}

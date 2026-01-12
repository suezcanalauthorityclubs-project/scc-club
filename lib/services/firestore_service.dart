import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/membership_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch the complete membership including sub-collections
  Future<Membership?> getMembership(String membershipId) async {
    try {
      // Fetch main document
      DocumentSnapshot doc = await _db.collection('main_membership').doc(membershipId).get();

      if (!doc.exists) return null;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Membership membership = Membership.fromMap(data, doc.id);

      // Fetch wives sub-collection
      QuerySnapshot wivesSnap = await doc.reference.collection('wives').get();
      membership.wives = wivesSnap.docs.map((d) => Wife.fromMap(d.data() as Map<String, dynamic>)).toList();

      // Fetch children sub-collection
      QuerySnapshot childrenSnap = await doc.reference.collection('children').get();
      membership.children = childrenSnap.docs.map((d) => Child.fromMap(d.data() as Map<String, dynamic>)).toList();

      return membership;
    } catch (e) {
      // Throw error to be handled by Cubit
      throw Exception(e.toString());
    }
  }

  // Method to seed initial sample data
  Future<void> uploadSampleData(Map<String, dynamic> sample) async {
    final mainKey = sample['main_membership'].keys.first;
    final data = sample['main_membership'][mainKey];

    // Upload main doc
    await _db.collection('main_membership').doc(mainKey).set({
      ...data,
      'wives': null, // Avoid nested maps, use sub-collections instead
      'children': null,
    });

    // Upload wives sub-collection
    if (data['wives'] != null) {
      for (var id in data['wives'].keys) {
        await _db.collection('main_membership').doc(mainKey).collection('wives').doc(id).set(data['wives'][id]);
      }
    }

    // Upload children sub-collection
    if (data['children'] != null) {
      for (var id in data['children'].keys) {
        await _db.collection('main_membership').doc(mainKey).collection('children').doc(id).set(data['children'][id]);
      }
    }
  }
}
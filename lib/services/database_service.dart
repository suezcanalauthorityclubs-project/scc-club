import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';
import '../models/family_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // retrieve full member details including family members
  Future<MemberModel?> getFullMemberDetails(String memberId) async {
    try {
      var memberDoc = await _db.collection('main_membership').doc(memberId).get();
      if (!memberDoc.exists) return null;

      var childrenSnap = await memberDoc.reference.collection('children').get();
      var children = childrenSnap.docs
          .map((doc) => FamilyMemberModel.fromMap(doc.data(), doc.id))
          .toList();

      var wivesSnap = await memberDoc.reference.collection('wives').get();
      var wives = wivesSnap.docs
          .map((doc) => FamilyMemberModel.fromMap(doc.data(), doc.id))
          .toList();

      return MemberModel.fromFirestore(
        memberDoc.data()!, 
        memberDoc.id, 
        children: children, 
        wives: wives
      );
    } catch (e) {
      throw Exception("Error fetching: $e");
    }
  }

  // upload member data (Create/Update)
  Future<void> uploadMember(MemberModel member) async {
    try {
      DocumentReference memberRef = _db.collection('main_membership').doc(member.id);
      
      //upload main member data
      await memberRef.set(member.toMap());

      // upload children
      for (var child in member.children) {
        await memberRef.collection('children').doc(child.id).set(child.toMap());
      }

      // upload spouses
      for (var wife in member.wives) {
        await memberRef.collection('wives').doc(wife.id).set(wife.toMap());
      }
    } catch (e) {
      throw Exception("Error uploading: $e");
    }
  }
}
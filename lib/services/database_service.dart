import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // upload member data along with family members
  Future<void> uploadMember(MemberModel member) async {
    try {
      // 1. identify the main member document reference
      DocumentReference memberRef = _db.collection('main_membership').doc(member.id);

      // upload member data
      await memberRef.set(member.toMap());

      // upload children in Sub-collection
      for (var child in member.children) {
        await memberRef.collection('children').doc(child.id).set(child.toMap());
      }

      //upload spouses in Sub-collection
      for (var wife in member.wives) {
        await memberRef.collection('wives').doc(wife.id).set(wife.toMap());
      }

      print("تم رفع بيانات العضو ${member.name} بنجاح!");
    } catch (e) {
      print("خطأ أثناء الرفع: $e");
      rethrow;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';
import '../models/family_model.dart';

class DatabaseService {
  // create firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// retrieve full member data including sub-collections
  Future<MemberModel?> getMemberFullData(String memberId) async {
    try {
      // 1. retrieve main member document
      DocumentSnapshot memberDoc = 
          await _db.collection('main_membership').doc(memberId).get();

      if (!memberDoc.exists) return null; // if member does not exist

      // retrieve main data as map
      Map<String, dynamic> mainData = memberDoc.data() as Map<String, dynamic>;

      // 2. retrieve children from the sub-collection of this member
      QuerySnapshot childrenSnap = 
          await memberDoc.reference.collection('children').get();
      
      List<ChildModel> childrenList = childrenSnap.docs
          .map((doc) => ChildModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // 3. retrieve wives from the sub-collection of this member
      QuerySnapshot wivesSnap = 
          await memberDoc.reference.collection('wives').get();
      
      List<WifeModel> wivesList = wivesSnap.docs
          .map((doc) => WifeModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      //  4. construct and return the full MemberModel
      return MemberModel.fromFirestore(
        mainData, 
        memberDoc.id, 
        children: childrenList, 
        wives: wivesList
      );
      
    } catch (e) {
      print("Error fetching member data: $e");
      rethrow; //   propagate the error
    }
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sca_members_clubs/core/routes/app_routes.dart';
import 'package:sca_members_clubs/core/services/session_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:sca_members_clubs/features/profile/domain/entities/family_member.dart';

class FamilyListScreen extends StatelessWidget {
  const FamilyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FamilyListView();
  }
}

class FamilyListView extends StatefulWidget {
  const FamilyListView({super.key});

  @override
  State<FamilyListView> createState() => _FamilyListViewState();
}

class _FamilyListViewState extends State<FamilyListView> {
  late Future<List<Map<String, dynamic>>> _familyMembersFuture;

  @override
  void initState() {
    super.initState();
    _familyMembersFuture = _getFamilyMembers();
  }

  Future<List<Map<String, dynamic>>> _getFamilyMembers() async {
    try {
      final sessionManager = GetIt.instance<SessionManager>();
      final membershipId = sessionManager.getSavedMembershipId();

      debugPrint(
        'DEBUG: Fetching family members for membershipId: $membershipId',
      );

      if (membershipId == null) {
        debugPrint('DEBUG: MembershipId is null');
        return [];
      }

      final List<Map<String, dynamic>> allMembers = [];

      // Try first: fetch using membershipId as document ID
      DocumentSnapshot mainMemberDoc = await FirebaseFirestore.instance
          .collection('main_membership')
          .doc(membershipId)
          .get();

      // If not found, try querying where membership_id field equals membershipId
      if (!mainMemberDoc.exists) {
        debugPrint(
          'DEBUG: Document ID not found, querying by membership_id field',
        );
        final query = await FirebaseFirestore.instance
            .collection('main_membership')
            .where('membership_id', isEqualTo: membershipId)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          mainMemberDoc = query.docs.first;
          debugPrint('DEBUG: Found membership by membership_id field');
        }
      }

      if (!mainMemberDoc.exists) {
        debugPrint('DEBUG: main_membership document NOT found');
        return [];
      }

      debugPrint('DEBUG: main_membership document found');

      // Fetch wives sub-collection using doc reference
      QuerySnapshot wivesSnap = await mainMemberDoc.reference
          .collection('wives')
          .get();
      debugPrint('DEBUG: Wives count: ${wivesSnap.docs.length}');

      for (var doc in wivesSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('DEBUG: Wife data: $data');
        allMembers.add({
          'name': data['name'] ?? 'بدون اسم',
          'relation': 'زوجة',
          'age': data['age'] ?? 0,
          'image': data['image'] ?? '',
          'docId': doc.id,
          'type': 'wife',
        });
      }

      // Fetch children sub-collection using doc reference
      QuerySnapshot childrenSnap = await mainMemberDoc.reference
          .collection('children')
          .get();
      debugPrint('DEBUG: Children count: ${childrenSnap.docs.length}');

      for (var doc in childrenSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('DEBUG: Child data: $data');
        allMembers.add({
          'name': data['name'] ?? 'بدون اسم',
          'relation': data['gender'] == 'ذكر' ? 'ابن' : 'ابنة',
          'age': data['age'] ?? 0,
          'image': data['image'] ?? '',
          'docId': doc.id,
          'type': 'child',
        });
      }

      debugPrint('DEBUG: Total members: ${allMembers.length}');
      return allMembers;
    } catch (e) {
      debugPrint('ERROR: Error fetching family members: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "أفراد الأسرة",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _familyMembersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "خطأ في تحميل البيانات",
                    style: GoogleFonts.cairo(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _familyMembersFuture = _getFamilyMembers();
                      });
                    },
                    child: Text("إعادة المحاولة", style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            );
          }

          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.family_restroom_rounded,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "لا يوجد أفراد مضافين حالياً",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: members.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final member = members[index];
              final familyMember = FamilyMember(
                id: member['docId'] ?? '---',
                name: member['name'] ?? 'بدون اسم',
                relation: member['relation'] ?? 'تابع',
                image: member['image'] ?? '',
                age: member['age'] ?? 0,
                nationalId: member['docId'] ?? '---',
                expiryDate: '',
              );
              return InkWell(
                onTap: () {
                  // Navigate to existing family membership card screen
                  Navigator.pushNamed(
                    context,
                    Routes.familyMembershipCard,
                    arguments: familyMember,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          image:
                              member['image'] != null &&
                                  (member['image'] as String).isNotEmpty &&
                                  (member['image'] as String).startsWith(
                                    'assets',
                                  )
                              ? DecorationImage(
                                  image: AssetImage(member['image']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            (member['image'] == null ||
                                (member['image'] as String).isEmpty ||
                                !(member['image'] as String).startsWith(
                                  'assets',
                                ))
                            ? const Icon(
                                Icons.person_rounded,
                                color: Colors.grey,
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['name'],
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              member['relation'],
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 12,
                      //     vertical: 6,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.primary.withValues(alpha: 0.08),
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: Text(
                      //     "${member['age']} سنة",
                      //     style: GoogleFonts.cairo(
                      //       fontSize: 12,
                      //       color: AppColors.primary,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

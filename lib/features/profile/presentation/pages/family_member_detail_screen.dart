import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:sca_members_clubs/features/profile/presentation/widgets/family_member_card.dart';

class FamilyMemberDetailScreen extends StatelessWidget {
  final Map<String, dynamic> memberData;

  const FamilyMemberDetailScreen({super.key, required this.memberData});

  @override
  Widget build(BuildContext context) {
    final name = memberData['name'] ?? 'بدون اسم';
    final relation = memberData['relation'] ?? 'تابع';
    final docId = memberData['docId'] ?? '---';
    final imageUrl = memberData['image'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'بطاقة $relation',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: FamilyMemberCard(
            name: name,
            relation: relation,
            memberId: docId,
            imageUrl: imageUrl,
          ),
        ),
      ),
    );
  }
}

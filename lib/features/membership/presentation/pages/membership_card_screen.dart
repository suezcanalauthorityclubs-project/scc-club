import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:sca_members_clubs/features/membership/presentation/widgets/dynamic_qr_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sca_members_clubs/core/services/session_manager.dart';
import 'package:get_it/get_it.dart';

class MembershipCardScreen extends StatefulWidget {
  const MembershipCardScreen({super.key});

  @override
  State<MembershipCardScreen> createState() => _MembershipCardScreenState();
}

class _MembershipCardScreenState extends State<MembershipCardScreen> {
  late Future<Map<String, dynamic>?> _membershipDataFuture;

  @override
  void initState() {
    super.initState();
    _membershipDataFuture = _getUserMembershipData();
  }

  Future<Map<String, dynamic>?> _getUserMembershipData() async {
    try {
      final sessionManager = GetIt.instance<SessionManager>();
      final role = sessionManager.getSavedRole();
      final membershipId = sessionManager.getSavedMembershipId();

      if (membershipId == null || membershipId.isEmpty) {
        return {
          'name': 'مستخدم',
          'role': _translateRole(role),
          'membership_id': '---',
          'membership_type': '---',
          'job': '---',
          'membership_status': '---',
          'photoUrl': null,
        };
      }

      // Try first: fetch using membership_id as document ID
      var membershipDoc = await FirebaseFirestore.instance
          .collection('main_membership')
          .doc(membershipId)
          .get();

      // If not found, try querying where membership_id field equals membershipId
      if (!membershipDoc.exists) {
        final query = await FirebaseFirestore.instance
            .collection('main_membership')
            .where('membership_id', isEqualTo: membershipId)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          membershipDoc = query.docs.first;
        }
      }

      if (membershipDoc.exists) {
        final data = membershipDoc.data() ?? {};
        return {
          'name': data['name'] ?? 'مستخدم',
          'role': _translateRole(role),
          'membership_id': data['membership_id'] ?? membershipId,
          'membership_type': data['membership_type']?.toString() ?? '---',
          'job': data['job'] ?? '---',
          'membership_status': data['membership_status'] ?? '---',
          'photoUrl': data['photoUrl'],
        };
      }

      return {
        'name': 'مستخدم',
        'role': _translateRole(role),
        'membership_id': membershipId,
        'membership_type': '---',
        'job': '---',
        'membership_status': '---',
        'photoUrl': null,
      };
    } catch (e) {
      print('ERROR: Error fetching membership data: $e');
      return {
        'name': 'مستخدم',
        'role': 'عضو',
        'membership_id': '---',
        'membership_type': '---',
        'job': '---',
        'membership_status': '---',
        'photoUrl': null,
      };
    }
  }

  String _translateRole(String? role) {
    if (role == null) return 'عضو';

    switch (role.toLowerCase()) {
      case 'member':
        return 'عضو';
      case 'wife':
      case 'child':
        return 'عضو تابع';
      case 'security':
        return 'أمن النادي';
      default:
        return 'عضو';
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubName =
        ModalRoute.of(context)?.settings.arguments as String? ??
        "النادي العام لهيئة قناة السويس";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "بطاقة العضوية الذكية",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _membershipDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "خطأ في تحميل البيانات",
                style: GoogleFonts.cairo(color: Colors.white),
              ),
            );
          }

          final membershipData = snapshot.data ?? {};
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              children: [
                _buildPremiumCarnet(membershipData, clubName),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.qr_code_2_rounded,
                        "استخدم الكود الخاص بك للدخول السريع عبر البوابات الإلكترونية.",
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.white12, height: 1),
                      ),
                      _buildInfoRow(
                        Icons.verified_user_rounded,
                        "هذه البطاقة رقمية مخصصة للعاملين وأسرهم بهيئة قناة السويس.",
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.white12, height: 1),
                      ),
                      _buildInfoRow(
                        Icons.sync_rounded,
                        "يتم تحديث صلاحية البطاقة تلقائياً عند تجديد اشتراك العضوية.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumCarnet(
    Map<String, dynamic> membershipData,
    String clubName,
  ) {
    return AspectRatio(
      aspectRatio: 0.63, // Standard ID Card Ratio but Vertical
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Abstract Background Patterns
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // SCA Watermark (Centered & Ghosted)
            Center(
              child: Opacity(
                opacity: 0.04,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 380,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.anchor, size: 300, color: Colors.white),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Logo & Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.anchor, color: Colors.white, size: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "هيئة قناة السويس",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Suez Canal Authority",
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Photo Frame
                  Container(
                    width: 120,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/user_placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // User Name
                  Text(
                    membershipData['name'] ?? 'مستخدم',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Membership Type Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      membershipData['membership_type'] ?? "---",
                      style: GoogleFonts.cairo(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // const Spacer()
                  const SizedBox(height: 20),

                  // Membership Details Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              "رقم العضوية",
                              membershipData['membership_id'] ?? "---",
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white12,
                            ),
                            _buildStatItem(
                              "الوظيفة",
                              membershipData['job'] ?? "---",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Digital Signature / QR Area
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DynamicQrWidget(
                      memberId: membershipData['membership_id'] ?? "---",
                      size: 80,
                      onlyQr: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 10),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

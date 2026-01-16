import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:sca_members_clubs/core/services/session_manager.dart';
import 'package:get_it/get_it.dart';

class SecurityDrawer extends StatelessWidget {
  const SecurityDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          _buildSecurityHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [_buildSecurityMenuSection(context)],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildSecurityHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003A8F), Color(0xFF001F4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.security_rounded,
                    color: Color(0xFF003A8F),
                    size: 32,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "مسؤول الأمن",
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
          ),
          Text(
            "منظومة الأمن",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "أمن النادي",
              style: GoogleFonts.cairo(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildDrawerItem(Icons.qr_code_scanner, "ماسح الأكواد", () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/security_scanner');
        }),
        _buildDrawerItem(Icons.list_alt, "التحقق من الدعوات", () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/security_invitations');
        }),
        _buildDrawerItem(Icons.emergency, "بلاغات الطوارئ", () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/security_emergencies');
        }),
        _buildDrawerItem(Icons.history, "سجل الدخول", () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/security_logs');
        }),
        const Divider(height: 24),
        _buildDrawerItem(Icons.logout, "تسجيل الخروج", () async {
          Navigator.pop(context);
          final sessionManager = GetIt.instance<SessionManager>();
          await sessionManager.clearUserSession();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: GoogleFonts.cairo(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      onTap: onTap,
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "نسخة 1.0.0",
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

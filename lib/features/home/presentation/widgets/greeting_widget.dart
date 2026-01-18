import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GreetingWidget extends StatelessWidget {
  final String userName;

  const GreetingWidget({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;

    if (hour >= 5 && hour < 12) {
      greeting = "صباح الخير";
      icon = Icons.wb_sunny_rounded;
    } else if (hour >= 12 && hour < 17) {
      greeting = "مساء الخير";
      icon = Icons.wb_cloudy_rounded;
    } else {
      greeting = "مساء الخير";
      icon = Icons.nightlight_round;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Column(
        children: [
          SizedBox(height: kToolbarHeight + 10.h), // Ensure spacing after app bar
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$greeting،",
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        height: 2.0,
                      ),
                    ),
                    Text(
                      userName,
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd MMM', 'ar').format(DateTime.now()),
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE', 'ar').format(DateTime.now()),
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

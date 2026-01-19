import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromoBanner extends StatefulWidget {
  final List<Map<String, dynamic>> promos;
  const PromoBanner({super.key, required this.promos});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      // Guard against widget being disposed or inactive
      if (!mounted) return;

      if (_currentPage < widget.promos.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (mounted && _pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 140.h, // Adjusted for responsiveness
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.promos.length,
            itemBuilder: (context, index) {
              final promo = widget.promos[index];
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/article_detail',
                    arguments: promo,
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    color: Color(int.parse(promo['color']!.toString())),
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                          int.parse(promo['color']!.toString()),
                        ).withOpacity(0.3),
                        blurRadius: 12.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned(
                        right: -30.w,
                        bottom: -30.h,
                        child: Icon(
                          Icons.local_offer,
                          size: 150.sp,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                "إعلان مميز",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              promo['title']!,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              promo['subtitle']!,
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.promos.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _currentPage == index ? 24.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

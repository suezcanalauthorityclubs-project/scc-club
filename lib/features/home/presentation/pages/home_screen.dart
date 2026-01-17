import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/promo_banner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'package:sca_members_clubs/core/di/injection_container.dart';
import '../widgets/greeting_widget.dart';
import 'package:sca_members_clubs/core/services/session_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clubName =
        ModalRoute.of(context)?.settings.arguments as String? ??
        "النادى العام هيئة قناة السويس";

    return BlocProvider(
      create: (context) => sl<HomeCubit>()..loadHomeData(),
      child: HomeView(clubName: clubName),
    );
  }
}

class HomeView extends StatefulWidget {
  final String clubName;
  const HomeView({super.key, required this.clubName});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<String?> _membershipNameFuture;

  @override
  void initState() {
    super.initState();
    _membershipNameFuture = _getMembershipName();
  }

  Future<String?> _getMembershipName() async {
    final sessionManager = GetIt.instance<SessionManager>();
    final membershipId = sessionManager.getSavedMembershipId();

    if (membershipId == null) return null;

    try {
      // Try document ID first
      var membershipDoc = await FirebaseFirestore.instance
          .collection('main_membership')
          .doc(membershipId)
          .get();

      // Fallback to field query if document doesn't exist
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
        final name = membershipDoc.data()?['name'];
        return name?.toString();
      }
    } catch (e) {
      print('Error fetching membership name: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: true,
          appBar: HomeAppBar(
            clubName: widget.clubName,
            onMapTap: () => _showMapSimulation(context, widget.clubName),
            onNotificationsTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          drawer: const AppDrawer(),
          body: RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().loadHomeData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: kToolbarHeight + 20.h),

                  // Dynamic Greeting
                  FutureBuilder<String?>(
                    future: _membershipNameFuture,
                    // initialData: GetIt.instance<SessionManager>().getSavedUsername() ?? "عضو الهيئة",
                    builder: (context, snapshot) {
                      final userName = snapshot.data ?? "";
                      return GreetingWidget(userName: userName);
                    },
                  ),

                  if (state is HomeLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SizedBox(
                        height: 160.h,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (state is HomeLoaded)
                    Column(children: [PromoBanner(promos: state.promos)])
                  else
                    const SizedBox.shrink(),

                  SizedBox(height: 32.h),

                  // Quick Actions Section
                  _buildSectionHeader("الخدمات السريعة"),
                  SizedBox(height: 16.h),

                  // Grid
                  Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 3;
                          if (constraints.maxWidth > 900) {
                            crossAxisCount = 5;
                          } else if (constraints.maxWidth > 600) {
                            crossAxisCount = 4;
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16.w,
                                  mainAxisSpacing: 16.h,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              final services = [
                                _ServiceData(
                                  Icons.badge_rounded,
                                  "كارنيه العضوية",
                                  AppColors.primary,
                                  () {
                                    Navigator.pushNamed(
                                      context,
                                      '/membership_card',
                                      arguments: widget.clubName,
                                    );
                                  },
                                ),
                                _ServiceData(
                                  Icons.mail_outline_rounded,
                                  "دعوات الزوار",
                                  const Color(0xFF0EA5E9),
                                  () {
                                    Navigator.pushNamed(
                                      context,
                                      '/invitations',
                                    );
                                  },
                                ),
                                _ServiceData(
                                  Icons.calendar_today_rounded,
                                  "حجز خدمات",
                                  const Color(0xFF8B5CF6),
                                  () {
                                    Navigator.pushNamed(context, '/booking');
                                  },
                                ),
                              ];
                              final s = services[index];
                              return _buildActionCard(
                                icon: s.icon,
                                label: s.label,
                                color: s.color,
                                onTap: s.onTap,
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent News Section
                  if (state is HomeLoaded && state.news.isNotEmpty) ...[
                    _buildSectionHeader(
                      "أحدث الأخبار",
                      onSeeAllTap: () {
                        Navigator.pushNamed(context, '/news');
                      },
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 340.h,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.news.length,
                        itemBuilder: (context, index) {
                          final newsItem = state.news[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/article_detail',
                                arguments: newsItem,
                              );
                            },
                            child: Container(
                              width: 280.w,
                              margin: EdgeInsets.only(left: 16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24.r),
                                    ),
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          newsItem.image,
                                          height: 150.h,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, progress) {
                                                if (progress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  height: 150.h,
                                                  color: Colors.grey[50],
                                                  child: Center(
                                                    child: SizedBox(
                                                      width: 24.w,
                                                      height: 24.w,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  height: 150.h,
                                                  width: double.infinity,
                                                  color: Colors.grey[100],
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .image_not_supported_outlined,
                                                        color: Colors.grey[300],
                                                        size: 40.sp,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        "الصورة غير متاحة",
                                                        style:
                                                            GoogleFonts.cairo(
                                                              fontSize: 10.sp,
                                                              color: Colors
                                                                  .grey[400],
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                        ),
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              newsItem.date,
                                              style: GoogleFonts.cairo(
                                                fontSize: 10.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          newsItem.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            height: 1.2,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          newsItem.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.sp,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            Text(
                                              "اقرأ المزيد",
                                              style: GoogleFonts.cairo(
                                                fontSize: 12.sp,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 10,
                                              color: AppColors.primary,
                                            ),
                                          ],
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
                  ],

                  // Recent News Section
                  SizedBox(height: 120.h),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/emergency');
            },
            backgroundColor: Colors.red[600],
            elevation: 8,
            icon: const Icon(
              Icons.emergency_share_rounded,
              color: Colors.white,
            ),
            label: Text(
              "طوارئ",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAllTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          if (onSeeAllTap != null)
            TextButton(
              onPressed: onSeeAllTap,
              child: Text(
                "عرض المزيد",
                style: GoogleFonts.cairo(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(icon, color: color, size: 26.sp),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  fontSize: 11.sp,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapSimulation(BuildContext context, String clubName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "جاري فتح موقع ($clubName) على خرائط جوجل...",
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _ServiceData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _ServiceData(this.icon, this.label, this.color, this.onTap);
}

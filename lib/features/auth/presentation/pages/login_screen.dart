import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:sca_members_clubs/core/widgets/custom_text_field.dart';
import 'package:sca_members_clubs/core/widgets/primary_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sca_members_clubs/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sca_members_clubs/features/auth/presentation/cubit/auth_state.dart';
import 'package:sca_members_clubs/core/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _usernameController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate based on user role
          if (state.user.role.toLowerCase() == 'security') {
            Navigator.pushReplacementNamed(context, '/security_dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.cairo()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Top Decoration
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 300.h,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32.r),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Icon(
                          Icons.anchor,
                          size: 200.sp,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.0.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 450.w),
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(32.0.w),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Logo
                                Center(
                                  child: Container(
                                    width: 80.w,
                                    height: 80.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.background,
                                        width: 4.w,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 40.w,
                                      height: 40.w,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Title
                                Text(
                                  "تسجيل الدخول",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "مرحباً بك في تطبيق النادي العام لهيئة قناة السويس",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Fields
                                CustomTextField(
                                  label: "اسم المستخدم",
                                  hint: "أدخل اسم المستخدم",
                                  controller: _usernameController,
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى إدخال البيانات المطلوبة';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                CustomTextField(
                                  label: "كلمة المرور",
                                  hint: "********",
                                  controller: _passwordController,
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !_isPasswordVisible,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى إدخال كلمة المرور';
                                    }
                                    return null;
                                  },
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),

                                SizedBox(height: 24.h),

                                state is AuthLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : PrimaryButton(
                                        text: "دخول",
                                        onPressed: () =>
                                            _onLoginPressed(context),
                                      ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.support,
                                    );
                                  },
                                  child: Text(
                                    "تواصل معنا",
                                    style: GoogleFonts.cairo(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/auth/presentation/pages/name_capture_page.dart';
import 'package:kajani/features/auth/presentation/pages/signup_page.dart';
import 'package:kajani/features/auth/presentation/state/auth_state.dart';
import 'package:kajani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authViewModelProvider.notifier).signInWithGoogle();
  }

  void _navigateToSignup() {
    AppRoutes.push(context, const SignupPage());
  }

  // ─── Reusable input decoration ─────────────────────────────────
  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: context.textSecondary, fontSize: 13),
      hintStyle: TextStyle(color: context.textTertiary),
      filled: true,
      fillColor: context.inputFillColor,
      prefixIcon: Icon(icon, color: context.textSecondary, size: 20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        final isOnboarded = ref.read(userSessionServiceProvider).isOnboarded();
        if(!isOnboarded){
          AppRoutes.pushReplacement(context, const NameCapturePage());
        }else{
          AppRoutes.pushReplacement(context, const BottomScreenLayout());
        }
        
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(authViewModelProvider.notifier).resetError();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // ─── Logo Text ──────────────────────────────
                  const Text(
                    "KaJani",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── Title ──────────────────────────────────
                  Text(
                    "Welcome back",
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ─── Subtitle ────────────────────────────────
                  Text(
                    "Enter your credentials to access your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Email Label ────────────────────────
                        Text(
                          "Email Address",
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ─── Email Field ────────────────────────
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: context.textSecondary),
                          decoration: _inputDecoration(
                            label: '',
                            hint: 'name@example.com',
                            icon: Iconsax.sms,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // ─── Password Label + Forgot ─────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Password",
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: forgot password
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Forgot password?",
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ─── Password Field ─────────────────────
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: context.textSecondary),
                          decoration: _inputDecoration(
                            label: '',
                            hint: '••••••••',
                            icon: Iconsax.lock,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Iconsax.eye_copy
                                    : Iconsax.eye_slash,
                                color: context.textSecondary,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // ─── Login Button ───────────────────────
                        SizedBox(
                          height: 55,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authState.status == AuthStatus.loading
                                ? null
                                : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: authState.status == AuthStatus.loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Iconsax.arrow_right,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ─── Divider ────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: context.textSecondary),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: context.textSecondary),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ─── Google Button ──────────────────────
                        SizedBox(
                          height: 55,
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: authState.status == AuthStatus.loading
                                ? null
                                : _handleGoogleSignIn,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: context.isDarkMode
                                  ? AppColors.darkSurface
                                  : Colors.white,
                              side: BorderSide(
                                color: context.isDarkMode
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google_logo.png',
                                  height: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ─── Signup Link ────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToSignup,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Create an account',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

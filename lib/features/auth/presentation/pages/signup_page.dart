import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/auth/presentation/state/auth_state.dart';
import 'package:kajani/features/auth/presentation/view_model/auth_view_model.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim().isEmpty
                ? null
                : _phoneNumberController.text.trim(),
          );
    }
  }

  // ─── Reusable input decoration ──────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: const Color(0xff1A1A2E),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
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

  // ─── Field label ────────────────────────────────────────────────
  Widget _fieldLabel(String label, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isOptional) ...[
            const SizedBox(width: 6),
            Text(
              "(optional)",
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(
          context,
          'Account created successfully! Please log in.',
        );
        AppRoutes.pop(context);
      } else if (next.status == AuthStatus.error &&
          next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(authViewModelProvider.notifier).resetError();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xff0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ─── Back Button ────────────────────────────────
                IconButton(
                  onPressed: () => AppRoutes.pop(context),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Title ──────────────────────────────────────
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Join Kajani and start exploring",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── First + Last Name ───────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("First Name"),
                                TextFormField(
                                  controller: _firstNameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration(
                                    hint: 'John',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("Last Name"),
                                TextFormField(
                                  controller: _lastNameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration(
                                    hint: 'Doe',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ─── Email ───────────────────────────────
                      _fieldLabel("Email Address"),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: 'name@example.com',
                          icon: Icons.email_outlined,
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

                      // ─── Username ────────────────────────────
                      _fieldLabel("Username"),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: '@username',
                          icon: Icons.alternate_email,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ─── Phone Number ────────────────────────
                      _fieldLabel("Phone Number", isOptional: true),
                      TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: '+977 98XXXXXXXX',
                          icon: Icons.phone_outlined,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─── Password ────────────────────────────
                      _fieldLabel("Password"),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ─── Confirm Password ────────────────────
                      _fieldLabel("Confirm Password"),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // ─── Create Account Button ───────────────
                      SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.status == AuthStatus.loading
                              ? null
                              : _handleSignup,
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
                                      'Create Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ─── Login Link ──────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => AppRoutes.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
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
    );
  }
}
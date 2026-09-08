import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/auth/presentation/state/auth_state.dart';
import 'package:kajani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout.dart';

class NameCapturePage extends ConsumerStatefulWidget {
  const NameCapturePage({super.key});

  @override
  ConsumerState<NameCapturePage> createState() => _NameCapturePageState();
}

class _NameCapturePageState extends ConsumerState<NameCapturePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      final fullName = _nameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      await ref.read(authViewModelProvider.notifier).completeProfile(
            firstName: firstName,
            lastName: lastName,
            username: _usernameController.text.trim(),
          );
    }
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.textTertiary),
      filled: true,
      fillColor: context.inputFillColor,
      prefixIcon: Icon(icon, color: context.textSecondary, size: 20),
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
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: context.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        AppRoutes.pushReplacement(context, const BottomScreenLayout());
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ─── Step indicator ─────────────────────────────
                Text(
                  "Step 2 of 2",
                  style: TextStyle(color: context.textTertiary, fontSize: 12),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    minHeight: 4,
                    backgroundColor: context.borderColor,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  "Tell us your name",
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "This helps others recognize you in Kajani",
                  style: TextStyle(color: context.textSecondary, fontSize: 13),
                ),

                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Name"),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: context.textSecondary),
                        decoration: _inputDecoration(
                          hint: 'Sagar Lama',
                          icon: Icons.person_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _fieldLabel("Username"),
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(color: context.textSecondary),
                        decoration: _inputDecoration(
                          hint: 'sagarlama',
                          icon: Icons.alternate_email,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.trim().length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.status == AuthStatus.loading
                              ? null
                              : _handleContinue,
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
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
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
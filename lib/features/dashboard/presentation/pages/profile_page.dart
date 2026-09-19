import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/auth/presentation/pages/login_page.dart';
import 'package:kajani/features/auth/presentation/state/auth_state.dart';
import 'package:kajani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kajani/features/dashboard/presentation/pages/about_kajani_page.dart';
import 'package:kajani/features/dashboard/presentation/pages/account_setting_page.dart';
import 'package:kajani/features/dashboard/presentation/pages/edit_profile_page.dart';
import 'package:kajani/features/dashboard/presentation/pages/help_support_page.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';
import 'package:kajani/features/dashboard/presentation/widgets/plans_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(planViewModelProvider.notifier).getJoinedPlans();
      ref.read(planViewModelProvider.notifier).getSavedPlans();
    });
  }

  Future<void> _sendFeedback() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'kajaniapp@gmail.com', // feedback email
      query: 'subject=${Uri.encodeComponent('KaJani Feedback')}'
          '&body=${Uri.encodeComponent('Hi KaJani team,\n\n')}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) SnackbarUtils.showError(context, 'No email app found');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log out', style: TextStyle(color: context.textPrimary)),
        content: Text(
          'Are you sure you want to end your session?',
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authViewModelProvider.notifier).logout();
              if (mounted) {
                AppRoutes.pushAndRemoveUntil(context, const LoginPage());
              }
            },
            child: const Text('Log out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planViewModelProvider);
    final userSession = ref.read(userSessionServiceProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        AppRoutes.pushAndRemoveUntil(context, const LoginPage());
      }
    });

    final firstName = userSession.getUserFirstName() ?? '';
    final lastName = userSession.getUserLastName() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final username = userSession.getUsername();
    final email = userSession.getUserEmail() ?? '';
    final profilePicture = userSession.getUserProfilePicture();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ─── Back button ─────────────────────────────
              IconButton(
                onPressed: () => AppRoutes.pop(context),
                padding: EdgeInsets.zero,
                icon: Icon(Iconsax.arrow_left_2, color: context.textPrimary, size: 22),
              ),

              const SizedBox(height: 8),

              // ─── Avatar + name ───────────────────────────
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: context.primary,
                      backgroundImage: profilePicture != null
                          ? NetworkImage(
                              profilePicture.startsWith('http')
                                  ? profilePicture
                                  : '${ApiEndpoints.baseUrlOnly}$profilePicture',
                            )
                          : null,
                      child: profilePicture == null
                          ? Text(
                              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      fullName.isNotEmpty ? fullName : 'User',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (username != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@$username',
                        style: TextStyle(color: context.textSecondary, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(color: context.textTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Stats ───────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  children: [
                    _statItem('Joined', planState.joinedPlans.length, onTap: () {
                      showPlansBottomSheet(
                        context,
                        title: 'Joined Events',
                        plans: planState.joinedPlans,
                        emptyImagePath: 'assets/images/teamwork.png',
                        emptyTitle: 'No joined events',
                        emptyMessage: 'Events you join will show up here.',
                      );
                    }),
                    _statDivider(),
                    _statItem('Saved', planState.savedPlans.length, onTap: () {
                      showPlansBottomSheet(
                        context,
                        title: 'Saved Events',
                        plans: planState.savedPlans,
                        emptyImagePath: 'assets/images/calander.png',
                        emptyTitle: 'No saved events',
                        emptyMessage: 'Tap the heart on any event to save it.',
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Settings cards ──────────────────────────
              _profileCard(
                icon: Iconsax.edit,
                title: 'Edit Profile',
                subtitle: 'Change your username and photo',
                onTap: () => AppRoutes.push(context, const EditProfilePage()),
              ),
              const SizedBox(height: 10),
              _profileCard(
                icon: Iconsax.setting_2,
                title: 'Account Settings',
                subtitle: 'Manage your account',
                onTap: () => AppRoutes.push(context, const AccountSettingsPage()),
              ),
              const SizedBox(height: 10),
              _profileCard(
                icon: Iconsax.message_question,
                title: 'Help & Support',
                subtitle: 'FAQs and how things work',
                onTap: () => AppRoutes.push(context, const HelpSupportPage()),
              ),
              const SizedBox(height: 10),
              _profileCard(
                icon: Iconsax.messages_1,
                title: 'Send Feedback',
                subtitle: 'Share your thoughts about KaJani',
                onTap: _sendFeedback,
              ),
              const SizedBox(height: 10),
              _profileCard(
                icon: Iconsax.info_circle,
                title: 'About KaJani',
                subtitle: 'App info and version',
                onTap: () => AppRoutes.push(context, const AboutKajaniPage()),
              ),

              const SizedBox(height: 28),

              // ─── Logout ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: Icon(Iconsax.logout, color: context.primary, size: 18),
                  label: Text(
                    'Log out',
                    style: TextStyle(color: context.primary, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.primary),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, int count, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 36, color: context.borderColor);
  }

  Widget _profileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: context.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: context.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, color: context.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }
}
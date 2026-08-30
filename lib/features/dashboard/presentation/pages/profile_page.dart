import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/auth/presentation/pages/login_page.dart';
import 'package:kajani/features/auth/presentation/state/auth_state.dart';
import 'package:kajani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planViewModelProvider.notifier).getMyPlans();
      ref.read(planViewModelProvider.notifier).getJoinedPlans();
      ref.read(planViewModelProvider.notifier).getSavedPlans();
    });
  }

  // ─── Permission Handler ───────────────────────────────────────────
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Permission Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Please enable access in settings to update your profile photo.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: Text('Settings', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ─── Pick from Camera ─────────────────────────────────────────────
  Future<void> _pickFromCamera() async {
    if (await _requestPermission(Permission.camera)) {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        await ref
            .read(authViewModelProvider.notifier)
            .uploadPhoto(File(photo.path));
      }
    }
  }

  // ─── Pick from Gallery ────────────────────────────────────────────
  Future<void> _pickFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      await ref
          .read(authViewModelProvider.notifier)
          .uploadPhoto(File(image.path));
    }
  }

  // ─── Bottom Sheet Picker ──────────────────────────────────────────
  void _pickProfilePhoto() {
    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
              title: const Text(
                'Take a Photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: Colors.white),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to end your session?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authViewModelProvider.notifier).logout();
              if (mounted) {
                AppRoutes.pushAndRemoveUntil(context, const LoginPage());
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final userSession = ref.read(userSessionServiceProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.loaded && next.uploadedPhotoUrl != null) {
        SnackbarUtils.showSuccess(context, 'Profile photo updated!');
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(authViewModelProvider.notifier).resetError();
      }
    });

    final firstName = userSession.getUserFirstName() ?? '';
    final lastName = userSession.getUserLastName() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final email = userSession.getUserEmail() ?? '';
    final profilePicture =
        authState.uploadedPhotoUrl ?? userSession.getUserProfilePicture();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ─── Back Button ────────────────────────────────────
              IconButton(
                onPressed: () => AppRoutes.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const SizedBox(height: 8),

              // ─── Avatar ──────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xffA8E6F5),
                      backgroundImage: profilePicture != null
                          ? NetworkImage(
                              profilePicture.startsWith('http')
                                  ? profilePicture
                                  : '${ApiEndpoints.baseUrlOnly}$profilePicture',
                            )
                          : null,
                      child: profilePicture == null
                          ? Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfilePhoto, // 👈 changed
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: authState.status == AuthStatus.loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Name + Email ────────────────────────────────────
              Center(
                child: Text(
                  fullName.isNotEmpty ? fullName : 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ─── Stats Row ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xff1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _statItem('Created', planState.myPlans.length),
                    _statDivider(),
                    _statItem('Joined', planState.joinedPlans.length),
                    _statDivider(),
                    _statItem('Saved', planState.savedPlans.length),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Joined Activities ────────────────────────────────
              _profileCard(
                icon: Icons.event_available_outlined,
                iconBgColor: AppColors.primary.withOpacity(0.15),
                iconColor: AppColors.primary,
                title: 'Joined Activities',
                subtitle: planState.joinedPlans.isEmpty
                    ? 'No activities joined yet'
                    : '${planState.joinedPlans.length} activities you\'re part of',
                onTap: () {
                  // AppRoutes.push(context, const JoinedActivitiesPage());
                },
              ),

              const SizedBox(height: 12),

              // ─── Account Settings ────────────────────────────────
              _profileCard(
                icon: Icons.settings_outlined,
                iconBgColor: Colors.grey.withOpacity(0.15),
                iconColor: Colors.grey,
                title: 'Account Settings',
                subtitle: 'Privacy, notifications, and security',
                onTap: () {
                  // TODO: build settings page
                },
              ),

              const SizedBox(height: 12),

              // ─── Help & Support ──────────────────────────────────
              _profileCard(
                icon: Icons.help_outline,
                iconBgColor: Colors.orange.withOpacity(0.15),
                iconColor: Colors.orange,
                title: 'Help & Support',
                subtitle: 'FAQs, contact us, report an issue',
                onTap: () {
                  // TODO: build help page
                },
              ),

              const SizedBox(height: 32),

              // ─── Logout Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  label: const Text(
                    'Log out',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

  // ─── Stat Item ────────────────────────────────────────────────────
  Widget _statItem(String label, int count) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.1),
    );
  }

  // ─── Profile Card ─────────────────────────────────────────────────
  Widget _profileCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff1A1A2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kajani/app/routes/app_routes.dart';

import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/auth/presentation/state/auth_state.dart';
import 'package:kajani/features/auth/presentation/view_model/auth_view_model.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _pickedPhoto; // locally selected, not yet uploaded

  @override
  void initState() {
    super.initState();
    // pre-fill with current username
    _usernameController.text =
        ref.read(userSessionServiceProvider).getUsername() ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // ─── Permission + picker (moved from profile page) ──────────────
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
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Permission Required', style: TextStyle(color: context.textPrimary)),
        content: Text(
          'Please enable access in settings to change your photo.',
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: Text('Settings', style: TextStyle(color: context.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    if (await _requestPermission(Permission.camera)) {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) setState(() => _pickedPhoto = File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) setState(() => _pickedPhoto = File(image.path));
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Iconsax.camera, color: context.textPrimary),
              title: Text('Take a Photo', style: TextStyle(color: context.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Iconsax.gallery, color: context.textPrimary),
              title: Text('Choose from Gallery', style: TextStyle(color: context.textPrimary)),
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUsername =
        ref.read(userSessionServiceProvider).getUsername() ?? '';
    final newUsername = _usernameController.text.trim();

    // Only send username if it actually changed
    final usernameChanged = newUsername != currentUsername;

    // Nothing to update?
    if (!usernameChanged && _pickedPhoto == null) {
      SnackbarUtils.showInfo(context, 'No changes to save');
      return;
    }

    await ref.read(authViewModelProvider.notifier).updateProfile(
          username: usernameChanged ? newUsername : null,
          photo: _pickedPhoto,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final currentPhoto = userSession.getUserProfilePicture();

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.profileUpdated) {
        SnackbarUtils.showSuccess(context, 'Profile updated');
        AppRoutes.pop(context);
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(authViewModelProvider.notifier).resetError();
      }
    });

    final firstName = userSession.getUserFirstName() ?? '';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: context.textPrimary),
          onPressed: () => AppRoutes.pop(context),
        ),
        title: Text('Edit Profile', style: TextStyle(color: context.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ─── Avatar with edit ─────────────────────────
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: context.primary,
                        backgroundImage: _pickedPhoto != null
                            ? FileImage(_pickedPhoto!)          // 👈 show newly picked photo
                            : (currentPhoto != null
                                ? NetworkImage(
                                    currentPhoto.startsWith('http')
                                        ? currentPhoto
                                        : '${ApiEndpoints.baseUrlOnly}$currentPhoto',
                                  ) as ImageProvider
                                : null),
                        child: (_pickedPhoto == null && currentPhoto == null)
                            ? Text(
                                firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
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
                          onTap: _showPhotoOptions,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.backgroundColor, width: 2),
                            ),
                            child: const Icon(Iconsax.edit_2, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ─── Username field ───────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Username',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: context.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'username',
                    hintStyle: TextStyle(color: context.textTertiary),
                    filled: true,
                    fillColor: context.inputFillColor,
                    prefixIcon: Icon(Iconsax.user, color: context.textSecondary, size: 20),
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
                      borderSide: BorderSide(color: context.primary, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username cannot be empty';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ─── Save button ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        authState.status == AuthStatus.loading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
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
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
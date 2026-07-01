import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kajani/core/api/api_client.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/dashboard/presentation/state/plan_state.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';

class CreatePlanPage extends ConsumerStatefulWidget {
  final PlanEntity? existingPlan;
  const CreatePlanPage({super.key, this.existingPlan});

  @override
  ConsumerState<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends ConsumerState<CreatePlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMembersController = TextEditingController();
  File? _coverImage;
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedCategory = 'social';
  String _selectedDate = '';
  String _selectedTime = '';
  String _selectedEndTime = '';
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();

    if (widget.existingPlan != null) {
      final plan = widget.existingPlan!;
      _titleController.text = plan.title;
      _descriptionController.text = plan.description;
      _locationController.text = plan.location;
      _maxMembersController.text = plan.maxMembers?.toString() ?? '';
      _selectedCategory = plan.category;
      _selectedDate = plan.date;
      _selectedTime = plan.time;
      _selectedEndTime = plan.endTime ?? '';
      _isPublic = plan.isPublic;
    }
  }

  final List<Map<String, String>> _categories = [
    {'value': 'social', 'label': 'Social'},
    {'value': 'outdoor', 'label': 'Outdoor'},
    {'value': 'sports', 'label': 'Sports'},
    {'value': 'food', 'label': 'Food'},
    {'value': 'educational', 'label': 'Educational'},
    {'value': 'creative', 'label': 'Creative'},
    {'value': 'travel', 'label': 'Travel'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _maxMembersController.dispose();
    super.dispose();
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
        backgroundColor: const Color(0xff1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Permission Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Please enable access in settings to add a cover photo.',
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
        setState(() => _coverImage = File(photo.path));
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
      setState(() => _coverImage = File(image.path));
    }
  }

  // ─── Bottom Sheet Picker ──────────────────────────────────────────
  void _pickCoverImage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1A1A2E),
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

  // ─── Date Picker ──────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: Color(0xff1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  // ─── Time Picker ──────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: Color(0xff1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: Color(0xff1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  // ─── Create Plan ──────────────────────────────────────────────────
  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate.isEmpty) {
      SnackbarUtils.showError(context, 'Please select a date');
      return;
    }
    if (_selectedTime.isEmpty) {
      SnackbarUtils.showError(context, 'Please select a time');
      return;
    }
    if (_selectedEndTime.isEmpty) {
      SnackbarUtils.showError(context, 'Please select an end time');
      return;
    }

    String? coverImageUrl;

    // 1. Upload image first if selected
    if (_coverImage != null) {
      try {
        final fileName = _coverImage!.path.split('/').last;
        final formData = FormData.fromMap({
          'coverImage': await MultipartFile.fromFile(
            _coverImage!.path,
            filename: fileName,
          ),
        });
        // upload directly via api client
        final uploadResponse = await ref
            .read(apiClientProvider)
            .uploadFile(ApiEndpoints.uploadPlanCover, formData: formData);

        if (uploadResponse.data['success'] == true) {
          coverImageUrl = uploadResponse.data['data']['coverImage'] as String;
        }
      } catch (e) {
        // if upload fails, create plan without image
        print('Image upload failed: $e');
      }
    }
    final isEditMode = widget.existingPlan != null;

    if (isEditMode) {
      final updateData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'date': _selectedDate,
        'time': _selectedTime,
        'endTime':_selectedEndTime,
        'isPublic': _isPublic,
        if (_maxMembersController.text.isNotEmpty)
          'maxMembers': int.tryParse(_maxMembersController.text),
        if (coverImageUrl != null)
          'coverImage': coverImageUrl, // only if changed
      };
      await ref
          .read(planViewModelProvider.notifier)
          .updatePlan(widget.existingPlan!.planId!, updateData);
    } else {
      // 2. Create plan with image URL
      await ref
          .read(planViewModelProvider.notifier)
          .createPlan(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            location: _locationController.text.trim(),
            date: _selectedDate,
            time: _selectedTime,
            endTime: _selectedEndTime,
            isPublic: _isPublic,
            maxMembers: _maxMembersController.text.isEmpty
                ? null
                : int.tryParse(_maxMembersController.text),
            coverImage: coverImageUrl,
          );
    }
  }

  // ─── Input decoration ─────────────────────────────────────────────
  InputDecoration _inputDecoration({required String hint, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: const Color(0xff1A1A2E),
      prefixIcon: prefixIcon,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planViewModelProvider);

    ref.listen<PlanState>(planViewModelProvider, (previous, next) {
      if (next.status == PlanStatus.created ||
          next.status == PlanStatus.updated) {
        SnackbarUtils.showSuccess(
          context,
          widget.existingPlan != null
              ? 'Activity updated successfully!'
              : 'Activity created successfully!',
        );
        AppRoutes.pop(context);
      } else if (next.status == PlanStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(planViewModelProvider.notifier).resetError();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ─── Header ─────────────────────────────────────────
              Row(
                children: [
                  IconButton(
                    onPressed: () => AppRoutes.pop(context),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Text(
                    'KaJani',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Title ──────────────────────────────────────────
              const Text(
                'Create New Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Share your plan and discover who's ready to join the journey.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              // ─── Cover Photo ─────────────────────────────────────
              GestureDetector(
                onTap: _pickCoverImage, // 👈 shows bottom sheet
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xff1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    image: _coverImage != null
                        ? DecorationImage(
                            image: FileImage(_coverImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _coverImage != null
                      // ─── Image selected — show edit overlay ──────────────
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        )
                      // ─── No image — show upload placeholder ──────────────
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Add Cover Photo',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to choose from gallery or camera',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Title Field ───────────────────────────────
                    _fieldLabel('Title'),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        hint: 'e.g., Sunday Morning Coffee Run',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.length < 5) {
                          return 'Title must be at least 5 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ─── Category + Time Row ───────────────────────
                    Row(
                      children: [
                        // Category dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Category'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xff1A1A2E),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    dropdownColor: const Color(0xff1A1A2E),
                                    style: const TextStyle(color: Colors.white),
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    items: _categories.map((cat) {
                                      return DropdownMenuItem<String>(
                                        value: cat['value'],
                                        child: Text(cat['label']!),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(
                                        () => _selectedCategory = value!,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Time picker
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Time'),
                              GestureDetector(
                                onTap: _pickTime,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff1A1A2E),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime.isEmpty
                                            ? '--:--'
                                            : _selectedTime,
                                        style: TextStyle(
                                          color: _selectedTime.isEmpty
                                              ? Colors.white.withOpacity(0.3)
                                              : Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('End Time'),
                        GestureDetector(
                          onTap: _pickEndTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff1A1A2E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedEndTime.isEmpty
                                      ? '--:--'
                                      : _selectedEndTime,
                                  style: TextStyle(
                                    color: _selectedEndTime.isEmpty
                                        ? Colors.white.withOpacity(0.3)
                                        : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ─── Date Picker ───────────────────────────────
                    _fieldLabel('Date'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff1A1A2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white.withOpacity(0.5),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDate.isEmpty
                                  ? 'Select a date'
                                  : _selectedDate,
                              style: TextStyle(
                                color: _selectedDate.isEmpty
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Location Field ────────────────────────────
                    _fieldLabel('Location'),
                    TextFormField(
                      controller: _locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        hint: 'Search for a place...',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ─── Description Field ─────────────────────────
                    _fieldLabel('Description'),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      decoration: _inputDecoration(
                        hint:
                            "What's the vibe? Let people know what to expect...",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 20) {
                          return 'Description must be at least 20 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ─── Max Members (optional) ────────────────────
                    _fieldLabel('Max Members', isOptional: true),
                    TextFormField(
                      controller: _maxMembersController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        hint: 'e.g., 20',
                        prefixIcon: Icon(
                          Icons.people_outline,
                          color: Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Public / Private Toggle ───────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.public,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Public Activity',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Anyone can discover and join',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isPublic,
                            onChanged: (value) =>
                                setState(() => _isPublic = value),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ─── Create Button ─────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: planState.status == PlanStatus.loading
                            ? null
                            : _handleCreate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: planState.status == PlanStatus.loading
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
                                    'Create Activity',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('🚀', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Field Label ──────────────────────────────────────────────────
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
              '(optional)',
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
}

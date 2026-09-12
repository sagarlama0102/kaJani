import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kajani/core/widgets/skeleton_box.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/create_plan_page.dart';
import 'package:kajani/features/dashboard/presentation/state/plan_state.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';

class PlanDetailPage extends ConsumerStatefulWidget {
  final String planId;
  const PlanDetailPage({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planViewModelProvider.notifier).getPlanById(widget.planId);
    });
  }

  String _formatDate(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date; // fallback, never crash
    return DateFormat('EEE, d MMM yyyy').format(parsed);
  }

  // ─── Format "14:30" → "2:30 PM" (local Nepal time as stored) ────
  String _formatTime(String time) {
    final parsed = DateTime.tryParse('2000-01-01T$time');
    if (parsed == null) return time;
    return DateFormat('h:mm a').format(parsed);
  }

  Future<void> _openInMaps(String location) async {
    final query = Uri.encodeComponent(location);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) SnackbarUtils.showError(context, 'Could not open Maps');
    }
  }

  Future<void> _addToCalendar(PlanEntity plan) async {
    final start = DateTime.tryParse('${plan.date}T${plan.time}');
    if (start == null) {
      SnackbarUtils.showError(context, 'Could not read the event date');
      return;
    }
    DateTime end;
    if (plan.endDate != null && plan.endTime != null) {
      end =
          DateTime.tryParse('${plan.endDate}T${plan.endTime}') ??
          start.add(const Duration(hours: 2));
    } else {
      end = start.add(const Duration(hours: 2));
    }
    String fmt(DateTime d) =>
        '${d.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.').first}Z';

    final uri = Uri.parse(
      'https://calendar.google.com/calendar/render'
      '?action=TEMPLATE'
      '&text=${Uri.encodeComponent(plan.title)}'
      '&dates=${fmt(start)}/${fmt(end)}'
      '&details=${Uri.encodeComponent(plan.description)}'
      '&location=${Uri.encodeComponent(plan.location)}',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) SnackbarUtils.showError(context, 'Could not open calendar');
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Plan',
          style: TextStyle(color: context.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this plan? This cannot be undone.',
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(planViewModelProvider.notifier).deletePlan(widget.planId);
    }
  }

  Future<void> _handleJoin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Join this plan?',
          style: TextStyle(color: context.textPrimary),
        ),
        content: Text(
          "You'll be added to this activity and can chat with other members.",
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(planViewModelProvider.notifier).joinPlan(widget.planId);
    }
  }

  Future<void> _handleLeave() async {
    await ref.read(planViewModelProvider.notifier).leavePlan(widget.planId);
  }

  Future<void> _handleSave() async {
    final currentUserId = ref.read(userSessionServiceProvider).getUserId();
    await ref
        .read(planViewModelProvider.notifier)
        .toggleSavePlan(widget.planId, currentUserId: currentUserId);
    final isSaved = ref.read(planViewModelProvider).isSaved;
    if (isSaved == true) {
      SnackbarUtils.showSuccess(context, 'Plan saved!');
    } else if (isSaved == false) {
      SnackbarUtils.showSuccess(context, 'Plan removed from saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planViewModelProvider);
    final currentUserId = ref.read(userSessionServiceProvider).getUserId();

    ref.listen<PlanState>(planViewModelProvider, (previous, next) {
      if (next.status == PlanStatus.deleted) {
        SnackbarUtils.showSuccess(context, 'Plan deleted successfully');
        AppRoutes.pop(context);
      } else if (next.status == PlanStatus.joined) {
        SnackbarUtils.showSuccess(context, 'You joined the plan!');
      } else if (next.status == PlanStatus.left) {
        SnackbarUtils.showSuccess(context, 'You left the plan');
      } else if (next.status == PlanStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(planViewModelProvider.notifier).resetError();
      }
    });

    final plan = planState.selectedPlan;

    if (planState.status == PlanStatus.loading || plan == null) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        body: _buildDetailSkeleton(),
      );
    }
    final isCreator = plan.creatorId == currentUserId;
    final isMember = plan.members?.contains(currentUserId) ?? false;
    final isSaved = plan.savedBy?.contains(currentUserId) ?? false;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Cover Image + top buttons ──────────────
                  Stack(
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        color: context.surfaceColor,
                        child: plan.coverImage != null
                            ? Image.network(
                                '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Iconsax.image,
                                  color: context.primary,
                                  size: 50,
                                ),
                              )
                            : Icon(
                                Iconsax.image,
                                color: context.primary,
                                size: 50,
                              ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _circleIconButton(
                                icon: Iconsax.arrow_left_2,
                                onTap: () => AppRoutes.pop(context),
                              ),
                              _circleIconButton(
                                icon: isSaved
                                    ? Iconsax.heart_add
                                    : Iconsax.heart,
                                iconColor: isSaved
                                    ? AppColors.error
                                    : Colors.white,
                                onTap: _handleSave,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            plan.category.toUpperCase(),
                            style: TextStyle(
                              color: context.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Title
                        Text(
                          plan.title,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Date & Time card ─────────────────
                        _infoCard(
                          icon: Iconsax.calendar_1,
                          title: _formatDate(plan.date),
                          subtitle:
                              '${_formatTime(plan.time)}'
                              '${plan.endTime != null ? ' - ${_formatTime(plan.endTime!)}' : ''}',
                          trailing: Iconsax.calendar_add,
                          onTrailingTap: () => _addToCalendar(plan),
                        ),
                        const SizedBox(height: 12),

                        // ─── Location card (tappable → Maps) ──
                        GestureDetector(
                          onTap: () => _openInMaps(plan.location),
                          child: _infoCard(
                            icon: Iconsax.location,
                            title: plan.location,
                            subtitle: 'Tap to open in Maps',
                            trailing: Iconsax.map,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildAttendeeStack(plan),
                       

                        const SizedBox(height: 24),
                        Divider(color: context.borderColor),
                        const SizedBox(height: 24),

                        // ─── Description ──────────────────────
                        Text(
                          'About this activity',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plan.description,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Bottom action bar ──────────────────────────────
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                border: Border(top: BorderSide(color: context.borderColor)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [                 
                  if (isCreator)
                    _buildCreatorActions(context, plan)
                  else
                    _buildJoinerActions(plan, isMember),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Attendee stack ─────────────────────────────────────────────
  Widget _buildAttendeeStack(PlanEntity plan) {
    final members = plan.memberDetails ?? [];
    final displayCount = members.length > 4 ? 4 : members.length;
    final total = plan.members?.length ?? members.length;

    return Row(
      children: [
        if (displayCount > 0)
          SizedBox(
            width: 32.0 + (displayCount - 1) * 20,
            
            height: 32,
            child: Stack(
              children: List.generate(displayCount, (index) {
                final member = members[index];
                return Positioned(
                  left: index * 18.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.backgroundColor,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: context.primary,
                      backgroundImage: member.profilePicture != null
                          ? NetworkImage(
                              member.profilePicture!.startsWith('http')
                                  ? member.profilePicture!
                                  : '${ApiEndpoints.baseUrlOnly}${member.profilePicture}',
                            )
                          : null,
                      child: member.profilePicture == null
                          ? Text(
                              member.firstName.isNotEmpty
                                  ? member.firstName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),
        if (displayCount > 0) const SizedBox(width: 12),
        Text(
          plan.maxMembers != null
              ? '$total / ${plan.maxMembers} going'
              : '$total going',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─── Reusable widgets ───────────────────────────────────────────
  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    String? subtitle,
    IconData? trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            child: Icon(icon, color: context.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: context.textTertiary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Icon(trailing, color: context.textPrimary, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _outlinedButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: context.primary, size: 18),
        label: Text(
          label,
          style: TextStyle(color: context.primary, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorActions(BuildContext context, PlanEntity plan) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await AppRoutes.push(context, CreatePlanPage(existingPlan: plan));
              ref
                  .read(planViewModelProvider.notifier)
                  .getPlanById(widget.planId);
            },
            icon: Icon(Iconsax.edit, color: context.primary, size: 18),
            label: Text(
              'Edit',
              style: TextStyle(
                color: context.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleDelete(context),
            icon: const Icon(Iconsax.trash, color: Colors.white, size: 18),
            label: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinerActions(PlanEntity plan, bool isMember) {
    final isFull =
        plan.maxMembers != null &&
        (plan.members?.length ?? 0) >= plan.maxMembers!;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isMember ? _handleLeave : (isFull ? null : _handleJoin),
        style: ElevatedButton.styleFrom(
          backgroundColor: isMember ? context.surfaceColor : context.primary,
          disabledBackgroundColor: context.surfaceColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isMember
                ? BorderSide(color: AppColors.error)
                : BorderSide.none,
          ),
        ),
        child: Text(
          isMember ? 'Leave Event' : (isFull ? 'Event Full' : 'Attend Event'),
          style: TextStyle(
            color: isMember
                ? AppColors.error
                : (isFull ? context.textTertiary : Colors.white),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ─── Skeleton for the detail page while the plan loads ──────────
Widget _buildDetailSkeleton() {
  return SkeletonShimmer(
    child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image block
          const SkeletonBox(height: 300, radius: 0),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Category badge
                SkeletonBox(width: 80, height: 24, radius: 20),
                SizedBox(height: 14),
                // Title (two lines)
                SkeletonBox(height: 22, radius: 6),
                SizedBox(height: 8),
                SkeletonBox(width: 200, height: 22, radius: 6),
                SizedBox(height: 20),
                // Date card
                SkeletonBox(height: 64, radius: 14),
                SizedBox(height: 12),
                // Location card
                SkeletonBox(height: 64, radius: 14),
                SizedBox(height: 20),
                // Attendee row
                SkeletonBox(width: 160, height: 32, radius: 16),
                SizedBox(height: 24),
                // Description heading
                SkeletonBox(width: 140, height: 16, radius: 4),
                SizedBox(height: 12),
                // Description lines
                SkeletonBox(height: 12, radius: 4),
                SizedBox(height: 8),
                SkeletonBox(height: 12, radius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: 220, height: 12, radius: 4),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

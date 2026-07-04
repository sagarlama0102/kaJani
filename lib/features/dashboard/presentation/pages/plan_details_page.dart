import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/plan_chat_screen.dart';
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

  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Plan', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this plan? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
        backgroundColor: const Color(0xff1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Join this plan?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You\'ll be added to this activity and can chat with other members once chat is available.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
    await ref
        .read(planViewModelProvider.notifier)
        .toggleSavePlan(widget.planId);
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
      return const Scaffold(
        backgroundColor: Color(0xff0F0F0F),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final isCreator = plan.creatorId == currentUserId;
    final isMember = plan.members?.contains(currentUserId) ?? false;

    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      body: Column(
        children: [
          // ─── Scrollable Content ─────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Cover Image with back/save icons ───────────
                  Stack(
                    children: [
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff1A1A2E),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          image: plan.coverImage != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: plan.coverImage == null
                            ? const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppColors.primary,
                                  size: 50,
                                ),
                              )
                            : null,
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
                                icon: Icons.arrow_back_ios_new,
                                onTap: () => AppRoutes.pop(context),
                              ),
                              _circleIconButton(
                                icon:
                                    plan.savedBy?.contains(currentUserId) ??
                                        false
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                                onTap: _handleSave,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ─── Content ──────────────────────────────────
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
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            plan.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Title
                        Text(
                          plan.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ─── Date Card ──────────────────────────
                        _infoCard(
                          icon: Icons.calendar_today_outlined,
                          title: plan.date,
                          subtitle: plan.time,
                          trailingIcon: Icons.edit_calendar_outlined,
                        ),

                        const SizedBox(height: 12),

                        // ─── Location Card ─────────────────────
                        _infoCard(
                          icon: Icons.location_on_outlined,
                          title: plan.location,
                          subtitle: null,
                          trailingIcon: Icons.map_outlined,
                        ),

                        const SizedBox(height: 12),

                        // ─── Members Card ───────────────────────
                        _infoCard(
                          icon: Icons.people_outline,
                          title: plan.maxMembers != null
                              ? '${plan.members?.length ?? 0} / ${plan.maxMembers} members'
                              : '${plan.members?.length ?? 0} members joined',
                          subtitle: null,
                          trailingIcon: Icons.arrow_forward_ios,
                        ),

                        if (isCreator &&
                            plan.memberDetails != null &&
                            plan.memberDetails!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Members',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...plan.memberDetails!.map(
                            (member) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primary,
                                    backgroundImage:
                                        member.profilePicture != null
                                        ? NetworkImage(
                                            member.profilePicture!.startsWith(
                                                  'http',
                                                )
                                                ? member.profilePicture!
                                                : '${ApiEndpoints.baseUrlOnly}${member.profilePicture}',
                                          )
                                        : null,
                                    child: member.profilePicture == null
                                        ? Text(
                                            member.firstName.isNotEmpty
                                                ? member.firstName[0]
                                                      .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${member.firstName} ${member.lastName}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (member.id == plan.creatorId)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Creator',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        Divider(color: Colors.white.withOpacity(0.08)),

                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'About this activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plan.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
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

          // ─── Bottom Fixed Action Bar ────────────────────────────
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: const Color(0xff0F0F0F),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Group Chat Button ──────────────────────────────
                  if (isCreator || isMember) ...[
                    GestureDetector(
                      onTap: () {
                        AppRoutes.push(
                          context,
                          PlanChatScreen(
                            planId: widget.planId,
                            planTitle: plan.title,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xff1A1A2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Group Chat',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ─── Creator Actions ────────────────────────────────
                  if (isCreator)
                    Row(
                      children: [
                        // Edit Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await AppRoutes.push(
                                context,
                                CreatePlanPage(existingPlan: plan),
                              );
                              ref
                                  .read(planViewModelProvider.notifier)
                                  .getPlanById(widget.planId);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xff1A1A2E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Delete Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleDelete(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  // ─── Joiner Actions ─────────────────────────────────
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

  // ─── Creator Actions (Edit / Delete icons) ───────────────────────
  Widget _buildCreatorActions(BuildContext context, PlanEntity plan) {
    return Row(
      children: [
        // Edit icon button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await AppRoutes.push(context, CreatePlanPage(existingPlan: plan));
              ref
                  .read(planViewModelProvider.notifier)
                  .getPlanById(widget.planId);
            },
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 18,
            ),
            label: const Text(
              'Edit',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Delete icon button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleDelete(context),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 18,
            ),
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

    return GestureDetector(
      onTap: isMember ? _handleLeave : (isFull ? null : _handleJoin),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isMember
              ? AppColors.error.withOpacity(0.1)
              : isFull
              ? Colors.grey.withOpacity(0.1)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMember
                ? AppColors.error.withOpacity(0.4)
                : isFull
                ? Colors.grey.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMember
                  ? Icons.exit_to_app_rounded
                  : isFull
                  ? Icons.block_rounded
                  : Icons.check_circle_outline_rounded,
              color: isMember
                  ? AppColors.error
                  : isFull
                  ? Colors.grey
                  : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isMember
                  ? 'Leave Plan'
                  : isFull
                  ? 'Plan is Full'
                  : 'Join Plan',
              style: TextStyle(
                color: isMember
                    ? AppColors.error
                    : isFull
                    ? Colors.grey
                    : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper Widgets ───────────────────────────────────────────────
  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    String? subtitle,
    IconData? trailingIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xff1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: Colors.white.withOpacity(0.3), size: 18),
        ],
      ),
    );
  }
}

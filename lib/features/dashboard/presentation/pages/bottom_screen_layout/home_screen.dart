import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/core/widgets/empty_state.dart';
import 'package:kajani/core/widgets/error_state.dart';
import 'package:kajani/core/widgets/skeleton_box.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/create_plan_page.dart';
import 'package:kajani/features/dashboard/presentation/pages/plan_details_page.dart';
import 'package:kajani/features/dashboard/presentation/pages/profile_page.dart';
import 'package:kajani/features/dashboard/presentation/state/plan_state.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';
import 'package:kajani/core/api/api_endpoints.dart';

import 'package:kajani/features/dashboard/presentation/widgets/plan_list_card.dart';
import 'package:kajani/features/dashboard/presentation/widgets/plans_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(planViewModelProvider.notifier).getJoinedPlans();
      ref.read(planViewModelProvider.notifier).getAllPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planViewModelProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final firstName = userSession.getUserFirstName() ?? 'User';
    final username = userSession.getUsername();

    final allJoined = planState.joinedPlans;
    final upcomingJoined =
        allJoined
            .where((p) => p.status != 'completed' && p.status != 'cancelled')
            .toList()
          ..sort(
            (a, b) => '${a.date} ${a.time}'.compareTo('${b.date} ${b.time}'),
          );
    final activeEvents =
        planState.plans
            .where((p) => p.status == 'upcoming' || p.status == 'ongoing')
            .toList()
          ..sort(
            (a, b) => '${a.date} ${a.time}'.compareTo('${b.date} ${b.time}'),
          );

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.wait([
              ref.read(planViewModelProvider.notifier).getJoinedPlans(),
              ref.read(planViewModelProvider.notifier).getAllPlans(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(firstName, username),
                const SizedBox(height: 28),
                if (planState.status == PlanStatus.error)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ErrorStateView(
                      message:
                          planState.errorMessage ??
                          'Could not load events. Check your connection and try again',
                      onRetry: () => ref
                          .read(planViewModelProvider.notifier)
                          .getJoinedPlans(),
                    ),
                  )
                else ...[
                  _buildSectionHeader(
                    'Your Groups',
                    allJoined.length,
                    onSeeAll: () => showPlansBottomSheet(
                      context,
                      title: 'Your Groups',
                      plans: allJoined,
                      emptyImagePath: 'assets/images/teamwork.png',
                      emptyTitle: 'No groups yet',
                      emptyMessage: 'Join an event to connect with people',
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (planState.status == PlanStatus.loading ||
                      planState.status == PlanStatus.initial)
                    _buildGroupsSkeleton()
                  else if (allJoined.isEmpty)
                    const SizedBox(
                      width: double.infinity,
                      child: EmptyState(
                        imagePath: 'assets/images/teamwork.png',
                        title: "No groups yet",
                        message: "Join an event to connect with people",
                      ),
                    )
                  else
                    _buildGroupsGrid(allJoined),
                  if (userSession.isAdmin()) ...[
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () =>
                          AppRoutes.push(context, const CreatePlanPage()),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 18,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.primary,
                              context.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: context.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Iconsax.add,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create an Event',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Add a new activity for people to join',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Iconsax.arrow_right_3,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    'Events',
                    activeEvents.length,
                    onSeeAll: () => showPlansBottomSheet(
                      context,
                      title: 'Active Events',
                      plans: upcomingJoined,
                      emptyImagePath: 'assets/images/calander.png',
                      emptyTitle: 'Noting coming up',
                      emptyMessage:
                          'Events you can join will show up here so you never miss out',
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (planState.status == PlanStatus.loading ||
                      planState.status == PlanStatus.initial)
                    _buildUpcomingSkeleton() //  new branch — this section had no loading state before
                  else if (activeEvents.isEmpty)
                    const EmptyState(
                      imagePath: 'assets/images/calander.png',
                      title: "Nothing coming up",
                      message:
                          "Events you can join will show up here so you never miss out",
                    )
                  else
                    ...activeEvents
                        .take(3)
                        .map((plan) => PlanListCard(plan: plan)),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String firstName, String? username) {
    final userSession = ref.read(userSessionServiceProvider);
    final profilePicture = userSession.getUserProfilePicture();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username != null
                  ? "Hi, $username"
                  : "Hi there", // username, not firstName
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Good to see you again!',
                style: TextStyle(color: context.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => AppRoutes.push(context, const ProfilePage()),
          child: CircleAvatar(
            radius: 20,
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
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    int count, {
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: TextStyle(
                color: context.textTertiary,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text(
                'See all',
                style: TextStyle(
                  color: context.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.chevron_right, color: context.primary, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupsGrid(List<PlanEntity> plans) {
    final displayPlans = plans.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemCount: displayPlans.length,
      itemBuilder: (context, index) => _buildGroupCard(displayPlans[index]),
    );
  }

  Widget _buildGroupCard(PlanEntity plan) {
    return GestureDetector(
      onTap: () =>
          AppRoutes.push(context, PlanDetailPage(planId: plan.planId!)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),

        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.expand(
                  child: plan.coverImage != null
                      ? Image.network(
                        plan.coverImage!.startsWith('http')
                        ? plan.coverImage!
                          : '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbFill(),
                        )
                      : _thumbFill(),
                ),
              ),
            ),

            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Text(
                plan.title,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbFill() {
    return Container(
      color: context.primary.withOpacity(0.12),
      child: Icon(Icons.image_outlined, color: context.primary, size: 24),
    );
  }

  // ─── Skeleton: Your Groups grid ─────────────────────────────────
  Widget _buildGroupsSkeleton() {
    return SkeletonShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.1, // must match _buildGroupsGrid exactly
        ),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              const Expanded(child: SkeletonBox(radius: 12)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(height: 10, radius: 4),
                    SizedBox(height: 6),
                    SkeletonBox(width: 50, height: 10, radius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Skeleton: Upcoming Groups list ─────────────────────────────
  Widget _buildUpcomingSkeleton() {
    return SkeletonShimmer(
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 64, height: 64, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(height: 12, radius: 4),
                      SizedBox(height: 8),
                      SkeletonBox(width: 120, height: 10, radius: 4),
                      SizedBox(height: 6),
                      SkeletonBox(width: 90, height: 10, radius: 4),
                      SizedBox(height: 10),
                      SkeletonBox(width: 70, height: 10, radius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SkeletonBox(width: 48, height: 44, radius: 10),
              ],
            ),
          );
        }),
      ),
    );
  }
}

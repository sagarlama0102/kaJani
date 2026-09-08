import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/core/widgets/empty_state.dart';
import 'package:kajani/core/widgets/skeleton_box.dart';
import 'package:kajani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/plan_details_page.dart';
import 'package:kajani/features/dashboard/presentation/pages/profile_page.dart';
import 'package:kajani/features/dashboard/presentation/state/plan_state.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:intl/intl.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planViewModelProvider.notifier).getJoinedPlans();
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

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(firstName, username),
              const SizedBox(height: 28),
              _buildSectionHeader(
                'Your Groups',
                allJoined.length,
                onSeeAll: () => showPlansBottomSheet(context, title: 'Your Groups', plans: allJoined, emptyImagePath: 'assets/images/teamwork.png', emptyTitle: 'No groups yet', emptyMessage: 'Join an event to connect with people'),
              ),
              const SizedBox(height: 14),
              if (planState.status == PlanStatus.loading ||
                  planState.status == PlanStatus.initial)
                _buildGroupsSkeleton()
              else if (allJoined.isEmpty)
                const EmptyState(imagePath: 'assets/images/teamwork.png', title: "No groups yet", message: "Join an event to connect with people")
              else
                _buildGroupsGrid(allJoined),
              const SizedBox(height: 28),
              _buildSectionHeader(
                'Upcoming Groups',
                upcomingJoined.length,
                onSeeAll: () => showPlansBottomSheet(context, title: 'Upcoming Groups', plans: upcomingJoined, emptyImagePath: 'assets/images/calander.png', emptyTitle: 'Noting coming up', emptyMessage: 'Events you can join will show up here so you never miss out')
              ),
              const SizedBox(height: 14),
              if (planState.status == PlanStatus.loading ||
                  planState.status == PlanStatus.initial)
                _buildUpcomingSkeleton() //  new branch — this section had no loading state before
              else if (upcomingJoined.isEmpty)
                const EmptyState(imagePath: 'assets/images/calander.png', title: "Nothing coming up", message: "Events you can join will show up here so you never miss out")
              else
                ...upcomingJoined.take(3).map((plan) => PlanListCard(plan: plan)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String firstName, String? username) {
    final authState = ref.watch(authViewModelProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final profilePicture =
        authState.uploadedPhotoUrl ?? userSession.getUserProfilePicture();

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
                    style: const TextStyle(
                      color: Colors.white,
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
                          '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
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
          childAspectRatio: 2.1, // 👈 must match _buildGroupsGrid exactly
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/create_plan_page.dart';
import 'package:kajani/features/dashboard/presentation/pages/plan_details_page.dart';
import 'package:kajani/features/dashboard/presentation/pages/profile_page.dart';
import 'package:kajani/features/dashboard/presentation/state/plan_state.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';

import 'package:kajani/core/api/api_endpoints.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Your groups', 'Going', 'Saved', 'Past'];

  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planViewModelProvider.notifier).getMyPlans();
      ref.read(planViewModelProvider.notifier).getJoinedPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planViewModelProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final firstName = userSession.getUserFirstName() ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ─── Header ─────────────────────────────────────────
              _buildHeader(firstName),

              const SizedBox(height: 24),

              // ─── Your Groups Section ─────────────────────────────
              _buildYourGroupsSection(planState),

              const SizedBox(height: 16),

              // ─── Start a New Group Button ────────────────────────
              _buildStartGroupButton(),

              const SizedBox(height: 28),

              // ─── Events Section ──────────────────────────────────
              _buildEventsSection(planState),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────
  Widget _buildHeader(String firstName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'KaJani',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ─── Avatar ──────────────────────────────────────────────
        GestureDetector(
          onTap: () {
            AppRoutes.push(context, const ProfilePage());
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Text(
              firstName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Your Groups Section ──────────────────────────────────────────
  Widget _buildYourGroupsSection(PlanState planState) {
    final myPlans = planState.myPlans;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + count
        Row(
          children: [
            const Text(
              'Your groups',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${myPlans.length}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (planState.status == PlanStatus.loading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else if (myPlans.isEmpty)
          _buildEmptyGroups()
        else
          _buildGroupsGrid(myPlans),
      ],
    );
  }

  // ─── Groups Grid (2x2) ────────────────────────────────────────────
  Widget _buildGroupsGrid(List<PlanEntity> plans) {
    final displayPlans = plans.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: displayPlans.length,
      itemBuilder: (context, index) {
        return _buildGroupCard(displayPlans[index]);
      },
    );
  }

  // ─── Group Card ───────────────────────────────────────────────────
  Widget _buildGroupCard(PlanEntity plan) {
    return GestureDetector(
      onTap: () {
        AppRoutes.push(context, PlanDetailPage(planId: plan.planId!));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff1A1A2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: plan.coverImage != null
                  ? Image.network(
                      '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
                      width: 56,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 8),
            // Title
            Expanded(
              child: Text(
                plan.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Placeholder Image ────────────────────────────────────────────
  Widget _buildPlaceholderImage() {
    return Container(
      width: 56,
      height: double.infinity,
      color: AppColors.primary.withOpacity(0.3),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }

  // ─── Empty Groups ─────────────────────────────────────────────────
  Widget _buildEmptyGroups() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "You haven't created any groups yet",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
      ),
    );
  }

  // ─── Start a New Group Button ─────────────────────────────────────
  Widget _buildStartGroupButton() {
    return GestureDetector(
      onTap: () {
        AppRoutes.push(context, const CreatePlanPage());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xff1A1A2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start a new group',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Organize your own events',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Events Section ───────────────────────────────────────────────
  Widget _buildEventsSection(PlanState planState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Events',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // ─── Tabs ──────────────────────────────────────────────────
        _buildTabs(),

        const SizedBox(height: 16),

        // ─── Today Label ───────────────────────────────────────────
        Text(
          'TODAY',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 12),

        // ─── Events List ───────────────────────────────────────────
        _buildEventsList(planState),
      ],
    );
  }

  // ─── Tabs ─────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedTab = index);
              // load data based on tab
              if (index == 0) {
                ref.read(planViewModelProvider.notifier).getMyPlans();
              } else if (index == 1) {
                ref.read(planViewModelProvider.notifier).getJoinedPlans();
              } else if (index == 2) {
                ref.read(planViewModelProvider.notifier).getSavedPlans();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xff1A1A2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Events List ──────────────────────────────────────────────────
  Widget _buildEventsList(PlanState planState) {
    List<PlanEntity> events = [];

    if (_selectedTab == 0)
      events = planState.myPlans;
    else if (_selectedTab == 1)
      events = planState.joinedPlans;
    else if (_selectedTab == 2)
      events = planState.savedPlans;

    if (planState.status == PlanStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No events found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _buildEventCard(events[index]);
      },
    );
  }

  // ─── Event Card ───────────────────────────────────────────────────
  Widget _buildEventCard(PlanEntity plan) {
    return GestureDetector(
      onTap: () {
        AppRoutes.push(context, PlanDetailPage(planId: plan.planId!));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Event Info ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${plan.date} • ${plan.time}',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.location,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Members count
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: Colors.white.withOpacity(0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plan.members?.length ?? 0} going',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ─── Cover Image ────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: plan.coverImage != null
                  ? Image.network(
                      '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildEventPlaceholder(),
                    )
                  : _buildEventPlaceholder(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Event Placeholder ────────────────────────────────────────────
  Widget _buildEventPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/core/widgets/skeleton_box.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/plan_details_page.dart';
import 'package:kajani/features/dashboard/presentation/state/plan_state.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'upcoming';
  String? _selectedCategory;

  final List<Map<String, String>> _statusFilters = [
    {'value': 'upcoming', 'label': 'Upcoming'},
    {'value': 'ongoing', 'label': 'Ongoing'},
    {'value': 'completed', 'label': 'Completed'},
  ];

  final List<Map<String, dynamic>> _categoryFilters = [
    {'value': null, 'label': 'All Events', 'icon': Iconsax.star_1},
    {'value': 'social', 'label': 'Social', 'icon': Iconsax.people_copy},
    {'value': 'outdoor', 'label': 'Outdoor', 'icon': Iconsax.tree_copy},
    {'value': 'sports', 'label': 'Sports', 'icon': Iconsax.game_copy},
    {'value': 'food', 'label': 'Food', 'icon': Iconsax.coffee_copy},
    {
      'value': 'educational',
      'label': 'Educational',
      'icon': Iconsax.teacher_copy,
    },
    {'value': 'creative', 'label': 'Creative', 'icon': Iconsax.brush_1},
    {'value': 'travel', 'label': 'Travel', 'icon': Iconsax.airplane_copy},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPlans());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchPlans() {
    ref
        .read(planViewModelProvider.notifier)
        .getAllPlans(
          status: _selectedStatus,
          category: _selectedCategory,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planViewModelProvider);
    final currentUserId = ref.read(userSessionServiceProvider).getUserId();
    final plans = planState.plans;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Search Bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: context.textPrimary),
                  onSubmitted: (_) => _fetchPlans(),
                  decoration: InputDecoration(
                    hintText: 'Search events or groups...',
                    hintStyle: TextStyle(color: context.textTertiary),
                    prefixIcon: Icon(
                      Iconsax.search_normal_copy,
                      color: context.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Status Filter Tabs ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_statusFilters.length, (index) {
                  final filter = _statusFilters[index];
                  final isSelected = _selectedStatus == filter['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedStatus = filter['value']!);
                        _fetchPlans();
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < _statusFilters.length - 1 ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.primary
                              : context.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? context.primary
                                : context.borderColor,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          filter['label']!,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : context.textSecondary, // 👈 fixed
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Category Icon Row ───────────────────────────────────
            SizedBox(
              height: 76,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categoryFilters.length,
                itemBuilder: (context, index) {
                  final cat = _categoryFilters[index];
                  final isSelected = _selectedCategory == cat['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat['value']);
                      _fetchPlans();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 64,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.primary
                                  : context.surfaceColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? context.primary
                                    : context.borderColor,
                              ),
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : context.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat['label'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ─── Plan Cards List ──────────────────────────────────────
            Expanded(
              child:
                  (planState.status == PlanStatus.loading ||
                      planState.status == PlanStatus.initial)
                  ? _buildPlansSkeleton()
                  : plans.isEmpty
                  ? Center(
                      child: Text(
                        'No events found',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: context.primary,
                      onRefresh: () async => _fetchPlans(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: plans.length,
                        itemBuilder: (context, index) =>
                            _buildPlanCard(plans[index], currentUserId),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(PlanEntity plan, String? currentUserId) {
    final isSaved = plan.savedBy?.contains(currentUserId) ?? false;

    return GestureDetector(
      onTap: () =>
          AppRoutes.push(context, PlanDetailPage(planId: plan.planId!)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
        ),
        clipBehavior: Clip.antiAlias, // 👈 so image corners match card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                plan.coverImage != null
                    ? Image.network(
                        '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
                        width: double.infinity,
                        height: 190,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(planViewModelProvider.notifier)
                          .toggleSavePlan(
                            plan.planId!,
                            currentUserId: currentUserId,
                          );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: 0.4,
                        ), // 👈 fixed contrast
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? AppColors.error : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 14,
                        color: context.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${plan.date} • ${plan.time}',
                        style: TextStyle(
                          color: context.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 14,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          plan.location,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Divider(color: context.borderColor, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (plan.memberDetails != null &&
                          plan.memberDetails!.isNotEmpty) ...[
                        SizedBox(
                          width: plan.memberDetails!.length == 1 ? 22 : 38,
                          height: 24,
                          child: Stack(
                            children: List.generate(
                              plan.memberDetails!.length > 2
                                  ? 2
                                  : plan.memberDetails!.length,
                              (index) {
                                final member = plan.memberDetails![index];
                                return Positioned(
                                  left: index * 12.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: context.surfaceColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: context.primary,
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
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${plan.members?.length ?? 0} going',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Skeleton: plan cards list ──────────────────────────────────
  Widget _buildPlansSkeleton() {
    return SkeletonShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(height: 190, radius: 0), // cover image block
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(height: 16, radius: 4), // title line
                    SizedBox(height: 10),
                    SkeletonBox(width: 140, height: 12, radius: 4), // date
                    SizedBox(height: 8),
                    SkeletonBox(width: 100, height: 12, radius: 4), // location
                    SizedBox(height: 12),
                    SkeletonBox(
                      width: 70,
                      height: 12,
                      radius: 4,
                    ), // going count
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 190,
      color: context.primary.withValues(alpha: 0.12),
      child: Icon(Iconsax.image, color: context.primary, size: 40),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
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
    {'value': null, 'label': 'All Events', 'icon': Icons.auto_awesome_outlined},
    {'value': 'social', 'label': 'Social', 'icon': Icons.groups_outlined},
    {'value': 'outdoor', 'label': 'Outdoor', 'icon': Icons.terrain_outlined},
    {
      'value': 'sports',
      'label': 'Sports',
      'icon': Icons.sports_basketball_outlined,
    },
    {'value': 'food', 'label': 'Food', 'icon': Icons.restaurant_outlined},
    {
      'value': 'educational',
      'label': 'Educational',
      'icon': Icons.school_outlined,
    },
    {'value': 'creative', 'label': 'Creative', 'icon': Icons.palette_outlined},
    {
      'value': 'travel',
      'label': 'Travel',
      'icon': Icons.flight_takeoff_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPlans();
    });
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
      
      body: SafeArea(
        child: Column(
          children: [
            // ─── Search Bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _fetchPlans(),
                  decoration: InputDecoration(
                    hintText: 'Search events or groups...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    suffixIcon: Icon(
                      Icons.mic_none_outlined,
                      color: Colors.white.withOpacity(0.4),
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
                              ? AppColors.primary
                              : const Color(0xff1A1A2E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          filter['label']!,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
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
                                  ? AppColors.primary
                                  : const Color(0xff1A1A2E),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
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
                              color: Colors.white.withOpacity(0.6),
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
              child: planState.status == PlanStatus.loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : plans.isEmpty
                  ? Center(
                      child: Text(
                        'No events found',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => _fetchPlans(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          return _buildPlanCard(plans[index], currentUserId);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(PlanEntity plan, String? currentUserId) {
    final currentUserId = ref.read(userSessionServiceProvider).getUserId();
    final isSaved = plan.savedBy?.contains(currentUserId) ?? false;

    return GestureDetector(
      onTap: () {
        AppRoutes.push(context, PlanDetailPage(planId: plan.planId!));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: const Color(0xff0F0F0F), // Dark mode matching screen capture
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Cover Image with overlay icons ───────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Matches image roundings completely
                  child: plan.coverImage != null
                      ? Image.network(
                          '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
                          width: double.infinity,
                          height: 190,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
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
                        color: const Color.fromARGB(
                          255,
                          69,
                          69,
                          69,
                        ).withOpacity(0.4),
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

            // ─── Content ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Title
                  Text(
                    plan.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 2. Date & Time (Orange/Amber accent styling)
                  Text(
                    '${plan.date} • ${plan.time}',
                    style: const TextStyle(
                      color: Colors
                          .orangeAccent, // Matches the screenshot text color
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 4. Rating Row
                  const SizedBox(height: 10),

                  // 5. Overlapping Going/Members Stack Section
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
                                        color: Colors.black,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 9,
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
                      ],
                      Text(
                        '${plan.members?.length ?? 0} going',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${plan.members?.length ?? 53} going',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
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

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      color: AppColors.primary.withOpacity(0.2),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }
}

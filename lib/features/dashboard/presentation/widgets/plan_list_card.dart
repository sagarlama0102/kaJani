import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/plan_details_page.dart';

class PlanListCard extends StatelessWidget {
  final PlanEntity plan;

  const PlanListCard({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRoutes.push(
        context,
        PlanDetailPage(planId: plan.planId!),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ─────────────────────────────────────────────
            // Cover image
            // ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: plan.coverImage != null
                  ? Image.network(
                      '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _thumbPlaceholder(context),
                    )
                  : _thumbPlaceholder(context),
            ),

            const SizedBox(width: 12),

            // ─────────────────────────────────────────────
            // Event details
            // ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    plan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Date + Time
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 13,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${plan.date} • ${plan.time}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 13,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          plan.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  // Members
                  Row(
                    children: [
                      if (plan.memberDetails != null &&
                          plan.memberDetails!.isNotEmpty)
                        SizedBox(
                          width: plan.memberDetails!.length == 1 ? 20 : 34,
                          height: 20,
                          child: Stack(
                            children: List.generate(
                              plan.memberDetails!.length > 2
                                  ? 2
                                  : plan.memberDetails!.length,
                              (index) {
                                final member =
                                    plan.memberDetails![index];

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
                                      radius: 8.5,
                                      backgroundColor: context.primary,
                                      backgroundImage:
                                          member.profilePicture != null
                                              ? NetworkImage(
                                                  member.profilePicture!
                                                          .startsWith('http')
                                                      ? member.profilePicture!
                                                      : '${ApiEndpoints.baseUrlOnly}${member.profilePicture}',
                                                )
                                              : null,
                                      child:
                                          member.profilePicture == null
                                              ? Text(
                                                  member.firstName.isNotEmpty
                                                      ? member.firstName[0]
                                                          .toUpperCase()
                                                      : '?',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 7,
                                                    fontWeight:
                                                        FontWeight.w600,
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

                      if (plan.memberDetails != null &&
                          plan.memberDetails!.isNotEmpty)
                        const SizedBox(width: 6),

                      Text(
                        '${plan.members?.length ?? 0} going',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ─────────────────────────────────────────────
            // Date badge
            // ─────────────────────────────────────────────
            _buildDateBadge(
              context,
              plan.date,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Date Badge
  // ─────────────────────────────────────────────────────
  Widget _buildDateBadge(
    BuildContext context,
    String date,
  ) {
    final parsed = DateTime.tryParse(date);

    if (parsed == null) {
      return const SizedBox(
        width: 48,
      );
    }

    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('MMM')
                .format(parsed)
                .toUpperCase(),
            style: TextStyle(
              color: context.primary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            DateFormat('d').format(parsed),
            style: TextStyle(
              color: context.primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Image Placeholder
  // ─────────────────────────────────────────────────────
  Widget _thumbPlaceholder(
    BuildContext context,
  ) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.10),
      ),
      child: Icon(
        Iconsax.image,
        color: context.primary,
        size: 24,
      ),
    );
  }
}
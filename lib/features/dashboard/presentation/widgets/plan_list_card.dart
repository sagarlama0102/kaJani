import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/plan_details_page.dart';
import 'package:path/path.dart';


class PlanListCard extends StatelessWidget {
  final PlanEntity plan;
  const PlanListCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          AppRoutes.push(context, PlanDetailPage(planId: plan.planId!)),
      child: Container(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: plan.coverImage != null
                  ? Image.network(
                      '${ApiEndpoints.baseUrlOnly}${plan.coverImage}',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _thumbPlaceholder(context, 64),
                    )
                  : _thumbPlaceholder(context, 64),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plan.date} • ${plan.time}',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          plan.location,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (plan.memberDetails != null &&
                          plan.memberDetails!.isNotEmpty)
                        SizedBox(
                          width: plan.memberDetails!.length == 1 ? 18 : 32,
                          height: 18,
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
                                      radius: 8,
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
                                                fontSize: 7,
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
                      const SizedBox(width: 6),
                      Text(
                        '${plan.members?.length ?? 0} going',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildDateBadge(context, plan.date),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBadge(BuildContext context, String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) {
    // Malformed date — render an empty badge rather than crashing
    return const SizedBox(width: 48);
  }

  return Container(
    width: 48,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: context.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text(
          DateFormat('MMM').format(parsed).toUpperCase(), //
          style: TextStyle(color: context.primary, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        Text(
          DateFormat('d').format(parsed), //
          style: TextStyle(color: context.primary, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

  Widget _thumbPlaceholder(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      color: context.primary.withOpacity(0.12),
      child: Icon(Icons.image_outlined, color: context.primary, size: size * 0.4),
    );
  }
}

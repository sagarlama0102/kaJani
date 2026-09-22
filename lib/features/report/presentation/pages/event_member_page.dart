import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_memeber_entity.dart';
import 'package:kajani/features/report/presentation/pages/report_sheet.dart';

class EventMembersPage extends ConsumerWidget {
  final List<PlanMemberEntity> members;
  final String creatorId;

  const EventMembersPage({
    super.key,
    required this.members,
    required this.creatorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.read(userSessionServiceProvider).getUserId();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: context.textPrimary),
          onPressed: () => AppRoutes.pop(context),
        ),
        title: Text('Members', style: TextStyle(color: context.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final isCreator = member.id == creatorId;
            final isMe = member.id == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
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
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${member.firstName} ${member.lastName}'.trim(),
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCreator) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Host',
                                style: TextStyle(color: context.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Report — only for OTHER users (not yourself)
                  if (!isMe)
                    IconButton(
                      icon: Icon(Iconsax.more, color: context.textTertiary, size: 20),
                      onPressed: () => showReportSheet(context, reportedUserId: member.id),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
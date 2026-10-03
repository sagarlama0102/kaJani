import 'package:flutter/material.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/widgets/empty_state.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/widgets/plan_list_card.dart';

/// Shows a draggable bottom sheet listing the given plans.
/// Used by both "See all" links on the home screen.
void showPlansBottomSheet(
  BuildContext context, {
  required String title,
  required List<PlanEntity> plans,
  required String emptyImagePath,
  required String emptyTitle,
  required String emptyMessage,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // lets the sheet grow taller than half-screen
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ─── Drag handle ────────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ─── Header ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: context.textSecondary, size: 22),
                    ),
                  ],
                ),
              ),

              // ─── List ───────────────────────────────────────
              Expanded(
                child: plans.isEmpty
                    ? SingleChildScrollView(
                        controller: scrollController, // keeps drag-to-dismiss working when empty
                        child: EmptyState(
                          imagePath: emptyImagePath,
                          title: emptyTitle,
                          message: emptyMessage,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController, //  required for the sheet's scroll/drag to work
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: plans.length,
                        itemBuilder: (context, index) => PlanListCard(plan: plans[index]),
                      ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
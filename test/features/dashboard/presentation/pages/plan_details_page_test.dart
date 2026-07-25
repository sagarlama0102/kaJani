import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/plan_details_page.dart';
import 'package:kajani/features/dashboard/presentation/state/plan_state.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

class FakePlanViewModel extends PlanViewModel {
  FakePlanViewModel(this._initial);
  final PlanState _initial;

  @override
  PlanState build() => _initial;

  @override
  Future<void> getPlanById(String planId) async {}
}

void main() {
  late MockUserSessionService mockSession;

  Widget makeTestable(PlanState state, String currentUserId) {
    mockSession = MockUserSessionService();
    when(() => mockSession.getUserId()).thenReturn(currentUserId);

    return ProviderScope(
      overrides: [
        planViewModelProvider.overrideWith(() => FakePlanViewModel(state)),
        userSessionServiceProvider.overrideWithValue(mockSession),
      ],
      child: const MaterialApp(
        home: PlanDetailPage(planId: 'plan123'),
      ),
    );
  }

  const tPlan = PlanEntity(
    planId: 'plan123',
    title: 'Trek to Shivapuri',
    description: 'A fun trekking trip for beginners in the hills',
    category: 'outdoor',
    location: 'Shivapuri, Kathmandu',
    date: '2026-07-15',
    time: '06:00',
    status: 'upcoming',
    creatorId: 'creator1',
    members: ['creator1'],
    maxMembers: 10,
  );

  group('PlanDetailPage', () {
    testWidgets('shows Edit and Delete when the current user is the creator',
        (tester) async {
      // arrange — logged in as the creator
      await tester.pumpWidget(
        makeTestable(
          const PlanState(
            status: PlanStatus.loaded,
            selectedPlan: tPlan,
          ),
          'creator1',
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Join Plan'), findsNothing);
    });

    testWidgets('shows Join Plan when the current user is not the creator',
        (tester) async {
      // arrange — logged in as somebody else
      await tester.pumpWidget(
        makeTestable(
          const PlanState(
            status: PlanStatus.loaded,
            selectedPlan: tPlan,
          ),
          'stranger9',
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Join Plan'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('renders the plan title, category and description',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        makeTestable(
          const PlanState(
            status: PlanStatus.loaded,
            selectedPlan: tPlan,
          ),
          'creator1',
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Trek to Shivapuri'), findsOneWidget);
      expect(find.text('OUTDOOR'), findsOneWidget);
      expect(
        find.text('A fun trekking trip for beginners in the hills'),
        findsOneWidget,
      );
    });

    testWidgets('shows a loading spinner while the plan is being fetched',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        makeTestable(const PlanState(status: PlanStatus.loading), 'creator1'),
      );
      await tester.pump();

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Trek to Shivapuri'), findsNothing);
    });
  });
}
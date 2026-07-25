import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/explore_screen.dart';
import 'package:kajani/features/dashboard/presentation/state/plan_state.dart';
import 'package:kajani/features/dashboard/presentation/view_model/plan_view_model.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

class FakePlanViewModel extends PlanViewModel {
  FakePlanViewModel(this._initial);
  final PlanState _initial;

  @override
  PlanState build() => _initial;

  @override
  Future<void> getAllPlans({
    int? page,
    int? size,
    String? search,
    String? category,
    String? status,
  }) async {}
}

void main() {
  late MockUserSessionService mockSession;

  setUp(() {
    mockSession = MockUserSessionService();
    when(() => mockSession.getUserId()).thenReturn('user1');
  });

  Widget makeTestable(PlanState state) {
    return ProviderScope(
      overrides: [
        planViewModelProvider.overrideWith(() => FakePlanViewModel(state)),
        userSessionServiceProvider.overrideWithValue(mockSession), // 👈 the fix
      ],
      child: const MaterialApp(home: ExploreScreen()),
    );
  }

  const tPlan = PlanEntity(
    planId: 'plan123',
    title: 'Trek to Shivapuri',
    description: 'A fun trekking trip for beginners',
    category: 'outdoor',
    location: 'Shivapuri, Kathmandu',
    date: '2026-07-15',
    time: '06:00',
    status: 'upcoming',
    members: ['user1', 'user2'],
  );

  group('ExploreScreen', () {
    testWidgets('shows the empty state when there are no plans',
        (tester) async {
      await tester.pumpWidget(
        makeTestable(const PlanState(status: PlanStatus.loaded, plans: [])),
      );
      await tester.pumpAndSettle();

      expect(find.text('No events found'), findsOneWidget);
    });

    testWidgets('shows a loading spinner while plans are loading',
        (tester) async {
      await tester.pumpWidget(
        makeTestable(const PlanState(status: PlanStatus.loading)),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('No events found'), findsNothing);
    });

    testWidgets('renders the search field and the status filter tabs',
        (tester) async {
      await tester.pumpWidget(
        makeTestable(const PlanState(status: PlanStatus.loaded, plans: [])),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Ongoing'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });


  });
}
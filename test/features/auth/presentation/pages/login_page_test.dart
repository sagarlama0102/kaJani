import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajani/features/auth/presentation/pages/login_page.dart';
import 'package:kajani/features/auth/presentation/state/auth_state.dart';
import 'package:kajani/features/auth/presentation/view_model/auth_view_model.dart';

// ─── Fake view model so no real network/providers are touched ────
class FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState();
}

void main() {
  Widget makeTestable() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage', () {
    testWidgets('renders email and password fields and a sign in button',
        (tester) async {
      // act
      await tester.pumpWidget(makeTestable());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting an empty form',
        (tester) async {
      // arrange
      await tester.pumpWidget(makeTestable());
      await tester.pumpAndSettle();

      // act — tap sign in with both fields empty
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // assert — form validators should have fired
      expect(find.textContaining('email', findRichText: true), findsWidgets);
    });

    testWidgets('accepts typed input into the email field', (tester) async {
      // arrange
      await tester.pumpWidget(makeTestable());
      await tester.pumpAndSettle();

      // act
      await tester.enterText(
        find.byType(TextFormField).first,
        'sagar@gmail.com',
      );
      await tester.pump();

      // assert
      expect(find.text('sagar@gmail.com'), findsOneWidget);
    });
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/services/auth_service.dart';
import 'package:food_finder/presentation/screens/profile/sign_in_sheet.dart';
import 'package:food_finder/presentation/state/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Signed out, and never on the network: the sheet reads auth through the
/// provider, so a fake is the whole injection point.
class _FakeAuth extends AuthService {
  _FakeAuth({this.onSignIn});

  final VoidCallback? onSignIn;

  @override
  Session? get session => null;

  @override
  Stream<AuthState> get changes => const Stream.empty();

  @override
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    onSignIn?.call();
    // The message the sheet maps to "that email and password do not match".
    throw const AuthException('Invalid login credentials');
  }
}

Widget _app(_FakeAuth auth) => ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(auth)],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                key: const ValueKey('open-sign-in'),
                onPressed: () => showSignInSheet(context),
                child: const Text('Sign in'),
              ),
            ),
          ),
        ),
      ),
    );

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('open-sign-in')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('fits a 5" phone with the keyboard up, every control reachable',
      (tester) async {
    // The reported case: 320×568, keyboard 300 px up, gesture-nav phone.
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    var submitted = false;
    await tester.pumpWidget(_app(_FakeAuth(onSignIn: () => submitted = true)));
    await _openSheet(tester);

    // A non-scrollable Column overflowed here; scrolling is the fix.
    expect(tester.takeException(), isNull,
        reason: 'no RenderFlex overflow with the keyboard up');
    // One header, not a header plus a duplicate title and body underneath.
    expect(find.text('Keep your journal'), findsOneWidget);
    expect(
      find.text(
          'Cooks stay on this phone until you sign in. Signing in puts them on every device you use.'),
      findsOneWidget,
    );

    final email = find.byKey(const ValueKey('auth-email'));
    final password = find.byKey(const ValueKey('auth-password'));
    expect(email, findsOneWidget);
    expect(password, findsOneWidget);

    await tester.ensureVisible(email);
    await tester.pump();
    await tester.enterText(email, 'cook@example.com');
    await tester.ensureVisible(password);
    await tester.pump();
    await tester.enterText(password, 'six-or-more');

    // The toggle is a control, not decoration.
    expect(tester.widget<TextField>(password).obscureText, isTrue);
    expect(find.byTooltip('Show password'), findsOneWidget);
    final toggle = find.byKey(const ValueKey('auth-password-toggle'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pump();
    expect(tester.widget<TextField>(password).obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);

    // Submit is reachable and hittable: the form actually runs from here.
    final submit = find.byKey(const ValueKey('auth-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(submitted, isTrue, reason: 'the button was under the keyboard');
    expect(find.text('That email and password do not match'), findsOneWidget);

    // And so is the create-account door.
    final create = find.byKey(const ValueKey('auth-create-toggle'));
    await tester.ensureVisible(create);
    await tester.pumpAndSettle();
    await tester.tap(create);
    await tester.pump();
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('the sheet is a form: autofill, next/done chain, submit on done',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var submitted = false;
    await tester.pumpWidget(_app(_FakeAuth(onSignIn: () => submitted = true)));
    await _openSheet(tester);

    final email =
        tester.widget<TextField>(find.byKey(const ValueKey('auth-email')));
    expect(email.autofillHints, contains(AutofillHints.email));
    expect(email.keyboardType, TextInputType.emailAddress);
    expect(email.textInputAction, TextInputAction.next);

    final password =
        tester.widget<TextField>(find.byKey(const ValueKey('auth-password')));
    expect(password.autofillHints, contains(AutofillHints.password));
    expect(password.textInputAction, TextInputAction.done);
    expect(find.byType(AutofillGroup), findsOneWidget);

    await tester.enterText(
        find.byKey(const ValueKey('auth-email')), 'cook@example.com');
    await tester.enterText(
        find.byKey(const ValueKey('auth-password')), 'six-or-more');
    // The keyboard's done key is the submit button.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(submitted, isTrue);
    expect(tester.takeException(), isNull);
  });
}

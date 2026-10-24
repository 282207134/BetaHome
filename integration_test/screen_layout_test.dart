import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:beta_home/app.dart';
import 'package:beta_home/state/app_state.dart';

AppState fixture(bool dark) {
  final s = AppState()
    ..dark = dark
    ..signedIn = true
    ..locationEnabled = true;
  s.start = DateTime.now().add(const Duration(days: 2));
  s.end = s.start.add(const Duration(days: 4));
  s.appointment = s.start;
  s.confirmBooking();
  s.search('Apartment');
  return s;
}

void main() {
  final selectedRoutes = const String.fromEnvironment('LAYOUT_ROUTES')
      .split(',')
      .where((s) => s.isNotEmpty)
      .toSet();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().testTextInput
      .register();
  for (final dark in [false, true]) {
    for (final route in ['/splash', ...appRoutes.keys].where(
      (route) => selectedRoutes.isEmpty || selectedRoutes.contains(route),
    )) {
      testWidgets(
        '${dark ? 'dark' : 'light'} $route fits ${dark ? '428' : '320'}px',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(dark ? 428 : 320, dark ? 926 : 760);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final s = fixture(dark)
            ..purchase = [
              '/buy-summary',
              '/cost',
              '/credit',
              '/appointment-date',
            ].contains(route);
          await tester.pumpWidget(
            BetaHomeApp(state: s, initialRoute: route, preview: true),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: route);
          // Reach the lower content as well: offscreen rows must not overflow.
          final scroll = find.byType(Scrollable);
          if (scroll.evaluate().isNotEmpty) {
            await tester.drag(scroll.first, const Offset(0, -1600));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '$route bottom');
          }
          await tester.pumpWidget(const SizedBox());
          s.dispose();
        },
      );
    }
  }
  testWidgets('login validates input and opens Home', (tester) async {
    final s = AppState();
    await tester.pumpWidget(BetaHomeApp(state: s, initialRoute: '/login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('Email')),
      'demo@example.com',
    );
    await tester.enterText(find.byKey(const ValueKey('Password')), 'demo1234');
    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();
    expect(s.signedIn, isTrue);
    expect(find.text('Recommendation'), findsOneWidget);
  });
}

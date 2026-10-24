import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:beta_home/app.dart';
import 'package:beta_home/state/app_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.testTextInput.register();
  final screenshotClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 20);
  Future<void> capture(String name) async {
    final bytes = await binding.takeScreenshot(name);
    final request = await screenshotClient.postUrl(
      Uri.parse('http://127.0.0.1:9742/$name'),
    );
    request.add(bytes);
    final response = await request.close();
    await response.drain<void>();
    expect(response.statusCode, 200);
    // Save each image immediately without retaining a large VM service result.
    (binding.reportData!['screenshots'] as List).clear();
  }

  Future<void> open(WidgetTester tester, AppState s, String route) async {
    await tester.pumpWidget(
      BetaHomeApp(
        key: UniqueKey(),
        state: s,
        initialRoute: route,
        preview: true,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String text) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    await tester.pump(const Duration(milliseconds: 600));
    final target = find.text(text).last;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  if (!const bool.fromEnvironment('CAPTURE_ONLY')) {
    testWidgets('Android: login, search, favorite, booking, chat, theme', (
      tester,
    ) async {
      final s = AppState();
      await open(tester, s, '/login');
      await tester.enterText(
        find.byKey(const ValueKey('Email')),
        'demo@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('Password')),
        'demo1234',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tap(tester, 'Login');
      expect(s.signedIn, isTrue);
      await tester.tap(find.byTooltip('Favorite Akasia House'));
      await tester.pumpAndSettle();
      expect(s.favorites, contains('akasia'));
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('search-input')),
        'Snow',
      );
      await tester.tap(find.byTooltip('Search properties'));
      await tester.pumpAndSettle();
      expect(find.text('Snow Apartment'), findsOneWidget);
      await tap(tester, 'Snow Apartment');
      await tap(tester, 'Booking Now · \$75/day');
      await tap(tester, 'Continue');
      await tap(tester, 'Continue');
      await tap(tester, 'Continue');
      await tap(tester, 'Continue');
      expect(find.text('Review Summary'), findsOneWidget);
      await tap(tester, 'Confirm Demo Booking');
      await tester.enterText(find.byKey(const ValueKey('code')), '0000');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tap(tester, 'Continue');
      expect(s.bookings, isEmpty);
      expect(find.text('Use the demo code 1234'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('code')), '1234');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tap(tester, 'Continue');
      expect(s.bookings, hasLength(1));
      expect(s.bookings.single.total, 310);
      await tap(tester, 'View E-Receipt');
      expect(find.text('Reservation Confirmed'), findsOneWidget);
      await open(tester, s, '/chat');
      await tester.enterText(
        find.byKey(const ValueKey('message-input')),
        'Can I visit tomorrow?',
      );
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect(s.messages('Achmad').last.text, 'Can I visit tomorrow?');
      await open(tester, s, '/profile');
      await tester.tap(find.byKey(const ValueKey('dark-mode')));
      await tester.pumpAndSettle();
      expect(s.dark, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
  if (!const bool.fromEnvironment('FLOW_ONLY')) {
    testWidgets('capture all pages in light and dark themes', (tester) async {
      final names = <String>[];
      final selectedRoutes = const String.fromEnvironment('CAPTURE_ROUTES')
          .split(',')
          .where((s) => s.isNotEmpty)
          .toSet();
      await binding.convertFlutterSurfaceToImage();
      for (final dark in [false, true]) {
        final s = AppState()
          ..signedIn = true
          ..dark = dark
          ..locationEnabled = true;
        s.start = DateUtils.dateOnly(DateTime.now())
            .add(const Duration(days: 2));
        s.end = s.start.add(const Duration(days: 4));
        s.appointment = s.start;
        s.confirmBooking();
        s.search('Apartment');
        for (final route in ['/splash', ...appRoutes.keys].where(
          (route) => selectedRoutes.isEmpty || selectedRoutes.contains(route),
        )) {
          s.purchase = [
            '/buy-summary',
            '/cost',
            '/credit',
            '/appointment-date',
          ].contains(route);
          await open(tester, s, route);
          await tester.pump(const Duration(milliseconds: 150));
          expect(tester.takeException(), isNull, reason: route);
          final name = '${dark ? 'dark' : 'light'}/${route.substring(1)}';
          await capture(name);
          names.add(name);
        }
        if (selectedRoutes.isEmpty) {
          await open(tester, s, '/favorites');
          await tester.tap(find.byTooltip('Sort by'));
          await tester.pumpAndSettle();
          await capture('${dark ? 'dark' : 'light'}/favorites-sort');
          await open(tester, s, '/detail');
          await tester.tap(find.byTooltip('Share'));
          await tester.pumpAndSettle();
          await capture('${dark ? 'dark' : 'light'}/property-share');
          await open(tester, s, '/profile');
          // The profile list scrolls; open the logout sheet through its real menu row.
          await tester.ensureVisible(find.text('Logout'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Logout'));
          await tester.pumpAndSettle();
          await capture('${dark ? 'dark' : 'light'}/logout');
        }
      }
      binding.reportData!['screenNames'] = names;
    }, timeout: const Timeout(Duration(minutes: 15)));
  }
}

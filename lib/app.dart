import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/account/account_pages.dart';
import 'features/auth/auth_pages.dart';
import 'features/booking/booking_pages.dart';
import 'features/discovery/discovery_pages.dart';
import 'features/explore/explore_pages.dart';
import 'features/messages/message_pages.dart';
import 'features/property/property_pages.dart';
import 'state/app_state.dart';
import 'ui/theme.dart';

/// Routes are shared by navigation, screenshot capture, and flow tests.
final Map<String, Widget Function()> appRoutes = {
  '/onboarding': () => const OnboardingPage(),
  '/onboarding-2': () => const OnboardingPage(initial: 1),
  '/onboarding-3': () => const OnboardingPage(initial: 2),
  '/welcome': () => const WelcomePage(),
  '/login': () => const AuthPage('login'),
  '/register': () => const AuthPage('register'),
  '/forgot': () => const AuthPage('forgot'),
  '/otp': () => const CodePage('otp'),
  '/reset': () => const AuthPage('reset'),
  '/password-success': () => const SuccessPage('password'),
  '/setup-profile': () => const ProfileFormPage(setup: true),
  '/setup-pin': () => const CodePage('setup'),
  '/profile-success': () => const SuccessPage('profile'),
  '/home': () => const HomePage(),
  '/list': () => const ListingPage(),
  '/search': () => const SearchPage(),
  '/results': () => const ListingPage(search: true),
  '/filter': () => const FilterPage(),
  '/facilities': () => const FacilityPage(),
  '/favorites': () => const ListingPage(favorite: true),
  '/notifications': () => const NotificationsPage(),
  '/detail': () => const PropertyDetailPage(),
  '/gallery': () => const GalleryPage(),
  '/reviews': () => const ReviewsPage(),
  '/purchase-method': () => const PurchaseMethodPage(),
  '/booking-date': () => const BookingDatePage(),
  '/user-info': () => const UserInfoPage(),
  '/payment': () => const PaymentPage(),
  '/summary': () => const SummaryPage(),
  '/booking-pin': () => const CodePage('booking'),
  '/booking-success': () => const SuccessPage('booking'),
  '/receipt': () => const ReceiptPage(),
  '/buy-summary': () => const SummaryPage(buyOverview: true),
  '/cost': () => const SummaryPage(cost: true),
  '/credit': () => const CreditPage(),
  '/appointment-date': () => const BookingDatePage(appointment: true),
  '/enable-location': () => const ExplorePage(permission: true),
  '/explore': () => const ExplorePage(),
  '/messages': () => const MessagesPage(),
  '/calls': () => const MessagesPage(calls: true),
  '/chat': () => const ChatPage(),
  '/call': () => const CallPage(),
  '/profile': () => const ProfilePage(),
  '/edit-profile': () => const ProfileFormPage(),
  '/appointments': () => const ReservationsPage(appointments: true),
  '/bookings': () => const ReservationsPage(),
  '/payment-methods': () => const PaymentPage(account: true),
  '/add-card': () => const AddCardPage(),
  '/language': () => const LanguagePage(),
  '/notification-settings': () => const SettingsPage(),
  '/security': () => const SettingsPage(security: true),
  '/help': () => const HelpPage(),
  '/contact': () => const HelpPage(contact: true),
  '/customer-service': () => const ChatPage(support: true),
};

class BetaHomeApp extends StatelessWidget {
  const BetaHomeApp({
    super.key,
    required this.state,
    this.initialRoute,
    this.preview = false,
  });
  final AppState state;
  final String? initialRoute;
  final bool preview;
  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: AnimatedBuilder(
      animation: state,
      builder: (context, _) => MaterialApp(
        title: 'Beta Home',
        debugShowCheckedModeBanner: false,
        theme: appTheme(false),
        darkTheme: appTheme(true),
        themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: initialRoute ?? (state.signedIn ? '/home' : '/splash'),
        onGenerateInitialRoutes: (route) => [
          _route(RouteSettings(name: route)),
        ],
        onGenerateRoute: _route,
      ),
    ),
  );
  Route<dynamic> _route(RouteSettings settings) => MaterialPageRoute(
    settings: settings,
    builder: (context) {
      final dark = AppScope.of(context).dark;
      final route = settings.name ?? '';
      final photo =
          route.startsWith('/onboarding') ||
          const [
            '/detail',
            '/welcome',
            '/filter',
            '/booking-date',
            '/appointment-date',
          ].contains(route);
      final lightStatus = route != '/explore' && (dark || photo);
      final darkNavigation =
          route != '/explore' &&
          (dark ||
              const ['/booking-date', '/appointment-date'].contains(route));
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: lightStatus
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: lightStatus ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: darkNavigation
              ? const Color(0xFF111111)
              : Colors.white,
          systemNavigationBarIconBrightness: darkNavigation
              ? Brightness.light
              : Brightness.dark,
        ),
        child: route == '/splash'
            ? SplashPage(preview: preview)
            : (appRoutes[route] ?? () => const HomePage())(),
      );
    },
  );
}

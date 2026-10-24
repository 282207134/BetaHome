import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AppPage(
      title: 'Profile',
      tab: 3,
      children: [
        Row(
          children: [
            const Avatar(size: 60),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(s.phone),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit profile',
              onPressed: () => go(context, '/edit-profile'),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _label('General'),
        _item(
          context,
          'Appointment',
          Icons.calendar_month_outlined,
          '/appointments',
        ),
        _item(context, 'My Booking', Icons.bookmark_border, '/bookings'),
        _label('Account Setting'),
        _item(
          context,
          'Payment Methods',
          Icons.account_balance_wallet_outlined,
          '/payment-methods',
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: _icon(context, Icons.visibility_outlined),
          title: const Text(
            'Dark Mode',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          trailing: Switch(
            key: const ValueKey('dark-mode'),
            value: s.dark,
            onChanged: (v) {
              s.dark = v;
              s.changed();
            },
          ),
        ),
        _item(context, 'Logout', Icons.logout, '/logout'),
        _label('App Setting'),
        _item(context, 'Language', Icons.article_outlined, '/language'),
        _item(
          context,
          'Notification',
          Icons.notifications_none,
          '/notification-settings',
        ),
        _item(context, 'Security', Icons.verified_user_outlined, '/security'),
        _label('Support'),
        _item(context, 'Help Center', Icons.help_outline, '/help'),
      ],
    );
  }

  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 12),
    child: Text(
      value,
      style: const TextStyle(color: muted, fontWeight: FontWeight.w700),
    ),
  );
  Widget _icon(BuildContext c, IconData icon) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Theme.of(c).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Icon(icon, color: muted, size: 23),
  );
  Widget _item(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: _icon(context, icon),
    title: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    trailing: const Icon(Icons.chevron_right, color: muted),
    onTap: () {
      if (route == '/logout') {
        showLogout(context);
      } else {
        go(context, route);
      }
    },
  );
}

void showLogout(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (c) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Logout',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(),
          const Text('Are you sure you want to log out?'),
          const SizedBox(height: 28),
          PrimaryButton(
            'Yes, Logout',
            onPressed: () {
              final s = AppScope.of(context);
              s.signedIn = false;
              s.changed();
              resetTo(context, '/welcome');
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  ),
);

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key, this.appointments = false});
  final bool appointments;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AppPage(
      title: appointments ? 'Appointment' : 'My Booking',
      children: [
        if (appointments && s.appointment != null)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Tag('Upcoming Visit'),
                const SizedBox(height: 18),
                Text(
                  s.appointmentProperty.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                InfoRow('Date', dateLabel(s.appointment!)),
                InfoRow('Time', s.appointmentTime),
                const InfoRow('Status', 'Scheduled · Demo'),
                OutlinedButton(
                  onPressed: () {
                    s.selected = s.appointmentProperty;
                    s.purchase = false;
                    go(context, '/appointment-date');
                  },
                  child: const Text('Reschedule'),
                ),
              ],
            ),
          )
        else if (appointments)
          const EmptyState(
            'Your next visit starts here',
            'Open a property to schedule an appointment.',
            icon: Icons.calendar_month_outlined,
          ),
        if (!appointments && s.bookings.isEmpty)
          const EmptyState(
            'No bookings yet',
            'Find a home you love and make your first demo reservation.',
            icon: Icons.bookmark_border,
          ),
        if (!appointments)
          for (final b in s.bookings)
            Column(
              children: [
                Row(
                  children: [
                    Tag(b.purchase ? 'Purchase' : 'Confirmed'),
                    const Spacer(),
                    Text(
                      dateLabel(b.start),
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PropertyCard(
                  b.property,
                  compact: true,
                  onTap: () {
                    s.lastReservation = b;
                    go(context, '/receipt');
                  },
                ),
              ],
            ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => resetTo(context, '/home'),
          child: const Text('Explore Homes'),
        ),
      ],
    );
  }
}

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AppPage(
      title: 'Language',
      children: [
        const SectionTitle('Suggested'),
        for (final language in [
          'English (US)',
          'English (UK)',
          'Bahasa Indonesia',
          '中文',
          '日本語',
          'Español',
          'Français',
        ])
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(language),
            trailing: Icon(
              s.language == language
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: blue,
            ),
            onTap: () {
              s.language = language;
              s.changed();
            },
          ),
        const SizedBox(height: 24),
        const Text(
          'Your language preference is saved. This UI demonstration currently uses the English design copy.',
          style: TextStyle(color: muted, fontSize: 13),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.security = false});
  final bool security;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final options = security
        ? ['Remember Me', 'Biometric Sign-In', 'Face ID', 'App Lock']
        : [
            'General Notification',
            'Sound',
            'Vibrate',
            'New Properties',
            'Booking Updates',
            'Special Offers',
          ];
    return AppPage(
      title: security ? 'Security' : 'Notification',
      children: [
        for (final option in options)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              option,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            value: s.settings[option] ?? !security,
            onChanged: (v) {
              s.settings[option] = v;
              s.changed();
            },
          ),
        const SizedBox(height: 28),
        if (security) ...[
          OutlinedButton(
            onPressed: () => go(context, '/reset'),
            child: const Text('Change Password'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Security switches save demo preferences. Device biometrics and server authentication are not connected.',
            style: TextStyle(color: muted, fontSize: 13),
          ),
        ] else
          const Text(
            'These preferences are saved on this device. Push notifications require a connected notification service.',
            style: TextStyle(color: muted, fontSize: 13),
          ),
      ],
    );
  }
}

class HelpPage extends StatefulWidget {
  const HelpPage({super.key, this.contact = false});
  final bool contact;
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    const questions = [
      'What is Beta Home?',
      'How do I book a property?',
      'How do I save a favorite?',
      'Can I change my booking?',
      'How do payments work?',
    ];
    const answers = [
      'Beta Home helps you explore, compare, and book properties. This build is a local UI demonstration.',
      'Open a property, tap Booking Now, choose dates, add contact details, and confirm with demo PIN 1234.',
      'Tap the heart on any property card. Find your saved homes using the heart on the Home page.',
      'You can edit your selected dates on the review screen before confirming. Completed demo bookings are available in Profile → My Booking.',
      'All methods in this build are simulated. No real payment is processed and no full card number is saved.',
    ];
    return AppPage(
      title: 'Help Center',
      children: [
        ChoiceRow(
          const ['FAQ', 'Contact Us'],
          widget.contact ? 'Contact Us' : 'FAQ',
          (v) {
            if ((v == 'Contact Us') != widget.contact) {
              Navigator.pushReplacementNamed(
                context,
                v == 'FAQ' ? '/help' : '/contact',
              );
            }
          },
        ),
        const SizedBox(height: 24),
        if (widget.contact) ...[
          for (final entry in [
            ('Customer Service', Icons.headset_mic_outlined),
            ('Property Support', Icons.home_outlined),
            ('Booking Assistance', Icons.calendar_month_outlined),
          ])
            Panel(
              padding: 6,
              child: ListTile(
                leading: Icon(entry.$2, color: blue),
                title: Text(entry.$1),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => go(context, '/customer-service'),
              ),
            ),
          const Text(
            'Support conversations are stored locally in this demo.',
            style: TextStyle(color: muted, fontSize: 13),
          ),
        ] else ...[
          TextField(
            onChanged: (v) => setState(() => query = v.toLowerCase()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search help articles',
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < questions.length; i++)
            if ('${questions[i]} ${answers[i]}'.toLowerCase().contains(query))
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Panel(
                  padding: 4,
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(
                      questions[i],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Text(
                          answers[i],
                          style: const TextStyle(color: muted, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

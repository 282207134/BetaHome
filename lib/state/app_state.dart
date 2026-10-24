import 'dart:async';

import 'package:flutter/material.dart';

import '../data/local_repository.dart';
import '../domain/models.dart';

class AppState extends ChangeNotifier {
  AppState({this.repository}) {
    final j = repository?.read() ?? {};
    dark = j['dark'] == true;
    signedIn = j['signedIn'] == true;
    onboarded = j['onboarded'] == true;
    name = j['name'] as String? ?? 'Mukhlisin';
    email = j['email'] as String? ?? 'mukhlisin@example.com';
    phone = j['phone'] as String? ?? '0845-3243-2324';
    address = j['address'] as String? ?? 'Snow Street 42343';
    language = j['language'] as String? ?? 'English (US)';
    locationEnabled = j['locationEnabled'] == true;
    appointment = DateTime.tryParse(j['appointment'] as String? ?? '');
    appointmentTime = j['appointmentTime'] as String? ?? '10:00 AM';
    appointmentPropertyId = j['appointmentProperty'] as String? ?? 'snow';
    favorites.addAll((j['favorites'] as List? ?? ['snow']).cast<String>());
    cards.addAll((j['cards'] as List? ?? ['Visa •••• 4242']).cast<String>());
    settings.addAll((j['settings'] as Map? ?? {}).cast<String, bool>());
    for (final item in j['bookings'] as List? ?? []) {
      try {
        bookings.add(Reservation.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        /* Ignore individual records from older schemas. */
      }
    }
    final savedChats = j['chats'] as Map? ?? {};
    for (final entry in savedChats.entries) {
      chats[entry.key as String] = (entry.value as List)
          .map((m) => ChatMessage(m['text'], m['mine']))
          .toList();
    }
  }
  final LocalRepository? repository;
  bool dark = false,
      signedIn = false,
      onboarded = false,
      locationEnabled = false;
  String name = '', email = '', phone = '', address = '', language = '';
  final favorites = <String>{};
  final cards = <String>[];
  final bookings = <Reservation>[];
  final chats = <String, List<ChatMessage>>{};
  final settings = <String, bool>{};
  final recentSearches = <String>[];
  Property selected = properties[1];
  PropertyFilter filter = const PropertyFilter();
  String query = '', payment = 'Visa •••• 4242', chatContact = 'Achmad';
  bool purchase = false;
  DateTime start = DateTime.now().add(const Duration(days: 1));
  DateTime end = DateTime.now().add(const Duration(days: 5));
  DateTime? appointment;
  String appointmentTime = '10:00 AM',
      appointmentPropertyId = 'snow',
      bookingNote = '';
  Property get appointmentProperty => properties.firstWhere(
    (p) => p.id == appointmentPropertyId,
    orElse: () => properties[1],
  );
  Reservation? lastReservation;
  bool rememberSession = true;
  Future<void> _pendingSave = Future.value();
  Future<void> get saved => _pendingSave;
  int get days => end
      .difference(DateTime(start.year, start.month, start.day))
      .inDays
      .clamp(1, 3650);
  int get units => selected.period == 'month' ? (days / 30).ceil() : days;
  double get amount => purchase ? 54723 : (units * selected.price).toDouble();
  double get tax => purchase ? amount * .025 : 10;
  double get total => amount + tax;
  List<Property> results({String sort = 'Recommended'}) {
    final items = properties.where((p) => filter.matches(p, query)).toList();
    if (sort == 'Price: low to high') {
      items.sort((a, b) => a.price.compareTo(b.price));
    }
    if (sort == 'Price: high to low') {
      items.sort((a, b) => b.price.compareTo(a.price));
    }
    if (sort == 'Name') items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  void changed() {
    notifyListeners();
    if (repository != null) {
      final snapshot = {
        'dark': dark,
        'signedIn': signedIn && rememberSession,
        'onboarded': onboarded,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'language': language,
        'locationEnabled': locationEnabled,
        'appointment': appointment?.toIso8601String(),
        'appointmentTime': appointmentTime,
        'appointmentProperty': appointmentPropertyId,
        'favorites': favorites.toList(),
        'cards': [...cards],
        'settings': {...settings},
        'bookings': bookings.map((b) => b.toJson()).toList(),
        'chats': chats.map(
          (k, v) => MapEntry(k, v.map((m) => m.toJson()).toList()),
        ),
      };
      _pendingSave = _pendingSave.then((_) => repository!.write(snapshot));
      unawaited(_pendingSave);
    }
  }

  void toggleFavorite(String id) {
    if (!favorites.remove(id)) favorites.add(id);
    changed();
  }

  void search(String text) {
    query = text.trim();
    if (query.isNotEmpty) {
      recentSearches.remove(query);
      recentSearches.insert(0, query);
    }
    changed();
  }

  void select(Property p) {
    selected = p;
    changed();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages(chatContact).add(ChatMessage(text.trim(), true));
    changed();
  }

  List<ChatMessage> messages(String contact) => chats.putIfAbsent(
    contact,
    () => [
      const ChatMessage('Hi! I am interested in Snow Apartment.', true),
      const ChatMessage(
        'Hi, good morning! The apartment is still available.',
        false,
      ),
      const ChatMessage('Could I schedule a visit this week?', true),
      const ChatMessage(
        'Of course. Let me know which day works for you.',
        false,
      ),
    ],
  );
  Reservation confirmBooking() {
    final reservation = Reservation(
      id: 'BH-${DateTime.now().microsecondsSinceEpoch}',
      propertyId: selected.id,
      start: start,
      end: end,
      total: total,
      purchase: purchase,
      payment: payment,
      note: bookingNote,
      appointmentTime: purchase ? appointmentTime : '',
    );
    bookings.insert(0, reservation);
    lastReservation = reservation;
    changed();
    return reservation;
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

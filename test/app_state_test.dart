import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beta_home/data/local_repository.dart';
import 'package:beta_home/domain/models.dart';
import 'package:beta_home/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('search combines query, category, facilities, price, and ordering', () {
    final s = AppState();
    s.search('  surakarta  ');
    s.filter = const PropertyFilter(
      type: 'Apartment',
      min: 50,
      max: 100,
      facilities: {'Gym', 'Wi-Fi'},
    );
    expect(s.results().map((p) => p.id), ['snow']);
    s.filter = const PropertyFilter(facilities: {'Swimming Pool'});
    s.query = '';
    expect(s.results(sort: 'Price: high to low').map((p) => p.id), [
      'palm',
      'snow',
    ]);
    s.query = 'no matching location';
    expect(s.results(), isEmpty);
  });
  test('daily and monthly rental totals use different billing units', () {
    final s = AppState()
      ..start = DateTime(2026, 11, 1)
      ..end = DateTime(2026, 11, 5);
    expect(s.days, 4);
    expect(s.amount, 300);
    expect(s.total, 310);
    s.selected = properties[0];
    expect(s.units, 1);
    expect(s.total, 130);
    s.end = DateTime(2026, 12, 2);
    expect(s.units, 2);
    expect(s.total, 250);
    s.purchase = true;
    expect(s.total, closeTo(56091.075, .001));
  });
  test(
    'favorites, profile, messages, bookings, cards and settings survive reload',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = LocalRepository(await SharedPreferences.getInstance());
      final s = AppState(repository: repository);
      s.toggleFavorite('akasia');
      s.name = 'Li';
      s.dark = true;
      s.signedIn = true;
      s.settings['Sound'] = false;
      s.cards.add('Card •••• 1234');
      s.appointment = DateTime(2026, 11, 1);
      s.appointmentPropertyId = 'akasia';
      s.sendMessage('Can I visit tomorrow?');
      final booking = s.confirmBooking();
      await s.saved;
      final restored = AppState(repository: repository);
      expect(restored.favorites, contains('akasia'));
      expect(restored.name, 'Li');
      expect(restored.dark, isTrue);
      expect(restored.signedIn, isTrue);
      expect(restored.settings['Sound'], isFalse);
      expect(restored.bookings.single.id, booking.id);
      expect(restored.bookings.single.total, booking.total);
      expect(restored.messages('Achmad').last.text, 'Can I visit tomorrow?');
      expect(restored.cards, contains('Card •••• 1234'));
      expect(restored.appointmentProperty.id, 'akasia');
      expect(
        repository.preferences.getString(LocalRepository.key),
        isNot(contains('password')),
      );
    },
  );
  test('invalid persisted JSON falls back to demo data', () async {
    SharedPreferences.setMockInitialValues({LocalRepository.key: '{broken'});
    final s = AppState(
      repository: LocalRepository(await SharedPreferences.getInstance()),
    );
    expect(s.name, 'Mukhlisin');
    expect(s.bookings, isEmpty);
  });
  test('reservation serialization preserves transaction values', () {
    final s = AppState();
    final r = s.confirmBooking();
    final copy = Reservation.fromJson(r.toJson());
    expect(copy.property.id, 'snow');
    expect(copy.total, r.total);
    expect(copy.start, r.start);
    s.selected = properties[0];
    expect(copy.property.id, 'snow');
  });
}

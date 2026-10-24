class Property {
  const Property(
    this.id,
    this.name,
    this.type,
    this.image,
    this.price,
    this.period,
    this.address,
    this.beds,
    this.baths,
    this.area,
    this.facilities,
  );
  final String id, name, type, image, period, address;
  final int price, beds, baths, area;
  final Set<String> facilities;
  String get priceLabel => '\$$price/$period';
}

const properties = [
  Property(
    'akasia',
    'Akasia House',
    'House',
    'house',
    120,
    'month',
    'Solo Raya, Surakarta, Jawa Tengah',
    2,
    1,
    1800,
    {'Parking', 'Wi-Fi', 'Garden', 'Restaurant'},
  ),
  Property(
    'snow',
    'Snow Apartment',
    'Apartment',
    'apartment',
    75,
    'day',
    'Solo Baru, Surakarta, Jawa Tengah',
    2,
    1,
    2500,
    {'Parking', 'Wi-Fi', 'Gym', 'Swimming Pool', 'Restaurant'},
  ),
  Property(
    'sakura',
    'Sakura Boarding House',
    'Boarding',
    'boarding',
    95,
    'month',
    'San Francisco, California',
    1,
    1,
    850,
    {'Wi-Fi', 'Parking', 'Laundry'},
  ),
  Property(
    'palm',
    'Palm Luxury Villa',
    'Villa',
    'villa',
    280,
    'day',
    'San Francisco, California',
    4,
    3,
    4200,
    {'Parking', 'Wi-Fi', 'Garden', 'Swimming Pool', 'Gym'},
  ),
];

class PropertyFilter {
  const PropertyFilter({
    this.type = 'All',
    this.rental = 'All',
    this.min = 0,
    this.max = 500,
    this.facilities = const {},
  });
  final String type, rental;
  final double min, max;
  final Set<String> facilities;

  bool matches(Property p, String query) =>
      (type == 'All' || type == p.type) &&
      (rental == 'All' ||
          rental == 'Buy' ||
          (rental == 'Daily' ? p.period == 'day' : p.period == 'month')) &&
      p.price >= min &&
      p.price <= max &&
      facilities.every(p.facilities.contains) &&
      '${p.name} ${p.type} ${p.address}'.toLowerCase().contains(
        query.toLowerCase().trim(),
      );
}

class Reservation {
  const Reservation({
    required this.id,
    required this.propertyId,
    required this.start,
    required this.end,
    required this.total,
    required this.purchase,
    required this.payment,
    this.note = '',
    this.appointmentTime = '',
  });
  final String id, propertyId, payment;
  final String note, appointmentTime;
  final DateTime start, end;
  final double total;
  final bool purchase;
  Property get property => properties.firstWhere((p) => p.id == propertyId);
  Map<String, dynamic> toJson() => {
    'id': id,
    'property': propertyId,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'total': total,
    'purchase': purchase,
    'payment': payment,
    'note': note,
    'appointmentTime': appointmentTime,
  };
  factory Reservation.fromJson(Map<String, dynamic> j) => Reservation(
    id: j['id'],
    propertyId: j['property'],
    start: DateTime.parse(j['start']),
    end: DateTime.parse(j['end']),
    total: (j['total'] as num).toDouble(),
    purchase: j['purchase'],
    payment: j['payment'],
    note: j['note'] as String? ?? '',
    appointmentTime: j['appointmentTime'] as String? ?? '',
  );
}

class ChatMessage {
  const ChatMessage(this.text, this.mine);
  final String text;
  final bool mine;
  Map<String, dynamic> toJson() => {'text': text, 'mine': mine};
}

const contacts = [
  'Achmad',
  'Antony Lukas',
  'Subandi Achmad',
  'Victor',
  'Rangga',
  'Anton',
];
const facilities = [
  'Parking',
  'Gym',
  'Restaurant',
  'Wi-Fi',
  'Swimming Pool',
  'Garden',
  'Laundry',
  'Security',
];

String dateLabel(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
String money(num n) =>
    '\$${n.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';

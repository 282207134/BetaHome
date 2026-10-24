import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class PurchaseMethodPage extends StatefulWidget {
  const PurchaseMethodPage({super.key});
  @override
  State<PurchaseMethodPage> createState() => _PurchaseMethodPageState();
}

class _PurchaseMethodPageState extends State<PurchaseMethodPage> {
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AppPage(
      title: 'Purchase Methods',
      bottom: PrimaryButton(
        'Continue',
        onPressed: () =>
            go(context, s.purchase ? '/buy-summary' : '/booking-date'),
      ),
      children: [
        PropertyCard(s.selected, compact: true),
        const SectionTitle('Make this place yours'),
        const Text(
          'Choose how you would like to enjoy your new home.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 28),
        for (final buy in [false, true])
          InkWell(
            onTap: () {
              s.purchase = buy;
              s.changed();
            },
            borderRadius: BorderRadius.circular(16),
            child: Panel(
              filled: s.purchase == buy,
              child: Row(
                children: [
                  Icon(
                    buy ? Icons.real_estate_agent_outlined : Icons.key_outlined,
                    color: blue,
                    size: 34,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buy ? 'Buy Real Estate' : 'Rent Real Estate',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          buy
                              ? 'A place to call your own'
                              : 'A flexible stay that fits your plans',
                          style: const TextStyle(color: muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    s.purchase == buy
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: blue,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Panel(
          filled: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Demo reservations only. No real payment or property transaction is made.',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BookingDatePage extends StatefulWidget {
  const BookingDatePage({super.key, this.appointment = false});
  final bool appointment;
  @override
  State<BookingDatePage> createState() => _BookingDatePageState();
}

class _BookingDatePageState extends State<BookingDatePage> {
  late DateTime month;
  late DateTime start, end;
  bool ready = false, selectEnd = false;
  String time = '10:00 AM';
  final note = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ready) {
      final s = AppScope.of(context);
      start = s.start;
      end = s.end;
      time = s.appointmentTime;
      note.text = s.bookingNote;
      month = DateTime(start.year, start.month);
      ready = true;
    }
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  void choose(DateTime d) {
    final today = DateUtils.dateOnly(DateTime.now());
    if (d.isBefore(today)) return;
    setState(() {
      if (widget.appointment) {
        start = d;
        end = d;
      } else if (!selectEnd) {
        start = d;
        end = d.add(const Duration(days: 1));
        selectEnd = true;
      } else if (d.isAfter(start)) {
        end = d;
        selectEnd = false;
      } else {
        start = d;
        end = d.add(const Duration(days: 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = DateUtils.getDaysInMonth(month.year, month.month),
        offset = DateTime(month.year, month.month).weekday - 1;
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        foregroundColor: Colors.white,
        title: Text(
          widget.appointment ? 'Schedule Appointment' : 'Book Real Estate',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Previous month',
                      onPressed: () => setState(
                        () => month = DateTime(month.year, month.month - 1),
                      ),
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        '${months[month.month - 1]} ${month.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next month',
                      onPressed: () => setState(
                        () => month = DateTime(month.year, month.month + 1),
                      ),
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .map(
                        (v) => Expanded(
                          child: Center(
                            child: Text(
                              v,
                              style: const TextStyle(color: muted),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: count + offset,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (c, i) {
                    if (i < offset) return const SizedBox.shrink();
                    final date = DateTime(
                      month.year,
                      month.month,
                      i - offset + 1,
                    );
                    final selected =
                        !date.isBefore(DateUtils.dateOnly(start)) &&
                        !date.isAfter(DateUtils.dateOnly(end));
                    final disabled = date.isBefore(
                      DateUtils.dateOnly(DateTime.now()),
                    );
                    return InkWell(
                      onTap: disabled ? null : () => choose(date),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? blue : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? blue : Colors.white12,
                          ),
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : disabled
                                ? Colors.white24
                                : muted,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: muted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    widget.appointment
                        ? 'Schedule a Visit'
                        : selectEnd
                        ? 'Select Check-Out Date'
                        : 'Schedule Booking',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(child: Tag(dateLabel(start))),
                    if (!widget.appointment) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward, size: 16),
                      ),
                      Expanded(child: Tag(dateLabel(end))),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                if (widget.appointment) ...[
                  const SectionTitle('Available Time'),
                  ChoiceRow(
                    const ['10:00 AM', '11:30 AM', '2:00 PM', '4:00 PM'],
                    time,
                    (v) => setState(() => time = v),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text('Note to owner (optional)'),
                const SizedBox(height: 8),
                TextField(
                  controller: note,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Anything you would like us to know?',
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  'Continue',
                  onPressed: () {
                    final s = AppScope.of(context);
                    s.start = DateUtils.dateOnly(start);
                    s.end = DateUtils.dateOnly(end);
                    s.bookingNote = note.text.trim();
                    if (widget.appointment) {
                      s.appointment = start;
                      s.appointmentTime = time;
                      s.appointmentPropertyId = s.selected.id;
                      if (s.purchase) {
                        go(context, '/payment');
                      } else {
                        Navigator.pop(context);
                      }
                    } else {
                      go(context, '/user-info');
                    }
                    s.changed();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});
  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final form = GlobalKey<FormState>();
  final fields = List.generate(3, (_) => TextEditingController());
  bool ready = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ready) {
      final s = AppScope.of(context);
      fields[0].text = s.name;
      fields[1].text = s.phone;
      fields[2].text = s.email;
      ready = true;
    }
  }

  @override
  void dispose() {
    for (final c in fields) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Your Information',
    bottom: PrimaryButton(
      'Continue',
      onPressed: () {
        if (!form.currentState!.validate()) return;
        final s = AppScope.of(context);
        s.name = fields[0].text.trim();
        s.phone = fields[1].text.trim();
        s.email = fields[2].text.trim();
        s.changed();
        go(context, '/payment');
      },
    ),
    children: [
      PropertyCard(AppScope.of(context).selected, compact: true),
      const SectionTitle('Contact Information'),
      const Text(
        'The owner will use these details to coordinate your stay.',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 28),
      Form(
        key: form,
        child: Column(
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: TextFormField(
                controller: fields[i],
                keyboardType: [
                  TextInputType.name,
                  TextInputType.phone,
                  TextInputType.emailAddress,
                ][i],
                decoration: InputDecoration(
                  labelText: ['Full Name', 'Phone Number', 'Email'][i],
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Required'
                    : i == 2 && !v.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key, this.account = false});
  final bool account;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AppPage(
      title: 'Payment Methods',
      bottom: account
          ? null
          : PrimaryButton('Continue', onPressed: () => go(context, '/summary')),
      children: [
        const Text(
          'Choose your preferred payment method.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 24),
        for (final method in [...s.cards, 'PayPal', 'Apple Pay'])
          Panel(
            padding: 6,
            child: ListTile(
              leading: Icon(
                method.startsWith('Visa') || method.startsWith('Card')
                    ? Icons.credit_card
                    : method == 'PayPal'
                    ? Icons.account_balance_wallet_outlined
                    : Icons.apple,
                color: blue,
                size: 28,
              ),
              title: Text(
                method,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: Icon(
                s.payment == method
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: blue,
              ),
              onTap: () {
                s.payment = method;
                s.changed();
              },
            ),
          ),
        OutlinedButton(
          onPressed: () => go(context, '/add-card'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add),
              SizedBox(width: 10),
              Text('Add New Card'),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Demo payment methods · no money will be charged.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 13),
        ),
      ],
    );
  }
}

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});
  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final form = GlobalKey<FormState>();
  final controllers = List.generate(4, (_) => TextEditingController());
  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Add New Card',
    bottom: PrimaryButton(
      'Add Card',
      onPressed: () {
        if (!form.currentState!.validate()) return;
        final number = controllers[1].text.replaceAll(' ', '');
        final s = AppScope.of(context);
        final label = 'Card •••• ${number.substring(number.length - 4)}';
        if (!s.cards.contains(label)) s.cards.add(label);
        s.payment = label;
        s.changed();
        Navigator.pop(context);
      },
    ),
    children: [
      Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: blue,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contactless, color: Colors.white, size: 32),
                Spacer(),
                Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '••••    ••••    ••••    ••••',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  letterSpacing: 3,
                ),
              ),
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR NAME',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'MM/YY',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),
      Form(
        key: form,
        child: Column(
          children: List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: TextFormField(
                controller: controllers[i],
                obscureText: i == 3,
                keyboardType: i == 0
                    ? TextInputType.name
                    : i == 2
                    ? TextInputType.text
                    : TextInputType.number,
                inputFormatters: i == 1
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(19),
                      ]
                    : i == 3
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ]
                    : null,
                decoration: InputDecoration(
                  labelText: [
                    'Cardholder Name',
                    'Card Number',
                    'Expiry Date (MM/YY)',
                    'CVV',
                  ][i],
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (i == 1 && (v.length < 13 || v.length > 19)) {
                    return 'Enter 13–19 digits';
                  }
                  if (i == 2) {
                    final match = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$')
                        .firstMatch(v);
                    if (match == null) return 'Use MM/YY';
                    final expiry = DateTime(
                      2000 + int.parse(match[2]!),
                      int.parse(match[1]!) + 1,
                    );
                    if (!expiry.isAfter(DateTime.now())) {
                      return 'Card is expired';
                    }
                  }
                  if (i == 3 && v.length < 3) return 'Enter 3–4 digits';
                  return null;
                },
              ),
            ),
          ),
        ),
      ),
      const Text(
        'Use dummy card details. Only the last four digits are saved on this device.',
        style: TextStyle(color: muted, fontSize: 13),
      ),
    ],
  );
}

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key, this.buyOverview = false, this.cost = false});
  final bool buyOverview, cost;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AppPage(
      title: cost ? 'Cost Calculation Detail' : 'Review Summary',
      bottom: PrimaryButton(
        buyOverview
            ? 'Schedule Appointment'
            : cost
            ? 'Back to Summary'
            : 'Confirm Demo Booking',
        onPressed: () {
          if (cost) {
            Navigator.pop(context);
          } else {
            go(context, buyOverview ? '/appointment-date' : '/booking-pin');
          }
        },
      ),
      children: [
        if (!cost) PropertyCard(s.selected, compact: true),
        if (s.purchase || buyOverview) ...[
          const SectionTitle('Housing Inspection'),
          Panel(
            child: Column(
              children: [
                const Tag('Initial Price'),
                const SizedBox(height: 22),
                Text(
                  money(54723),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Review the property with the owner before making your decision.',
                        style: TextStyle(color: Colors.green, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Panel(
            child: Column(
              children: [
                const SectionTitle('Client Information'),
                InfoRow('Name', s.name),
                InfoRow('Phone Number', s.phone),
                InfoRow('Address', s.address),
              ],
            ),
          ),
        ] else
          Panel(
            child: Column(
              children: [
                SectionTitle(
                  'Date Rent',
                  action: 'Edit',
                  onTap: () => go(context, '/booking-date'),
                ),
                const Divider(),
                InfoRow('Check In', dateLabel(s.start)),
                InfoRow('Check Out', dateLabel(s.end)),
                InfoRow('Duration', '${s.days} days'),
                if (s.selected.period == 'month')
                  InfoRow('Billing', '${s.units} month(s), rounded up'),
              ],
            ),
          ),
        Panel(
          filled: true,
          child: Column(
            children: [
              const SectionTitle('Order Summary'),
              InfoRow(
                s.purchase
                    ? 'Property Price'
                    : 'Amount (${s.units} ${s.selected.period}${s.units > 1 ? 's' : ''})',
                money(s.amount),
              ),
              InfoRow(s.purchase ? 'Tax (2.5%)' : 'Service Fee', money(s.tax)),
              const Divider(),
              InfoRow('Total', money(s.total), highlight: true),
            ],
          ),
        ),
        if (!cost && !buyOverview) Panel(child: InfoRow('Payment', s.payment)),
        if (buyOverview) ...[
          TextButton(
            onPressed: () => go(context, '/cost'),
            child: const Text('View Cost Calculation Detail →'),
          ),
          TextButton(
            onPressed: () => go(context, '/credit'),
            child: const Text('Try Credit Simulation →'),
          ),
        ],
        const Text(
          'Local demo · no real property booking or payment will be processed.',
          style: TextStyle(color: muted, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class CreditPage extends StatefulWidget {
  const CreditPage({super.key});
  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  double down = 20, years = 10, rate = 5;
  @override
  Widget build(BuildContext context) {
    final principal = 54723 * (1 - down / 100), n = years * 12, r = rate / 1200;
    final monthly = r == 0
        ? principal / n
        : principal * r / (1 - math.pow(1 + r, -n));
    return AppPage(
      title: 'Credit Simulation',
      bottom: PrimaryButton(
        'Schedule Appointment',
        onPressed: () => go(context, '/appointment-date'),
      ),
      children: [
        const SectionTitle('Plan your next chapter'),
        const Text(
          'Adjust the values to explore an illustrative monthly payment.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 28),
        Panel(
          filled: true,
          child: Column(
            children: [
              const Tag('Estimated Monthly Payment'),
              const SizedBox(height: 22),
              Text(
                money(monthly),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: blue,
                ),
              ),
              const SizedBox(height: 12),
              InfoRow('Property Price', money(54723)),
            ],
          ),
        ),
        _slider(
          'Down Payment',
          '${down.round()}%',
          down,
          0,
          80,
          (v) => setState(() => down = v),
        ),
        _slider(
          'Loan Term',
          '${years.round()} years',
          years,
          1,
          30,
          (v) => setState(() => years = v.roundToDouble()),
        ),
        _slider(
          'Annual Interest Rate',
          '${rate.toStringAsFixed(1)}%',
          rate,
          0,
          15,
          (v) => setState(() => rate = v),
        ),
        const SizedBox(height: 24),
        const Text(
          'Illustrative calculation only. Excludes insurance and additional fees; this is not a lending offer.',
          style: TextStyle(color: muted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _slider(
    String label,
    String value,
    double current,
    double min,
    double max,
    ValueChanged<double> change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      children: [
        InfoRow(label, value),
        Slider(value: current, min: min, max: max, onChanged: change),
      ],
    ),
  );
}

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final b =
        s.lastReservation ?? (s.bookings.isEmpty ? null : s.bookings.first);
    if (b == null) {
      return const AppPage(
        title: 'E-Receipt',
        children: [
          EmptyState(
            'No receipt yet',
            'Complete a demo reservation to get your e-receipt.',
            icon: Icons.receipt_long_outlined,
          ),
        ],
      );
    }
    return AppPage(
      title: 'E-Receipt',
      bottom: PrimaryButton(
        'Back to Home',
        onPressed: () => resetTo(context, '/home'),
      ),
      actions: [
        IconButton(
          tooltip: 'Copy receipt',
          icon: const Icon(Icons.ios_share),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(
                text:
                    'Beta Home Demo Receipt\n${b.id}\n${b.property.name}\n${dateLabel(b.start)} – ${dateLabel(b.end)}\n${money(b.total)}\n${b.payment}\nNo real payment made.',
              ),
            );
            if (context.mounted) toast(context, 'Receipt copied');
          },
        ),
        const SizedBox(width: 12),
      ],
      children: [
        const Center(
          child: Icon(Icons.check_circle_outline, color: blue, size: 56),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'Reservation Confirmed',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 28),
        PropertyCard(b.property, compact: true),
        Panel(
          child: Column(
            children: [
              InfoRow('Booking ID', b.id),
              InfoRow('Name', s.name),
              InfoRow('Email', s.email),
              InfoRow(
                b.purchase ? 'Appointment' : 'Check In',
                dateLabel(b.start),
              ),
              if (!b.purchase) InfoRow('Check Out', dateLabel(b.end)),
              InfoRow('Payment Method', b.payment),
              if (b.appointmentTime.isNotEmpty)
                InfoRow('Visit Time', b.appointmentTime),
              if (b.note.isNotEmpty) InfoRow('Note', b.note),
              const Divider(),
              InfoRow('Total', money(b.total), highlight: true),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      70,
                      (i) => Container(
                        width: i % 3 == 0 ? 3 : 1,
                        height: 48,
                        color: Theme.of(context).colorScheme.onSurface,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'DEMO RECEIPT · NO REAL CHARGE',
                style: TextStyle(color: muted, fontSize: 11, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

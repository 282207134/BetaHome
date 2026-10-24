import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.preview = false});
  final bool preview;
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    if (!widget.preview) {
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) {
          resetTo(
            context,
            AppScope.of(context).onboarded ? '/welcome' : '/onboarding',
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.maps_home_work_outlined, size: 86, color: blue),
          SizedBox(height: 18),
          Text(
            'Beta Home',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12),
          Text('Find a place to call yours', style: TextStyle(color: muted)),
        ],
      ),
    ),
  );
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.initial = 0});
  final int initial;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late int index = widget.initial;
  void finish() {
    final s = AppScope.of(context);
    s.onboarded = true;
    s.changed();
    resetTo(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      "We're excited to have you on board and help you find your dream home",
      'Discover a place that feels like you',
      'Your next chapter starts with a new home',
    ];
    const bodies = [
      "Whether you're a first-time buyer, a seasoned investor, or just looking for a change, our app is here to make your search easier and more efficient.",
      'Explore beautiful homes, compare the details, and save the places you love. Your perfect space is waiting.',
      'Connect with owners, schedule a visit, and book your favorite property. We are with you every step of the way.',
    ];
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: SizedBox(
              width: double.infinity,
              child: AssetPhoto('onboard${index + 1}'),
            ),
          ),
          Expanded(
            flex: 5,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == index ? blue : pale,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      titles[index],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(bodies[index]),
                    const SizedBox(height: 30),
                    PrimaryButton(
                      index == 2 ? 'Get Started' : 'Next',
                      onPressed: () =>
                          index == 2 ? finish() : setState(() => index++),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: finish,
                        child: const Text('Skip'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .53,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AssetPhoto('welcome'),
                Container(color: Colors.black.withValues(alpha: .18)),
                const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.maps_home_work_outlined,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Beta Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Discover your dream house',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'A home for every new beginning',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  'Login with Email',
                  onPressed: () => go(context, '/login'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => go(context, '/register'),
                  child: const Text('Create an Account'),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    final s = AppScope.of(context);
                    s.signedIn = true;
                    s.onboarded = true;
                    s.changed();
                    resetTo(context, '/home');
                  },
                  child: const Text('Explore the local demo'),
                ),
                const Text(
                  'Find it. Love it. Make it home.',
                  style: TextStyle(color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage(this.mode, {super.key});
  final String mode;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool hidden = true, remember = true;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    final s = AppScope.of(context);
    switch (widget.mode) {
      case 'forgot':
        s.email = email.text.trim();
        go(context, '/otp');
      case 'reset':
        resetTo(context, '/password-success');
      case 'register':
        s.email = email.text.trim();
        go(context, '/setup-profile');
      default:
        s.email = email.text.trim();
        s.rememberSession = remember;
        s.signedIn = true;
        s.onboarded = true;
        s.changed();
        resetTo(context, '/home');
    }
  }

  Widget field(
    String label,
    TextEditingController controller, {
    bool secret = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          key: ValueKey(label),
          obscureText: secret && hidden,
          keyboardType: secret
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          autofillHints: secret
              ? [AutofillHints.password]
              : [AutofillHints.email],
          decoration: InputDecoration(
            hintText: secret ? 'Type your password' : 'example@yourdomain.com',
            prefixIcon: Icon(secret ? Icons.lock_outline : Icons.mail_outline),
            suffixIcon: secret
                ? IconButton(
                    tooltip: 'Show password',
                    onPressed: () => setState(() => hidden = !hidden),
                    icon: Icon(
                      hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: muted,
                    ),
                  )
                : null,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return '$label is required';
            if (!secret &&
                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) {
              return 'Enter a valid email';
            }
            if (secret && v.length < 6) return 'Use at least 6 characters';
            if (label == 'Confirm Password' && v != password.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final register = widget.mode == 'register',
        forgot = widget.mode == 'forgot',
        reset = widget.mode == 'reset';
    return AppPage(
      title: '',
      children: [
        Text(
          forgot
              ? 'Forgot Password'
              : reset
              ? 'Create New\nPassword'
              : register
              ? 'Create Your\nAccount'
              : 'Login Your\nAccount',
          style: const TextStyle(
            fontSize: 32,
            height: 1.15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 28),
        if (forgot) ...[
          const Text(
            'Enter your email address to receive a verification code.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 26),
        ],
        Form(
          key: form,
          child: Column(
            children: [
              if (!reset) field('Email', email),
              if (!forgot) field('Password', password, secret: true),
              if (register || reset)
                field('Confirm Password', confirm, secret: true),
            ],
          ),
        ),
        if (!forgot && !reset && !register)
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Checkbox(
                  value: remember,
                  onChanged: (v) => setState(() => remember = v!),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Remember me', style: TextStyle(fontSize: 12)),
              const Spacer(),
              TextButton(
                onPressed: () => go(context, '/forgot'),
                child: const Text(
                  'Forgot Password',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        PrimaryButton(
          forgot
              ? 'Send Code'
              : reset
              ? 'Save New Password'
              : register
              ? 'Sign Up'
              : 'Login',
          onPressed: submit,
        ),
        const SizedBox(height: 20),
        const Text(
          'Local demo · use any valid email and a password of 6+ characters.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: muted),
        ),
        if (!forgot && !reset) ...[
          const SizedBox(height: 28),
          const Center(
            child: Text('or continue with', style: TextStyle(color: blue)),
          ),
          const SizedBox(height: 22),
          for (final provider in ['Google', 'Apple']) ...[
            OutlinedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text('$provider sign-in'),
                  content: const Text(
                    'Social sign-in requires a connected identity service. You can explore this local demo using email or guest access.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    provider == 'Google' ? Icons.g_mobiledata : Icons.apple,
                    size: 30,
                  ),
                  Expanded(
                    child: Text(
                      'Sign in with $provider',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          TextButton(
            onPressed: () => go(context, register ? '/login' : '/register'),
            child: Text(
              register
                  ? 'Already have an account? Login'
                  : "Don't have an account? Sign Up",
            ),
          ),
        ],
      ],
    );
  }
}

class CodePage extends StatefulWidget {
  const CodePage(this.mode, {super.key});
  final String mode;
  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  final code = TextEditingController();
  String? error;
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otp = widget.mode == 'otp', setup = widget.mode == 'setup';
    final expected = otp ? '123456' : '1234';
    return AppPage(
      title: otp
          ? 'Verification'
          : setup
          ? 'Create Your PIN'
          : 'Enter Your PIN',
      children: [
        const SizedBox(height: 42),
        Icon(
          otp ? Icons.mark_email_read_outlined : Icons.lock_outline,
          color: blue,
          size: 74,
        ),
        const SizedBox(height: 30),
        Text(
          otp
              ? 'We sent a verification code to\n${AppScope.of(context).email}'
              : setup
              ? 'Use demo PIN 1234 to complete your profile.'
              : 'Confirm your demo booking with your PIN.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        TextField(
          key: const ValueKey('code'),
          controller: code,
          textAlign: TextAlign.center,
          obscureText: !otp,
          maxLength: otp ? 6 : 4,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 30, letterSpacing: 18),
          decoration: InputDecoration(
            counterText: '',
            hintText: otp ? '------' : '----',
            errorText: error,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Demo ${otp ? 'code' : 'PIN'}: $expected',
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 36),
        PrimaryButton(
          'Continue',
          onPressed: () {
            if (code.text != expected) {
              setState(() => error = 'Use the demo code $expected');
              return;
            }
            if (otp) {
              go(context, '/reset');
            } else if (setup) {
              final s = AppScope.of(context);
              s.signedIn = true;
              s.onboarded = true;
              s.changed();
              resetTo(context, '/profile-success');
            } else {
              AppScope.of(context).confirmBooking();
              resetTo(context, '/booking-success');
            }
          },
        ),
        if (otp)
          TextButton(
            onPressed: () => toast(context, 'Demo verification code: 123456'),
            child: const Text('Resend Code'),
          ),
      ],
    );
  }
}

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key, this.setup = false});
  final bool setup;
  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final form = GlobalKey<FormState>();
  final controllers = List.generate(4, (_) => TextEditingController());
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final s = AppScope.of(context);
      final values = [s.name, s.email, s.phone, s.address];
      for (var i = 0; i < 4; i++) {
        controllers[i].text = values[i];
      }
      initialized = true;
    }
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: widget.setup ? 'Fill Your Profile' : 'Edit Profile',
    bottom: PrimaryButton(
      widget.setup ? 'Continue' : 'Save Changes',
      onPressed: () {
        if (!form.currentState!.validate()) return;
        final s = AppScope.of(context);
        s.name = controllers[0].text.trim();
        s.email = controllers[1].text.trim();
        s.phone = controllers[2].text.trim();
        s.address = controllers[3].text.trim();
        s.changed();
        if (widget.setup) {
          go(context, '/setup-pin');
        } else {
          Navigator.pop(context);
        }
      },
    ),
    children: [
      const Center(child: Avatar(size: 100)),
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
                key: ValueKey('profile-$i'),
                keyboardType: [
                  TextInputType.name,
                  TextInputType.emailAddress,
                  TextInputType.phone,
                  TextInputType.streetAddress,
                ][i],
                decoration: InputDecoration(
                  labelText: [
                    'Full Name',
                    'Email',
                    'Phone Number',
                    'Address',
                  ][i],
                  prefixIcon: Icon(
                    [
                      Icons.person_outline,
                      Icons.mail_outline,
                      Icons.phone_outlined,
                      Icons.location_on_outlined,
                    ][i],
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (i == 1 && !v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class SuccessPage extends StatelessWidget {
  const SuccessPage(this.kind, {super.key});
  final String kind;
  @override
  Widget build(BuildContext context) {
    final booking = kind == 'booking', password = kind == 'password';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(38),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: blue.withValues(alpha: .1),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: blue,
                  size: 100,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                booking
                    ? 'Booking Successful!'
                    : password
                    ? 'Password Updated!'
                    : 'You are all set!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                booking
                    ? 'Your demo reservation is confirmed. You can find all the details in your e-receipt.'
                    : password
                    ? 'Your demo password reset flow is complete. Continue to log in.'
                    : 'Your profile is ready. Let us find your dream home.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 16),
              ),
              const SizedBox(height: 44),
              PrimaryButton(
                booking
                    ? 'View E-Receipt'
                    : password
                    ? 'Back to Login'
                    : 'Explore Homes',
                onPressed: () => resetTo(
                  context,
                  booking
                      ? '/receipt'
                      : password
                      ? '/login'
                      : '/home',
                ),
              ),
              if (booking)
                TextButton(
                  onPressed: () => resetTo(context, '/home'),
                  child: const Text('Back to Home'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

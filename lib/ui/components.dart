import 'package:flutter/material.dart';

import '../domain/models.dart';
import '../state/app_state.dart';
import 'theme.dart';

void go(BuildContext context, String route) =>
    Navigator.pushNamed(context, route);
void resetTo(BuildContext context, String route) =>
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

class AssetPhoto extends StatelessWidget {
  const AssetPhoto(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });
  final String name;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/$name.png',
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
    ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.index = 1, this.size = 52});
  final int index;
  final double size;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: AssetPhoto('avatar$index', width: size, height: size),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 22), const SizedBox(width: 10)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    ),
  );
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.children,
    this.bottom,
    this.actions,
    this.tab,
    this.leading,
    this.padding = 24,
  });
  final String title;
  final List<Widget> children;
  final Widget? bottom, leading;
  final List<Widget>? actions;
  final int? tab;
  final double padding;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading:
          leading ??
          (tab == null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: null),
                  tooltip: 'Back',
                  onPressed: () => Navigator.maybePop(context),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Icon(
                    [
                      Icons.home_outlined,
                      Icons.explore_outlined,
                      Icons.chat_bubble_outline,
                      Icons.person_outline,
                    ][tab!],
                    color: blue,
                  ),
                )),
      title: Text(title),
      actions: actions ?? [const SizedBox(width: 16)],
    ),
    body: Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(
            padding,
            20,
            padding,
            tab != null ? 120 : 24,
          ),
          children: children,
        ),
        if (tab != null)
          Positioned(bottom: 20, left: 24, right: 24, child: BottomNav(tab!)),
      ],
    ),
    bottomNavigationBar: bottom == null ? null : BottomAction(bottom!),
  );
}

class BottomAction extends StatelessWidget {
  const BottomAction(this.child, {super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    ),
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
    child: SafeArea(top: false, child: child),
  );
}

class BottomNav extends StatelessWidget {
  const BottomNav(this.index, {super.key});
  final int index;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: dark ? pale : const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          4,
          (i) => IconButton(
            tooltip: ['Home', 'Explore', 'Message', 'Profile'][i],
            onPressed: () {
              if (i != index) {
                resetTo(
                  context,
                  ['/home', '/explore', '/messages', '/profile'][i],
                );
              }
            },
            icon: Icon(
              [
                Icons.home_outlined,
                Icons.search,
                Icons.chat_bubble_outline,
                Icons.person_outline,
              ][i],
              color: i == index ? blue : (dark ? Colors.black : Colors.white),
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        if (action != null)
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(action!, style: const TextStyle(fontSize: 14)),
            ),
          ),
      ],
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.filled = false,
    this.padding = 18,
  });
  final Widget child;
  final bool filled;
  final double padding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Material(
      color: filled
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        side: filled
            ? BorderSide.none
            : BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1.5,
              ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    ),
  );
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.highlight = false});
  final String label, value;
  final bool highlight;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: muted, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: highlight ? blue : null,
            ),
          ),
        ),
      ],
    ),
  );
}

class Tag extends StatelessWidget {
  const Tag(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(label, style: const TextStyle(color: blue, fontSize: 14)),
  );
}

class ChoiceRow extends StatelessWidget {
  const ChoiceRow(this.options, this.value, this.onChanged, {super.key});
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: options
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(s),
                selected: s == value,
                showCheckmark: false,
                selectedColor: blue,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                labelStyle: TextStyle(
                  color: s == value ? Colors.white : null,
                  fontSize: 14,
                ),
                side: BorderSide(
                  color: s == value
                      ? blue
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                onSelected: (_) => onChanged(s),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class PropertyCard extends StatelessWidget {
  const PropertyCard(
    this.property, {
    super.key,
    this.compact = false,
    this.onTap,
  });
  final Property property;
  final bool compact;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = property;
    void open() {
      s.select(p);
      go(context, '/detail');
    }

    if (compact) {
      return InkWell(
        onTap: onTap ?? open,
        borderRadius: BorderRadius.circular(16),
        child: Panel(
          padding: 10,
          child: Row(
            children: [
              AssetPhoto(p.image, width: 80, height: 80, radius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                p.priceLabel,
                style: const TextStyle(
                  color: blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? open,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.9,
                      child: AssetPhoto(p.image, radius: 15),
                    ),
                    Positioned(
                      right: 14,
                      top: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          tooltip: 'Favorite ${p.name}',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => s.toggleFavorite(p.id),
                          icon: Icon(
                            s.favorites.contains(p.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: s.favorites.contains(p.id)
                                ? blue
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Icon(Icons.star, size: 19, color: blue),
                          const SizedBox(width: 4),
                          const Text('4.7', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(p.address, style: const TextStyle(color: muted)),
                      const SizedBox(height: 10),
                      Tag(p.type),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.bed_outlined, size: 22),
                          Text('  ${p.beds}'),
                          const SizedBox(width: 22),
                          const Icon(Icons.bathtub_outlined, size: 21),
                          Text('  ${p.baths}'),
                          const Spacer(),
                          Text(
                            p.priceLabel,
                            style: const TextStyle(
                              color: blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(
    this.title,
    this.message, {
    super.key,
    this.icon = Icons.search_off,
  });
  final String title, message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 12),
    child: Column(
      children: [
        Icon(icon, color: blue, size: 64),
        const SizedBox(height: 22),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
      ],
    ),
  );
}

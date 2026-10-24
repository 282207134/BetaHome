import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, this.permission = false});
  final bool permission;
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int selected = 0;
  String city = 'San Francisco California';
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    if (widget.permission || !s.locationEnabled) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: blue.withValues(alpha: .08),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: blue,
                    size: 96,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Find homes around you',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Explore a curated neighborhood map and discover your next home nearby.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 16),
                ),
                const SizedBox(height: 36),
                PrimaryButton(
                  'Use Demo Location',
                  onPressed: () {
                    s.locationEnabled = true;
                    s.changed();
                    resetTo(context, '/explore');
                  },
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => resetTo(context, '/home'),
                  child: const Text('Maybe Later'),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Static neighborhood preview · GPS is not accessed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.white,
                  child: AssetPhoto('map', fit: BoxFit.fill),
                ),
              ),
              Positioned(
                top: 26,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: blue.withValues(alpha: .12),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location (within 10 km)',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              city,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Change location',
                        onPressed: () async {
                          final result = await showModalBottomSheet<String>(
                            context: context,
                            showDragHandle: true,
                            builder: (c) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final v in [
                                    'San Francisco California',
                                    'Solo Raya, Surakarta',
                                    'Sakura Street',
                                  ])
                                    ListTile(
                                      title: Text(v),
                                      onTap: () => Navigator.pop(c, v),
                                    ),
                                  const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      'Demo map remains an illustrated neighborhood.',
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (result != null && mounted) {
                            setState(() => city = result);
                          }
                        },
                        icon: const Icon(Icons.edit_location_alt_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              for (var i = 0; i < 6; i++)
                Positioned(
                  left: box.maxWidth * [.46, .61, .10, .48, .78, .1][i],
                  top: box.maxHeight * [.22, .34, .42, .50, .54, .63][i],
                  child: Semantics(
                    label: 'Select ${properties[i % 4].name}',
                    button: true,
                    child: GestureDetector(
                      onTap: () => setState(() => selected = i),
                      child: Container(
                        width: 56,
                        height: 60,
                        decoration: selected == i
                            ? BoxDecoration(
                                border: Border.all(color: blue, width: 3),
                                borderRadius: BorderRadius.circular(30),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 120,
                left: 24,
                right: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: PropertyCard(
                    properties[selected % 4],
                    compact: true,
                    onTap: () {
                      s.select(properties[selected % 4]);
                      go(context, '/detail');
                    },
                  ),
                ),
              ),
              const Positioned(
                bottom: 20,
                left: 24,
                right: 24,
                child: BottomNav(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

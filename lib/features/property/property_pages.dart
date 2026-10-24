import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class PropertyDetailPage extends StatelessWidget {
  const PropertyDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.selected;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                AspectRatio(aspectRatio: 1, child: AssetPhoto(p.image)),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Favorite',
                          onPressed: () => s.toggleFavorite(p.id),
                          icon: Icon(
                            s.favorites.contains(p.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Share',
                          onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (c) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SectionTitle('Share Property'),
                                    Text(p.name),
                                    Text(
                                      '${p.address}\n${p.priceLabel}',
                                      style: const TextStyle(color: muted),
                                    ),
                                    const SizedBox(height: 24),
                                    PrimaryButton(
                                      'Copy Property Details',
                                      icon: Icons.copy,
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text:
                                                '${p.name}\n${p.address}\n${p.priceLabel}\nBeta Home local demo',
                                          ),
                                        );
                                        if (c.mounted) {
                                          Navigator.pop(c);
                                          toast(
                                            context,
                                            'Property details copied',
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      p.priceLabel,
                      style: const TextStyle(
                        color: blue,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Tag(p.type),
                    const SizedBox(width: 14),
                    const Icon(Icons.star, color: blue, size: 20),
                    TextButton(
                      onPressed: () => go(context, '/reviews'),
                      child: const Text(
                        '4.7 (324 Reviews)',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _spec(Icons.bed_outlined, '${p.beds} beds'),
                    _spec(Icons.bathtub_outlined, '${p.baths} bath'),
                    _spec(Icons.open_in_full, '${p.area} sqft'),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const Avatar(index: 3, size: 60),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Falla',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 8),
                          Text('Owner'),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Message owner',
                      onPressed: () {
                        s.chatContact = 'Falla';
                        go(context, '/chat');
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                    ),
                    IconButton(
                      tooltip: 'Call owner',
                      onPressed: () {
                        s.chatContact = 'Falla';
                        go(context, '/call');
                      },
                      icon: const Icon(Icons.phone_in_talk_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const SectionTitle('Overview'),
                Text(
                  '${p.name} is a welcoming space with thoughtfully designed rooms, natural light, and all the comforts of home. Enjoy a convenient location close to local restaurants, shops, and everyday essentials.',
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 26),
                const SectionTitle('Facilities'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: p.facilities
                      .map(
                        (f) => Chip(
                          avatar: Icon(_facilityIcon(f), color: blue, size: 18),
                          label: Text(f, style: const TextStyle(fontSize: 13)),
                          side: BorderSide.none,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 26),
                SectionTitle(
                  'Gallery',
                  action: 'View all',
                  onTap: () => go(context, '/gallery'),
                ),
                Row(
                  children: [
                    for (final image in ['interior1', 'interior2', 'interior3'])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => go(context, '/gallery'),
                            child: AssetPhoto(image, height: 100, radius: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 26),
                const SectionTitle('Location'),
                Text(p.address, style: const TextStyle(color: muted)),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => go(context, '/explore'),
                  child: const SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: ColoredBox(
                      color: Colors.white,
                      child: AssetPhoto('map', radius: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    s.purchase = true;
                    go(context, '/purchase-method');
                  },
                  child: const Text(
                    'Interested in buying? Explore purchase options',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        PrimaryButton(
          'Booking Now · ${p.priceLabel}',
          icon: Icons.shopping_cart_outlined,
          onPressed: () {
            s.purchase = false;
            go(context, '/purchase-method');
          },
        ),
      ),
    );
  }

  Widget _spec(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: blue, size: 22),
      const SizedBox(width: 7),
      Text(text, style: const TextStyle(fontSize: 13)),
    ],
  );
}

IconData _facilityIcon(String f) => switch (f) {
  'Parking' => Icons.local_parking,
  'Wi-Fi' => Icons.wifi,
  'Gym' => Icons.fitness_center,
  'Swimming Pool' => Icons.pool,
  'Garden' => Icons.park_outlined,
  _ => Icons.check_circle_outline,
};

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Gallery',
    children: [
      for (final row in [
        ['interior1', 'interior2'],
        ['interior3'],
        [AppScope.of(context).selected.image, 'interior1'],
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: row
                .map(
                  (name) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (c) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(12),
                            child: Stack(
                              children: [
                                InteractiveViewer(
                                  child: AssetPhoto(name, fit: BoxFit.contain),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(c),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        child: AssetPhoto(
                          name,
                          height: row.length == 1 ? 245 : 180,
                          radius: 16,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
    ],
  );
}

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Reviews',
    children: [
      const Panel(
        filled: true,
        child: Row(
          children: [
            Text(
              '4.7',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('★★★★★', style: TextStyle(color: blue, fontSize: 24)),
                  Text('Based on 324 reviews', style: TextStyle(color: muted)),
                ],
              ),
            ),
          ],
        ),
      ),
      for (var i = 0; i < 5; i++)
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Avatar(index: i + 1, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      contacts[i],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Text('★ 4.8', style: TextStyle(color: blue)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                [
                  'A beautiful place with lots of natural light. The owner made everything easy.',
                  'Very comfortable and close to everything we needed.',
                  'Clean rooms, thoughtful details, and a lovely neighborhood.',
                ][i % 3],
              ),
              const SizedBox(height: 12),
              const Text(
                'Verified stay · 2 weeks ago',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
    ],
  );
}

import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 120),
              children: [
                Row(
                  children: [
                    const Avatar(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 5),
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: muted,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'San Francisco',
                                style: TextStyle(color: muted, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Favorites',
                      onPressed: () => go(context, '/favorites'),
                      icon: const Icon(Icons.favorite_border),
                    ),
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => go(context, '/notifications'),
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SearchBox(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (i) {
                    const labels = ['Apartment', 'Boarding', 'House', 'Villa'];
                    return InkWell(
                      onTap: () {
                        s.filter = PropertyFilter(type: labels[i]);
                        s.query = '';
                        s.changed();
                        go(context, '/list');
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              [
                                Icons.apartment_outlined,
                                Icons.holiday_village_outlined,
                                Icons.home_outlined,
                                Icons.villa_outlined,
                              ][i],
                              color: blue,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(labels[i], style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 26),
                SectionTitle(
                  'Recommendation',
                  action: 'View all',
                  onTap: () {
                    s.filter = const PropertyFilter();
                    s.query = '';
                    s.changed();
                    go(context, '/list');
                  },
                ),
                ...properties.map((p) => PropertyCard(p)),
              ],
            ),
            const Positioned(
              bottom: 20,
              left: 24,
              right: 24,
              child: BottomNav(0),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});
  @override
  Widget build(BuildContext context) => TextField(
    readOnly: true,
    onTap: () => go(context, '/search'),
    decoration: InputDecoration(
      hintText: 'Search',
      prefixIcon: const Icon(Icons.search, color: blue),
      suffixIcon: IconButton(
        tooltip: 'Filter',
        onPressed: () => go(context, '/filter'),
        icon: const Icon(Icons.filter_list, color: blue),
      ),
    ),
  );
}

class ListingPage extends StatefulWidget {
  const ListingPage({super.key, this.favorite = false, this.search = false});
  final bool favorite, search;
  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  String sort = 'Recommended';
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final items = widget.favorite
        ? properties.where((p) => s.favorites.contains(p.id)).toList()
        : s.results(sort: sort);
    if (widget.favorite && sort == 'Name') {
      items.sort((a, b) => a.name.compareTo(b.name));
    }
    if (widget.favorite && sort.startsWith('Price:')) {
      items.sort(
        (a, b) => sort.contains('low')
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price),
      );
    }
    return AppPage(
      title: widget.favorite
          ? 'My Favorites'
          : widget.search
          ? 'Search Results'
          : 'List Real Estate',
      actions: [
        IconButton(
          tooltip: 'Sort by',
          onPressed: () async {
            final result = await showModalBottomSheet<String>(
              context: context,
              showDragHandle: true,
              builder: (c) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final option in [
                      'Recommended',
                      'Price: low to high',
                      'Price: high to low',
                      'Name',
                    ])
                      ListTile(
                        title: Text(option),
                        trailing: option == sort
                            ? const Icon(Icons.check, color: blue)
                            : null,
                        onTap: () => Navigator.pop(c, option),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
            if (result != null && mounted) setState(() => sort = result);
          },
          icon: const Icon(Icons.sort),
        ),
        const SizedBox(width: 12),
      ],
      children: [
        if (!widget.favorite) ...[
          const SearchBox(),
          const SizedBox(height: 24),
        ],
        SectionTitle(
          widget.favorite
              ? '${items.length} saved homes'
              : '${items.length} properties found',
          action: sort,
        ),
        if (items.isEmpty)
          EmptyState(
            widget.favorite ? 'Your favorites live here' : 'No homes found',
            widget.favorite
                ? 'Tap a heart on a property to save it for later.'
                : 'Try a different location or adjust your filters.',
            icon: widget.favorite ? Icons.favorite_border : Icons.search_off,
          ),
        ...items.map((p) => PropertyCard(p)),
        if (!widget.favorite && items.isEmpty)
          OutlinedButton(
            onPressed: () {
              s.filter = const PropertyFilter();
              s.query = '';
              s.changed();
            },
            child: const Text('Reset Search'),
          ),
      ],
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search(String text) {
    AppScope.of(context).search(text);
    go(context, '/results');
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AppPage(
      title: 'Search',
      children: [
        TextField(
          key: const ValueKey('search-input'),
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: search,
          decoration: InputDecoration(
            hintText: 'Search homes, cities, or neighborhoods',
            prefixIcon: const Icon(Icons.search, color: blue),
            suffixIcon: IconButton(
              tooltip: 'Search properties',
              onPressed: () => search(controller.text),
              icon: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
        const SizedBox(height: 30),
        SectionTitle(
          'Recent Searches',
          action: 'Clear all',
          onTap: () {
            s.recentSearches.clear();
            s.changed();
          },
        ),
        for (final text in s.recentSearches)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, color: muted),
            title: Text(text),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 19),
              onPressed: () {
                s.recentSearches.remove(text);
                s.changed();
              },
            ),
            onTap: () => search(text),
          ),
        const SizedBox(height: 20),
        const SectionTitle('Popular Searches'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              ['San Francisco', 'House', 'Apartment', 'Villa', 'Surakarta']
                  .map(
                    (v) =>
                        ActionChip(label: Text(v), onPressed: () => search(v)),
                  )
                  .toList(),
        ),
        const SizedBox(height: 32),
        const SectionTitle('A place you might love'),
        PropertyCard(properties[1], compact: true),
      ],
    );
  }
}

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  bool ready = false;
  String type = 'All', rental = 'All';
  RangeValues range = const RangeValues(0, 500);
  Set<String> selected = {};
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ready) {
      final f = AppScope.of(context).filter;
      type = f.type;
      rental = f.rental;
      range = RangeValues(f.min, f.max);
      selected = {...f.facilities};
      ready = true;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: blue,
    appBar: AppBar(
      backgroundColor: blue,
      foregroundColor: Colors.white,
      leading: IconButton(
        tooltip: 'Close filter',
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Filter', style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            type = 'All';
            rental = 'All';
            range = const RangeValues(0, 500);
            selected.clear();
          }),
          child: const Text('Reset', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Row(
            children: [
              _headerTag(type),
              const SizedBox(width: 12),
              _headerTag(rental),
              const SizedBox(width: 12),
              Expanded(
                child: _headerTag(
                  '\$${range.start.round()} – \$${range.end.round()}',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Buy Real Estate',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  secondary: const Icon(
                    Icons.real_estate_agent_outlined,
                    color: blue,
                  ),
                  value: rental == 'Buy',
                  onChanged: (v) => setState(() => rental = v ? 'Buy' : 'All'),
                ),
                const SizedBox(height: 16),
                const SectionTitle('Type Real Estate'),
                ChoiceRow(
                  const ['All', 'House', 'Apartment', 'Boarding', 'Villa'],
                  type,
                  (v) => setState(() => type = v),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Type Rental'),
                ChoiceRow(
                  const ['All', 'Daily', 'Monthly', 'Buy'],
                  rental,
                  (v) => setState(() => rental = v),
                ),
                const SizedBox(height: 28),
                const SectionTitle('Price Range'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 70,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      20,
                      (i) => Container(
                        width: (MediaQuery.sizeOf(context).width - 168) / 20,
                        height: <double>[
                          15.0,
                          24,
                          18,
                          32,
                          40,
                          58,
                          35,
                          62,
                          70,
                          48,
                        ][i % 10],
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        color: blue.withValues(
                          alpha: i > 3 && i < 15 ? .8 : .12,
                        ),
                      ),
                    ),
                  ),
                ),
                RangeSlider(
                  values: range,
                  min: 0,
                  max: 500,
                  divisions: 50,
                  labels: RangeLabels(money(range.start), money(range.end)),
                  onChanged: (v) => setState(() => range = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Tag(money(range.start)),
                    const Text('—'),
                    Tag(money(range.end)),
                  ],
                ),
                const SizedBox(height: 28),
                SectionTitle(
                  'Facility',
                  action: 'More Facilities',
                  onTap: () async {
                    final result = await Navigator.push<Set<String>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FacilityPage(initial: selected),
                      ),
                    );
                    if (result != null && mounted) {
                      setState(() => selected = result);
                    }
                  },
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: facilities
                      .take(6)
                      .map(
                        (f) => FilterChip(
                          label: Text(f),
                          selected: selected.contains(f),
                          onSelected: (v) => setState(() {
                            v ? selected.add(f) : selected.remove(f);
                          }),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: BottomAction(
      PrimaryButton(
        'Apply Filter',
        onPressed: () {
          final s = AppScope.of(context);
          s.filter = PropertyFilter(
            type: type,
            rental: rental,
            min: range.start,
            max: range.end,
            facilities: {...selected},
          );
          s.changed();
          Navigator.pushReplacementNamed(context, '/results');
        },
      ),
    ),
  );
  Widget _headerTag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.white, fontSize: 13),
    ),
  );
}

class FacilityPage extends StatefulWidget {
  const FacilityPage({super.key, this.initial = const {}});
  final Set<String> initial;
  @override
  State<FacilityPage> createState() => _FacilityPageState();
}

class _FacilityPageState extends State<FacilityPage> {
  late Set<String> selected = {...widget.initial};
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Facilities',
    bottom: PrimaryButton(
      'Apply',
      onPressed: () => Navigator.pop(context, selected),
    ),
    children: [
      const Text(
        'Make room for what matters to you.',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 20),
      for (final f in facilities)
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(f),
          value: selected.contains(f),
          onChanged: (v) => setState(() {
            v! ? selected.add(f) : selected.remove(f);
          }),
        ),
    ],
  );
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool unread = false;
  final read = <int>{};
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Notification',
    actions: [
      IconButton(
        tooltip: 'Unread only',
        onPressed: () => setState(() => unread = !unread),
        icon: Icon(unread ? Icons.filter_alt : Icons.filter_alt_outlined),
      ),
      const SizedBox(width: 14),
    ],
    children: [
      SectionTitle(
        unread ? 'Unread' : 'Today',
        action: 'Mark all read',
        onTap: () => setState(() => read.addAll([0, 1, 2, 3])),
      ),
      for (var i = 0; i < 4; i++)
        if (!unread || !read.contains(i))
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              onTap: () => setState(() => read.add(i)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: read.contains(i)
                  ? null
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: blue.withValues(alpha: .08),
                child: Icon(
                  [
                    Icons.home_outlined,
                    Icons.calendar_month_outlined,
                    Icons.favorite_border,
                    Icons.security_outlined,
                  ][i],
                  color: blue,
                ),
              ),
              title: Text(
                [
                  'Discover your dream home',
                  'Schedule a property visit',
                  'Your saved home is waiting',
                  'Welcome to Beta Home',
                ][i],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  [
                    'Explore new properties near you.',
                    'Meet the owner and see every detail.',
                    'Snow Apartment is available to book.',
                    'Your account is ready to explore.',
                  ][i],
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
              ),
              trailing: !read.contains(i)
                  ? const Icon(Icons.circle, size: 7, color: blue)
                  : null,
            ),
          ),
      if (unread && read.length == 4)
        const EmptyState(
          'All caught up',
          'You have read every notification.',
          icon: Icons.notifications_none,
        ),
    ],
  );
}

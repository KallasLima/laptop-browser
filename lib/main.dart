import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'theme.dart';
import 'widgets/laptop_art.dart';
import 'laptop_detail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'catalog.dart';

SemanticsHandle? _webSemantics;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep the small web app accessible without an invisible activation gesture.
  if (kIsWeb) _webSemantics ??= SemanticsBinding.instance.ensureSemantics();
  runApp(const LaptopApp());
}

class LaptopApp extends StatelessWidget {
  final CatalogRepository? repository;
  const LaptopApp({super.key, this.repository});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Laptop browser',
    debugShowCheckedModeBanner: false,
    theme: machineTheme(),
    home: CatalogPage(repository: repository),
  );
}

class CatalogPage extends StatefulWidget {
  final CatalogRepository? repository;
  const CatalogPage({super.key, this.repository});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final CatalogRepository repository;
  SharedPreferences? preferences;
  List<Laptop> items = [];
  Set<String> saved = {};
  bool loading = true, saving = false, savedOnly = false;
  String query = '', error = '';
  int generation = 0;
  @override
  void initState() {
    super.initState();
    repository = widget.repository ?? CatalogRepository();
    load();
  }

  Future<void> load() async {
    final current = ++generation;
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final values = await Future.wait<dynamic>([
        repository.load(),
        SharedPreferences.getInstance(),
      ]);
      if (!mounted || generation != current) return;
      preferences = values[1] as SharedPreferences;
      setState(() {
        items = values[0] as List<Laptop>;
        saved = (preferences!.getStringList('laptop_browser.saved.v1') ?? [])
            .toSet();
        loading = false;
      });
    } catch (_) {
      if (mounted && generation == current) {
        setState(() {
          loading = false;
          error =
              'We couldn’t load the catalog. Check your connection and try again.';
        });
      }
    }
  }

  Future<void> toggle(Laptop laptop) async {
    if (saving || preferences == null) return;
    final next = {...saved};
    next.contains(laptop.id) ? next.remove(laptop.id) : next.add(laptop.id);
    setState(() => saving = true);
    try {
      final ok = await preferences!.setStringList(
        'laptop_browser.saved.v1',
        next.toList(),
      );
      if (!ok) throw Exception();
      if (mounted) setState(() => saved = next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn’t save your change. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    generation++;
    repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = items
        .where(
          (x) =>
              (!savedOnly || saved.contains(x.id)) &&
              ('${x.title} ${x.description}').toLowerCase().contains(
                query.trim().toLowerCase(),
              ),
        )
        .toList();
    void open(Laptop laptop) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaptopDetail(
          laptop: laptop,
          index: items.indexOf(laptop),
          isSaved: () => saved.contains(laptop.id),
          toggle: () => toggle(laptop),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: const Text(
          'FORM',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22),
            child: Center(
              child: Text(
                repository.isDemo ? 'Offline demo' : 'Catalog API',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavItem(
              label: 'Browse',
              icon: Icons.layers_outlined,
              selected: !savedOnly,
              tap: () => setState(() => savedOnly = false),
            ),
            _NavItem(
              label: 'Saved (${saved.length})',
              icon: Icons.bookmark_border,
              selected: savedOnly,
              tap: () => setState(() => savedOnly = true),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 44),
                        const SizedBox(height: 18),
                        Text(error, textAlign: TextAlign.center),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: load,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              savedOnly
                                  ? 'Your saved\nmachines.'
                                  : 'Find your next\nmachine.',
                              style: const TextStyle(
                                fontSize: 44,
                                height: 1.02,
                                color: ink,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.7,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Search laptops',
                                hintText: 'Search laptops',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) =>
                                  setState(() => query = value),
                            ),
                            const SizedBox(height: 18),
                            if (!savedOnly &&
                                query.trim().isEmpty &&
                                items.isNotEmpty)
                              Semantics(
                                button: true,
                                label: 'View ${items.first.title}',
                                child: InkWell(
                                  onTap: () => open(items.first),
                                  child: SizedBox(
                                    height: 205,
                                    width: double.infinity,
                                    child: LaptopArt(
                                      index: 0,
                                      productId: items.first.id,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              '${filtered.length} ${filtered.length == 1 ? 'laptop' : 'laptops'} · USD${repository.isDemo ? ' · Fictional products' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: muted,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    if (filtered.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                savedOnly
                                    ? Icons.bookmark_border
                                    : Icons.search_off,
                                color: accent,
                                size: 42,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                savedOnly
                                    ? 'Nothing saved here yet.'
                                    : 'No laptops match your search.',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Explore the catalog or try another search.',
                                style: TextStyle(color: muted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        sliver: SliverList.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final laptop = filtered[index];
                            return LaptopCard(
                              laptop: laptop,
                              index: items.indexOf(laptop),
                              saved: saved.contains(laptop.id),
                              onTap: () => open(laptop),
                            );
                          },
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: Text(
                          'Saved on this device. No orders or checkout.',
                          style: TextStyle(color: muted, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback tap;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.tap,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: tap,
        child: ColoredBox(
          color: selected ? accent : ink,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 25),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class LaptopCard extends StatelessWidget {
  final Laptop laptop;
  final int index;
  final bool saved;
  final VoidCallback onTap;
  const LaptopCard({
    super.key,
    required this.laptop,
    required this.index,
    required this.saved,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: rule)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 65,
                child: LaptopArt(index: index, productId: laptop.id),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      laptop.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        letterSpacing: -.5,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      [
                            laptop.display,
                            laptop.memory,
                            laptop.storage,
                          ].whereType<String>().join(' · ').isNotEmpty
                          ? [
                              laptop.display,
                              laptop.memory,
                              laptop.storage,
                            ].whereType<String>().join(' · ')
                          : laptop.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    laptop.priceLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ink,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Icon(
                    saved ? Icons.bookmark : Icons.arrow_forward,
                    color: saved ? accent : ink,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

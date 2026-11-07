import 'theme.dart';
import 'widgets/laptop_art.dart';
import 'laptop_detail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'catalog.dart';

void main() => runApp(const LaptopApp());

class LaptopApp extends StatelessWidget {
  final CatalogRepository? repository;
  const LaptopApp({super.key, this.repository});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Laptop browser',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, surface: paper),
      scaffoldBackgroundColor: paper,
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.laptop_mac, size: 23),
            SizedBox(width: 10),
            Text(
              'FORM',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Chip(
              label: Text(
                repository.isDemo ? 'Offline demo' : 'Catalog API',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: savedOnly ? 1 : 0,
        onDestinationSelected: (i) => setState(() => savedOnly = i == 1),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            selectedIcon: const Icon(Icons.bookmark),
            label: 'Saved (${saved.length})',
          ),
        ],
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
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              savedOnly
                                  ? 'YOUR SHORTLIST'
                                  : 'TOOLS FOR YOUR NEXT IDEA',
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 2,
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              savedOnly
                                  ? 'Worth a second look.'
                                  : 'Find your everyday fit.',
                              style: const TextStyle(
                                fontSize: 32,
                                height: 1.15,
                                fontWeight: FontWeight.w500,
                                color: ink,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Explore a small collection. Save the ones that suit you.',
                              style: TextStyle(
                                color: Color(0xff536b64),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search laptops',
                                labelText: 'Search laptops',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) =>
                                  setState(() => query = value),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '${filtered.length} laptops · USD${repository.isDemo ? ' · Fictional products' : ''}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xff536b64),
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                size: 40,
                                color: accent,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                savedOnly
                                    ? 'Nothing saved here yet.'
                                    : 'No laptops match your search.',
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Explore the catalog or try another search.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.crossAxisExtent > 780
                                ? 3
                                : constraints.crossAxisExtent > 520
                                ? 2
                                : 1;
                            return SliverGrid(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final laptop = filtered[index];
                                return LaptopCard(
                                  laptop: laptop,
                                  index: items.indexOf(laptop),
                                  saved: saved.contains(laptop.id),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LaptopDetail(
                                        laptop: laptop,
                                        index: items.indexOf(laptop),
                                        isSaved: () =>
                                            saved.contains(laptop.id),
                                        toggle: () => toggle(laptop),
                                      ),
                                    ),
                                  ),
                                );
                              }, childCount: filtered.length),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: cols,
                                    mainAxisExtent: 304,
                                    crossAxisSpacing: 18,
                                    mainAxisSpacing: 18,
                                  ),
                            );
                          },
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'A catalog to explore, with favorites stored on this device.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xff536b64),
                          ),
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
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: LaptopArt(index: index)),
                if (saved)
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(Icons.bookmark, color: accent),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  laptop.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  laptop.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff536b64),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      laptop.priceLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 18, color: accent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

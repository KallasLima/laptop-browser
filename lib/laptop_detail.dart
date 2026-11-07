import 'package:flutter/material.dart';
import 'catalog.dart';
import 'theme.dart';
import 'widgets/laptop_art.dart';

class LaptopDetail extends StatefulWidget {
  final Laptop laptop;
  final int index;
  final bool Function() isSaved;
  final Future<void> Function() toggle;
  const LaptopDetail({
    super.key,
    required this.laptop,
    required this.index,
    required this.isSaved,
    required this.toggle,
  });
  @override
  State<LaptopDetail> createState() => _LaptopDetailState();
}

class _LaptopDetailState extends State<LaptopDetail> {
  bool busy = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Laptop details')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(
              height: 260,
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: LaptopArt(
                  index: widget.index,
                  productId: widget.laptop.id,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              widget.laptop.title,
              style: const TextStyle(
                fontSize: 42,
                color: ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.laptop.priceLabel} USD',
              style: const TextStyle(fontSize: 22, color: accent),
            ),
            const SizedBox(height: 24),
            const Text(
              'SPECIFICATIONS',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.laptop.description,
              style: const TextStyle(fontSize: 16, height: 1.65, color: muted),
            ),
            if (widget.laptop.display != null ||
                widget.laptop.memory != null ||
                widget.laptop.storage != null) ...[
              const SizedBox(height: 25),
              const Divider(color: rule),
              Wrap(
                spacing: 28,
                runSpacing: 18,
                children: [
                  for (final spec in [
                    ['DISPLAY', widget.laptop.display],
                    ['MEMORY', widget.laptop.memory],
                    ['STORAGE', widget.laptop.storage],
                  ])
                    if (spec[1] != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spec[0]!,
                            style: const TextStyle(color: muted, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            spec[1]!,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                ],
              ),
              const Divider(color: rule),
            ],
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      setState(() => busy = true);
                      await widget.toggle();
                      if (mounted) setState(() => busy = false);
                    },
              icon: Icon(
                widget.isSaved() ? Icons.bookmark : Icons.bookmark_border,
              ),
              label: Text(
                busy
                    ? 'Saving…'
                    : widget.isSaved()
                    ? 'Remove from saved'
                    : 'Save laptop',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Saved items stay on this device. This catalog does not process orders.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      ),
    ),
  );
}

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
                borderRadius: BorderRadius.circular(20),
                child: LaptopArt(index: widget.index),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              widget.laptop.title,
              style: const TextStyle(
                fontSize: 32,
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.laptop.priceLabel} USD',
              style: const TextStyle(fontSize: 22, color: accent),
            ),
            const SizedBox(height: 24),
            const Text(
              'THE DETAILS',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.laptop.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.65,
                color: Color(0xff60746e),
              ),
            ),
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
              style: TextStyle(fontSize: 12, color: Color(0xff536b64)),
            ),
          ],
        ),
      ),
    ),
  );
}

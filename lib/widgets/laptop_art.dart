import 'package:flutter/material.dart';
import '../theme.dart';

class LaptopArt extends StatelessWidget {
  final int index;
  final String? productId;
  const LaptopArt({super.key, required this.index, this.productId});
  static const products = {
    'atlas-14',
    'studio-16',
    'roam-13',
    'workshop-15',
    'field-14',
    'canvas-16',
  };
  @override
  Widget build(BuildContext context) => products.contains(productId)
      ? Image.asset(
          'assets/machines/$productId.webp',
          fit: BoxFit.contain,
          semanticLabel: 'Illustrative laptop render',
          errorBuilder: (_, error, stack) => const Center(
            child: Icon(Icons.laptop_mac, color: accent, size: 80),
          ),
        )
      : const Center(child: Icon(Icons.laptop_mac, color: accent, size: 80));
}

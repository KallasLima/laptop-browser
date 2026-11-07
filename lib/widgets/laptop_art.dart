import 'package:flutter/material.dart';
import '../theme.dart';

class LaptopArt extends StatelessWidget {
  final int index;
  const LaptopArt({super.key, required this.index});
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: [
      const Color(0xffe4ebe7),
      const Color(0xffeae3d7),
      const Color(0xffdce8e5),
    ][index % 3],
    child: CustomPaint(painter: _LaptopPainter(index)),
  );
}

class _LaptopPainter extends CustomPainter {
  final int index;
  _LaptopPainter(this.index);
  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / 320).clamp(0.0, 1.8);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + 6);
    canvas.scale(scale);
    final p = Paint();
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 48), width: 205, height: 14),
      p..color = Colors.black.withValues(alpha: .07),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-86, -55, 172, 104),
        const Radius.circular(6),
      ),
      p..color = ink,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-80, -49, 160, 91),
        const Radius.circular(2),
      ),
      p
        ..color = [
          const Color(0xff668b85),
          const Color(0xffa9957b),
          const Color(0xff6e9c91),
        ][index % 3],
    );
    canvas.drawCircle(
      const Offset(25, -15),
      26,
      p..color = Colors.white.withValues(alpha: .12),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-80, 42)
        ..lineTo(-80, 8)
        ..quadraticBezierTo(-15, -32, 80, 10)
        ..lineTo(80, 42)
        ..close(),
      p..color = Colors.white.withValues(alpha: .16),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-86, 49)
        ..lineTo(86, 49)
        ..lineTo(109, 57)
        ..quadraticBezierTo(113, 62, 100, 63)
        ..lineTo(-100, 63)
        ..quadraticBezierTo(-113, 62, -109, 57)
        ..close(),
      p..color = const Color(0xffa2afac),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-18, 50, 36, 3),
      p..color = const Color(0xff7b8c88),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LaptopPainter old) => old.index != index;
}

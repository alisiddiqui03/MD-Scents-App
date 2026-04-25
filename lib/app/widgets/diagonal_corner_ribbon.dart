import 'dart:math' as math;
import 'package:flutter/material.dart';

class DiagonalCornerRibbon extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const DiagonalCornerRibbon({
    super.key,
    required this.text,
    this.color = const Color(0xFFD32F2F), // Deep Red
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: -32,
      child: Transform.rotate(
        angle: -math.pi / 4,
        child: Container(
          width: 110,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 6,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

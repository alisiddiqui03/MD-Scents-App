import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Small gold-style badge for VIP-only catalog items (VIP users only see these).
class VipExclusiveCornerBadge extends StatelessWidget {
  const VipExclusiveCornerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC9A227), Color(0xFFFFE082), Color(0xFFD4AF37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 11, color: Colors.brown.shade900),
          const SizedBox(width: 3),
          Text(
            'VIP Exclusive',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.brown.shade900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

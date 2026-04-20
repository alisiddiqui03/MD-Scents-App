import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MilestoneTrackerWidget extends StatelessWidget {
  const MilestoneTrackerWidget({
    super.key,
    required this.milestoneOrderCount,
    this.showLabels = true,
  });

  final int milestoneOrderCount;
  final bool showLabels;

  static const _milestones = <int>[1, 5, 10];

  @override
  Widget build(BuildContext context) {
    final count = milestoneOrderCount < 0 ? 0 : milestoneOrderCount;
    final next = _milestones.firstWhere(
      (m) => count < m,
      orElse: () => _milestones.last,
    );
    final remaining = (next - count).clamp(0, 999);
    final text = count >= _milestones.last
        ? 'All milestone rewards unlocked for this cycle.'
        : 'Order $remaining more to unlock next reward';
    final toFive = (5 - count).clamp(0, 999);
    final toTen = (10 - count).clamp(0, 999);
    final betweenText = count < 5
        ? '1 → 5: $toFive order${toFive == 1 ? '' : 's'} left'
        : '1 → 5: completed';
    final topText = count < 10
        ? '5 → 10: $toTen order${toTen == 1 ? '' : 's'} left'
        : '5 → 10: completed';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '90‑Day Milestones',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Qualifying orders ≥ PKR 10,000 (max 1 per 24h)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MilestoneRow(count: count, showLabels: showLabels),
          const SizedBox(height: 10),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  betweenText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.58),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  topText,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.58),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.count, required this.showLabels});

  final int count;
  final bool showLabels;

  static const _rewards = <int, String>{
    1: '+50 pts',
    5: '+100 pts',
    10: '+1000 pts',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _milestoneNode(step: 1, done: count >= 1, label: _rewards[1]),
        _line(done: count >= 5),
        _milestoneNode(step: 5, done: count >= 5, label: _rewards[5]),
        _line(done: count >= 10),
        _milestoneNode(step: 10, done: count >= 10, label: _rewards[10]),
      ],
    );
  }

  Widget _line({required bool done}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: done
              ? AppColors.accent.withValues(alpha: 0.9)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _milestoneNode({
    required int step,
    required bool done,
    required String? label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.accent : Colors.white,
            border: Border.all(
              color: done ? AppColors.accent : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: done
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$step',
              style: AppTextStyles.bodyMedium.copyWith(
                color: done ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 6),
          Text(
            label ?? '',
            style: AppTextStyles.bodyMedium.copyWith(
              color: done ? AppColors.accent : AppColors.textDark.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}


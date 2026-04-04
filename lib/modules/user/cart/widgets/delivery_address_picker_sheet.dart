import 'package:flutter/material.dart';

import '../../../../app/data/models/delivery_address.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Bottom sheet: saved addresses from Firestore (`users/{uid}/addresses`) or new address.
class DeliveryAddressPickerSheet extends StatefulWidget {
  final List<DeliveryAddress> savedAddresses;
  final int initialIndex;
  final void Function(DeliveryAddress address) onPickSaved;
  final void Function() onPickNew;

  const DeliveryAddressPickerSheet({
    super.key,
    required this.savedAddresses,
    required this.initialIndex,
    required this.onPickSaved,
    required this.onPickNew,
  });

  @override
  State<DeliveryAddressPickerSheet> createState() =>
      _DeliveryAddressPickerSheetState();
}

class _DeliveryAddressPickerSheetState
    extends State<DeliveryAddressPickerSheet> {
  late int _selected;

  /// Index of "New address" in the radio group.
  int get _newOptionIndex => widget.savedAddresses.length;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex.clamp(0, _newOptionIndex);
  }

  /// Popping during the tap handler can assert (!navigator._debugLocked). Defer.
  void _closeSheet() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final nav = Navigator.maybeOf(context);
      nav?.pop();
    });
  }

  void _applyAndClose(int index) {
    setState(() => _selected = index);
    if (index == _newOptionIndex) {
      widget.onPickNew();
    } else {
      widget.onPickSaved(widget.savedAddresses[index]);
    }
    _closeSheet();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    final sheetH = MediaQuery.of(context).size.height * 0.72;
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: sheetH,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Delivery address',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Choose a saved address from your account or enter a new one.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.55),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < widget.savedAddresses.length; i++) ...[
                        Builder(
                          builder: (context) {
                            final a = widget.savedAddresses[i];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: IgnorePointer(
                                child: Radio<int>(
                                  value: i,
                                  groupValue: _selected,
                                  onChanged: (_) {},
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      a.label,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (a.isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Default',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                '${a.fullName.isNotEmpty ? '${a.fullName}\n' : ''}'
                                '${a.phone}\n${a.street}${a.city.isNotEmpty ? ', ${a.city}' : ''}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textDark.withValues(
                                    alpha: 0.55,
                                  ),
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                              onTap: () => _applyAndClose(i),
                            );
                          },
                        ),
                        const Divider(height: 1),
                      ],
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: IgnorePointer(
                          child: Radio<int>(
                            value: _newOptionIndex,
                            groupValue: _selected,
                            onChanged: (_) {},
                            activeColor: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          'New address',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Clear fields and type a different delivery address.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                        onTap: () => _applyAndClose(_newOptionIndex),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _closeSheet,
                      child: const Text('Close'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => _applyAndClose(_selected),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Use selected'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

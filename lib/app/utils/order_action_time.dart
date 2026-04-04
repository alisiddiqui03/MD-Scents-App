/// Consistent date + time for order actions (snackbars, confirm screen, etc.).
String formatOrderActionTime([DateTime? t]) {
  final d = t ?? DateTime.now();
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day}/${d.month}/${d.year} · $hh:$mm';
}

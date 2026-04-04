import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared helpers so [Get.snackbar] works in debug & release (home tab, admin, etc.).
/// Same pattern for user cancel alerts and admin new-order alerts.

bool getSnackbarSurfaceReady() {
  if (Get.key.currentState?.overlay != null) return true;
  final ctx = Get.overlayContext;
  if (ctx != null && ctx.mounted) {
    return Overlay.maybeOf(ctx, rootOverlay: true) != null;
  }
  return false;
}

Future<void> waitOneFrame() {
  final c = Completer<void>();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!c.isCompleted) c.complete();
  });
  return c.future;
}

/// Calls [show] when overlay is ready, or after [maxFrames] with [show](true) as fallback
/// (skip internal overlay guard — last resort for release).
///
/// [show]: `skipOverlayGuard` is false when overlay was verified; true on fallback only.
Future<void> runWhenSnackbarSurfaceReady(
  void Function(bool skipOverlayGuard) show, {
  bool Function()? shouldAbort,
  int maxFrames = 120,
}) async {
  for (var i = 0; i < maxFrames; i++) {
    if (shouldAbort?.call() ?? false) return;
    if (getSnackbarSurfaceReady()) {
      show(false);
      return;
    }
    await waitOneFrame();
  }
  if (shouldAbort?.call() ?? false) return;
  show(true);
}

import 'package:flutter/material.dart';

class GlobalLoader {
  static final GlobalLoader _instance = GlobalLoader._internal();
  factory GlobalLoader() => _instance;

  OverlayEntry? _overlayEntry;

  GlobalLoader._internal();

  void show(BuildContext context) {
    if (_overlayEntry != null) return; // Prevent multiple overlays
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    if (overlayState != null) {
      overlayState.insert(_overlayEntry!);
    }
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

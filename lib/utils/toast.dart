import 'package:flutter/material.dart';

void showModernToast(BuildContext context, String message,
    {bool success = true, Duration duration = const Duration(seconds: 3)}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.1,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSlide(
          offset: const Offset(0, -1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero),
            duration: const Duration(milliseconds: 300),
            builder: (context, offset, child) => Transform.translate(
              offset: offset * 100, // slide anim
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: success ? Colors.green.shade600 : Colors.red.shade600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    success ? Icons.check_circle_outline : Icons.error_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}

import 'dart:async';
import 'package:flutter/material.dart';

class InactivityDialog extends StatefulWidget {
  final VoidCallback onExtendSession;
  final VoidCallback onTimeout;

  const InactivityDialog({
    Key? key,
    required this.onExtendSession,
    required this.onTimeout,
  }) : super(key: key);

  @override
  State<InactivityDialog> createState() => _InactivityDialogState();
}

class _InactivityDialogState extends State<InactivityDialog> {
  int countdown = 30;
  Timer? _dialogTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _dialogTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (countdown <= 1) {
        timer.cancel();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        widget.onTimeout();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _dialogTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔹 Dimmed overlay background for modal emphasis
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),

        // 🔹 Centered wide modal box
        Center(
          child: Container(
            width: 600, // ⬅️ wider for modal presence
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 🔹 Close button (top-right)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 28,
                    ),
                    onPressed: () {
                      _dialogTimer?.cancel();
                      Navigator.of(context).pop();
                      widget.onExtendSession();
                    },
                  ),
                ),

                // 🔹 Main content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      "We've noticed an inactivity",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Closing this session in $countdown seconds...",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          _dialogTimer?.cancel();
                          Navigator.of(context).pop();
                          widget.onExtendSession();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A306D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "Extend session",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

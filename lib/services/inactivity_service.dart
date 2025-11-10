import 'dart:async';
import 'package:flutter/material.dart';

/// Global singleton service for managing inactivity detection across the app
class InactivityService {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  static const Duration _inactivityTimeout = Duration(seconds: 120);

  Timer? _inactivityTimer;
  VoidCallback? _onTimeout;
  bool _isEnabled = false;

  /// Start the inactivity timer with a callback for when timeout occurs
  void start(VoidCallback onTimeout) {
    _onTimeout = onTimeout;
    _isEnabled = true;
    _resetTimer();
    debugPrint('🟢 [InactivityService] Started');
  }

  /// Stop and disable the inactivity timer
  void stop() {
    _isEnabled = false;
    _cancelTimer();
    _onTimeout = null;
    debugPrint('🔴 [InactivityService] Stopped');
  }

  /// Reset the timer (call this on user interaction)
  void resetTimer() {
    if (!_isEnabled) return;
    _resetTimer();
  }

  /// Temporarily disable timeout callback (e.g., when dialog is already shown)
  void suppressTimeout() {
    _cancelTimer();
    debugPrint('🔇 [InactivityService] Timeout suppressed');
  }

  /// Re-enable timeout callback after suppression
  void enableTimeout() {
    if (!_isEnabled) return;
    _resetTimer();
    debugPrint('🔊 [InactivityService] Timeout re-enabled');
  }

  void _resetTimer() {
    _cancelTimer();
    _inactivityTimer = Timer(_inactivityTimeout, () {
      debugPrint('⚠️ [InactivityService] Timeout reached');
      _onTimeout?.call();
    });
  }

  void _cancelTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  bool get isEnabled => _isEnabled;
}

/// Wrapper widget that automatically handles user interaction events
class InactivityDetector extends StatelessWidget {
  final Widget child;

  const InactivityDetector({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => InactivityService().resetTimer(),
      onPointerMove: (_) => InactivityService().resetTimer(),
      onPointerUp: (_) => InactivityService().resetTimer(),
      child: child,
    );
  }
}

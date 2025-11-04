// lib/widgets/dialog_terminal_payment.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum TerminalDialogState { waiting, success, error }

class TerminalDialogController {
  TerminalDialogController._(this.state, this.message, this._close);
  final ValueNotifier<TerminalDialogState> state;
  final ValueNotifier<String> message;
  final VoidCallback _close;
  bool _isClosed = false;

  void waiting([String? msg]) {
    if (msg != null) message.value = msg;
    state.value = TerminalDialogState.waiting;
  }

  void success([String? msg]) {
    if (msg != null) message.value = msg;
    state.value = TerminalDialogState.success;
  }

  void error([String? msg]) {
    if (msg != null) message.value = msg;
    state.value = TerminalDialogState.error;
  }

  void close() {
    if (_isClosed) return;
    _isClosed = true;
    _close();
  }
}

TerminalDialogController showUpdatableTerminalDialog(
  BuildContext context, {
  String initialMessage = 'Please confirm on the terminal…',
  Future<void> Function()? onCancel, // 👈 new
}) {
  final state = ValueNotifier<TerminalDialogState>(TerminalDialogState.waiting);
  final message = ValueNotifier<String>(initialMessage);
  final cancelling = ValueNotifier<bool>(false);

  void pop() {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
  }

  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (ctx) {
      final size = MediaQuery.of(ctx).size;
      return PopScope(
        canPop: false,
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.1, // ~80% width
            vertical: size.height * 0.08,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height * 0.45,
              maxHeight: size.height * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // animation
                  Center(
                    child: ValueListenableBuilder<TerminalDialogState>(
                      valueListenable: state,
                      builder: (_, s, __) {
                        switch (s) {
                          case TerminalDialogState.success:
                            return Lottie.asset(
                              'assets/animations/success.json',
                              repeat: false,
                              fit: BoxFit.contain,
                            );
                          case TerminalDialogState.error:
                            return Lottie.asset(
                              'assets/animations/error.json',
                              repeat: false,
                              fit: BoxFit.contain,
                            );
                          case TerminalDialogState.waiting:
                            return Lottie.asset(
                              'assets/animations/online-payment.json',
                              repeat: true,
                              frameRate: FrameRate.max,
                              fit: BoxFit.contain,
                            );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // message
                  ValueListenableBuilder<String>(
                    valueListenable: message,
                    builder: (_, msg, __) => Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // subtext + spinner only while waiting
                  ValueListenableBuilder<TerminalDialogState>(
                    valueListenable: state,
                    builder: (_, s, __) {
                      final isWaiting = s == TerminalDialogState.waiting;
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isWaiting ? 1 : 0,
                        child: Column(
                          children: const [
                            Text(
                              'Follow the prompts on the reader.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 24,
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
                  ),

                  // Buttons row: Cancel (if provided) shows during waiting
                  if (onCancel != null)
                    ValueListenableBuilder<TerminalDialogState>(
                      valueListenable: state,
                      builder: (_, s, __) {
                        if (s != TerminalDialogState.waiting)
                          return const SizedBox.shrink();
                        return ValueListenableBuilder<bool>(
                          valueListenable: cancelling,
                          builder: (_, isCancelling, __) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: isCancelling
                                    ? null
                                    : () async {
                                        cancelling.value = true;
                                        try {
                                          // Update UI while cancelling
                                          message.value = 'Cancelling…';
                                          await onCancel();
                                          // Show error state (since we aborted)
                                          state.value =
                                              TerminalDialogState.error;
                                          message.value = 'Payment cancelled';
                                          await Future.delayed(
                                            const Duration(milliseconds: 900),
                                          );
                                          pop();
                                        } catch (e) {
                                          state.value =
                                              TerminalDialogState.error;
                                          message.value = 'Cancel failed: $e';
                                          await Future.delayed(
                                            const Duration(milliseconds: 1200),
                                          );
                                          pop();
                                        }
                                      },
                                icon: isCancelling
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.close),
                                label: Text(
                                  isCancelling ? 'Cancelling…' : 'Cancel',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  return TerminalDialogController._(state, message, pop);
}

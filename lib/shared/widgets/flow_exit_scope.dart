import 'package:flutter/material.dart';

/// Guards terminal flow screens (success, completion) so Android/iOS system back
/// triggers the same exit action as the primary completion button.
class FlowExitScope extends StatelessWidget {
  const FlowExitScope({
    super.key,
    required this.onExit,
    required this.child,
    this.allowSystemPop = false,
  });

  final VoidCallback onExit;
  final Widget child;

  /// When true, system back pops normally instead of invoking [onExit].
  final bool allowSystemPop;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: allowSystemPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          onExit();
        }
      },
      child: child,
    );
  }
}

/// Blocks system back while an async operation is in progress.
class ProcessingBackGuard extends StatelessWidget {
  const ProcessingBackGuard({
    super.key,
    required this.isProcessing,
    required this.child,
  });

  final bool isProcessing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isProcessing,
      child: child,
    );
  }
}

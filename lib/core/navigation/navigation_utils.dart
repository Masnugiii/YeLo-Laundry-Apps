import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Returns whether the current route can navigate back.
bool canNavigateBack(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router != null) {
    return router.canPop();
  }
  return Navigator.of(context).canPop();
}

/// Pops the current route when possible.
void navigateBack(BuildContext context, [Object? result]) {
  final router = GoRouter.maybeOf(context);
  if (router != null && router.canPop()) {
    router.pop(result);
    return;
  }
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop(result);
  }
}

/// Pops with a flow result, used by terminal success screens so system back
/// matches the primary "Selesai" action.
void exitFlowWithResult(BuildContext context, Object? result) {
  if (context.canPop()) {
    context.pop(result);
  }
}

/// Pops repeatedly until the predicate returns true or the stack is empty.
void popUntilRoute(BuildContext context, bool Function(GoRouter) predicate) {
  final router = GoRouter.of(context);
  while (router.canPop() && !predicate(router)) {
    router.pop();
  }
}

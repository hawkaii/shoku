import 'package:flutter/foundation.dart';

/// The one place a failure the user cannot see is written down.
///
/// A `catch` that recovers still owes an account of what it recovered from:
/// without one, "the feed is empty" and "the feed endpoint is down" read the
/// same in a bug report. One greppable line, `what` first so the same failure
/// groups together.
///
/// Never throws — a logger that can fail is worse than the failure it reports —
/// and works in release as well as debug, because a swallowed failure is most
/// expensive in the build nobody is watching.
void logFailure(String what, Object error, [StackTrace? stack]) {
  try {
    final frame = _firstFrame(stack);
    debugPrint('[failure] $what: $error${frame == null ? '' : ' ($frame)'}');
  } catch (_) {
    // Logging is best-effort by definition; there is nowhere left to report.
  }
}

/// Only the top frame, so the line stays one line and still says where.
String? _firstFrame(StackTrace? stack) {
  if (stack == null) return null;
  for (final line in stack.toString().split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return null;
}

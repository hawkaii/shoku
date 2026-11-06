import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/failure_log.dart';
import '../../data/services/auth_service.dart';

/// The one auth object. It lives apart from the sync layer so a store that
/// needs to know "is there an account?" does not have to import the sync
/// wiring (and the cycle that would come with it).
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Opening the session, off the critical path of the first frame.
///
/// `Supabase.initialize` restores the stored session and may refresh it over
/// the network before it answers. The splash paints first; the shell — and the
/// journal store's "is there an account?" question — wait for this. A failure
/// is signed-out, which is a valid kitchen.
final authReadyProvider = FutureProvider<void>((ref) async {
  try {
    // Four seconds is generous for a local restore; a refresh that needs the
    // network is not something the splash should wait for.
    await AuthService.init().timeout(const Duration(seconds: 4));
  } catch (error, stack) {
    // No session, no network, or no plugin: signed out is a valid state, but a
    // signed-out user who had an account needs this line to explain why.
    logFailure('auth init', error, stack);
  }
});

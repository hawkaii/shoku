import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/auth_service.dart';

/// The one auth object. It lives apart from the sync layer so a store that
/// needs to know "is there an account?" does not have to import the sync
/// wiring (and the cycle that would come with it).
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Temporary provider returning hardcoded profile ID 1.
// Replace with real profile management when multi-profile support is added.
final activeProfileIdProvider = Provider<int?>((ref) {
  return 1;
});

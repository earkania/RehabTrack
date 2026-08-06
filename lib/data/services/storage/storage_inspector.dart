import 'package:flutter/services.dart';

/// Reports free storage on the filesystem hosting a given path.
///
/// On Android the value is read natively via `StatFs` (`freeBytes` method
/// channel), so temporary-sized operations can be gated on a conservative
/// estimate before they start writing. On non-Android platforms (or when the
/// platform channel is unavailable) a null is returned to signal "unknown",
/// which callers treat as "do not block on free space".
class StorageInspector {
  static const MethodChannel _channel =
      MethodChannel('com.earkania.rehabtrack/backup');

  const StorageInspector();

  /// Returns the number of free bytes on the filesystem that hosts [path], or
  /// null when the value cannot be determined.
  Future<int?> freeBytes(String path) async {
    try {
      return await _channel.invokeMethod<int>('freeBytes', {'path': path});
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
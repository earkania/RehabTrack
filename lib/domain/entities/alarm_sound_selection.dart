import 'dart:convert';

/// A user-selected Alarm-style alarm sound.
///
/// Holds the ringtone URI (the playback source for the native alarm player)
/// and the human-readable title resolved when the sound was picked. A null
/// selection means the system default alarm sound is used.
class AlarmSoundSelection {
  const AlarmSoundSelection({required this.uri, this.title});

  final String uri;
  final String? title;

  /// Parses the `{ "uri": ..., "title": ... }` JSON returned natively by the
  /// ringtone picker. Throws [FormatException] when the payload is malformed.
  factory AlarmSoundSelection.fromJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('AlarmSoundSelection JSON is not an object');
    }
    final map = decoded.cast<String, Object?>();
    final uri = map['uri'] as String?;
    if (uri == null || uri.isEmpty) {
      throw const FormatException('AlarmSoundSelection JSON has no uri');
    }
    return AlarmSoundSelection(uri: uri, title: map['title'] as String?);
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches the system dialer for a phone number. Never dials automatically.
Future<bool> launchCall(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  return launchUrl(uri);
}

/// Opens the default mail client addressed to [email]. Never sends
/// automatically.
Future<bool> launchEmail(String email) async {
  final uri = Uri(scheme: 'mailto', path: email);
  return launchUrl(uri);
}

/// Opens [website] in an external browser. Missing schemes are normalized to
/// https and invalid URLs are rejected safely.
Future<bool> launchWebsite(String website) async {
  final trimmed = website.trim();
  if (trimmed.isEmpty) return false;
  final normalized =
      trimmed.startsWith('http://') || trimmed.startsWith('https://')
      ? trimmed
      : 'https://$trimmed';
  final uri = Uri.tryParse(normalized);
  if (uri == null || (uri.host.isEmpty && uri.scheme != 'http' && uri.scheme != 'https')) {
    return false;
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Opens an address in a maps application. Uses a generic geo: URI when
/// possible and falls back to a browser search so it never depends on a
/// specific maps app being installed.
Future<bool> launchAddress(String address) async {
  final trimmed = address.trim();
  if (trimmed.isEmpty) return false;

  final encoded = Uri.encodeComponent(trimmed);
  final geoUri = Uri.tryParse('geo:0,0?q=$encoded');
  if (geoUri != null) {
    final handled = await launchUrl(geoUri);
    if (handled) return true;
  }

  final webUri =
      Uri.tryParse('https://www.google.com/maps/search/?api=1&query=$encoded');
  if (webUri == null) return false;
  return launchUrl(webUri, mode: LaunchMode.externalApplication);
}

/// Returns true when the given phone number looks usable.
bool hasPhone(String? value) => value != null && value.trim().isNotEmpty;

/// Returns true when the given email looks usable.
bool hasEmail(String? value) => value != null && value.trim().isNotEmpty;

/// Builds a mailto address string for a contact name + email.
String mailtoAddress({String? name, required String email}) {
  if (name != null && name.trim().isNotEmpty) {
    return '${name.trim()} <$email>';
  }
  return email;
}

/// Shows a snackbar when an external action cannot be opened.
void showActionFailed(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/presentation/utils/care_contact_localizer.dart';

/// Avatar for a care contact: photo when available, otherwise generated
/// initials (doctors use first/last name initials, organizations use
/// organization-name initials), otherwise the contact-type icon.
class CareContactAvatar extends StatelessWidget {
  final CareContact contact;
  final double radius;

  const CareContactAvatar({
    super.key,
    required this.contact,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: _backgroundColor(colorScheme),
      backgroundImage: _backgroundImage,
      child: _backgroundImage == null
          ? _buildFallback(colorScheme)
          : null,
    );
  }

  Widget _buildFallback(ColorScheme colorScheme) {
    final initials = contact.initials;
    final icon = CareContactLocalizer.typeIcon(contact.contactType);
    final fallbackStyle = TextStyle(
      fontSize: radius * 0.7,
      fontWeight: FontWeight.w600,
      color: colorScheme.onPrimary,
    );
    return contact.hasName
        ? Text(initials, style: fallbackStyle)
        : Icon(icon, size: radius, color: colorScheme.onPrimary);
  }

  ImageProvider? get _backgroundImage {
    final photoPath = contact.photoPath;
    if (photoPath == null) return null;
    final file = File(photoPath);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    final seed = contact.effectiveDisplayName.isNotEmpty
        ? contact.effectiveDisplayName
        : contact.contactType.name;
    final hash = seed.hashCode.abs();
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.5, 0.4).toColor();
  }
}

extension on CareContact {
  bool get hasName => initials != '?';
}

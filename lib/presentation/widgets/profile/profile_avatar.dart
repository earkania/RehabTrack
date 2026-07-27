import 'dart:io';

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoPath;
  final String? firstName;
  final String? lastName;
  final double radius;
  final bool isPrimary;

  const ProfileAvatar({
    super.key,
    this.photoPath,
    this.firstName,
    this.lastName,
    this.radius = 40,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: _backgroundColor(colorScheme),
          backgroundImage: _backgroundImage,
          child: _backgroundImage == null
              ? Text(
                  _initials,
                  style: TextStyle(
                    fontSize: radius * 0.8,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                )
              : null,
        ),
        if (isPrimary)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.star,
                size: radius * 0.35,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }

  String get _initials {
    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';
    if (first.isEmpty && last.isEmpty) return '?';
    return '$first$last'.toUpperCase();
  }

  ImageProvider? get _backgroundImage {
    if (photoPath == null) return null;
    final file = File(photoPath!);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    final name = '${firstName ?? ''}${lastName ?? ''}';
    if (name.isEmpty) return colorScheme.primary;
    final hash = name.hashCode.abs();
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.5, 0.4).toColor();
  }
}

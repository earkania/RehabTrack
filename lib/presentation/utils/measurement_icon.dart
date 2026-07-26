import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

IconData measurementIconForType(String? key) {
  return switch (key) {
    'blood_pressure' => Icons.monitor_heart,
    'pulse' => Icons.favorite,
    'weight' => Symbols.weight,
    'blood_glucose' => Icons.bloodtype,
    'spo2' => Icons.air,
    'temperature' => Icons.thermostat,
    _ => Icons.straighten,
  };
}

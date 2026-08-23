import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Icons for the compact circular toolbar buttons beside Search, shared by
/// the list screens (Activities, Diet, Lab Analyses, Doctor Prescriptions)
/// so every module renders identical category-filter and sort controls.
///
/// - Category filter: Google Material `filter_alt` (filter_alt_24).
/// - Sort: Google Material Symbols `list_arrow` (list_arrow_24). Flutter's
///   built-in [Icons] class does not expose this newer symbol, so it comes
///   from the already-bundled material_symbols_icons package.
const IconData toolbarCategoryFilterIcon = Icons.filter_alt;
const IconData toolbarSortIcon = Symbols.list_arrow;

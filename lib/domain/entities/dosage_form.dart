enum DosageForm {
  tablet,
  capsule,
  drop,
  ml,
  puff,
  unit,
  sachet,
  spoon,
  injection,
  topical,
  other,
}

extension DosageFormExtension on DosageForm {
  String toStorageString() => name;

  static DosageForm? fromStorageString(String? value) {
    if (value == null || value.isEmpty) return null;
    return DosageForm.values.asNameMap()[value];
  }

  bool get requiresCustom => this == DosageForm.other;
}

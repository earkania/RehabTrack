class DietPlan {
  final int? id;
  final int profileId;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
  final String? notes;

  const DietPlan({
    this.id,
    required this.profileId,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.active = true,
    this.notes,
  });

  DietPlan copyWith({
    int? id,
    int? profileId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
    String? notes,
  }) {
    return DietPlan(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
      notes: notes ?? this.notes,
    );
  }
}

class DietItem {
  final int? id;
  final int dietPlanId;
  final String category;
  final String itemText;
  final String? notes;

  const DietItem({
    this.id,
    required this.dietPlanId,
    required this.category,
    required this.itemText,
    this.notes,
  });

  DietItem copyWith({
    int? id,
    int? dietPlanId,
    String? category,
    String? itemText,
    String? notes,
  }) {
    return DietItem(
      id: id ?? this.id,
      dietPlanId: dietPlanId ?? this.dietPlanId,
      category: category ?? this.category,
      itemText: itemText ?? this.itemText,
      notes: notes ?? this.notes,
    );
  }
}

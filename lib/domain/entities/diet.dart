import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart'
    hide DietItem, DietGuidanceRule;

/// Diet Food Guidance domain entity.
///
/// [category] holds a stable value (`allowed`, `caution` or `avoid`).
/// Localized labels are mapped at the UI layer and never persisted.
class DietItem {
  final int? id;
  final int profileId;
  final String name;
  final String category;
  final String? foodGroup;
  final String? notes;
  final String? source;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DietItem({
    this.id,
    required this.profileId,
    required this.name,
    required this.category,
    this.foodGroup,
    this.notes,
    this.source,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  DietItem copyWith({
    int? id,
    int? profileId,
    String? name,
    String? category,
    String? foodGroup,
    String? notes,
    String? source,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DietItem(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      category: category ?? this.category,
      foodGroup: foodGroup ?? this.foodGroup,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from database model.
  static DietItem fromDb(dynamic dbModel) {
    return DietItem(
      id: dbModel.id,
      profileId: dbModel.profileId,
      name: dbModel.name,
      category: dbModel.category,
      foodGroup: dbModel.foodGroup,
      notes: dbModel.notes,
      source: dbModel.source,
      isArchived: dbModel.isArchived,
      createdAt: dbModel.createdAt,
      updatedAt: dbModel.updatedAt,
    );
  }

  /// Convert to a database companion for insertion.
  DietItemsCompanion toCompanion({bool includeId = false}) {
    return DietItemsCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      profileId: Value(profileId),
      name: Value(name),
      category: Value(category),
      foodGroup: Value(foodGroup),
      notes: Value(notes),
      source: Value(source),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// Convert to a database companion for update.
  DietItemsCompanion toUpdateCompanion() {
    return DietItemsCompanion(
      id: Value(id!),
      profileId: Value(profileId),
      name: Value(name),
      category: Value(category),
      foodGroup: Value(foodGroup),
      notes: Value(notes),
      source: Value(source),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(DateTime.now()),
    );
  }
}

/// Diet General Guidance domain entity.
///
/// [category] holds a stable value (`diet`, `smoking`, `hydration`,
/// `caffeine` or `other`). Localized labels are mapped at the UI layer and
/// never persisted.
class DietGuidanceRule {
  final int? id;
  final int profileId;
  final String title;
  final String category;
  final String? description;
  final String? source;
  final int? sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DietGuidanceRule({
    this.id,
    required this.profileId,
    required this.title,
    required this.category,
    this.description,
    this.source,
    this.sortOrder,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  DietGuidanceRule copyWith({
    int? id,
    int? profileId,
    String? title,
    String? category,
    String? description,
    String? source,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DietGuidanceRule(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      source: source ?? this.source,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from database model.
  static DietGuidanceRule fromDb(dynamic dbModel) {
    return DietGuidanceRule(
      id: dbModel.id,
      profileId: dbModel.profileId,
      title: dbModel.title,
      category: dbModel.category,
      description: dbModel.description,
      source: dbModel.source,
      sortOrder: dbModel.sortOrder,
      isArchived: dbModel.isArchived,
      createdAt: dbModel.createdAt,
      updatedAt: dbModel.updatedAt,
    );
  }

  /// Convert to a database companion for insertion.
  DietGuidanceRulesCompanion toCompanion({bool includeId = false}) {
    return DietGuidanceRulesCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      profileId: Value(profileId),
      title: Value(title),
      category: Value(category),
      description: Value(description),
      source: Value(source),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// Convert to a database companion for update.
  DietGuidanceRulesCompanion toUpdateCompanion() {
    return DietGuidanceRulesCompanion(
      id: Value(id!),
      profileId: Value(profileId),
      title: Value(title),
      category: Value(category),
      description: Value(description),
      source: Value(source),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(DateTime.now()),
    );
  }
}

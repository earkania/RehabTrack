import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

/// Diet Food Guidance — patient-managed food-specific guidance.
///
/// Each food belongs to one of three stable categories: `allowed`, `caution`
/// or `avoid`. Only stable values are persisted; localized labels are mapped
/// at the UI layer.
@TableIndex(name: 'diet_items_profile_idx', columns: {#profileId})
@TableIndex(name: 'diet_items_category_idx', columns: {#category})
@TableIndex(name: 'diet_items_archived_idx', columns: {#isArchived})
@TableIndex(name: 'diet_items_name_idx', columns: {#name})
class DietItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get foodGroup => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get source => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Diet General Guidance — free-form diet and lifestyle guidance rules.
///
/// Categories use stable values: `diet`, `smoking`, `hydration`, `caffeine`,
/// `other`. Localized labels are mapped at the UI layer.
@TableIndex(name: 'diet_guidance_rules_profile_idx', columns: {#profileId})
@TableIndex(name: 'diet_guidance_rules_category_idx', columns: {#category})
@TableIndex(name: 'diet_guidance_rules_archived_idx', columns: {#isArchived})
@TableIndex(name: 'diet_guidance_rules_title_idx', columns: {#title})
@TableIndex(name: 'diet_guidance_rules_sort_idx', columns: {#sortOrder})
class DietGuidanceRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  TextColumn get source => text().nullable()();
  IntColumn get sortOrder => integer().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

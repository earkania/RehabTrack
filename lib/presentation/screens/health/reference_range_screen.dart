import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/domain/entities/default_reference_ranges.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/measurement_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/reference_range_provider.dart';
import 'package:rehab_track/presentation/theme/app_spacing.dart';
import 'package:rehab_track/presentation/utils/measurement_localizer.dart';

class ReferenceRangeScreen extends ConsumerStatefulWidget {
  const ReferenceRangeScreen({super.key});

  @override
  ConsumerState<ReferenceRangeScreen> createState() =>
      _ReferenceRangeScreenState();
}

class _ReferenceRangeScreenState extends ConsumerState<ReferenceRangeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileId = ref.watch(activeProfileIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.referenceRanges),
      ),
      body: profileId == null
          ? Center(child: Text(l10n.error))
          : _buildBody(context, l10n, profileId),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, int profileId) {
    final typesAsync = ref.watch(activeMeasurementTypesProvider);

    return typesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.error)),
      data: (types) {
        if (types.isEmpty) {
          return Center(child: Text(l10n.noMeasurementsYet));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          itemCount: types.length,
          separatorBuilder: (_, _) => AppSpacing.smH,
          itemBuilder: (context, index) {
            final type = types[index];
            final typeKey = type.key ?? '';
            return _TypeRangeCard(
              typeKey: typeKey,
              typeName: MeasurementLocalizer.typeName(l10n, typeKey),
              profileId: profileId,
            );
          },
        );
      },
    );
  }
}

class _TypeRangeCard extends ConsumerWidget {
  final String typeKey;
  final String typeName;
  final int profileId;

  const _TypeRangeCard({
    required this.typeKey,
    required this.typeName,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rangesAsync = ref.watch(
      effectiveRangesProvider((profileId: profileId, typeKey: typeKey)),
    );

    return Card(
      child: ListTile(
        title: Text(typeName),
        subtitle: rangesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (ranges) {
            if (ranges == null || ranges.fieldRanges.isEmpty) {
              return Text(
                l10n.noReferenceRange,
                style: Theme.of(context).textTheme.bodySmall,
              );
            }
            final count = ranges.fieldRanges.length;
            return Text(
              l10n.referenceRangeCount(count),
              style: Theme.of(context).textTheme.bodySmall,
            );
          },
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(
          '/measurements/ranges/$typeKey',
        ),
      ),
    );
  }
}

class TypeRangeDetailScreen extends ConsumerStatefulWidget {
  final String typeKey;

  const TypeRangeDetailScreen({super.key, required this.typeKey});

  @override
  ConsumerState<TypeRangeDetailScreen> createState() =>
      _TypeRangeDetailScreenState();
}

class _TypeRangeDetailScreenState extends ConsumerState<TypeRangeDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileId = ref.watch(activeProfileIdProvider);

    if (profileId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.referenceRanges)),
        body: Center(child: Text(l10n.error)),
      );
    }

    final rangesAsync = ref.watch(
      effectiveRangesProvider((profileId: profileId, typeKey: widget.typeKey)),
    );
    final profileRangesAsync = ref.watch(
      profileReferenceRangesProvider(profileId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${MeasurementLocalizer.typeName(l10n, widget.typeKey)} - ${l10n.referenceRange}',
        ),
      ),
      body: rangesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.error)),
        data: (effectiveRanges) {
          return profileRangesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.error)),
            data: (profileRanges) {
              final fieldKeys = _fieldKeysForType(widget.typeKey);
              if (fieldKeys.isEmpty) {
                return Center(child: Text(l10n.noReferenceRange));
              }

              final defaults = DefaultReferenceRanges.rangesForType(widget.typeKey);
              _ensureControllers(fieldKeys, effectiveRanges, defaults);

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    ...fieldKeys.map((fieldKey) => _buildFieldRange(
                          context,
                          l10n,
                          fieldKey,
                          effectiveRanges,
                          defaults,
                        )),
                    AppSpacing.lgH,
                    FilledButton(
                      onPressed:
                          _isSaving ? null : () => _save(context, l10n, profileId),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.save),
                    ),
                    AppSpacing.mdH,
                    OutlinedButton(
                      onPressed: () => _resetToDefault(context, l10n, profileId),
                      child: Text(l10n.resetToDefault),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _ensureControllers(
    List<String> fieldKeys,
    MeasurementRanges? effectiveRanges,
    MeasurementRanges? defaults,
  ) {
    if (_initialized) return;
    _initialized = true;

    for (final fieldKey in fieldKeys) {
      final range = effectiveRanges?.rangeForField(fieldKey);
      _controllers['${fieldKey}_min'] = TextEditingController(
        text: range?.minValue != null ? range!.minValue!.toStringAsFixed(1) : '',
      );
      _controllers['${fieldKey}_max'] = TextEditingController(
        text: range?.maxValue != null ? range!.maxValue!.toStringAsFixed(1) : '',
      );
    }
  }

  Widget _buildFieldRange(
    BuildContext context,
    AppLocalizations l10n,
    String fieldKey,
    MeasurementRanges? effectiveRanges,
    MeasurementRanges? defaults,
  ) {
    final label = MeasurementLocalizer.fieldName(l10n, fieldKey);
    final defaultRange = defaults?.rangeForField(fieldKey);
    final hasDefault = defaultRange?.hasRange ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (hasDefault)
                  Text(
                    l10n.applicationDefault,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
            AppSpacing.smH,
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controllers['${fieldKey}_min'],
                    decoration: InputDecoration(
                      labelText: l10n.lowerBound,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^-?\d*\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _controllers['${fieldKey}_max'],
                    decoration: InputDecoration(
                      labelText: l10n.upperBound,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^-?\d*\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _fieldKeysForType(String typeKey) {
    return switch (typeKey) {
      'blood_pressure' => ['systolic', 'diastolic'],
      'pulse' => ['pulse'],
      'weight' => ['weight'],
      'blood_glucose' => ['glucose'],
      'spo2' => ['spo2'],
      'temperature' => ['temperature'],
      _ => [],
    };
  }

  Future<void> _save(
    BuildContext context,
    AppLocalizations l10n,
    int profileId,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(referenceRangeRepositoryProvider);
      final fieldKeys = _fieldKeysForType(widget.typeKey);

      for (final fieldKey in fieldKeys) {
        final minText = _controllers['${fieldKey}_min']!.text.trim();
        final maxText = _controllers['${fieldKey}_max']!.text.trim();

        final minValue = minText.isNotEmpty ? double.tryParse(minText) : null;
        final maxValue = maxText.isNotEmpty ? double.tryParse(maxText) : null;

        if (minValue != null &&
            maxValue != null &&
            minValue > maxValue) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.lowerBoundAboveUpperBound)),
            );
          }
          setState(() => _isSaving = false);
          return;
        }

        if (minValue != null || maxValue != null) {
          await repo.saveProfileRange(
            profileId: profileId,
            typeKey: widget.typeKey,
            fieldKey: fieldKey,
            minValue: minValue,
            maxValue: maxValue,
          );
        } else {
          await repo.removeProfileRange(
            profileId: profileId,
            typeKey: widget.typeKey,
            fieldKey: fieldKey,
          );
        }
      }

      ref.invalidate(effectiveRangesProvider);
      ref.invalidate(profileReferenceRangesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.rangeSaved)),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSaveRange)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resetToDefault(
    BuildContext context,
    AppLocalizations l10n,
    int profileId,
  ) async {
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(referenceRangeRepositoryProvider);
      await repo.clearAllProfileRanges(
        profileId: profileId,
        typeKey: widget.typeKey,
      );

      ref.invalidate(effectiveRangesProvider);
      ref.invalidate(profileReferenceRangesProvider);

      _initialized = false;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.rangeSaved)),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSaveRange)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

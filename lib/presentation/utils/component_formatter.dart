import 'package:rehab_track/domain/entities/medication_alternative_component.dart';
import 'package:rehab_track/domain/entities/medication_component.dart';

class ComponentFormatter {
  ComponentFormatter._();

  static String formatComponents(List<MedicationComponent> components) {
    if (components.isEmpty) return '';
    if (components.length == 1) {
      return _formatSingle(components.first.doseAmount, components.first.doseUnit);
    }
    final buffer = StringBuffer();
    for (var i = 0; i < components.length; i++) {
      if (i > 0) buffer.write('/');
      buffer.write(components[i].doseAmount);
      if (components[i].doseUnit.isNotEmpty) {
        buffer.write(' ${components[i].doseUnit}');
      }
    }
    return buffer.toString();
  }

  static String formatComponentsDetailed(
    List<MedicationComponent> components,
  ) {
    if (components.isEmpty) return '';
    if (components.length == 1) {
      return _formatSingleDetailed(
        components.first.componentName,
        components.first.doseAmount,
        components.first.doseUnit,
      );
    }
    final buffer = StringBuffer();
    for (var i = 0; i < components.length; i++) {
      if (i > 0) buffer.write(' + ');
      final c = components[i];
      if (c.componentName != null && c.componentName!.isNotEmpty) {
        buffer.write('${c.componentName} ');
      }
      buffer.write(c.doseAmount);
      if (c.doseUnit.isNotEmpty) {
        buffer.write(' ${c.doseUnit}');
      }
    }
    return buffer.toString();
  }

  static String formatAlternativeComponents(
    List<MedicationAlternativeComponent> components,
  ) {
    if (components.isEmpty) return '';
    if (components.length == 1) {
      return _formatSingle(components.first.doseAmount, components.first.doseUnit);
    }
    final buffer = StringBuffer();
    for (var i = 0; i < components.length; i++) {
      if (i > 0) buffer.write('/');
      buffer.write(components[i].doseAmount);
      if (components[i].doseUnit.isNotEmpty) {
        buffer.write(' ${components[i].doseUnit}');
      }
    }
    return buffer.toString();
  }

  static String formatAlternativeComponentsDetailed(
    List<MedicationAlternativeComponent> components,
  ) {
    if (components.isEmpty) return '';
    if (components.length == 1) {
      return _formatSingleDetailed(
        components.first.componentName,
        components.first.doseAmount,
        components.first.doseUnit,
      );
    }
    final buffer = StringBuffer();
    for (var i = 0; i < components.length; i++) {
      if (i > 0) buffer.write(' + ');
      final c = components[i];
      if (c.componentName != null && c.componentName!.isNotEmpty) {
        buffer.write('${c.componentName} ');
      }
      buffer.write(c.doseAmount);
      if (c.doseUnit.isNotEmpty) {
        buffer.write(' ${c.doseUnit}');
      }
    }
    return buffer.toString();
  }

  static String _formatSingle(String amount, String unit) {
    if (amount.isEmpty) return '';
    if (unit.isEmpty) return amount;
    return '$amount $unit';
  }

  static String _formatSingleDetailed(
    String? name,
    String amount,
    String unit,
  ) {
    if (amount.isEmpty) return '';
    final hasName = name != null && name.isNotEmpty;
    if (unit.isEmpty) {
      return hasName ? '$name $amount' : amount;
    }
    return hasName ? '$name $amount $unit' : '$amount $unit';
  }
}

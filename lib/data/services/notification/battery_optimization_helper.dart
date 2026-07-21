import 'package:flutter/foundation.dart';

class BatteryOptimizationHelper {
  BatteryOptimizationHelper();

  BatteryOptimizationStatus _status = BatteryOptimizationStatus.unknown;
  BatteryOptimizationStatus get status => _status;

  Future<BatteryOptimizationStatus> checkStatus() async {
    if (kIsWeb) {
      _status = BatteryOptimizationStatus.notApplicable;
      return _status;
    }

    try {
      _status = BatteryOptimizationStatus.unknown;
      return _status;
    } catch (e) {
      _status = BatteryOptimizationStatus.unknown;
      return _status;
    }
  }

  Future<bool> requestExemption() async {
    if (kIsWeb) return false;

    try {
      return false;
    } catch (e) {
      return false;
    }
  }

  bool get isLikelyRestricted =>
      _status == BatteryOptimizationStatus.restricted ||
      _status == BatteryOptimizationStatus.unknown;
}

enum BatteryOptimizationStatus {
  unknown,
  notApplicable,
  unrestricted,
  restricted,
  notSupported,
}

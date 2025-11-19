import 'package:flutter/foundation.dart';
import 'package:piesp_patrol/features/duty/data/duty_dtos.dart';

class DutyController extends ChangeNotifier {
  DutyDto? _currentDuty;

  DutyDto? get currentDuty => _currentDuty;
  bool get hasCurrentDuty => _currentDuty != null;

  void setCurrentDuty(DutyDto duty) {
    _currentDuty = duty;
    notifyListeners();
  }

  void clearCurrentDuty() {
    if (_currentDuty != null) {
      _currentDuty = null;
      notifyListeners();
    }
  }
}


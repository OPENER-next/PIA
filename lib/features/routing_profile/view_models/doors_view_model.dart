import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';

import '/shared/services/config_service.dart';
import '../models/accessibility_grades.dart';
import '../models/user_profile.dart';

class DoorsViewModel extends ViewModel {

  UserProfile get _userProfile => getService<ConfigService>().userProfile;

  double get manualDoor => _userProfile.manualDoor.value;
  updateManualDoor(double value) {
    runInAction(() => _userProfile.manualDoor = AccessibilityGradeManualDoor(value));
  }

  double get automaticRevolvingDoor => _userProfile.automaticRevolvingDoor.value;
  updateAutomaticRevolvingDoor(double value) {
    runInAction(() => _userProfile.automaticRevolvingDoor = AccessibilityGradeAutomaticRevolvingDoor(value));
  }

  double get buttonDoor => _userProfile.buttonDoor.value;
  updateButtonDoor(double value) {
    runInAction(() => _userProfile.buttonDoor = AccessibilityGradeButtonDoor(value));
  }

  double get sensorDoor => _userProfile.sensorDoor.value;
  updateSensorDoor(double value) {
    runInAction(() => _userProfile.sensorDoor = AccessibilityGradeSensorDoor(value));
  }
}

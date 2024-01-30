import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';

import '/shared/services/config_service.dart';
import '../models/accessibility_grades.dart';
import '../models/user_profile.dart';

class CrossingsViewModel extends ViewModel {

  UserProfile get _userProfile => getService<ConfigService>().userProfile;

  double get unmarkedCrossing => _userProfile.unmarkedCrossing.value;
  updateUnmarkedCrossing(double value) {
    runInAction(() => _userProfile.unmarkedCrossing = AccessibilityGradeUnmarkedCrossing(value));
  }

  double get markedCrossing => _userProfile.markedCrossing.value;
  updateMarkedCrossing(double value) {
    runInAction(() => _userProfile.markedCrossing = AccessibilityGradeMarkedCrossing(value));
  }

  double get islandCrossing => _userProfile.islandCrossing.value;
  updateIslandCrossing(double value) {
    runInAction(() => _userProfile.islandCrossing = AccessibilityGradeIslandCrossing(value));
  }

  double get signalsCrossing => _userProfile.signalsCrossing.value;
  updateSignalsCrossing(double value) {
    runInAction(() => _userProfile.signalsCrossing = AccessibilityGradeSignalsCrossing(value));
  }

  double get blindSignalsCrossing => _userProfile.blindSignalsCrossing.value;
  updateBlindSignalsCrossing(double value) {
    runInAction(() => _userProfile.blindSignalsCrossing = AccessibilityGradeBlindSignalsCrossing(value));
  }
}

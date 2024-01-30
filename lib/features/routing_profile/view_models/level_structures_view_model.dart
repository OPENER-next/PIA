import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';

import '/shared/services/config_service.dart';
import '../models/accessibility_grades.dart';
import '../models/user_profile.dart';

class LevelStructuresViewModel extends ViewModel {

  UserProfile get _userProfile => getService<ConfigService>().userProfile;

  double get stairsUp => _userProfile.stairsUp.value;
  updateStairsUp(double value) {
    runInAction(() => _userProfile.stairsUp = AccessibilityGradeStairsUp(value));
  }

  double get stairsDown => _userProfile.stairsDown.value;
  updateStairsDown(double value) {
    runInAction(() => _userProfile.stairsDown = AccessibilityGradeStairsDown(value));
  }

  double get escalator => _userProfile.escalator.value;
  updateEscalator(double value) {
    runInAction(() => _userProfile.escalator = AccessibilityGradeEscalator(value));
  }

  double get movingWalkway => _userProfile.movingWalkway.value;
  updateMovingWalkway(double value) {
    runInAction(() => _userProfile.movingWalkway = AccessibilityGradeMovingWalkway(value));
  }

  double get elevator => _userProfile.elevator.value;
  updateElevator(double value) {
    runInAction(() => _userProfile.elevator = AccessibilityGradeElevator(value));
  }
}

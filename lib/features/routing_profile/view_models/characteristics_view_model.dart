import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';

import '/shared/services/config_service.dart';
import '../models/user_profile_presets.dart';
import '../models/user_profile.dart';

class CharacteristicsViewModel extends ViewModel {

  UserProfile get _userProfile => getService<ConfigService>().userProfile;

  double get speed => _userProfile.speed;
  updateSpeed(double value) {
    runInAction(() => _userProfile.speed = value);
  }

  double get minWidth => _userProfile.minRequiredWidth * 100;
  updateMinWidth(double value) {
    runInAction(() => _userProfile.minRequiredWidth = value / 100);
  }

  double get maxInclineUp => _userProfile.maxIncline.toDouble();
  double get maxInclineDown => _userProfile.maxDecline.toDouble();
  updateIncline(double inclineDown, double inclineUp) {
    runInAction(() {
      _userProfile.maxIncline = inclineUp.toInt();
      _userProfile.maxDecline = inclineDown.toInt();
    });
  }

  void applyPreset(UserProfilePreset preset) {
    runInAction(() => _userProfile.applyPreset(preset));
  }
}

import 'package:flutter/material.dart' hide View;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '../view_models/doors_view_model.dart';
import 'accessibility_preference.dart';
import 'profile_page.dart';

class DoorProfileView extends View<DoorsViewModel> {
  const DoorProfileView({
    super.key,
  }): super(create: DoorsViewModel.new);

  @override
  Widget build(context, viewModel) {
    final localizations = AppLocalizations.of(context)!;

    return ProfilePage(
      title: localizations.doorProfileTitle,
      children: [
        AccessibilityPreference(
          label: localizations.doorProfileManualLabel,
          icon: MdiIcons.doorOpen,
          value: viewModel.manualDoor,
          onChanged: viewModel.updateManualDoor,
        ),
        AccessibilityPreference(
          label: localizations.doorProfileAutomaticRevolvingLabel,
          icon: MdiIcons.rotate360,
          value: viewModel.automaticRevolvingDoor,
          onChanged: viewModel.updateAutomaticRevolvingDoor,
        ),
        AccessibilityPreference(
          label: localizations.doorProfileAutomaticButtonLabel,
          icon: MdiIcons.doorSlidingOpen,
          value: viewModel.buttonDoor,
          onChanged: viewModel.updateButtonDoor,
        ),
        AccessibilityPreference(
          label: localizations.doorProfileAutomaticSensorLabel,
          icon: MdiIcons.motionSensor,
          value: viewModel.sensorDoor,
          onChanged: viewModel.updateSensorDoor,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart' hide View;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '../view_models/level_structures_view_model.dart';
import 'accessibility_preference.dart';
import 'profile_page.dart';

class LevelProfileView extends View<LevelStructuresViewModel> {
  const LevelProfileView({
    super.key,
  }): super(create: LevelStructuresViewModel.new);

  @override
  Widget build(context, viewModel) {
    final localizations = AppLocalizations.of(context)!;

    return ProfilePage(
      title: localizations.levelProfileTitle,
      children: [
        AccessibilityPreference(
          label: localizations.levelProfileStairsUpLabel,
          icon: MdiIcons.stairsUp,
          value: viewModel.stairsUp,
          onChanged: viewModel.updateStairsUp,
        ),
        AccessibilityPreference(
          label: localizations.levelProfileStairsDownLabel,
          icon: MdiIcons.stairsDown,
          value: viewModel.stairsDown,
          onChanged: viewModel.updateStairsDown,
        ),
        const Divider(),
        AccessibilityPreference(
          label: localizations.levelProfileEscalatorLabel,
          icon: MdiIcons.escalator,
          value: viewModel.escalator,
          onChanged: viewModel.updateEscalator,
        ),
        AccessibilityPreference(
          label: localizations.levelProfileMovingWalkwayLabel,
          icon: MdiIcons.slopeUphill,
          value: viewModel.movingWalkway,
          onChanged: viewModel.updateMovingWalkway,
        ),
        const Divider(),
        AccessibilityPreference(
          label: localizations.levelProfileElevatorLabel,
          icon: MdiIcons.elevator,
          value: viewModel.elevator,
          onChanged: viewModel.updateElevator,
        ),
      ],
    );
  }
}

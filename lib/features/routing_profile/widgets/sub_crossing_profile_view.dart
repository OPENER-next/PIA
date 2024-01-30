import 'package:flutter/material.dart' hide View;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '../view_models/crossings_view_model.dart';
import 'accessibility_preference.dart';
import 'profile_page.dart';

class CrossingProfileView extends View<CrossingsViewModel> {
  const CrossingProfileView({
    super.key,
  }): super(create: CrossingsViewModel.new);

  @override
  Widget build(context, viewModel) {
    final localizations = AppLocalizations.of(context)!;

    return ProfilePage(
      title: localizations.crossingProfileTitle,
      children: [
        AccessibilityPreference(
          label: localizations.crossingProfileUnmarkedLabel,
          icon: MdiIcons.road,
          value: viewModel.unmarkedCrossing,
          onChanged: viewModel.updateUnmarkedCrossing,
        ),
        AccessibilityPreference(
          label: localizations.crossingProfileMarkedLabel,
          icon: MdiIcons.road,
          value: viewModel.markedCrossing,
          onChanged: viewModel.updateMarkedCrossing,
        ),
        AccessibilityPreference(
          label: localizations.crossingProfileIslandLabel,
          icon: MdiIcons.road,
          value: viewModel.islandCrossing,
          onChanged: viewModel.updateIslandCrossing,
        ),
        const Divider(),
        AccessibilityPreference(
          label: localizations.crossingProfileSignalsLabel,
          icon: MdiIcons.trafficLight,
          value: viewModel.signalsCrossing,
          onChanged: viewModel.updateSignalsCrossing,
        ),
        AccessibilityPreference(
          label: localizations.crossingProfileBlindSignalsLabel,
          icon: Icons.blind_rounded,
          value: viewModel.blindSignalsCrossing,
          onChanged: viewModel.updateBlindSignalsCrossing,
        ),
      ],
    );
  }
}

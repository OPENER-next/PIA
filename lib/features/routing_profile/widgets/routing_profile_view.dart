import 'package:flutter/material.dart' hide View;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '../models/user_profile_presets.dart';
import '../view_models/characteristics_view_model.dart';
import 'profile_page.dart';
import 'sub_crossing_profile_view.dart';
import 'sub_door_profile_view.dart';
import 'sub_level_profile_view.dart';

class RoutingProfileView extends View<CharacteristicsViewModel> {
  const RoutingProfileView({
    super.key,
  }): super(create: CharacteristicsViewModel.new);

  @override
  Widget build(context, viewModel) {
    final localizations = AppLocalizations.of(context)!;

    return ProfilePage(
      title: localizations.generalProfileTitle,
      actions: [
        IconButton(
          onPressed: () async {
            final preset = await showDialog<UserProfilePreset>(
              context: context,
              builder: (_) => const ProfilePresets(),
            );
            if (preset != null) viewModel.applyPreset(preset);
          },
          icon: Icon(
            MdiIcons.accountSwitch,
            semanticLabel: localizations.presetsButtonSemantic,
          ),
        ),
      ],
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(localizations.generalProfileSpeedLabel),
              Text(localizations.generalProfileSpeedValue(viewModel.speed)),
            ],
          ),
          leading: const Icon(MdiIcons.speedometerSlow),
          subtitle: Slider(
            value: viewModel.speed,
            min: 1,
            max: 10,
            onChanged: viewModel.updateSpeed,
          ),
        ),
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(localizations.generalProfileMinWidthLabel),
              Text(localizations.generalProfileMinWidthValue(viewModel.minWidth)),
            ],
          ),
          leading: const Icon(MdiIcons.arrowExpandHorizontal),
          subtitle: Slider(
            value: viewModel.minWidth,
            min: 50,
            max: 150,
            onChanged: viewModel.updateMinWidth,
          ),
        ),
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(localizations.generalProfileInclineDeclineLabel),
              Text(localizations.generalProfileInclineDeclineValue(
                viewModel.maxInclineDown,
                viewModel.maxInclineUp,
              )),
            ],
          ),
          leading: const Icon(MdiIcons.elevationRise),
          subtitle: RangeSlider(
            values: RangeValues(
              viewModel.maxInclineDown,
              viewModel.maxInclineUp,
            ),
            divisions: 30,
            min: -15,
            max: 15,
            onChanged: (v) => viewModel.updateIncline(v.start, v.end),
          ),
        ),
        const Divider(),
        ListTile(
          title: Text(localizations.generalProfileLevelConnectionsLabel),
          leading: const Icon(MdiIcons.swapVerticalBold),
          trailing: const Icon(Icons.arrow_forward),
          subtitle: Text(localizations.generalProfileLevelConnectionsDescription),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LevelProfileView(),
            ),
          ),
        ),
        ListTile(
          title: Text(localizations.generalProfileCrossingsLabel),
          leading: const Icon(MdiIcons.roadVariant),
          trailing: const Icon(Icons.arrow_forward),
          subtitle: Text(localizations.generalProfileCrossingsDescription),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CrossingProfileView(),
            ),
          ),
        ),
        ListTile(
          title: Text(localizations.generalProfileDoorsLabel),
          leading: const Icon(MdiIcons.door),
          trailing: const Icon(Icons.arrow_forward),
          subtitle: Text(localizations.generalProfileDoorsDescription),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DoorProfileView(),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePresets extends StatelessWidget {
  const ProfilePresets({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.presetTitle),
      content: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text(localizations.presetWheelchairLabel),
                leading: const Icon(MdiIcons.wheelchairAccessibility),
                onTap: () => Navigator.of(context).pop(UserProfilePresets.wheelchair),
              ),
              ListTile(
                title: Text(localizations.presetBlindLabel),
                leading: const Icon(Icons.blind_rounded),
                onTap: () => Navigator.of(context).pop(UserProfilePresets.blind),
              ),
              ListTile(
                title: Text(localizations.presetAssistGuideDogLabel),
                leading: const Icon(MdiIcons.dogService),
                onTap: () => Navigator.of(context).pop(UserProfilePresets.guideDog),
              ),
              ListTile(
                title: Text(localizations.presetAssistWalkerLabel),
                leading: const Icon(Icons.assist_walker),
                onTap: () => Navigator.of(context).pop(UserProfilePresets.assistWalker),
              ),
              ListTile(
                title: Text(localizations.presetBuggyLabel),
                leading: const Icon(Icons.child_friendly_rounded),
                onTap: () => Navigator.of(context).pop(UserProfilePresets.buggy),
              ),
              ListTile(
                title: Text(localizations.presetBicycleLabel),
                leading: const Icon(Icons.pedal_bike_rounded),
                onTap: () => Navigator.of(context).pop(UserProfilePresets.bicycle),
              ),
              ListTile(
                title: Text(localizations.presetLuggageLabel),
                leading: const Icon(Icons.luggage_rounded),
                onTap: () => Navigator.of(context).pop(UserProfilePresets.luggage),
              ),
              ListTile(
                title: Text(localizations.presetPedestrianLabel),
                leading: const Icon(Icons.directions_walk_rounded),
                onTap: () => Navigator.of(context).pop(UserProfilePresets.unrestricted),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancelButton)
        ),
      ],
    );
  }
}

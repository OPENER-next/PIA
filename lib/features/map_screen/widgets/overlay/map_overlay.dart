import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/features/tracelet_manager/widgets/tracelet_manager_view.dart';
import '/features/routing_profile/widgets/routing_profile_view.dart';
import '/features/poi_finder/widgets/poi_finder_view.dart';
import '../../view_models/map_screen_view_model.dart';
import 'indoor_level_bar.dart';
import 'route_selection.dart';

class MapOverlay extends ViewFragment<MapViewModel> {
  final void Function()? onZoomInPressed;
  final void Function()? onZoomOutPressed;

  const MapOverlay({
    super.key,
    this.onZoomInPressed,
    this.onZoomOutPressed,
  });

  @override
  Widget build(BuildContext context, viewModel) {
    final localizations = AppLocalizations.of(context)!;
    final theme =  Theme.of(context);
    const inset = 10.0;

    return Stack(
      children: [
        Positioned.fill(
          top: inset,
          bottom: inset,
          left: inset,
          right: inset,
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      POIFinderView(
                        onSelection: (poi) {
                          viewModel.setDestination(poi.position, viewModel.clearDestination);
                        },
                      ),
                      FloatingActionButton.small(
                        tooltip: localizations.routingProfileButtonSemantic,
                        heroTag: UniqueKey(),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            return const RoutingProfileView();
                          }));
                        },
                        child: const Icon(MdiIcons.humanEdit),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        backgroundColor: viewModel.isTrackingPosition
                            ? theme.colorScheme.primary
                            : null,
                            foregroundColor: viewModel.isTrackingPosition
                            ? theme.colorScheme.onPrimary
                            : null,
                        tooltip: localizations.indoorPositionTrackingButtonSemantic,
                        heroTag: UniqueKey(),
                        onPressed: viewModel.togglePositioningTracking,
                        child: const Icon(Icons.navigation_rounded),
                      ),
                      FloatingActionButton.small(
                        tooltip: localizations.indoorPositioningButtonSemantic,
                        heroTag: UniqueKey(),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => const Dialog(
                            child: TraceletManagerView(),
                          ),
                        ),
                        child: const Icon(Icons.settings_remote_outlined),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: viewModel.hasAnyRoutes
                          ? FloatingActionButton.small(
                            tooltip: localizations.routeSelectionButtonSemantic,
                            heroTag: UniqueKey(),
                            onPressed: viewModel.showRouteSelection,
                            child: const Icon(Icons.directions_rounded),
                          )
                          : null
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: inset),
                  child: AnimatedBuilder(
                    animation: viewModel.mapController,
                    builder: (_, child) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: viewModel.mapController.cameraPosition!.zoom >= 16 ? child : null,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedBuilder(
                        animation: viewModel.levelController,
                        builder: (_, __) => IndoorLevelBar(
                          levels: viewModel.levelController.levels,
                          active: viewModel.levelController.level,
                          onSelect: viewModel.levelController.changeLevel,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                switchInCurve: Curves.easeInOutCubicEmphasized,
                switchOutCurve: Curves.ease,
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => DecoratedBox(
                  decoration: BoxDecoration(
                    // flip box shadow upside down
                    boxShadow: kElevationToShadow[4]!
                      .map((s) => BoxShadow(
                        color: s.color,
                        offset: s.offset.scale(1, -1),
                        blurRadius: s.blurRadius,
                        spreadRadius: s.spreadRadius,
                        blurStyle: s.blurStyle,
                      ))
                      .toList(),
                  ),
                  child: SizeTransition(
                    axisAlignment: 1,
                    sizeFactor: animation,
                    child: SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(0, 1), end: Offset.zero),
                      ),
                      child: child,
                    ),
                  ),
                ),
                child: viewModel.routeSelectionVisible && viewModel.hasAnyRoutes
                  ? const RouteSelection()
                  : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

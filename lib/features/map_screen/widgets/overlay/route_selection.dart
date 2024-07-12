import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:render_metrics/render_metrics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/route_discomforts.dart';
import '../../view_models/map_screen_view_model.dart';


class RouteSelection extends ViewFragment<MapViewModel> {
  const RouteSelection({super.key});

  @override
  Widget build(BuildContext context, viewModel) {
    return RenderMetricsObject(
      id: 'routesBottomSheet',
      manager: viewModel.renderManager,
      child: Material(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        children: List.generate(viewModel.routeCount, (index) {
                          return ChoiceChip(
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            onSelected: (value) {
                              if (value) {
                                viewModel.routePageController?.animateToPage(index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubicEmphasized,
                                );
                              }
                            },
                            label: Text(viewModel.routeDurationFormatted(index)),
                            selected: index == viewModel.selectedRouteIndex,
                          );
                        }),
                      ),
                    ),
                    IconButton(
                      onPressed: viewModel.hideRouteSelection,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 160,
                child: PageView.builder(
                  onPageChanged: viewModel.selectRoute,
                  controller: viewModel.routePageController,
                  itemCount: viewModel.routeCount,
                  itemBuilder: (context, index) => RouteDetails(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class RouteDetails extends ViewFragment<MapViewModel> {
  final int index;

  const RouteDetails(this.index, {
    super.key,
  });

  @override
  Widget build(BuildContext context, viewModel) {
    final localizations = AppLocalizations.of(context)!;
    final discomforts = viewModel.routeDiscomforts(index);
    const columnCount = 2;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              localizations.routeInfoTitle(
                viewModel.routeDurationFormatted(index),
                viewModel.routeDistanceFormatted(index),
              ),
              style: const TextStyle(fontSize: 20),),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Table(
                children: discomforts.stats.entries.slices(columnCount).map((chunk) {
                  final columns = chunk.map<Widget>((item) {
                    final IconData icon;
                    final String text;
                    switch (item.key) {
                      case DiscomfortType.door:
                        icon = MdiIcons.doorOpen;
                        text = localizations.routeDiscomfortDoor(item.value);
                      break;
                      case DiscomfortType.stairsUp:
                        icon = MdiIcons.stairsUp;
                        text = localizations.routeDiscomfortStairsUp(item.value);
                      break;
                      case DiscomfortType.stairsDown:
                        icon = MdiIcons.stairsDown;
                        text = localizations.routeDiscomfortStairsDown(item.value);
                      break;
                      case DiscomfortType.elevator:
                        icon = MdiIcons.elevator;
                        text = localizations.routeDiscomfortElevator(
                          Duration(seconds: item.value).toDurationString(
                            round: false,
                            dropPrefixOrSuffix: true,
                            form: Abbreviation.semi,
                            format: DurationFormat.ms,
                          ),
                        );
                      break;
                      case DiscomfortType.escalator:
                        icon = MdiIcons.escalator;
                        text = localizations.routeDiscomfortEscalator(
                          Duration(seconds: item.value).toDurationString(
                            round: false,
                            dropPrefixOrSuffix: true,
                            form: Abbreviation.semi,
                            format: DurationFormat.ms,
                          ),
                        );
                      break;
                      case DiscomfortType.movingWalkway:
                        icon = MdiIcons.slopeUphill;
                        text = localizations.routeDiscomfortMovingWalkway(
                          Duration(seconds: item.value).toDurationString(
                            round: false,
                            dropPrefixOrSuffix: true,
                            form: Abbreviation.semi,
                            format: DurationFormat.ms,
                          ),
                        );
                      break;
                      case DiscomfortType.crossingWithSignals:
                        icon = MdiIcons.trafficLight;
                        text = localizations.routeDiscomfortCrossingWithSignals(item.value);
                      break;
                      case DiscomfortType.crossingWithoutSignals:
                        icon = MdiIcons.road;
                        text = localizations.routeDiscomfortCrossingWithoutSignals(item.value);
                      break;
                    }
                    return Row(
                      children: [
                        Icon(icon),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                            child: Text(text),
                          ),
                        ),
                      ],
                    );
                  }).toList();
                  // the table widget requires table rows with children of same length
                  while (columns.length != columnCount) {
                    columns.add(const SizedBox.shrink());
                  }
                  return TableRow(
                    children: columns,
                  );
                }).toList(),
              ),
            ),
          ),
          Flexible(
            child: Wrap(
              spacing: 10,
              alignment: WrapAlignment.end,
              children: [
                FilledButton(
                  onPressed: viewModel.hideRouteSelection,
                  child: Text(localizations.startNavigationButton),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

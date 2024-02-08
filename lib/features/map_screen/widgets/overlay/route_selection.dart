import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:render_metrics/render_metrics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../view_models/map_screen_view_model.dart';


class RouteSelection extends ViewFragment<MapViewModel> {
  const RouteSelection({super.key});

  @override
  Widget build(BuildContext context, viewModel) {
    final localizations = AppLocalizations.of(context)!;

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
                  itemBuilder: (context, index) {
                    return Observer(builder: (context) => RouteSelectionEntry(
                      title: localizations.routeInfoTitle(
                        viewModel.routeDurationFormatted(index),
                        viewModel.routeDistanceFormatted(index),
                      ), // MdiIcons.clockFast, MdiIcons.flash, Mdi.Icons.run vs MdiIcons.accessible
                      text: '',
                      onSelect: () { },
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class RouteSelectionEntry extends StatelessWidget {
  final String title;
  final String text;
  final VoidCallback? onSelect;

  const RouteSelectionEntry({
    required this.title,
    required this.text,
    this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(title, style: const TextStyle(fontSize: 20),),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                text,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          Wrap(
            spacing: 10,
            alignment: WrapAlignment.end,
            children: [
              FilledButton(
                onPressed: onSelect,
                child: Text(localizations.startNavigationButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

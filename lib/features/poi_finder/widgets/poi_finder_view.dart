import 'package:flutter/material.dart' hide View;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../view_models/poi_finder_view_model.dart';
import '/shared/models/pois.dart';


class POIFinderView extends View<POIFinderViewModel> {
  final ValueChanged<POI> onSelection;

  const POIFinderView({
    required this.onSelection,
    super.key,
  }): super(create: POIFinderViewModel.new);

  @override
  Widget build(context, viewModel) {
    return SearchAnchor(
      searchController: viewModel.controller,
      viewBuilder: (suggestions) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: FutureBuilder(
            future: viewModel.poiResults,
            builder: (context, snapshot) {
              return snapshot.hasData
                ? MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView(
                    children: suggestions.toList(),
                  ),
                )
                : const Center(
                  child: CircularProgressIndicator(),
                );
            }
          )
        );
      },
      builder: (context, SearchController controller) {
        final localizations = AppLocalizations.of(context)!;
        return FloatingActionButton.small(
          tooltip: localizations.findPOIsButtonSemantic,
          heroTag: UniqueKey(),
          onPressed: viewModel.open,
          child: const Icon(Icons.search),
        );
      },
      suggestionsBuilder: (context, SearchController controller) async {
        final pois = await viewModel.poiResults;
        return pois.map((poi) => ListTile(
          leading: Icon(poi.symbol),
          title: Text(viewModel.poiName(poi)),
          trailing: Text(viewModel.poiDistance(poi)),
          onTap: () {
            onSelection(poi);
            controller.closeView(null);
          }
        ));
      }
    );
  }
}

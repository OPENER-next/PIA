import 'package:flutter/material.dart' hide View;
import 'package:flutter_mvvm_architecture/base.dart';

import '../view_models/poi_finder_view_model.dart';
import '/shared/models/pois.dart';


class POIFinderView extends View<POIFinderViewModel> {
  final Function(POI poi) onSelection;

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
          child: viewModel.nearbyPoisLoaded
            ? MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView(
                children: suggestions.toList(),
              ),
            )
            : const Center(
              child: CircularProgressIndicator(),
            ),
        );
      },
      builder: (context, SearchController controller) {
        return IconButton(
          icon: const Icon(Icons.search),
          onPressed: viewModel.open,
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

import 'package:flutter/material.dart' hide View;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../view_models/tracelet_manager_view_model.dart';

class TraceletManagerView extends View<TraceletManagerViewModel> {
  const TraceletManagerView({super.key}) : super(create: TraceletManagerViewModel.new);

  @override
  Widget build(BuildContext context, TraceletManagerViewModel viewModel) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.logMessageCount,
            itemBuilder: (context, i) => Text(
              viewModel.logMessageByIndex(i),
              style: const TextStyle(fontSize: 10),
            )
          ),
        ),
        Flexible(
          child: Wrap(
            spacing: 5,
            children: [
              TextButton(
                onPressed: !viewModel.isConnected
                  ? viewModel.connectToTracelet
                  : null,
                child: Text(localizations.indoorPositioningDialogConnectButton),
              ),
              TextButton(
                onPressed: viewModel.isConnected
                  ? viewModel.disconnectFromTracelet
                  : null,
                child: Text(localizations.indoorPositioningDialogDisconnectButton),
              ),
            ],
          ),
        )
      ],
    );
  }
}

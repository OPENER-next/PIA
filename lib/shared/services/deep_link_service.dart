import 'dart:async';

import 'package:flutter_mvvm_architecture/base.dart';
import 'package:get_it/get_it.dart';
import 'package:app_links/app_links.dart';

import '../models/deep_link_actions.dart';
import '../utils/consumable.dart';


/// The idea is that there is only one action consumer.
/// Clearing the action on read makes sure that an action is not accidentally consumed again.

class DeepLinkService extends Service with Disposable {

  static final _appLinks = AppLinks();

  static Future<DeepLinkService> init() async {
    final uri = await _appLinks.getInitialLink();
    final action = uri != null ? DeepLinkAction.fromUri(uri) : null;
    return DeepLinkService._(action);
  }

  final Consumable<DeepLinkAction> _action;

  bool get hasAction => _action.isStocked;

  DeepLinkAction? watch() => _action.watch();

  T? consume<T extends DeepLinkAction>() {
    if (_action.watch() is T) {
      return _action.consume() as T?;
    }
    return null;
  }

  late final StreamSubscription _subscription;

  DeepLinkService._(DeepLinkAction? initialAction) :
    _action = Consumable<DeepLinkAction>(initialAction)
  {
    _subscription = _appLinks.uriLinkStream.listen(_handleDeepLinkUri);
  }

  void _handleDeepLinkUri(Uri uri) {
    _action.stock(DeepLinkAction.fromUri(uri));
  }

  @override
  FutureOr onDispose() {
    _subscription.cancel();
  }
}

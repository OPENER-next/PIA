import 'dart:async';

import 'package:flutter_mvvm_architecture/base.dart';
import 'package:get_it/get_it.dart';
import 'package:uni_links/uni_links.dart' as deep_link;

import '../models/deep_link_actions.dart';
import '../utils/consumable.dart';


/// The idea is that there is only one action consumer.
/// Clearing the action on read makes sure that an action is not accidentally consumed again.

class DeepLinkService extends Service with Disposable {

  static Future<DeepLinkService> init() async {
    final uri = await deep_link.getInitialUri();
    return DeepLinkService._(uri);
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

  DeepLinkService._(Uri? initialUri) :
    _action = Consumable<DeepLinkAction>(
      initialUri != null ? DeepLinkAction.fromUri(initialUri) : null,
    )
  {
    _subscription = deep_link.uriLinkStream.listen(_handleDeepLinkUri);
  }

  void _handleDeepLinkUri(Uri? uri) {
    if (uri != null) {
      _action.stock(DeepLinkAction.fromUri(uri));
    }
  }

  @override
  FutureOr onDispose() {
    _subscription.cancel();
  }
}

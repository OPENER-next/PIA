import 'level.dart';
import 'position.dart';


sealed class DeepLinkAction {
  static const Map<String, DeepLinkAction Function(Uri)> uriActionMap = {
    '/navigate': NavigateAction.fromUri,
  };

  static DeepLinkAction fromUri(Uri uri) {
    final actionCallback = uriActionMap[uri.path];
    if (actionCallback != null) {
      return actionCallback(uri);
    }
    throw UnimplementedError('No DeepLinkAction implemented for URI: $uri');
  }
}


class NavigateAction extends DeepLinkAction {
  final Position destination;
  final List<String> limitations;

  NavigateAction({
    required this.destination,
    required this.limitations,
  });

  factory NavigateAction.fromUri(Uri uri) {
    final to = uri.queryParameters['to'];
    if (to != null) {
      final [lat, lon, level] = to.split(';');
      try {
        final position = Position(
          double.parse(lat),
          double.parse(lon),
          level: Level.fromString(level),
        );
        final limitations = uri.queryParameters['limitations']?.split(';');

        return NavigateAction(
          destination: position,
          limitations: limitations ?? const [],
        );
      }
      catch(e) { /* noop */ }
    }
    throw FormatException('NavigateAction failed parsing Uri $uri');
  }
}

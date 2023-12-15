part of 'ppr.dart';


/// PPR routing request.

class RoutingRequest {
  final Position start;
  final Position destination;

  final RoutingProfile profile;

  final bool includeInfos;
  final bool includeFullPath;
  final bool includeSteps;
  final bool includeStepsPath;
  final bool includeEdges;
  final bool includeStatistics;

  const RoutingRequest({
    required this.start,
    required this.destination,
    required this.profile,
    this.includeInfos = true,
    this.includeFullPath = true,
    this.includeSteps = true,
    this.includeStepsPath = false,
    this.includeEdges = false,
    this.includeStatistics = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'start': start.toJson(),
      'destination': destination.toJson(),
      'profile': profile.toJson(),
      'include_edges': includeEdges,
      'include_full_path': includeFullPath,
      'include_infos': includeInfos,
      'include_statistics':	includeStatistics,
      'include_steps': includeSteps,
      'include_steps_path':	includeStepsPath,
    };
  }
}

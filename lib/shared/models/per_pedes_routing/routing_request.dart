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
  /// If true, start level must be exactly the same. If false, deviating levels are also taken into account.
  final bool forceLevelMatch;
  /// If forceLevelMatch = false, edges/surfaces with a different level are penalized with this value multiplied by the absolute difference in levels
  final double levelDistPenalty;
  /// If true, all edges/surfaces that do not have a level tag also match.
  /// If false, there must be a matching level (if a level is specified in the request).
  final bool allowMatchWithNoLevel;
  /// If allowMatchWithNoLevel = true and the edge has no level tag, this value is added to the distance (like levelDistPenalty).
  final double noLevelPenalty;

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
    this.forceLevelMatch = true,
    this.levelDistPenalty = 0,
    this.allowMatchWithNoLevel = true,
    this.noLevelPenalty = 0,
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
      'force_level_match': forceLevelMatch,
      'level_dist_penalty': levelDistPenalty,
      'allow_match_with_no_level': allowMatchWithNoLevel,
      'no_level_penalty': noLevelPenalty,
    };
  }
}

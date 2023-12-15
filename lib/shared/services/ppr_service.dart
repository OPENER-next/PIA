import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:get_it/get_it.dart';

import '../models/per_pedes_routing/ppr.dart';


class PerPedesRoutingService extends Service with Disposable {
  final Uri apiEndPoint;

  final _client = http.Client();

  PerPedesRoutingService({
    Uri? apiEndPoint,
  }) : apiEndPoint = apiEndPoint ?? Uri.https('ppr.motis-project.de', 'api/route');


  Future<List<Route>> request(RoutingRequest request) async {
    final response = await _client.post(
      apiEndPoint,
      headers: const {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );
    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
    return RoutingResponse.fromJson(decodedResponse).routes;
  }


  void dispose() => _client.close();

  @override
  void onDispose() => dispose();
}

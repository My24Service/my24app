import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:my24_flutter_core/api/api_mixin.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'models.dart';

final log = Logger('company.engineer.api');

class EngineersForSelectApi with CoreApiMixin {
  http.Client httpClient = http.Client();

  Future<EngineersForSelect> get() async {
    SlidingToken? newToken = await refreshSlidingToken(httpClient);

    if(newToken == null) {
      throw Exception('Token expired');
    }

    final url = await getUrl('/company/engineer/list-for-select/');
    log.info('get() url: $url, client: $httpClient');

    final response = await httpClient.get(
        Uri.parse(url),
        headers: getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return EngineersForSelect.fromJson(json.decode(response.body));
    }

    String msg = "fetch engineers for select: (${response.body})";

    throw Exception(msg);
  }
}

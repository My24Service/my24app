import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24_flutter_core/api/api_mixin.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24app/common/utils.dart';
import 'package:my24app/company/models/models.dart';
import 'package:my24app/company/models/engineer/models.dart';

class CompanyApi with CoreApiMixin {
  // default and settable for tests
  http.Client _httpClient = new http.Client();

  set httpClient(http.Client client) {
    _httpClient = client;
  }

  /// This calls a deprecated endpoint.
  Future<EngineerUsers> fetchEngineers() async {
    SlidingToken? newToken = await refreshSlidingToken(_httpClient);

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/engineer/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return EngineerUsers.fromJson(json.decode(response.body));
    }

    throw Exception('orders.assign.exception_fetch_engineers'.tr());
  }


  Future<List<CompanyUser>> userListTypeAhead( String query, {required String userType} ) async {
    SlidingToken? newToken = await refreshSlidingToken(_httpClient);

    if (newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/user-list/?user_type=$userType&q=$query');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode( response.body );
      return list.map( (i) => CompanyUser.fromJson(i) ).toList();
    }

    throw Exception('orders.assign.exception_fetch_engineers'.tr());
  }


  Future<LastLocations> fetchEngineersLastLocations() async {
    SlidingToken? newToken = await refreshSlidingToken(_httpClient);

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/engineer/get_locations/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      List results = json.decode(response.body);
      return LastLocations.fromJson(results);
    } else {
      print('Got non-200 (${response.statusCode} response${response.body}');
    }

    throw Exception('interact.map.exception_fetch_locations'.tr());
  }

  // Future<bool> insertRating(double rating, int assignedorderPk) async {
  //   SlidingToken newToken = await localUtils.refreshSlidingToken();
  //
  //   if(newToken == null) {
  //     throw Exception('generic.token_expired'.tr());
  //   }
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getInt('user_id');
  //   final ratedBy = 1;
  //   final customerName = prefs.getString('member_name');
  //
  //   final url = await getUrl('/company/userrating/');
  //   Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
  //   allHeaders.addAll(localUtils.getHeaders(newToken.token));
  //
  //   final Map body = {
  //     'rating': rating,
  //     'assignedorder_id': assignedorderPk,
  //     'user': userId,
  //     'rated_by': ratedBy,  // obsolete
  //     'customer_name': customerName,
  //   };
  //
  //   final response = await _httpClient.post(
  //     Uri.parse(url),
  //     body: json.encode(body),
  //     headers: allHeaders,
  //   );
  //
  //   if (response.statusCode == 201) {
  //     return true;
  //   }
  //
  //   return false;
  // }

  Future<Branch> fetchMyBranch() async {
    SlidingToken? newToken = await refreshSlidingToken(_httpClient);

    if (newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/branch-my/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: utils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Branch.fromJson(json.decode(response.body));
    }
    print('branch get error: ${response.statusCode}');

    throw Exception('generic.exception_fetch'.tr());
  }

  String? _typeAheadToken;
  Future <List<BranchTypeAheadModel>> branchTypeAhead(String query) async {
    // don't call for every search
    if (_typeAheadToken == null) {
      SlidingToken? newToken = await refreshSlidingToken(_httpClient);

      if (newToken == null) {
        throw Exception('generic.token_expired'.tr());
      }

      _typeAheadToken = newToken.token;
    }

    final url = await getUrl('/company/branch/autocomplete/?q=' + query);
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: getHeaders(_typeAheadToken)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      var list = parsedJson as List;
      List<BranchTypeAheadModel> results = list.map((i) => BranchTypeAheadModel.fromJson(i)).toList();

      return results;
    }

    return [];
  }
}

CompanyApi companyApi = CompanyApi();

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyApi with ApiMixin {
  // default and settable for tests
  http.Client _httpClient = new http.Client();

  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Utils localUtils = utils;

  Future<EngineerUsers> fetchEngineers() async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/engineer/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return EngineerUsers.fromJson(json.decode(response.body));
    }

    throw Exception('orders.assign.exception_fetch_engineers'.tr());
  }

  Future<LastLocations> fetchEngineersLastLocations() async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/engineer/get_locations/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );
    print(localUtils.getHeaders(newToken.token));

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

  Future<bool> deleteSalesUserCustomer(SalesUserCustomer salesuserCustomer) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/salesusercustomer/${salesuserCustomer.id}/');
    final response = await _httpClient.delete(
        Uri.parse(url),
        headers: utils.getHeaders(newToken.token))
    ;

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

  Future<SalesUserCustomers> fetchSalesUserCustomers() async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userPk = prefs.getInt('user_id');
    final url = await getUrl('/company/salesusercustomer/?user=$userPk');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: utils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return SalesUserCustomers.fromJson(json.decode(response.body));
    }

    throw Exception('sales.customers.exception_fetch'.tr());
  }

  Future<bool> insertSalesUserCustomer(SalesUserCustomer salesUserCustomer) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userPk = prefs.getInt('user_id');
    final url = await getUrl('/company/salesusercustomer/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'customer': salesUserCustomer.customer,
      'user': userPk,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  // work hours
  Future<UserWorkHoursPaginated> fetchUserWorkHours(DateTime startDate) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url;
    if (startDate != null) {
      final String startDateTxt = utils.formatDate(startDate);
      url = await getUrl('/company/user-workhours/?start_date=$startDateTxt');
    } else {
      url = await getUrl('/company/user-workhours/');
    }

    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return UserWorkHoursPaginated.fromJson(json.decode(response.body));
    }

    print('fetchUserWorkHours: non 200 returned: ${response.body}');

    throw Exception('company.workhours.exception_fetch'.tr());
  }

  Future<UserWorkHours> fetchUserWorkHoursDetail(int pk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await getUrl('/company/user-workhours/$pk/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return UserWorkHours.fromJson(json.decode(response.body));
    }

    print('fetchUserWorkHoursDetail: non 200 returned: ${response.body}');

    throw Exception('company.workhours.exception_fetch'.tr());
  }

  Future<UserWorkHours> insertUserWorkHours(UserWorkHours hours) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/user-workhours/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'project': hours.project,
      'start_date': hours.startDate,
      'duration': hours.duration,
      'description': hours.description,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return UserWorkHours.fromJson(json.decode(response.body));
    }

    print('insertUserWorkHours: non 201 returned: ${response.body}');

    return null;
  }

  Future<bool> editUserWorkHours(int pk, UserWorkHours hours) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/user-workhours/$pk/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'project': hours.project,
      'start_date': hours.startDate,
      'duration': hours.duration,
      'description': hours.description,
    };

    final response = await _httpClient.patch(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    print('editUserWorkHours: non 200 returned: ${response.body}');

    return false;
  }

  Future<bool> deleteUserWorkHours(int pk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/user-workhours/$pk/');
    final response = await _httpClient.delete(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

  // projects
  Future<ProjectsPaginated> fetchProjects() async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/project/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return ProjectsPaginated.fromJson(json.decode(response.body));
    }

    print('fetchProjects: non 200 returned: ${response.body}');

    throw Exception('company.projects.exception_fetch'.tr());
  }

  Future<ProjectsPaginated> fetchProjectsForSelect() async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/project/list_for_select/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return ProjectsPaginated.fromJson(json.decode(response.body));
    }

    print('fetchProjects: non 200 returned: ${response.body}');

    throw Exception('company.projects.exception_fetch'.tr());
  }

  Future<Project> fetchProjectDetail(int pk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await getUrl('/company/project/$pk/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Project.fromJson(json.decode(response.body));
    }

    print('fetchProjectDetail: non 200 returned: ${response.body}');

    throw Exception('company.projects.exception_fetch'.tr());
  }

  Future<Project> insertProject(Project project) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/project/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'name': project.name,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return Project.fromJson(json.decode(response.body));
    }

    return null;
  }

  Future<bool> editProject(int pk, Project project) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/project/$pk/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'name': project.name,
    };

    final response = await _httpClient.patch(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> deleteProject(int pk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/company/project/$pk/');
    final response = await _httpClient.delete(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

}

CompanyApi companyApi = CompanyApi();

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/api/api_mixin.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_member_models/public/api.dart';
import 'package:my24_flutter_member_models/public/models.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/company/models/engineer/models.dart';
import 'package:my24app/company/models/picture/api.dart';

final log = Logger('common.utils');

class Utils with CoreApiMixin {
  MemberDetailPublicApi memberApi = MemberDetailPublicApi();
  PicturePublicApi picturePublicApi = PicturePublicApi();
  MemberByCompanycodePublicApi memberByCompanycodeApi = MemberByCompanycodePublicApi();
  CoreUtils coreUtils = CoreUtils();

  // default and settable for tests
  http.Client _httpClient = http.Client();
  set httpClient(http.Client client) {
    _httpClient = client;
    coreUtils.httpClient = client;
  }

  Future<String?> getMemberName() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    return _prefs.getString('member_name');
  }

  Future<Member?> fetchMemberPref() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    final int? memberPk = _prefs.getInt('member_pk');
    if (memberPk != null) {
      try {
        final Member result =
            await memberApi.detail(memberPk, needsAuth: false);
        return result;
      } catch (e) {
        print("Error fetching member public: $e");
      }
    }

    return null;
  }

  Future<DefaultPageData> getDefaultPageData() async {
    String? memberPicture = await coreUtils.getMemberPicture();

    DefaultPageData result = DefaultPageData(
      memberPicture: memberPicture,
    );

    return result;
  }

  Future<bool> logout() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs.remove('token');

    return true;
  }

  Future<dynamic> getUserInfo({withFetch=true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userInfoData = prefs.getString('userInfoData');
    if (userInfoData == null || withFetch) {
      if (!withFetch) {
        return null;
      }

      final url = await getUrl('/company/user-info-me/');
      final token = prefs.getString('token');
      // print("url: $url, client: $_httpClient");
      final res = await _httpClient.get(
          Uri.parse(url),
          headers: getHeaders(token)
      );

      if (res.statusCode == 200) {
        userInfoData = res.body;
        log.info('Got user info');
        await prefs.setString('userInfoData', userInfoData);
      } else {
        log.info("User info call returned ${res.statusCode}, body=${res.body}");
        userInfoData = null;
      }
    }

    if (userInfoData == null) {
      log.warning("Could not determine user");
      return;
    }

    var userInfoDataDecoded = json.decode(userInfoData);

    if (userInfoDataDecoded['submodel'] == 'planning_user') {
      final user = PlanningUser.fromJson(userInfoDataDecoded['user']);
      prefs.setString('first_name', user.firstName!);
      prefs.setInt('user_id', user.id!);
      prefs.setString('submodel', 'planning_user');
      return user;
    }

    if (userInfoDataDecoded['submodel'] == 'employee_user') {
      final EmployeeUser user = EmployeeUser.fromJson(userInfoDataDecoded['user']);
      prefs.setString('first_name', user.firstName!);
      prefs.setInt('user_id', user.id!);
      prefs.setString('submodel', 'branch_employee_user');
      return user;
    }

    if (userInfoDataDecoded['submodel'] == 'engineer') {
      EngineerUser user = EngineerUser.fromJson(userInfoDataDecoded['user']);
      prefs.setString('first_name', user.firstName!);
      prefs.setInt('user_id', user.id!);
      prefs.setString('submodel', 'engineer');

      return user;
    }

    if (userInfoDataDecoded['submodel'] == 'customer_user') {
      CustomerUser user = CustomerUser.fromJson(userInfoDataDecoded['user']);
      prefs.setString('first_name', user.firstName!);
      prefs.setInt('user_id', user.id!);
      prefs.setString('submodel', 'customer_user');
      prefs.setInt('customer_pk', user.customer!.customer!);

      return user;
    }

    if (userInfoDataDecoded['submodel'] == 'sales_user') {
      SalesUser user = SalesUser.fromJson(userInfoDataDecoded['user']);
      prefs.setString('first_name', user.firstName!);
      prefs.setInt('user_id', user.id!);
      prefs.setString('submodel', 'sales_user');

      return user;
    }

    return null;
  }

  Future<Member?> fetchMember({String? companycode}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    companycode ??= prefs.getString('companycode');

    if (companycode == null) {
      return null;
    }

    // fetch member by company code
    try {
      Member member = await memberByCompanycodeApi.detail(companycode, needsAuth: false);
      await prefs.setString('memberData', member.toJson());
      await prefs.setString('companycode', member.companycode!);

      return member;
    } catch (e) {
      log.severe("Error fetching member public: $e");
      return null;
    }
  }

  Future<StreamInfo> getStreamInfo() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    final url = await getUrl('/company/stream-info/');
    final token = _prefs.getString('token');
    final res =
        await _httpClient.get(Uri.parse(url), headers: getHeaders(token));

    if (res.statusCode == 200) {
      var responseData = json.decode(res.body);

      // create models based on user type
      return StreamInfo.fromJson(responseData);
    }

    throw Exception(res.body);
  }

  Future<bool?> getHasBranches() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    final Map<String, String> envVars = Platform.environment;

    if (!_prefs.containsKey('member_has_branches')) {
      if (envVars['TESTING'] != null) {
        _prefs.setBool('member_has_branches', false);
      } else {
        final Member member = (await fetchMemberPref())!;
        _prefs.setBool('member_has_branches', member.hasBranches!);
      }
    }

    return _prefs.getBool('member_has_branches');
  }

  Future<int?> getEmployeeBranch() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    if (!_prefs.containsKey('employee_branch')) {
      var userData = await utils.getUserInfo();
      var userInfo = userData['user'];
      if (userInfo is EmployeeUser) {
        EmployeeUser employeeUser = userInfo;
        if (employeeUser.employee!.branch != null) {
          _prefs.setString('submodel', 'branch_employee_user');
          _prefs.setInt('employee_branch', employeeUser.employee!.branch!);
        } else {
          _prefs.setString('submodel', 'employee_user');
          _prefs.setInt('employee_branch', 0);
        }
      } else {
        _prefs.setInt('employee_branch', 0);
      }
    }

    return _prefs.getInt('employee_branch');
  }

  Future<String?> getOrderListTitleForUser() async {
    String? submodel = await coreUtils.getUserSubmodel();

    if (submodel == 'customer_user') {
      return 'orders.list.app_title_customer_user'.tr();
    }

    if (submodel == 'planning_user') {
      return 'orders.list.app_title_planning_user'.tr();
    }

    if (submodel == 'sales_user') {
      return 'orders.list.app_title_sales_user'.tr();
    }

    if (submodel == 'branch_employee_user') {
      return 'orders.list.app_title_employee_user'.tr();
    }

    return null;
  }

  Future<void> storeMemberInfo(Member member) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // generic prefs
    await prefs.setString('companycode', member.companycode!);
    await prefs.setInt('member_pk', member.pk!);
    await prefs.setString('member_name', member.name!);
    await prefs.setString('member_logo_url', member.companylogoUrl!);
    await prefs.setBool('member_has_branches', member.hasBranches!);

    // preferred member prefs
    await prefs.setBool('skip_member_list', true);
    await prefs.setInt('preferred_member_pk', member.pk!);
    await prefs.setString('preferred_companycode', member.companycode!);
  }

  Future<int?> getPreferredMemberPk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? preferredMemberPk = prefs.getInt('preferred_member_pk');

    if (preferredMemberPk != null) {
      return preferredMemberPk;
    } else {
      // handle rename
      int? preferredMemberPk = prefs.getInt('prefered_member_pk');
      if (preferredMemberPk != null) {
        await prefs.setInt('preferred_member_pk', preferredMemberPk);
        return preferredMemberPk;
      }
    }

    return null;
  }

  String getCurrencySymbol(String currencyCode) {
    return NumberFormat().simpleCurrencySymbol(currencyCode);
  }

  Future<String?> getLanguageCode(String? contextLanguageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode;

    // check the default language
    if (!prefs.containsKey('preferred_language_code')) {
      if (contextLanguageCode != null) {
        log.info("Setting preferred language from device to: $contextLanguageCode");
        await prefs.setString('preferred_language_code', contextLanguageCode);
      } else {
        log.info('not setting contextLanguageCode, it\'s null');
      }
    } else {
      languageCode = prefs.getString('preferred_language_code');
      if (languageCode != null) {
        await prefs.setString('preferred_language_code', languageCode);
      }
    }

    return prefs.getString('preferred_language_code');
  }

  Future<bool> engineerCanSelectUsers() async {
    return await coreUtils.getMemberSettingBool('mobile_hours_select_user');
  }
}

Utils utils = Utils();

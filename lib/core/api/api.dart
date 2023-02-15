import 'package:shared_preferences/shared_preferences.dart';

mixin ApiMixin {
  Future<int> getPageSize() async {
    final prefs = await SharedPreferences.getInstance();
    int pageSize = prefs.getInt('pageSize');
    if (pageSize == null) {
      return 20;
    }

    return pageSize;
  }

  Future<String> getUrl(String path) async {
    final prefs = await SharedPreferences.getInstance();
    String companycode = prefs.getString('companycode');
    String apiBaseUrl = prefs.getString('apiBaseUrl');

    if (companycode == null || companycode == '') {
      companycode = 'demo';
    }

    if (apiBaseUrl == null || apiBaseUrl == '') {
      apiBaseUrl = 'my24service-dev.com';
    }

    return 'https://$companycode.$apiBaseUrl/api$path';
  }

  Future<String> getBaseUrlPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String companycode = prefs.getString('companycode');
    String apiBaseUrl = prefs.getString('apiBaseUrl');

    if (companycode == null || companycode == '') {
      companycode = 'demo';
    }

    if (apiBaseUrl == null || apiBaseUrl == '') {
      apiBaseUrl = 'my24service-dev.com';
    }

    return 'https://$companycode.$apiBaseUrl';
  }
}

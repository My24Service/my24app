import 'package:shared_preferences/shared_preferences.dart';

mixin ApiMixin {
  Future<String> getUrl(String path) async {
    final prefs = await SharedPreferences.getInstance();
    String companycode = prefs.getString('companycode');
    String apiBaseUrl = prefs.getString('apiBaseUrl');

    if (companycode == null || companycode == '' || companycode == 'jansenit') {
      companycode = 'demo';
    }

    if (apiBaseUrl == null || apiBaseUrl == '') {
      apiBaseUrl = 'my24service-dev.com';
    }

    return 'https://$companycode.$apiBaseUrl$path';
  }
}

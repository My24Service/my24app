import 'package:shared_preferences/shared_preferences.dart';

dynamic getUrl(path) async {
  final prefs = await SharedPreferences.getInstance();
  final companycode = prefs.getString('companycode') ?? 'demo';
  final apiBaseUrl = prefs.getString('apiBaseUrl');
  return 'https://$companycode.$apiBaseUrl$path';
}

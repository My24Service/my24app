import 'dart:convert';

import 'fixtures.dart';

String getEngineersSelectInitialsData() {
  Map<String, dynamic> data = json.decode(initialData);
  data['memberInfo']['settings']['mobile_hours_select_user'] = true;
  return json.encode(data);
}

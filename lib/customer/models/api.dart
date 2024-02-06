import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/api/base_crud.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'models.dart';

class CustomerApi extends BaseCrud<Customer, Customers> {
  final String basePath = "/customer/customer";
  String? _typeAheadToken;

  @override
  Customer fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Customer.fromJson(parsedJson!);
  }

  @override
  Customers fromJsonList(Map<String, dynamic>? parsedJson) {
    return Customers.fromJson(parsedJson!);
  }

  Future<Customer> fetchCustomerFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? customerPk = prefs.getInt('customer_pk');

    return await detail(customerPk!);
  }

  Future <List<CustomerTypeAheadModel>> customerTypeAhead(String query) async {
    // don't call for every search
    if (_typeAheadToken == null) {
      SlidingToken newToken = await getNewToken();

      _typeAheadToken = newToken.token;
    }

    final url = await getUrl('$basePath/autocomplete/?q=' + query);
    final response = await httpClient.get(
        Uri.parse(url),
        headers: getHeaders(_typeAheadToken)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      var list = parsedJson as List;
      List<CustomerTypeAheadModel> results = list.map((i) => CustomerTypeAheadModel.fromJson(i)).toList();

      return results;
    }

    return [];
  }

  Future<String> fetchNewCustomerId() async {
    final String responseBody = await getListResponseBody(
        basePathAddition: 'check_customer_id_handling/'
    );

    Map result = json.decode(responseBody);
    return result['customer_id'].toString();
  }
}

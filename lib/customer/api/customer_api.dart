import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerApi with ApiMixin {
  // default and setable for tests
  http.Client _httpClient = new http.Client();
  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Utils localUtils = utils;

  Future<Customer> insertCustomer(Customer customer) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await localUtils.getUrl('/customer/customer/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'customer_id': customer.customerId,
      'name': customer.name,
      'address': customer.address,
      'postal': customer.postal,
      'city': customer.city,
      'country_code': customer.countryCode,
      'tel': customer.tel,
      'mobile': customer.mobile,
      'email': customer.email,
      'contact': customer.contact,
      'remarks': customer.remarks,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      Customer customer = Customer.fromJson(json.decode(response.body));
      return customer;
    }

    return null;
  }

  Future<Customer> editCustomer(Customer customer) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await localUtils.getUrl('/customer/customer/${customer.id}/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'name': customer.name,
      'address': customer.address,
      'postal': customer.postal,
      'city': customer.city,
      'country_code': customer.countryCode,
      'tel': customer.tel,
      'mobile': customer.mobile,
      'email': customer.email,
      'contact': customer.contact,
      'remarks': customer.remarks,
    };

    final response = await _httpClient.put(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      Customer customer = Customer.fromJson(json.decode(response.body));
      return customer;
    }

    return null;
  }

  Future<bool> deleteCustomer(int customerPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await localUtils.getUrl('/customer/customer/$customerPk/');
    final response = await _httpClient.delete(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

  Future<Customers> fetchCustomers({ query=''}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await localUtils.getUrl('/customer/customer/');
    if (query != null && query != '') {
      url += '?q=$query';
    }

    final response = await _httpClient.get(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      Customers results = Customers.fromJson(json.decode(response.body));
      return results;
    }

    throw Exception('customers.list.exception_fetch'.tr());
  }

  Future<Customer> fetchCustomer(int customerPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await localUtils.getUrl('/customer/customer/$customerPk/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    }

    throw Exception('customers.form.exception_fetch'.tr());
  }

  Future<Customer> fetchCustomerFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int customerPk = prefs.getInt('customer_pk');

    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await localUtils.getUrl('/customer/customer/$customerPk/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    }

    throw Exception('customers.form.exception_fetch'.tr());
  }

  Future <List> customerTypeAhead(String query) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/customer/customer/autocomplete/?q=' + query);
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      var list = parsedJson as List;
      List<CustomerTypeAheadModel> results = list.map((i) => CustomerTypeAheadModel.fromJson(i)).toList();

      return results;
    }

    return [];
  }
}

CustomerApi customerApi = CustomerApi();

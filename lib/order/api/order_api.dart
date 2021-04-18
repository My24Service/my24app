import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/models/models.dart';

class OrderApi with ApiMixin {
  // default and setable for tests
  http.Client _httpClient = new http.Client();
  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Utils localUtils = utils;

  Future<Order> insertOrder(Order order) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/order/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    // order lines
    List<Map> orderlines = [];
    for (int i=0; i<order.orderLines.length; i++) {
      Orderline orderline = order.orderLines[i];

      orderlines.add({
        'product': orderline.product,
        'location': orderline.location,
        'remarks': orderline.remarks,
      });
    }

    // info lines
    List<Map> infolines = [];
    for (int i=0; i<order.infoLines.length; i++) {
      Infoline infoline = order.infoLines[i];

      infolines.add({
        'info': infoline.info,
      });
    }

    final Map body = {
      'customer_id': order.customerId,
      'order_name': order.orderName,
      'order_address': order.orderAddress,
      'order_postal': order.orderPostal,
      'order_city': order.orderCity,
      'order_country_code': order.orderCountryCode,
      'customer_relation': order.customerRelation,
      'order_type': order.orderType,
      'order_reference': order.orderReference,
      'order_tel': order.orderTel,
      'order_mobile': order.orderMobile,
      'order_contact': order.orderContact,
      'start_date': order.startDate,
      'start_time': order.startTime,
      'end_date': order.endDate,
      'end_time': order.endTime,
      'customer_remarks': order.customerRemarks,
      'orderlines': orderlines,
      'infolines': infolines,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      Order order = Order.fromJson(json.decode(response.body));
      return order;
    }

    return null;
  }

  Future<Order> editOrder(Order order) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/order/${order.id}/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    // order lines
    List<Map> orderlines = [];
    for (int i=0; i<order.orderLines.length; i++) {
      Orderline orderline = order.orderLines[i];

      orderlines.add({
        'product': orderline.product,
        'location': orderline.location,
        'remarks': orderline.remarks,
      });
    }

    // info lines
    List<Map> infolines = [];
    for (int i=0; i<order.infoLines.length; i++) {
      Infoline infoline = order.infoLines[i];

      infolines.add({
        'info': infoline.info,
      });
    }

    final Map body = {
      'customer_id': order.customerId,
      'order_name': order.orderName,
      'order_address': order.orderAddress,
      'order_postal': order.orderPostal,
      'order_city': order.orderCity,
      'order_country_code': order.orderCountryCode,
      'customer_relation': order.customerRelation,
      'order_type': order.orderType,
      'order_reference': order.orderReference,
      'order_tel': order.orderTel,
      'order_mobile': order.orderMobile,
      'order_contact': order.orderContact,
      'start_date': order.startDate,
      'start_time': order.startTime,
      'end_date': order.endDate,
      'end_time': order.endTime,
      'customer_remarks': order.customerRemarks,
      'orderlines': orderlines,
      'infolines': infolines,
    };

    final response = await _httpClient.put(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      Order order = Order.fromJson(json.decode(response.body));
      return order;
    }

    return null;
  }

  Future<bool> deleteOrder(int orderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/order/$orderPk/');
    final response = await _httpClient.delete(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

  Future<Orders> fetchOrders({ query='', page=1}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await getUrl('/order/order/');
    List<String> args = [];

    if (query != null && query != '') {
      args.add('q=$query');
    }

    if (page != null && page != 1) {
      args.add('page=$page');
    }

    if (args.length > 0) {
      url = '$url?' + args.join('&');
    }

    final response = await _httpClient.get(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      Orders results = Orders.fromJson(json.decode(response.body));
      return results;
    }

    throw Exception('orders.exception_fetch'.tr());
  }

  Future<Order> fetchOrder(int orderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/order/$orderPk/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    }

    throw Exception('orders.exception_fetch'.tr());
  }

  Future<OrderTypes>fetchOrderTypes() async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/order/order_types/');
    final response = await _httpClient.get(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return OrderTypes.fromJson(json.decode(response.body));
    }

    throw Exception('orders.edit_form.exception_fetch_order_types'.tr());
  }

  Future<bool> acceptOrder(int orderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/order/$orderPk/set_order_accepted/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {};

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return null;
  }

  Future<Orders> fetchUnaccepted({ query='', page=1}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await getUrl('/order/order/get_all_for_customer_not_accepted/');
    List<String> args = [];

    if (query != null && query != '') {
      args.add('q=$query');
    }

    if (page != null && page != 1) {
      args.add('page=$page');
    }

    if (args.length > 0) {
      url = '$url?' + args.join('&');
    }

    final response = await _httpClient.get(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Orders.fromJson(json.decode(response.body));
    }

    throw Exception('orders.exception_fetch'.tr());
  }

  Future<Orders> fetchOrdersUnAssigned({ query='', page=1}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await getUrl('/order/order/dispatch_list_unassigned/');
    List<String> args = [];

    if (query != null && query != '') {
      args.add('q=$query');
    }

    if (page != null && page != 1) {
      args.add('page=$page');
    }

    if (args.length > 0) {
      url = '$url?' + args.join('&');
    }

    final response = await _httpClient.get(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Orders.fromJson(json.decode(response.body));
    }

    throw Exception('orders.exception_fetch'.tr());
  }

  Future<Orders> fetchOrdersPast({query='', page=1}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await getUrl('/order/order/past/');
    List<String> args = [];

    if (query != null && query != '') {
      args.add('q=$query');
    }

    if (page != null && page != 1) {
      args.add('page=$page');
    }

    if (args.length > 0) {
      url = '$url?' + args.join('&');
    }

    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Orders.fromJson(json.decode(response.body));
    }

    throw Exception('orders.exception_fetch'.tr());
  }

  Future<CustomerHistory> fetchCustomerHistory(int customerPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/order/all_for_customer/?customer_id=$customerPk');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      CustomerHistory results = CustomerHistory.fromJson(json.decode(response.body));
      return results;
    }

    throw Exception('customers.history.exception_fetch'.tr());
  }
}

OrderApi orderApi = OrderApi();

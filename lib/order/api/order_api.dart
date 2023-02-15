import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/models/models.dart';

class OrderApi with ApiMixin {
  // default and settable for tests
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

      // sales orders have these extra fields
      if (orderline.locationRelationInventory != null) {
        orderlines.add({
          'product': orderline.product,
          'location': orderline.location,
          'remarks': orderline.remarks,
          'price_purchase': orderline.pricePurchase,
          'price_selling': orderline.priceSelling,
          'material_relation': orderline.materialRelation,
          'location_relation_inventory': orderline.locationRelationInventory,
          'amount': orderline.amount,
        });
      } else {
        orderlines.add({
          'product': orderline.product,
          'location': orderline.location,
          'remarks': orderline.remarks,
        });
      }
    }

    // info lines
    List<Map> infolines = [];
    if (order.infoLines != null) {
      for (int i=0; i<order.infoLines.length; i++) {
        Infoline infoline = order.infoLines[i];

        infolines.add({
          'info': infoline.info,
        });
      }
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
      'customer_order_accepted': order.customerOrderAccepted,
      'orderlines': orderlines,
      'infolines': infolines,
      'maintenance_product_lines': []
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
    print(response.body);

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
      'maintenance_product_lines': []
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

    String url = await getUrl('/order/order/?order_by=-start_date');
    List<String> args = [];

    if (query != null && query != '') {
      args.add('q=$query');
    }

    if (page != null && page != 1 && page != 0) {
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

    final String errorMsg = 'orders.exception_fetch'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
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

    final String errorMsg = 'orders.exception_fetch'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
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

    final String errorMsg = 'orders.edit_form.exception_fetch_order_types'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<bool> rejectOrder(int orderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/order/$orderPk/set_order_rejected/');
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

    String url = await getUrl('/order/order/all_for_customer_not_accepted/');
    List<String> args = [];

    if (query != null && query != '') {
      args.add('q=$query');
    }

    if (page != null && page != 1 && page != 0) {
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

    final String errorMsg = 'orders.exception_fetch'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
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

    if (page != null && page != 1 && page != 0) {
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

    final String errorMsg = 'orders.exception_fetch'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
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

    if (page != null && page != 1 && page != 0) {
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

    final String errorMsg = 'orders.exception_fetch'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<Orders> fetchSalesOrders({query='', page=1}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await getUrl('/order/order/sales_orders/');
    List<String> args = [];

    if (query != null && query != '') {
      args.add('q=$query');
    }

    if (page != null && page != 1 && page != 0) {
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

    final String errorMsg = 'orders.exception_fetch'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<CustomerHistory> fetchCustomerHistory(int customerPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final String url = await getUrl('/order/order/all_for_customer/?customer_id=$customerPk');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return CustomerHistory.fromJson(json.decode(response.body));
    }

    throw Exception('customers.history.exception_fetch'.tr());
  }

  Future<Orders> fetchOrderHistory(int customerPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final String url = await getUrl('/order/order/past/?customer_relation=$customerPk');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Orders.fromJson(json.decode(response.body));
    }

    final String errorMsg = 'customers.detail.exception_fetch_orders'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<bool> createWorkorder(int orderPk, int assignedOrderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/order/$orderPk/create_pdf_background/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'assignedorder_pk': assignedOrderPk
    };

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

}

OrderApi orderApi = OrderApi();

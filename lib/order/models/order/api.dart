import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24_flutter_core/api/base_crud.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'models.dart';

class OrderApi extends BaseCrud<Order, Orders> {
  final String basePath = "/order/order";

  @override
  Order fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Order.fromJson(parsedJson!);
  }

  @override
  Orders fromJsonList(Map<String, dynamic>? parsedJson) {
    return Orders.fromJson(parsedJson!);
  }

  Future<OrderTypes> fetchOrderTypes() async {
    SlidingToken? newToken = await refreshSlidingToken(httpClient);

    if (newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final String url = await getUrl('$basePath/order_types/');
    final response = await httpClient.get(
        Uri.parse(url),
        headers: getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return OrderTypes.fromJson(json.decode(response.body));
    }

    final String errorMsg = 'orders.edit_form.exception_fetch_order_types'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<bool> rejectOrder(int orderPk) async {
    final Map body = {};
    String basePathAddition = '$orderPk/set_order_rejected/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<bool> acceptOrder(int orderPk) async {
    final Map body = {};
    String basePathAddition = '$orderPk/set_order_accepted/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<Orders> fetchUnaccepted({ query = '', page = 1}) async {
    return super.list(
        filters: { 'q': query, 'page': page },
        basePathAddition: 'all_for_customer_not_accepted/');
  }

  Future<Orders> fetchOrdersUnAssigned({ query = '', page = 1}) async {
    return super.list(
        filters: { 'q': query, 'page': page },
        basePathAddition: 'dispatch_list_unassigned/');
  }

  Future<Orders> fetchOrdersPast({query = '', page = 1}) async {
    return super.list(
        filters: { 'q': query, 'page': page },
        basePathAddition: 'past/');
  }

  Future<Orders> fetchSalesOrders({query='', page=1}) async {
    return super.list(
        filters: { 'q': query, 'page': page },
        basePathAddition: 'sales_orders/');
  }

  Future<Orders> fetchOrderHistory(int customerPk, {query='', page=1}) async {
    return super.list(
        filters: { 'q': query, 'page': page, 'customer_relation': "$customerPk" },
        basePathAddition: 'past/');
  }

  Future<bool> createWorkorderPdf(int orderPk, int assignedOrderPk) async {
    final Map body = {
      'assignedorder_pk': assignedOrderPk
    };
    String basePathAddition = '$orderPk/create_pdf_background/';
    return await super.insertCustom(body, basePathAddition);
  }
}

class CustomerHistoryOrderApi extends BaseCrud<CustomerHistoryOrder, CustomerHistoryOrders> {
  final String basePath = "/order/order/all_for_customer_v2";

  @override
  CustomerHistoryOrder fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return CustomerHistoryOrder.fromJson(parsedJson!);
  }

  @override
  CustomerHistoryOrders fromJsonList(Map<String, dynamic>? parsedJson) {
    return CustomerHistoryOrders.fromJson(parsedJson!);
  }
}

import 'package:flutter/material.dart';

import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/widgets/order/list.dart';
import 'package:my24app/order/blocs/order_bloc.dart';


class SalesListWidget extends OrderListWidget {
  final String basePath = "orders.sales";
  final OrderPageMetaData orderPageMetaData;
  final List<Order> orderList;
  final PaginationInfo paginationInfo;
  final OrderEventStatus fetchEvent;
  final String searchQuery;

  SalesListWidget({
    Key key,
    @required this.orderList,
    @required this.orderPageMetaData,
    @required this.fetchEvent,
    @required this.searchQuery,
    @required this.paginationInfo,
  }): super(
    key: key,
    orderList: orderList,
    orderPageMetaData: orderPageMetaData,
    paginationInfo: paginationInfo,
    fetchEvent: fetchEvent,
    searchQuery: searchQuery,
  );
}

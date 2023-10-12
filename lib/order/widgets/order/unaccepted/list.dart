import 'package:flutter/material.dart';

import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import '../list.dart';


class UnacceptedListWidget extends OrderListWidget {
  final String basePath = "orders.unaccepted";
  final List<Order>? orderList;
  final PaginationInfo paginationInfo;
  final OrderPageMetaData orderPageMetaData;
  final OrderEventStatus fetchEvent;
  final String? searchQuery;

  UnacceptedListWidget({
    Key? key,
    required this.orderList,
    required this.orderPageMetaData,
    required this.fetchEvent,
    required this.searchQuery,
    required this.paginationInfo,
  }): super(
    key: key,
    orderList: orderList,
    orderPageMetaData: orderPageMetaData,
    paginationInfo: paginationInfo,
    fetchEvent: fetchEvent,
    searchQuery: searchQuery,
  );

  SliverAppBar getAppBar(BuildContext context) {
    UnacceptedOrdersAppBarFactory factory = UnacceptedOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList,
        count: paginationInfo.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getEditButton(context, order.id),
        SizedBox(width: 10),
        getDocumentsButton(context, order.id),
        SizedBox(width: 10),
        getDeleteButton(context, order.id),
      ],
    );
  }
}

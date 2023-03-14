import 'package:flutter/material.dart';

import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/widgets/list.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';


// ignore: must_be_immutable
class PastListWidget extends OrderListWidget {
  final List<Order> orderList;
  final PaginationInfo paginationInfo;
  final OrderPageMetaData orderListData;
  final dynamic fetchEvent;
  final String searchQuery;
  final String error;

  PastListWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData,
    @required this.fetchEvent,
    @required this.searchQuery,
    @required this.paginationInfo,
    @required this.error,
  }): super(
      key: key,
      orderList: orderList,
      orderListData: orderListData,
      paginationInfo: paginationInfo,
      fetchEvent: fetchEvent,
      searchQuery: searchQuery,
      error: error
  );

  SliverAppBar getAppBar(BuildContext context) {
    PastOrdersAppBarFactory factory = PastOrdersAppBarFactory(
        context: context,
        orderListData: orderListData,
        orders: orderList,
        count: paginationInfo.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    return Row();
  }
}

class PastListEmptyErrorWidget extends OrderListEmptyErrorWidget {
  final OrderPageMetaData orderListData;
  final List<Order> orderList;
  final String error;
  final dynamic fetchEvent;

  PastListEmptyErrorWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData,
    @required this.error,
    @required this.fetchEvent
  }): super(
      key: key,
      error: error,
      orderList: orderList,
      fetchEvent: fetchEvent,
      orderListData: orderListData
  );
}

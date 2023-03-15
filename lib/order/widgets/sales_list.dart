import 'package:flutter/material.dart';

import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/widgets/list.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';


// ignore: must_be_immutable
class SalesListWidget extends OrderListWidget {
  final List<Order> orderList;
  final OrderPageMetaData orderListData;
  final PaginationInfo paginationInfo;
  final dynamic fetchEvent;
  final String searchQuery;
  final String error;

  SalesListWidget({
    Key key,
    @required this.orderList,
    @required this.fetchEvent,
    @required this.searchQuery,
    @required this.orderListData,
    @required this.paginationInfo,
    @required this.error,
  }): super(key: key,
      orderListData: orderListData,
      orderList: orderList,
      paginationInfo: paginationInfo,
      fetchEvent: fetchEvent,
      searchQuery: searchQuery,
      error: error
  );

  SliverAppBar getAppBar(BuildContext context) {
    SalesListOrdersAppBarFactory factory = SalesListOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderListData,
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

class SalesListEmptyErrorWidget extends OrderListEmptyErrorWidget {
  final OrderPageMetaData orderListData;
  final List<Order> orderList;
  final String error;
  final dynamic fetchEvent;

  SalesListEmptyErrorWidget({
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

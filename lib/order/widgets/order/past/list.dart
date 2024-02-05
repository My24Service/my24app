import 'package:flutter/material.dart';

import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/widgets/order/list.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';

class PastListWidget extends OrderListWidget {
  final OrderPageMetaData orderPageMetaData;
  final List<Order>? orderList;
  final PaginationInfo paginationInfo;
  final OrderEventStatus fetchEvent;
  final String? searchQuery;
  final CoreWidgets widgetsIn;

  PastListWidget({
    Key? key,
    required this.orderList,
    required this.orderPageMetaData,
    required this.fetchEvent,
    required this.searchQuery,
    required this.paginationInfo,
    required this.widgetsIn,
  }): super(
    key: key,
    orderList: orderList,
    orderPageMetaData: orderPageMetaData,
    paginationInfo: paginationInfo,
    fetchEvent: fetchEvent,
    searchQuery: searchQuery,
    widgetsIn: widgetsIn
  );

  SliverAppBar getAppBar(BuildContext context) {
    PastOrdersAppBarFactory factory = PastOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList,
        count: paginationInfo.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }
}

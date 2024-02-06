import 'package:flutter/material.dart';

import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/common/widgets/widgets.dart';
import '../list.dart';

class UnacceptedListWidget extends OrderListWidget {
  final List<Order>? orderList;
  final PaginationInfo paginationInfo;
  final OrderPageMetaData orderPageMetaData;
  final OrderEventStatus fetchEvent;
  final String? searchQuery;
  final CoreWidgets widgetsIn;

  UnacceptedListWidget({
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

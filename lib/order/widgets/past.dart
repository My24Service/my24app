import 'package:flutter/material.dart';
import 'package:my24app/order/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/widgets/list.dart';

import '../../core/models/models.dart';
import 'package:my24app/core/widgets/sliver_classes.dart';

// ignore: must_be_immutable
class PastListWidget extends OrderListWidget {
  final List<Order> orderList;
  final PaginationInfo paginationInfo;
  final OrderListData orderListData;
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
        count: paginationInfo.count
    );
    return factory.createAppBar();
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    return Row();
  }

  @override
  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: fetchEvent));
  }
}

import 'package:flutter/material.dart';
import 'package:my24app/order/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/widgets/list.dart';

import '../../core/models/models.dart';
import '../../core/widgets/widgets.dart';

// ignore: must_be_immutable
class SalesListWidget extends OrderListWidget {
  final List<Order> orderList;
  final OrderListData orderListData;
  final dynamic fetchEvent;
  final String searchQuery;

  SalesListWidget({
    Key key,
    @required this.orderList,
    @required this.fetchEvent,
    @required this.searchQuery,
    @required this.orderListData,
  }): super(key: key,
      orderListData: orderListData,
      orderList: orderList,
      fetchEvent: fetchEvent,
      searchQuery: searchQuery
  );

  SliverAppBar getAppBar(BuildContext context) {
    SalesListOrdersAppBarFactory factory = SalesListOrdersAppBarFactory(
        context: context,
        orderListData: orderListData,
        orders: orderList
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

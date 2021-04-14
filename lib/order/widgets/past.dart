import 'package:flutter/material.dart';
import 'package:my24app/order/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/widgets/list.dart';

// ignore: must_be_immutable
class PastListWidget extends OrderListWidget {
  final List<Order> orderList;
  final ScrollController controller;

  PastListWidget({
    Key key,
    @required this.orderList,
    @required this.controller,
  }): super(key: key, orderList: orderList, controller: controller);

  @override
  Row getButtonRow(BuildContext context, Order order) {
    return Row();
  }

  @override
  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_PAST));
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/order/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/widgets/list.dart';

// ignore: must_be_immutable
class UnacceptedListWidget extends OrderListWidget {
  final List<Order> orderList;
  final ScrollController controller;

  UnacceptedListWidget({
    Key key,
    @required this.orderList,
    @required this.controller,
  }): super(key: key, orderList: orderList, controller: controller);

  doAcceptOrder(BuildContext context, int orderPk) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.ACCEPT, value: orderPk));
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if (isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'orders.unaccepted.button_accept'.tr(),
              () => doAcceptOrder(context, order.id)
          ),
        ],
      );
    } else {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'orders.unaccepted.button_edit'.tr(),
              () => navEditOrder(context, order.id)
          ),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'orders.unaccepted.button_documents'.tr(),
              () => navDocuments(context, order.id)),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'orders.unaccepted.button_delete'.tr(),
              () => showDeleteDialog(context,order),
              primaryColor: Colors.red),
        ],
      );
    }

    return row;
  }

  @override
  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_UNACCEPTED));
  }
}

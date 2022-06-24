import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/mobile/pages/assign.dart';
import 'package:my24app/order/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/widgets/list.dart';

import '../../mobile/blocs/assign_bloc.dart';

// ignore: must_be_immutable
class UnAssignedListWidget extends OrderListWidget {
  final List<Order> orderList;
  final ScrollController controller;
  final dynamic fetchEvent;
  final String searchQuery;
  final bool isPlanning;

  UnAssignedListWidget({
    Key key,
    @required this.orderList,
    @required this.controller,
    @required this.fetchEvent,
    @required this.searchQuery,
    @required this.isPlanning,
  }): super(
      key: key,
      orderList: orderList,
      controller: controller,
      fetchEvent: fetchEvent,
      searchQuery: searchQuery
  );

  _navAssignOrder(BuildContext context, int orderPk) async {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => OrderAssignPage(orderPk: orderPk))
    );
  }

  _doAssignOrderEngineer(BuildContext context, String orderId) async {
    final bloc = BlocProvider.of<AssignBloc>(context);
    bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
    bloc.add(AssignEvent(
        status: AssignEventStatus.ASSIGN_ME,
        orderId: orderId,
        engineerPks: []
    ));
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    if (isPlanning) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createBlueElevatedButton(
                'orders.unassigned.button_assign'.tr(),
                () => _navAssignOrder(context, order.id)
            ),
          ],
        );
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'orders.unassigned.button_assign_engineer'.tr(),
              () => _doAssignOrderEngineer(context, order.orderId)
          ),
        ],
      );

  }

  @override
  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: fetchEvent));
  }
}

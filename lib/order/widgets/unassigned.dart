import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/mobile/pages/assign.dart';
import 'package:my24app/order/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/widgets/list.dart';

// ignore: must_be_immutable
class UnAssignedListWidget extends OrderListWidget {
  final Orders orders;

  UnAssignedListWidget({
    Key key,
    @required this.orders,
  }): super(key: key, orders: orders);

  _navAssignOrder(BuildContext context, int orderPk) async {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => OrderAssignPage(orderPk: orderPk))
    );
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
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

  @override
  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_UNASSIGNED));
  }

}

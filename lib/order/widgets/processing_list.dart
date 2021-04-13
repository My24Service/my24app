import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/order/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/widgets/order_list.dart';

// ignore: must_be_immutable
class ProcessingListWidget extends OrderListWidget {
  final Orders orders;

  ProcessingListWidget({
    Key key,
    @required this.orders,
  }): super(key: key, orders: orders);

  doAcceptOrder(BuildContext context, int orderPk) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_FETCH));
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
              'orders.not_yet_accepted.button_accept'.tr(),
              () => doAcceptOrder(context, order.id)
          ),
        ],
      );
    } else {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'orders.not_yet_accepted.button_edit'.tr(),
                  () => navEditOrder(context, order.id)
          ),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'orders.not_yet_accepted.button_documents'.tr(),
                  () => _navDocuments(context, order.id)),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'orders.not_yet_accepted.button_delete'.tr(),
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

    bloc.add(OrderEvent(status: OrderEventStatus.DO_FETCH));
    bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_PROCESSING));
  }

  _navDocuments(BuildContext context, int orderPk) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => OrderDocumentsPage(orderPk: orderPk)
        )
    );
  }

}

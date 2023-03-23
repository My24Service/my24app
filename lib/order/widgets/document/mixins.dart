import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/pages/list.dart';


mixin OrderDocumentMixin {
  final int orderId = 0;

  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createButton(
          () { handleNew(context); },
          title: 'assigned_orders.documents.button_add'.tr(),
        ),
        SizedBox(width: 10),
        createElevatedButtonColored(
            'assigned_orders.documents.button_nav_order'.tr(),
            _navOrderList
        )
      ],
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.FETCH_ALL,
        orderId: orderId
    ));
  }

  handleNew(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.NEW,
        orderId: orderId
    ));
  }

  _navOrderList(BuildContext context) {
    final page = OrderListPage();

    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

}

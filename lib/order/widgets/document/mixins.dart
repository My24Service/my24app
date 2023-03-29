import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/core/i18n_mixin.dart';

mixin OrderDocumentMixin {
  final int orderId = 0;

  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createElevatedButtonColored(
            getTranslationTr('assigned_orders.documents.button_nav_order', null),
            () => _navOrderList(context)
        ),
        SizedBox(width: 10),
        createButton(
          () { handleNew(context); },
          title: getTranslationTr('assigned_orders.documents.button_add', null),
        ),
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
    final page = OrderListPage(bloc: OrderBloc());

    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

}

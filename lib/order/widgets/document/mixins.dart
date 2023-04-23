import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/core/i18n_mixin.dart';

mixin OrderDocumentMixin {
  final int orderId = 0;

  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        createButton(
          () { handleNew(context); },
          title: getTranslationTr('orders.documents.button_add', null),
        ),
        Spacer(),
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
}

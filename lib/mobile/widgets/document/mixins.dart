import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/document_bloc.dart';


mixin DocumentMixin {
  final int assignedOrderId = 0;

  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createButton(
          () { handleNew(context); },
          title: 'assigned_orders.activity.button_add'.tr(),
        )
      ],
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));
  }

  handleNew(BuildContext context) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(
        status: DocumentEventStatus.NEW,
        assignedOrderId: assignedOrderId
    ));
  }
}

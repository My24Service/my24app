import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/widgets/order/unaccepted/list.dart';
import 'package:my24app/order/widgets/order/unaccepted/empty.dart';
import 'package:my24app/order/widgets/order/unaccepted/error.dart';
import 'package:my24app/order/models/order/models.dart';
import 'base_order.dart';

class UnacceptedPage extends BaseOrderListPage {
  final OrderEventStatus fetchMode = OrderEventStatus.FETCH_UNACCEPTED;
  final String basePath = "orders.unaccepted";
  final OrderBloc bloc;
  final CoreWidgets widgets = CoreWidgets();

  UnacceptedPage({
    Key? key,
    required this.bloc,
  }) : super(
    bloc: bloc,
  );

  BaseErrorWidget getErrorWidget(String? error, OrderPageMetaData? orderPageMetaData) {
    return UnacceptedListErrorWidget(
      error: error,
      orderPageMetaData: orderPageMetaData!,
      widgetsIn: widgets,
    );
  }

  BaseEmptyWidget getEmptyWidget(OrderPageMetaData? orderPageMetaData) {
    return UnacceptedListEmptyWidget(
      memberPicture: orderPageMetaData!.memberPicture,
      fetchEvent: fetchMode,
      widgetsIn: widgets,
    );
  }

  BaseSliverListStatelessWidget getListWidget(orderList, orderPageMetaData, paginationInfo, fetchEvent, searchQuery) {
    return UnacceptedListWidget(
        orderList: orderList,
        orderPageMetaData: orderPageMetaData,
        paginationInfo: paginationInfo,
        fetchEvent: fetchMode,
        searchQuery: searchQuery,
        widgetsIn: widgets,
    );
  }
}
